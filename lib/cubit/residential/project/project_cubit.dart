import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lf_survey/app_popups/cutsom_alert_dialogues.dart';
import 'package:lf_survey/constants/storage_function.dart';
import 'package:lf_survey/constants/storage_key.dart';
import 'package:lf_survey/cubit/residential/project/project_state.dart';
import 'package:lf_survey/database/db_helper.dart';
import 'package:lf_survey/model/db_model/residential/flat_entity.dart';
import 'package:lf_survey/model/db_model/residential/new_flat_entity.dart';
import 'package:lf_survey/model/db_model/residential/new_project_entity.dart';
import 'package:lf_survey/model/db_model/residential/new_sub_project_entity.dart';
import 'package:lf_survey/model/db_model/residential/project_entity.dart';
import 'package:lf_survey/model/db_model/residential/reject_reason_model.dart';
import 'package:lf_survey/model/db_model/residential/sub_prj_entity.dart';
import 'package:lf_survey/model/residential/archi_response.dart';
import 'package:lf_survey/model/residential/project_response.dart';
import 'package:lf_survey/model/residential/project_scheme_entity.dart';
import 'package:lf_survey/model/residential/project_spinner.dart';
import 'package:lf_survey/model/residential/user_response.dart';
import 'package:lf_survey/services/api_client.dart';

class ProjectCubit extends Cubit<ProjectState> {
  ProjectCubit() : super(InitState());

