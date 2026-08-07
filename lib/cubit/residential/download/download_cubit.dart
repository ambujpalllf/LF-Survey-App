import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lf_survey/constants/storage_function.dart';
import 'package:lf_survey/constants/storage_key.dart';
import 'package:lf_survey/cubit/residential/download/download_state.dart';
import 'package:lf_survey/database/db_helper.dart';
import 'package:lf_survey/model/db_model/residential/city_entiy.dart';
import 'package:lf_survey/model/db_model/residential/flat_entity.dart';
import 'package:lf_survey/model/db_model/residential/location_entity.dart';
import 'package:lf_survey/model/db_model/residential/project_entity.dart';
import 'package:lf_survey/model/db_model/residential/sub_prj_entity.dart';
import 'package:lf_survey/model/db_model/residential/suburb_entity.dart';
import 'package:lf_survey/model/residential/archi_response.dart';
import 'package:lf_survey/model/residential/cities_response.dart';
import 'package:lf_survey/model/residential/project_response.dart';
import 'package:lf_survey/model/residential/project_spinner.dart';
import 'package:lf_survey/services/api_client.dart';

class DownloadCubit extends Cubit<DownloadState> {
  DownloadCubit() : super(InitState());

  void fetchData() async {
    try {
      bool? isDownloadedData = await StorageFunction.readBoolData(StorageKey.isDownloadData);
      if (isDownloadedData == true) {
        List<CityEntity> cities = await DBHelper.fetchAllCitiesEntity();
        emit(LocalDbState(cities: cities));
      } else {
        getCities();
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void selectCity({required int cityId, required Map<String, dynamic> city}) async {
    try {
      List<SuburbEntity> suburbs = await DBHelper.fetchSuburbsByCityId(cityId);
      emit(SelectedCityState(cityEntity: city, suburb: suburbs));
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void selectSuburb({required int suburbId, required Map<String, dynamic> selectedSuburb}) async {
    try {
      List<LocationEntity> suburbs = await DBHelper.fetchLocationsBySuburbId(suburbId);
      emit(SelectedSuburbState(suburbEntity: selectedSuburb, locations: suburbs));
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void getCities() async {
    try {
      emit(RefreshState());
      downloadProjectSpinner();
      downloadArchitect();
      final response = await ApiClient.fetchCities();
      if (response == null) {
        emit(ErrorState(message: "No response from server"));
        return;
      }

      if (response != null) {
        if (response["citiesList"] == null) {
          emit(ErrorState(message: "You have not assigned the project"));
        } else {
          CitiesResponse cityData = CitiesResponse.fromJson(response);
          List<CitiesDatum>? cities = cityData.citiesList;
          if (cities != null && cities.isNotEmpty) {
            for (var city in cities) {
              CityEntity cityEntity = CityEntity(
                cityId: city.cityId ?? 0,
                cityName: city.cityName ?? "",
                checked: false,
              );
              await DBHelper.insertCityEntity(cityEntity);
              List<SuburbsList>? suburbs = city.suburbsList;
              if (suburbs != null && suburbs.isNotEmpty) {
                for (var sub in suburbs) {
                  SuburbEntity suburbEntity = SuburbEntity(
                    suburbId: sub.suburbId ?? 0,
                    suburbName: sub.suburbName ?? "",
                    cityId: cityEntity.cityId,
                  );
                  await DBHelper.insertSuburbEntity(suburbEntity);
                  List<LocationsList>? locations = sub.locationsList;
                  if (locations != null && locations.isNotEmpty) {
                    for (var loc in locations) {
                      LocationEntity locationEntity = LocationEntity(
                        locationId: loc.locationId!,
                        locationName: loc.locationName!,
                        suburbId: suburbEntity.suburbId,
                        checked: false,
                      );
                      await DBHelper.insertLocationEntity(locationEntity);
                    }
                  }
                }
              }
            }
          }
          await StorageFunction.writeBoolData(StorageKey.isDownloadData, true);
          emit(LoadedState(citiesResponse: cityData));
        }
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void selectCheckBox({required bool value, required int index}) {
    emit(SelectedState(selectedValue: value, index: index));
    emit(InitState());
  }

  void downloadProject({required String locationIds}) async {
    try {
      // downloadProjectSpinner();
      // downloadArchitect();
      emit(LoadingState());
      final response = await ApiClient.fetchProject(locationIds: locationIds);

      if (response != null) {
        // using ProjectResponse.fromJson
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
                suburbId: data.suburbId,
                cityId: data.cityId,
                reDevelopment: data.reDevelopment == true ? 1 : 0,
                reraNo: data.reraNo,
                drinkingWater: data.drinkingWater,
                totalWings: data.totalWings,
                marketableWings: data.marketableWings,
                totalSupplyUnits: data.totalSupplyUnits,
                landParcelSize: data.landParcelSize,
                landParcelSizeUnit: data.landParcelSizeUnit,
                syncGlobalStatus: data.prjSync,
                syncLocalStatus: 0,
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
                assignedNewPrj: 0,
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
                  assignedNewPrj: 0,
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
                      dataFilled: sprj.syncStatus ?? 0,
                    );
                    await DBHelper.insertFlat(flatEntity);
                  }
                }
              }
            }
          }
          // access projects list
          await DBHelper.insertProjects(projectEntity);
          emit(SuccessState(message: "${projectEntity.length} projects downloaded successfully"));
        } else {
          emit(ErrorState(message: "No Project Assign to you. 0 Projects Downloaded."));
        }
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void downloadProjectSpinner() async {
    try {
      emit(LoadingState());
      final response = await ApiClient.fetchProjectSpinner();

      if (response != null) {
        SpinnerResponse spinnerResponse = SpinnerResponse.fromJson(response);
        await DBHelper.insertSpinnerData(spinnerResponse);
        emit(InitState());
      } else {
        emit(InitState());
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void downloadArchitect() async {
    try {
      emit(LoadingState());
      final response = await ApiClient.fetchArchitect();

      if (response != null) {
        ArchitectResponse archiResponse = ArchitectResponse.fromJson(response);
        if (archiResponse.architectList!.isNotEmpty || archiResponse.architectList != null) {
          await DBHelper.insertArchi(archiResponse.architectList!);
        }
        emit(InitState());
      } else {
        emit(InitState());
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }
}
