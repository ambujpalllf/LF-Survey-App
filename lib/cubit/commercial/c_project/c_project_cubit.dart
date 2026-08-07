import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lf_survey/constants/storage_function.dart';
import 'package:lf_survey/constants/storage_key.dart';
import 'package:lf_survey/cubit/commercial/c_project/c_project_state.dart';
import 'package:lf_survey/database/db_helper.dart';
import 'package:lf_survey/model/commercial/c_new_project_response.dart';
import 'package:lf_survey/model/commercial/c_new_sub_prj_response.dart';
import 'package:lf_survey/model/db_model/commercial/c_new_project_entity.dart';
import 'package:lf_survey/model/db_model/commercial/c_new_sub_project_entity.dart';
import 'package:lf_survey/model/db_model/commercial/c_project_entity.dart';
import 'package:lf_survey/model/db_model/commercial/c_sub_project_entity.dart';
import 'package:lf_survey/services/api_client.dart';

class CProjectCubit extends Cubit<CProjectState> {
  CProjectCubit() : super(InitState());

  void fetchData() async {
    try {
      emit(LoadingState());
      final response = await Future.wait([DBHelper.cGetProjects(), DBHelper.cGetSubProjects()]);
      if (response.isNotEmpty) {
        final projects = response[0] as List<CProjectEntity>;
        final subProjects = response[1] as List<CSubProjectEntity>;
        if (projects.isEmpty) {
          emit(ErrorState(message: "No projects found. Please download projects first."));
          return;
        }
        emit(LoadedState(projects: projects, subProjects: subProjects));
      }
    } catch (e) {
      emit(ErrorState(message: "Something went wrong while loading projects. Please try again."));
    }
  }