  void getProject() async {
    try {
      emit(LoadingState());
      final response = await Future.wait([
        DBHelper.getProjects(),
        DBHelper.getAllSprjEntity(),
        DBHelper.fetchAllNewProjects(),
        DBHelper.getAllNewSubProjects(),
        DBHelper.getUnsoldFlatsForAllProjects(),
      ]);
      final respPrj = response[0] as List<Map<String, dynamic>>;
      final respSubPrj = response[1] as List<Map<String, dynamic>>;
      final respNewPrj = response[2] as List<NewProjectEntity>;
      final respNewSubPrj = response[3] as List<NewSubProjectEntity>;
      final totalUnsoldFlats = response[4] as Map<int, int>;

      if (respPrj.isNotEmpty) {
        List<ProjectEntity> projects = respPrj.map((i) => ProjectEntity.fromJson(i)).toList();
        List<SubProjectEntity> subProjects = [];
        if (respSubPrj.isNotEmpty) {
          subProjects.clear();
          subProjects = respSubPrj.map((e) => SubProjectEntity.fromJson(e)).toList();
        }
        emit(
          LoadedState(
            projectData: projects,
            subProjects: subProjects,
            newProjects: respNewPrj,
            newSubProjects: respNewSubPrj,
            totalUnsoldflats: totalUnsoldFlats,
          ),
        );
      } else {
        emit(InitState());
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void deleteProject({required int projectId, required int index}) async {
    try {
      final result = await DBHelper.deleteProjectEntityById(projectId: projectId);
      if (result > 0) {
        emit(DeleteProject(index: index));
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void searchProject({
    required String query,
    required List<ProjectEntity> projects,
    required List<ProjectEntity> filteredProjects,
    required bool applyFilter,
  }) {
    final trimmedQuery = query.trim().toLowerCase();

    List<ProjectEntity> filteredList = applyFilter ? filteredProjects : projects;
    // List<ProjectEntity> filteredList = projects;

    if (trimmedQuery.isNotEmpty && trimmedQuery.length >= 3) {
      filteredList = projects.where((e) {
        return e.projectId.toString().contains(trimmedQuery) ||
            e.projectName!.toLowerCase().contains(trimmedQuery) ||
            e.builderName!.toLowerCase().contains(trimmedQuery) ||
            e.roadName!.toLowerCase().contains(trimmedQuery);
      }).toList();
    }

    emit(SearchState(projectData: filteredList, applyFilter: applyFilter));
  }

  void clearFilter({required List<ProjectEntity> projects, Map<String, dynamic> filterQuery = const {}}) {
    List<ProjectEntity> filteredProjects = List.from(projects);
    emit(FilterState(projectData: filteredProjects, applyFilter: false));
  }

  void applyFilter({required List<ProjectEntity> projects}) async {
    try {
      List<ProjectEntity> filteredProjects = List.from(projects);
      Map<String, dynamic>? filterData = await DBHelper.getFilterQuery();
      if (filterData == null || filterData['prjType'] != "res") {
        emit(FilterState(projectData: filteredProjects, applyFilter: false));
        return;
      }
      Map<String, dynamic> filterQuery = jsonDecode(filterData['query']);
      if (filterQuery.isEmpty) {
        emit(FilterState(projectData: filteredProjects, applyFilter: false));
        return;
      }

      bool hasActiveFilter = false;

      /* ---------------- Project Type ---------------- */
      final Map<String, dynamic>? projectType = filterQuery["projectType"] as Map<String, dynamic>?;

      if (projectType != null && projectType.isNotEmpty) {
        final int? prjTypeId = projectType["id"] as int?;

        if (prjTypeId != null) {
          hasActiveFilter = true;

          switch (prjTypeId) {
            case 1:
              filteredProjects = filteredProjects.where((p) => p.syncGlobalStatus == 1).toList();
              break;

            case 2:
              filteredProjects = filteredProjects.where((p) => p.syncGlobalStatus == 0).toList();
              break;

            case 3:
              filteredProjects = filteredProjects.where((p) => (p.rejectId ?? 0) > 0).toList();
              break;
          }
        }
      }

      /* ---------------- Total Supply ---------------- */
      final Map<String, dynamic>? selectedTotalSupply = filterQuery["selectedTotalSupply"] as Map<String, dynamic>?;

      final String? totalSupply = filterQuery["totalSupply"] as String?;

      if (selectedTotalSupply != null &&
          selectedTotalSupply.isNotEmpty &&
          totalSupply != null &&
          totalSupply.isNotEmpty) {
        final int? supply = int.tryParse(totalSupply);

        if (supply != null) {
          hasActiveFilter = true;

          filteredProjects = filteredProjects.where((p) {
            switch (selectedTotalSupply["id"]) {
              case 1:
                return p.totalSupplyUnits == supply;
              case 2:
                return p.totalSupplyUnits != null && p.totalSupplyUnits! > supply;
              case 3:
                return p.totalSupplyUnits != null && p.totalSupplyUnits! < supply;
              default:
                return true;
            }
          }).toList();
        }
      }

      /* ---------------- Project Unsold ---------------- */
      final Map<String, dynamic>? selectedPrjUnsold = filterQuery["selectedPrjUnsold"] as Map<String, dynamic>?;

      final String? projectUnsold = filterQuery["projectUnsold"] as String?;

      if (selectedPrjUnsold != null &&
          selectedPrjUnsold.isNotEmpty &&
          projectUnsold != null &&
          projectUnsold.isNotEmpty) {
        final int? unsold = int.tryParse(projectUnsold);

        if (unsold != null) {
          hasActiveFilter = true;

          filteredProjects = filteredProjects.where((p) {
            switch (selectedPrjUnsold["id"]) {
              case 1:
                return p.projectUnsold == unsold;
              case 2:
                return p.projectUnsold != null && p.projectUnsold! >= unsold;
              case 3:
                return p.projectUnsold != null && p.projectUnsold! <= unsold;
              default:
                return true;
            }
          }).toList();
        }
      }

      /* ---------------- Location ---------------- */
      // final List<int> locations = (filterQuery["location"] as List?)?.map((e) => e as int).toList() ?? [];

      // if (locations.isNotEmpty) {
      //   hasActiveFilter = true;
      //   filteredProjects = filteredProjects.where((p) => locations.contains(p.locationId)).toList();
      // }

      final List<int> existingPrjlocations = (filterQuery["location"] as List?)?.map((e) => e as int).toList() ?? [];
      final List<int> newAssignPrjlocations =
          (filterQuery["newAssignPrjLocation"] as List?)?.map((e) => e as int).toList() ?? [];
      final List<int> locations = [...existingPrjlocations, ...newAssignPrjlocations];
      final uniqueLocations = locations.toSet().toList();

      if (uniqueLocations.isNotEmpty) {
        hasActiveFilter = true;
        filteredProjects = filteredProjects.where((p) => uniqueLocations.contains(p.locationId)).toList();
      }
      final List<int> newAssignPrjCities =
          (filterQuery["newAssignPrjCity"] as List?)?.map((e) => e as int).toList() ?? [];
      final uniqueCities = newAssignPrjCities.toSet().toList();
      if (uniqueCities.isNotEmpty) {
        hasActiveFilter = true;
        filteredProjects = filteredProjects.where((e) => uniqueCities.contains(e.cityId)).toList();
      }
      emit(FilterState(projectData: filteredProjects, applyFilter: hasActiveFilter));
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void downloadAssignNewProject({required String locationIds}) async {
    try {
      emit(LoadingState());
      final response = await ApiClient.fetchProject(locationIds: locationIds, isAssignedNewPrj: true);
      if (response != null) {
        ProjectResponse projectResponse = ProjectResponse.fromJson(response);
        List<ProjectEntity> projectEntity = [];
        if (projectResponse.projectsData!.isNotEmpty) {
          for (var data in projectResponse.projectsData!) {
            ProjectCosting? ppp = data.projectCosting;
            final costingMap = ppp?.toPrjCostingJson();
            projectEntity.add(
              ProjectEntity(
                projectId: data.projectId,
                dos: data.dos?.toIso8601String() ?? "",
                projectName: data.projectName,
                projectAddress: data.projectAddress,
                pxval: data.pxval,
                pyval: data.pyval,
                projectPhoneNo: data.projectPhoneNo,
                projectMobileNo: data.projectMobileNo,
                builderId: data.builderId,
                builderName: data.builderName,
                builderAddress: data.builderAddress,
                builderPhoneNo: data.builderPhoneNo,
                builderMobileNo: data.builderMobileNo,
                roadName: data.roadName,
                locationId: data.locationId,
                locationName: data.locationName,
                suburbId: data.suburbId,
                cityId: data.cityId,
                cityName: data.cityName,
                reDevelopment: data.reDevelopment == true ? 1 : 0,
                reraNo: data.reraNo,
                drinkingWater: data.drinkingWater,
                totalWings: data.totalWings,
                marketableWings: data.marketableWings,
                totalSupplyUnits: data.totalSupplyUnits,
                landParcelSize: data.landParcelSize,
                landParcelSizeUnit: data.landParcelSizeUnit,
                syncGlobalStatus: data.prjSync,
                syncLocalStatus: data.prjSync,
                // syncLocalStatus: 0,
                projectUnsold: data.projectUnsold,
                qtrId: data.qtrId,
                projectCosting: costingMap == null ? null : jsonEncode(costingMap),
                modularKitchenBrand: data.modularKitchenBrand,
                architectName: data.mobArchitectName,
                architectId: data.architectId,
                isWrongPXValPYVal: 0,
                rejectId: data.rejectId,
                fixedBy: data.fixedBy,
                rejectedSurveyorId: data.rejectedSurveyorId,
                cinNo: data.cinNo,
                schemeOthers: data.schemeOthers,
                telFlag: data.telFlag == true ? 1 : 0,

                syncCheckDate: DateTime.now().toIso8601String(),
                reraInfo: data.reraInfo,
                newProjectUpdate: data.newProjectUpdate == true ? 1 : 0,
                assignedNewPrj: 1,
              ),
            );
            if (data.subProjectsList!.isNotEmpty) {
              for (var sprj in data.subProjectsList!) {
                SubProjectEntity subProjectEntity = SubProjectEntity(
                  subProjectId: sprj.subProjectId,
                  dos: sprj.dos!.toIso8601String(),
                  subProjectName: sprj.subProject,
                  saleableRatepsf: sprj.saleableRatepsf,
                  carpetRatepsf: sprj.carpetRatepsf,
                  startDate: sprj.startDate?.toIso8601String(),
                  endDate: sprj.endDate?.toIso8601String(),
                  wings: sprj.wings,
                  storey: sprj.storey,
                  flatsPerFloor: sprj.flatsPerFloor,
                  projectStatusId: sprj.projectStatusId,
                  constructionProgressId: sprj.constructionProgressId,
                  floorSlab: sprj.floorSlab,
                  remarks: sprj.remarks,
                  scr: sprj.scr,
                  maintenancePersqft: sprj.maintenancePersqft,
                  stiltPark: sprj.stiltPark,
                  openPark: sprj.openPark,
                  podium: sprj.podium,
                  doublePodium: sprj.doublePodium,
                  basementPark: sprj.basementPark,
                  bookingStop: sprj.bookingStop,
                  floorRise: sprj.floorRise,
                  deleteFlag: sprj.deleteFlag == true ? 1 : 0,
                  hasVillas: sprj.hasVillas == true ? 1 : 0,
                  percVilaStarted: sprj.percVilaStarted,
                  percVilaPiling: sprj.percVilaPiling,
                  percVilaPlinth: sprj.percVilaPlinth,
                  percVilaFloorslab: sprj.percVilaFloorslab,
                  percVilaInternalWork: sprj.percVilaInternalWork,
                  percVilaExternal: sprj.percVilaExternal,
                  percVilaComplete: sprj.percVilaComplete,
                  syncGlobalStatus: sprj.syncStatus,
                  syncLocalStatus: 0,
                  flatSoldCount: 0,
                  projectId: data.projectId,
                  surveyDate: sprj.surveyDate?.toIso8601String(),
                  qtrId: sprj.qtrId.toString(),
                  rateType: sprj.rateType,
                  isCarpetOrSaleableChoosen: 0,
                  errMsg: "",
                  flatgroupid: sprj.flatgroupid,
                  assignedNewPrj: 1,
                );
                await DBHelper.insertSprjEntity(subProjectEntity);
                if (sprj.flatsList != null && sprj.flatsList!.isNotEmpty) {
                  for (var flatData in sprj.flatsList!) {
                    final String id = '${data.projectId}_${sprj.subProjectId}_${flatData.flatId}';
                    final FlatEntity flatEntity = FlatEntity(
                      id: id,
                      flatId: flatData.flatId,
                      flatType: flatData.flat,
                      flatSold: flatData.flatSold,
                      oldFlatSold: flatData.flatSold,
                      flatUnsold: flatData.flatUnsold,
                      flatSize: flatData.flatSize,
                      flatSizeCarpet: flatData.flatSizeCarpet,
                      flatSizeAvg: flatData.flatSizeAvg,
                      flatSizeCarpetAvg: flatData.flatSizeCarpetAvg,
                      subProjectId: sprj.subProjectId,
                      projectId: data.projectId,
                      isSaleableEnable: 1,
                      sizeType: flatData.sizeType,
                      dataFilled: 0,
                    );
                    await DBHelper.insertFlat(flatEntity);
                  }
                }
              }
            }
          }
          await DBHelper.insertProjects(projectEntity);
          emit(SuccessState(message: "${projectEntity.length} projects downloaded successfully"));
          getProject();
        } else if (projectResponse.projectsData!.isEmpty) {
          emit(ErrorState(message: "No New Project assigned to you to Download."));
        }
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  // void downloadProjectSpinner({bool isDownload = false}) async {
  //   try {
  //     final isSpinner = await StorageFunction.readBoolData(StorageKey.isSpinnerData);
  //     if (isDownload == false && isSpinner == true) return;
  //     emit(LoadingState());
  //     final response = await ApiClient.fetchProjectSpinner();
  //     if (response != null) {
  //       SpinnerResponse spinnerResponse = SpinnerResponse.fromJson(response);
  //       await DBHelper.insertSpinnerData(spinnerResponse);
  //       await StorageFunction.writeBoolData(StorageKey.isSpinnerData, true);
  //       emit(SuccessState(message: "Drop-down data downloaded successfully"));
  //     } else {
  //       emit(ErrorState(message: "No Drop-down Data Downloaded."));
  //     }
  //   } catch (e) {
  //     emit(ErrorState(message: e.toString()));
  //   }
  // }

  void downloadProjectSpinner({bool isDownload = false}) async {
    try {
      final isSpinner = await StorageFunction.readBoolData(StorageKey.isSpinnerData);

      if (!isDownload && isSpinner == true) return;

      emit(LoadingState());

      // Download spinner data
      final spinnerResponse = await ApiClient.fetchProjectSpinner();

      if (spinnerResponse != null) {
        final spinnerData = SpinnerResponse.fromJson(spinnerResponse);
        await DBHelper.insertSpinnerData(spinnerData);

        // Download architect data
        final architectResponse = await ApiClient.fetchArchitect();

        if (architectResponse != null) {
          final architectData = ArchitectResponse.fromJson(architectResponse);

          if (architectData.architectList != null && architectData.architectList!.isNotEmpty) {
            await DBHelper.insertArchi(architectData.architectList!);
          }
        }

        await StorageFunction.writeBoolData(StorageKey.isSpinnerData, true);

        emit(SuccessState(message: "Drop-down data downloaded successfully"));
      } else {
        emit(ErrorState(message: "No Drop-down Data Downloaded."));
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void clearDb() async {
    try {
      await DBHelper.clearAllData();
      await StorageFunction.removeData(StorageKey.isSpinnerData);
      emit(ClearDbState());
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void downloadNewProjects() async {
    try {
      emit(LoadingState());
      final userData = await StorageFunction.readStringData(StorageKey.userData);
      if (userData != null) {
        UserData user = UserData.fromJson(jsonDecode(userData));
        final decodedList = jsonDecode(user.jsonstr ?? "");
        final List<Map<String, dynamic>> prjEntryData = decodedList.cast<Map<String, dynamic>>();
        if (prjEntryData.isNotEmpty) {
          String qtrId = prjEntryData.first["NEW_PRJ_ENTRY_QTR_ID"];
          int empId = user.empId ?? 0;
          final apiResp = await ApiClient.fetchNewPrjAndSubPrj(empId: empId, qtrId: qtrId, lookup: "NEW_PROJECT");
          if (apiResp == null || apiResp["data"] == null) {
            emit(ErrorState(message: "No New Project added by you to Download."));
            return;
          }
          final List<NewProjectEntity> projects = (apiResp["data"] as List)
              .map((e) => NewProjectEntity.fromJson(NewProjectEntity().mapApiProjectToEntity(e)))
              .toList();
          for (var newPrj in projects) {
            await DBHelper.insertNewProject(newPrj);
          }
          emit(SuccessState(message: "${projects.length} New Project downloaded successfully"));
          downloadNewSubProjects();
        }
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void downloadNewSubProjects() async {
    try {
      emit(LoadingState());
      final userData = await StorageFunction.readStringData(StorageKey.userData);
      if (userData != null) {
        UserData user = UserData.fromJson(jsonDecode(userData));
        final decodedList = jsonDecode(user.jsonstr ?? "");
        final List<Map<String, dynamic>> prjEntryData = decodedList.cast<Map<String, dynamic>>();
        if (prjEntryData.isNotEmpty) {
          String qtrId = prjEntryData.first["NEW_PRJ_ENTRY_QTR_ID"];
          int empId = user.empId ?? 0;
          final apiResp = await ApiClient.fetchNewPrjAndSubPrj(empId: empId, qtrId: qtrId, lookup: "NEW_SUB_PROJECT");
          if (apiResp == null || apiResp["data"] == null) {
            emit(ErrorState(message: "No New Sub-Project added by you to Download."));
            return;
          }
          final List<dynamic> dataList = apiResp["data"];
          if (dataList.isNotEmpty) {
            for (var data in dataList) {
              NewSubProjectEntity newSubPrj = NewSubProjectEntity.fromJson(
                NewSubProjectEntity().mapApiSubProjectToEntity(data),
              );
              final List<dynamic> flatList = data["FLAT_LIST"] ?? [];
              await DBHelper.insertNewSubProject(newSubPrj);
              List<NewFlatEntity> newFlats = flatList
                  .map((i) => NewFlatEntity.fromJson(NewFlatEntity().mapApiFlatToEntity(i)))
                  .toList();
              for (var flats in newFlats) {
                await DBHelper.insertNewFlatEntity(flats);
              }
            }
          }

          emit(SuccessState(message: "${dataList.length} New Sub-Project Downloaded successfully."));
        }
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void refreshData({required List<ProjectEntity> projects, required List<SubProjectEntity> subProjects}) async {
    try {
      List<ProjectEntity> unsyncPrj = projects.where((i) => i.syncGlobalStatus == 0 && i.syncLocalStatus == 1).toList();
      List<SubProjectEntity> unsyncSubPrj = subProjects
          .where((i) => i.syncGlobalStatus == 0 && i.syncLocalStatus == 1)
          .toList();
      if (unsyncSubPrj.isNotEmpty || unsyncPrj.isNotEmpty) {
        emit(
          ErrorState(
            message: "There are unsync projects. Please sync first your local data to check global sync status.",
          ),
        );
        return;
      } else {
        DateTime current = DateTime.now();
        String formattedDate = DateFormat("yyyy-MM-dd'T'hh:mm:ss").format(current);
        for (var prj in unsyncPrj) {
          prj.syncCheckDate = formattedDate;
          await DBHelper.updateProject(prj);
        }
        List<ProjectEntity> projectsToSync = unsyncPrj.take(50).toList();
        final response = await ApiClient.syncProjects(projectEntity: projectsToSync);
        if (response != null) {
          ProjectResponse projectResponse = ProjectResponse.fromJson(response);

          insertIntoDb(projectResponse);
          emit(SuccessState(message: "Projects checked successfully."));
        }
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  Future<void> insertIntoDb(ProjectResponse response) async {
    try {
      List<ProjectEntity> projectEntities = [];
      List<SubProjectEntity> subProjectEntities = [];
      List<ProjectSchemeEntity> schemeEntities = [];
      List<FlatEntity> flatEntities = [];

      if (response.projectsData != null) {
        for (var project in response.projectsData!) {
          /// Project
          ProjectCosting? ppp = project.projectCosting;
          final costingMap = ppp?.toPrjCostingJson();
          projectEntities.add(
            ProjectEntity(
              projectId: project.projectId,
              dos: project.dos?.toIso8601String() ?? "",
              projectName: project.projectName,
              projectAddress: project.projectAddress,
              pxval: project.pxval,
              pyval: project.pyval,
              projectPhoneNo: project.projectPhoneNo,
              projectMobileNo: project.projectMobileNo,
              builderId: project.builderId,
              builderName: project.builderName,
              builderAddress: project.builderAddress,
              builderPhoneNo: project.builderPhoneNo,
              builderMobileNo: project.builderMobileNo,
              roadName: project.roadName,
              locationId: project.locationId,
              suburbId: project.suburbId,
              cityId: project.cityId,
              reDevelopment: project.reDevelopment == true ? 1 : 0,
              reraNo: project.reraNo,
              drinkingWater: project.drinkingWater,
              totalWings: project.totalWings,
              marketableWings: project.marketableWings,
              totalSupplyUnits: project.totalSupplyUnits,
              landParcelSize: project.landParcelSize,
              landParcelSizeUnit: project.landParcelSizeUnit,
              // syncGlobalStatus: project.prjSync,
              syncGlobalStatus: 1,
              syncLocalStatus: 1,
              projectUnsold: project.projectUnsold,
              qtrId: project.qtrId,
              projectCosting: costingMap == null ? null : jsonEncode(costingMap),
              modularKitchenBrand: project.modularKitchenBrand,
              architectName: project.mobArchitectName,
              architectId: project.architectId,
              isWrongPXValPYVal: 0,
              rejectId: project.rejectId,
              fixedBy: project.fixedBy,
              rejectedSurveyorId: project.rejectedSurveyorId,
              cinNo: project.cinNo,
              schemeOthers: project.schemeOthers,
              telFlag: project.telFlag == true ? 1 : 0,
              syncCheckDate: DateTime.now().toIso8601String(),
              reraInfo: project.reraInfo,
              newProjectUpdate: project.newProjectUpdate == true ? 1 : 0,
              assignedNewPrj: 0,
            ),
          );

          /// Schemes

          if (project.schemeList != null) {
            for (var scheme in project.schemeList!) {
              ProjectSchemeEntity prjScheme = ProjectSchemeEntity(
                schemeId: scheme.schemeId,
                projectId: scheme.projectId,
                qtrId: scheme.qtrId,
                openText: scheme.openText,
              );
              schemeEntities.add(prjScheme);
            }
          }

          /// SubProjects
          if (project.subProjectsList != null) {
            for (var sub in project.subProjectsList!) {
              subProjectEntities.add(
                SubProjectEntity(
                  subProjectId: sub.subProjectId,
                  dos: sub.dos!.toIso8601String(),
                  subProjectName: sub.subProject,
                  saleableRatepsf: sub.saleableRatepsf,
                  carpetRatepsf: sub.carpetRatepsf,
                  startDate: sub.startDate?.toIso8601String(),
                  endDate: sub.endDate?.toIso8601String(),
                  wings: sub.wings,
                  storey: sub.storey,
                  flatsPerFloor: sub.flatsPerFloor,
                  projectStatusId: sub.projectStatusId,
                  constructionProgressId: sub.constructionProgressId,
                  floorSlab: sub.floorSlab,
                  remarks: sub.remarks,
                  scr: sub.scr,
                  maintenancePersqft: sub.maintenancePersqft,
                  stiltPark: sub.stiltPark,
                  openPark: sub.openPark,
                  podium: sub.podium,
                  doublePodium: sub.doublePodium,
                  basementPark: sub.basementPark,
                  bookingStop: sub.bookingStop,
                  floorRise: sub.floorRise,
                  deleteFlag: sub.deleteFlag == true ? 1 : 0,
                  hasVillas: sub.hasVillas == true ? 1 : 0,
                  percVilaStarted: sub.percVilaStarted,
                  percVilaPiling: sub.percVilaPiling,
                  percVilaPlinth: sub.percVilaPlinth,
                  percVilaFloorslab: sub.percVilaFloorslab,
                  percVilaInternalWork: sub.percVilaInternalWork,
                  percVilaExternal: sub.percVilaExternal,
                  percVilaComplete: sub.percVilaComplete,
                  // syncGlobalStatus: sub.syncStatus,
                  syncGlobalStatus: 1,
                  syncLocalStatus: 1,
                  flatSoldCount: 0,
                  projectId: project.projectId,
                  surveyDate: sub.surveyDate?.toIso8601String(),
                  qtrId: sub.qtrId.toString(),
                  rateType: sub.rateType,
                  isCarpetOrSaleableChoosen: 0,
                  errMsg: "",
                  flatgroupid: sub.flatgroupid,
                  assignedNewPrj: 0,
                ),
              );

              /// Flats
              if (sub.flatsList != null) {
                for (var flat in sub.flatsList!) {
                  final String id = '${project.projectId}_${sub.subProjectId}_${flat.flatId}';
                  flatEntities.add(
                    FlatEntity(
                      id: id,
                      flatId: flat.flatId,
                      flatType: flat.flat,
                      flatSold: flat.flatSold,
                      oldFlatSold: flat.flatSold,
                      flatUnsold: flat.flatUnsold,
                      flatSize: flat.flatSize,
                      flatSizeCarpet: flat.flatSizeCarpet,
                      flatSizeAvg: flat.flatSizeAvg,
                      flatSizeCarpetAvg: flat.flatSizeCarpetAvg,
                      subProjectId: sub.subProjectId,
                      projectId: project.projectId,
                      isSaleableEnable: 1,
                      sizeType: flat.sizeType,
                      dataFilled: 1,
                    ),
                  );
                }
              }
            }
          }
        }
      }

      /// Bulk insert (IMPORTANT)
      await DBHelper.insertProjects(projectEntities);
      await DBHelper.insertSubProjectsBulk(subProjectEntities);
      await DBHelper.insertFlatsBulk(flatEntities);
      await DBHelper.insertProjectScheme(schemeEntities);
    } catch (e) {
      throw Exception("DB Insert Failed: $e");
    }
  }

  void fixMethod({
    required BuildContext context,
    required ProjectEntity projectData,
    required List<SubProjectEntity> subProjects,
  }) async {
    try {
      List<SubProjectEntity> unSyncSubPrj = subProjects.where((e) => e.syncGlobalStatus == 0).toList();
      if (unSyncSubPrj.isNotEmpty) {
        emit(ErrorState(message: "Please sync the sub-project to fix it"));
      } else {
        final remarks = await CutsomAlertDialogues.projectFixDialogue(context: context);
        if (remarks != null) {
          fixedApiCall(projectData: projectData, remarks: remarks);
        }
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void fixedApiCall({required ProjectEntity projectData, required String remarks}) async {
    try {
      final response = await ApiClient.fixedProject(projectData: projectData, remarks: remarks);
      if (response != null) {
        getProject();
      } else {
        emit(ErrorState(message: "Unable to mark the project as fix, Please try again later"));
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void getRejectReason({required int projectId, required int qtrId}) async {
    try {
      emit(RejectLoadingState());
      var response = await ApiClient.getRejectReason(projectId: projectId, qtrId: qtrId);
      if (response != null && response["status"] == "OK") {
        RejectReasonModel reasonModel = RejectReasonModel.fromJson(response);
        emit(RejectState(rejectData: reasonModel.data!));
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }
}
