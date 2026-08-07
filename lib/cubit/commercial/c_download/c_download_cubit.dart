import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lf_survey/constants/storage_function.dart';
import 'package:lf_survey/constants/storage_key.dart';
import 'package:lf_survey/cubit/commercial/c_download/c_download_state.dart';
import 'package:lf_survey/database/db_helper.dart';
import 'package:lf_survey/model/commercial/c_location_response.dart';
import 'package:lf_survey/model/commercial/c_project_response.dart';
import 'package:lf_survey/model/commercial/c_spinner_response.dart';
import 'package:lf_survey/model/db_model/commercial/c_entity.dart';
import 'package:lf_survey/model/db_model/commercial/c_location_entity.dart';
import 'package:lf_survey/model/db_model/commercial/c_project_entity.dart';
import 'package:lf_survey/model/db_model/commercial/c_sub_project_entity.dart';
import 'package:lf_survey/model/db_model/commercial/c_suburb_entity.dart';
import 'package:lf_survey/services/api_client.dart';

class CDownloadCubit extends Cubit<CDownloadState> {
  CDownloadCubit() : super(InitState());

  void fetchData() async {
    try {
      bool? isDownloadedData = await StorageFunction.readBoolData(StorageKey.cIsDownloadData);
      if (isDownloadedData == true) {
        List<CCityEntity> cities = await DBHelper.cfetchAllCities();
        emit(LocalDbState(cities: cities));
      } else {
        fetchCities();
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void fetchCities() async {
    try {
      emit(LoadingState());
      final response = await ApiClient.cFetchCities();
      if (response == null) {
        emit(ErrorState(message: "No response from server"));
        return;
      }
      if (response != null) {
        if (response["citiesList"] == null) {
          emit(ErrorState(message: "You have not assigned the project"));
        } else {
          CLocationResponse cityData = CLocationResponse.fromJson(response);
          List<CCitiesList>? cities = cityData.citiesList;
          if (cities != null && cities.isNotEmpty) {
            for (var city in cities) {
              CCityEntity cityEntity = CCityEntity(
                cityId: city.cityId ?? 0,
                cityName: city.cityName ?? "",
                checked: false,
              );
              await DBHelper.cInsertCityEntity(cityEntity);
              List<CSuburbsList>? suburbs = city.suburbsList;
              if (suburbs != null && suburbs.isNotEmpty) {
                for (var sub in suburbs) {
                  CSuburbEntity suburbEntity = CSuburbEntity(
                    suburbId: sub.suburbId ?? 0,
                    suburbName: sub.suburbName ?? "",
                    cityId: cityEntity.cityId,
                  );
                  await DBHelper.cInsertSuburbEntity(suburbEntity);
                  List<CLocationsList>? locations = sub.locationsList;
                  if (locations != null && locations.isNotEmpty) {
                    for (var loc in locations) {
                      CLocationEntity locationEntity = CLocationEntity(
                        locationId: loc.locationId!,
                        locationName: loc.locationName!,
                        suburbId: suburbEntity.suburbId,
                        checked: false,
                      );
                      await DBHelper.cInsertLocationEntity(locationEntity);
                    }
                  }
                }
              }
            }
          }
          await StorageFunction.writeBoolData(StorageKey.cIsDownloadData, true);
          emit(LoadedSate(locData: cityData));
        }
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void selectCity({required int cityId}) async {
    try {
      final response = await DBHelper.cFetchAllSuburbs(cityId: cityId);
      if (response.isNotEmpty) {
        emit(SelectCityState(suburb: response));
      } else {
        emit(SelectCityState(suburb: []));
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void selectSuburb({required int suburbId}) async {
    try {
      final response = await DBHelper.cFetchAllLocations(suburbId: suburbId);
      if (response.isNotEmpty) {
        emit(SelectSuburbState(locations: response));
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void toggleSelectAll({required List<CLocationEntity> locations, required bool isSelected}) {
    try {
      final updatedList = locations.map((item) {
        item.checked = isSelected;
        return item;
      }).toList();

      emit(SelectSuburbState(locations: updatedList));
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void toggleLocation({required List<CLocationEntity> locations, required int selectedId, required bool isSelected}) {
    try {
      final updatedList = locations.map((item) {
        if (item.locationId == selectedId) {
          item.checked = isSelected;
        }
        return item;
      }).toList();

      emit(SelectSuburbState(locations: updatedList));
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void downloadProjects({required List<int> location}) async {
    try {
      if (location.isEmpty) {
        emit(ErrorState(message: "Please select at least one location"));
        return;
      }

      emit(LoadingState());

      final userId = await StorageFunction.readIntData(StorageKey.userId);
      if (userId == null) {
        emit(ErrorState(message: "User not found"));
        return;
      }

      final response = await ApiClient.cFetchProjects(locationsId: location.join(","), userId: userId);

      if (response == null || response['status'] != "OK") {
        emit(ErrorState(message: "No response from server"));
        return;
      }

      final data = response["data"];
      if (data == null) {
        emit(ErrorState(message: "Invalid server response"));
        return;
      }

      final prjData = data["projectsList"];

      if (prjData == null || prjData.isEmpty) {
        emit(ErrorState(message: "No Project allocated to you."));
        return;
      }

      final spinData = data["spinnerMaster"];
      if (spinData != null) {
        final spinner = CSpinnerData.fromJson(spinData);
        await DBHelper.cInsertSpinnerData(spinner);
      }

      final List<CProjectResponse> projects = prjData
          .map<CProjectResponse>((e) => CProjectResponse.fromJson(e))
          .toList();

      final prjList = projects.map((e) {
        return CProjectEntity(
          projectId: e.projectId,
          locationId: e.locationId,
          suburbId: e.suburbId,
          cityId: e.cityId,
          pxval: e.pxval,
          pyval: e.pyval,
          dos: e.dos,
          projectName: e.projectName,
          projectAddress: e.projectAddress,
          projectPhoneNo: e.projectPhoneNo,
          projectContactPerson: e.projectContactPerson,
          projectMobileNo: e.projectMobileNo,
          builderId: e.builderId,
          builderName: e.builderName,
          builderAddress: e.builderAddress,
          builderContactPerson: e.builderContactPerson,
          builderPhoneNo: e.builderPhoneNo,
          builderMobileNo: e.builderMobileNo,
          roadName: e.roadName,
          parkingOpen: e.parkingOpen,
          parkingStacked: e.parkingStacked,
          parkingStilt: e.parkingStilt,
          parkingBasement: e.parkingBasement,
          parkingPodium: e.parkingPodium,
          parkingRatio: e.parkingRatio,
          scr: double.tryParse("${e.scr}"),
          maintenancePerSqft: double.tryParse("${e.maintenancePerSqft}"),
          propertyTax: e.propertyTax,
          landParcelSizeUnit: e.landParcelSizeUnit,
          landParcelSize: e.landParcelSize,
          tenantMixId: e.tenantMixId,
          syncGlobalStatus: 0,
          syncLocalStatus: 0,
          rerano: e.reraNo,
          telFlag: 0,
          userid: userId,
        );
      }).toList();

      final List<CSubProjectEntity> subProjects = projects.expand((prj) {
        final list = prj.subProjects?.comSubProjectsList;
        if (list == null) return <CSubProjectEntity>[];

        return list.map((subPrj) {
          return CSubProjectEntity(
            subProjectId: subPrj.subProjectId,
            dos: subPrj.dos,
            subProjectName: subPrj.subProjectName,
            storeyBasement: subPrj.storeyBasement,
            storeyPodium: subPrj.storeyPodium,
            storeyService: subPrj.storeyService,
            storeyHabitable: subPrj.storeyHabitable,
            constStartDate: subPrj.constStartDate,
            constEndDate: subPrj.constEndDate,
            marketingStartDate: subPrj.marketingStartDate,
            marketingEndDate: subPrj.marketingEndDate,
            constructionProgressId: subPrj.constructionProgressId,
            floorSlab: subPrj.floorSlab,
            buildingTypeId: subPrj.buildingTypeId,
            operationModelId: subPrj.operationModelId,
            totalSupplySqft: subPrj.totalSupplySqft,
            soldAreaSqft: subPrj.soldAreaSqft,
            unsoldAreaSqft: subPrj.unsoldAreaSqft,
            leasedOccupiedArea: subPrj.leasedOccupiedArea,
            vacancyArea: subPrj.vacancyArea,
            minFloorplate: subPrj.minFloorplate,
            maxFloorplate: subPrj.maxFloorplate,
            orBareshell: subPrj.orBareshell,
            orWarmshell: subPrj.orWarmshell,
            orFullyFurnished: subPrj.orFullyFurnished,
            lrBareshell: subPrj.lrBareshell,
            lrWarmshell: subPrj.lrWarmshell,
            lrFullyFurnished: subPrj.lrFullyFurnished,
            projectStatusId: subPrj.projectStatusId,
            remarks: subPrj.remarks,
            syncGlobalStatus: subPrj.syncStatus,
            syncLocalStatus: subPrj.syncStatus,
            projectId: prj.projectId,
          );
        });
      }).toList();

      // Insert into DB
      await DBHelper.cInsertMultiProjeject(projects: prjList);
      await DBHelper.cInsertMultiSubPrj(subProjects: subProjects);

      emit(SuccessState(message: "${prjList.length} projects downloaded successfully."));
    } catch (e) {
      emit(ErrorState(message: "Something went wrong"));
    }
  }
}