  void downloadNewPrj() async {
    try {
      emit(LoadingState());
      final userResp = await StorageFunction.readStringData(StorageKey.userData);
      if (userResp == null || userResp.isEmpty) return;
      final Map<String, dynamic> userData = jsonDecode(userResp);
      final userId = userData['empId'];
      final ff = userData['jsonstr'];
      var jsonData = jsonDecode(ff);
      final List<Map<String, dynamic>> hh = (jsonData as List<dynamic>)
          .map((e) => Map<String, dynamic>.from(e as Map<String, dynamic>))
          .toList();
      Map<String, dynamic> singleItem = hh.first;
      String dos = singleItem['COM_NEW_PRJ_ENTRY_QTR'];
      final response = await ApiClient.cFetchNewProjects(dos: dos, userId: userId);

      if (response != null && response['status'].toString().toLowerCase() == "ok") {
        CNewProjectResponse prjData = CNewProjectResponse.fromJson(response);
        List<CNewProjectEntity> newProjectsData = [];
        List<CNewProjectDatum> newPrj = prjData.data ?? [];
        if (newPrj.isNotEmpty) {
          for (var data in newPrj) {
            CNewProjectEntity newPrjData = CNewProjectEntity(
              prjId: data.newProjectId,
              prjName: data.projectName,
              prjAddr: data.projectAddress,
              roadName: data.roadName,
              builderName: data.builderName,
              architectName: data.architectName,
              lat: data.lat,
              lng: data.lng,
              mobile: data.mobileNo,
              amenitiesIds: data.amenitiesIds,
              approvedBankIds: data.approvedBankIds,
              operatingModelId: data.operatingModelId,
              buildingTypeId: data.buildingTypeId,
              tenantMixId: data.tenantMixId,
              dos: data.dos,
              mobileCreatedDatetime: data.createdDatetimeMob,
              localSyncStatus: 1,
              globalSyncStatus: 1,
            );
            newProjectsData.add(newPrjData);
          }
          emit(SuccessState(message: "${newProjectsData.length} New Projects Downloaded."));
          await DBHelper.cInsertMultiNewProject(projects: newProjectsData);
          downloadNewSubPrj(dos: dos, userId: userId);
        } else {
          emit(ErrorState(message: "No New Project added by you to Download."));
        }
      } else {
        emit(ErrorState(message: response['message']));
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void downloadNewSubPrj({required String dos, required int userId}) async {
    try {
      final response = await ApiClient.cFetchNewSubPrj(dos: dos, userId: userId);
      if (response != null && response['status'].toString().toLowerCase() == "ok") {
        CNewSubPrjResponse subPrjData = CNewSubPrjResponse.fromJson(response);
        List<CNewSubProjectEntity> newSubPrjData = [];
        List<CNewSubPrjDatum> data = subPrjData.data ?? [];
        if (data.isNotEmpty) {
          for (var item in data) {
            CNewSubProjectEntity newSubPrj = CNewSubProjectEntity(
              subPrjId: item.newSubProjectId,
              prjId: item.newProjectId,
              prjIdLF: item.lfProjectId,
              subPrjName: item.newSubProjectName,
              storey: item.storey,
              scr: item.scr,
              maintenance: item.maintenance,
              floorPlate: item.floorPlate,
              carpetOrSaleable: item.isCarpetOrSaleable,
              leaseBareshell: item.leaseBareshell,
              leaseWarmshell: item.leaseWarmshell,
              leaseFullyFurnished: item.leaseFullyFurnished,
              outrightBareshell: item.outrightBareshell,
              outrightWarmshell: item.outrightWarmshell,
              outrightFullyFurnished: item.outrightFullyFurnished,
              launchDate: item.launchDate,
              endDate: item.endDate,
              constructionStageId: item.constructionStageId,
              floorSlab: item.floorSlab,
              totalSupply: item.totalSupply,
              soldPercent: item.soldPercent,
              unsoldPercent: item.unsoldPercent,
              leasePercent: item.leasePercent,
              vacantPercent: item.vacantPercent,
              reraNo: item.reraNo,
              remark: item.remark,
              dos: item.dos,
              mobileCreatedDatetime: item.createdDatetimeMob,
              localSyncStatus: 1,
              globalSyncStatus: 1,
            );
            newSubPrjData.add(newSubPrj);
          }
          emit(SuccessState(message: "${newSubPrjData.length} New Sub-Projects Downloaded."));
          await DBHelper.cNewInstertMultiSubProject(subprojects: newSubPrjData);
          emit(InitState());
        }
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void searchProject({
    required List<CProjectEntity> projects,
    required List<CProjectEntity> filterProjects,
    required bool isActiveFilter,
    required String query,
  }) {
    try {
      final trimmedQuery = query.trim().toLowerCase();
      List<CProjectEntity> filteredList = isActiveFilter ? filterProjects : projects;

      if (trimmedQuery.isNotEmpty && trimmedQuery.length >= 3) {
        filteredList = (isActiveFilter ? filterProjects : projects).where((e) {
          return e.projectId.toString().contains(trimmedQuery) ||
              e.projectName!.toLowerCase().contains(trimmedQuery) ||
              e.builderName!.toLowerCase().contains(trimmedQuery) ||
              e.roadName!.toLowerCase().contains(trimmedQuery) ||
              e.projectAddress!.toLowerCase().contains(trimmedQuery);
        }).toList();
      }
      emit(SearchState(projects: filteredList, isActiveFilter: isActiveFilter));
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void clearDb() async {
    try {
      await DBHelper.clearComAllData();
      emit(ClearDbState());
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void applyFilter({required List<CProjectEntity> projects}) async {
    try {
      List<CProjectEntity> filteredProjects = List.from(projects);
      Map<String, dynamic>? filterData = await DBHelper.getFilterQuery();
      if (filterData == null || filterData['prjType'] == "res") {
        emit(FilterState(projects: filteredProjects, applyFilter: false));
        return;
      }
      Map<String, dynamic> filterQuery = jsonDecode(filterData['query']);

      if (filterQuery.isEmpty) {
        emit(FilterState(projects: filteredProjects, applyFilter: false));
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
          }
        }
      }
      /************* By Location  */
      final List<int> locations = (filterQuery["location"] as List?)?.map((e) => e as int).toList() ?? [];
      if (locations.isNotEmpty) {
        hasActiveFilter = true;
        filteredProjects = filteredProjects.where((p) => locations.contains(p.locationId)).toList();
      }
      emit(FilterState(projects: filteredProjects, applyFilter: hasActiveFilter));
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }
}
