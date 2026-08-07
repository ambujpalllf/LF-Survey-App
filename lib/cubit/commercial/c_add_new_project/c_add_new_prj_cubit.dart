import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lf_survey/constants/storage_function.dart';
import 'package:lf_survey/constants/storage_key.dart';
import 'package:lf_survey/cubit/commercial/c_add_new_project/c_add_new_prj_state.dart';
import 'package:lf_survey/database/db_helper.dart';
import 'package:lf_survey/model/db_model/commercial/c_new_project_entity.dart';
// import 'package:lf_survey/model/db_model/commercial/c_new_project_entity.dart';

class CAddNewPrjCubit extends Cubit<CAddNewPrjState> {
  CAddNewPrjCubit() : super(InitState());

  void fetchData() async {
    try {
      int? empId;
      String? comQtr;
      String? comQtrId;
      final response = await Future.wait([
        DBHelper.cGetAmenties(),
        DBHelper.cGetApproveBanks(),
        DBHelper.cGetOperationModel(),
        DBHelper.cGetBuildingType(),
        DBHelper.cGetTenantMixEntity(),
        DBHelper.cGetCityList(),
      ]);
      final userdata = await StorageFunction.readStringData(StorageKey.userData);
      if (userdata != null) {
        final userMap = jsonDecode(userdata);
        empId = userMap['empId'];
        final jsonStr = userMap['jsonstr'];
        List<dynamic> jsonList = [];
        if (jsonStr != null && jsonStr.isNotEmpty) {
          jsonList = jsonDecode(jsonStr);
        }

        if (jsonList.isNotEmpty) {
          final firstItem = jsonList[0];

          comQtr = firstItem['COM_NEW_PRJ_ENTRY_QTR'];
          comQtrId = firstItem['COM_NEW_PRJ_ENTRY_QTR_ID'];
        }
      }
      if (response.isNotEmpty) {
        emit(
          LocalDbState(
            empId: empId,
            comQtr: comQtr,
            comQtrId: comQtrId,
            amenties: response[0],
            approvedBanks: response[1],
            operationModel: response[2],
            buildingType: response[3],
            tenantType: response[4],
            cities: response[5],
          ),
        );
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  bool fieldsValidation({
    String? projectName,
    String? projectAddress,
    String? roadName,
    String? builderName,
    String? architectName,
    String? lat,
    String? lng,
    String? mobileNo,
    Map<String, dynamic>? selectedCities,
    List<Map<String, dynamic>>? selectedAmenties,
    List<Map<String, dynamic>>? selectApproveBanks,
    Map<String, dynamic>? selectOperatingModel,
    Map<String, dynamic>? selectBuildingType,
    Map<String, dynamic>? selectTenantType,
  }) {
    String? projectNameEr;
    String? projectAddressEr;
    String? roadNameEr;
    String? builderNameEr;
    String? architectNameEr;
    String? latEr;
    String? lngEr;
    String? mobileNoEr;
    String? cityEr;
    String? amentiesEr;
    String? approveBanksEr;
    String? operatingModelEr;
    String? buildingTypeEr;
    String? tenantTypeEr;

    if (projectName == null || projectName.trim().isEmpty) {
      projectNameEr = "Please enter the project name.";
    }

    if (projectAddress == null || projectAddress.trim().isEmpty) {
      projectAddressEr = "Please enter the project address.";
    }

    if (roadName == null || roadName.trim().isEmpty) {
      roadNameEr = "Please enter the road name.";
    }

    if (builderName == null || builderName.trim().isEmpty) {
      builderNameEr = "Please enter the builder name.";
    }

    if (architectName == null || architectName.trim().isEmpty) {
      architectNameEr = "Please enter the architect name.";
    }

    if (lat == null || lat.isEmpty) {
      latEr = "Latitude is required.";
    }

    if (lng == null || lng.isEmpty) {
      lngEr = "Longitude is required.";
    }

    if (mobileNo == null || mobileNo.trim().isEmpty) {
      mobileNoEr = "Please enter a mobile number.";
    } else if (mobileNo.length != 10) {
      mobileNoEr = "Please enter a valid 10-digit mobile number.";
    }

    if (selectedCities == null || selectedCities.isEmpty) {
      cityEr = "Please select a city.";
    }

    if (selectedAmenties == null || selectedAmenties.isEmpty) {
      amentiesEr = "Please select at least one amenity.";
    }

    if (selectApproveBanks == null || selectApproveBanks.isEmpty) {
      approveBanksEr = "Please select at least one approved bank.";
    }

    if (selectOperatingModel == null || selectOperatingModel.isEmpty) {
      operatingModelEr = "Please select an operating model.";
    }

    if (selectBuildingType == null || selectBuildingType.isEmpty) {
      buildingTypeEr = "Please select a building type.";
    }

    if (selectTenantType == null || selectTenantType.isEmpty) {
      tenantTypeEr = "Please select a tenant type.";
    }

    // Emit once
    emit(
      FieldsValidation(
        projectNameEr: projectNameEr,
        projectAddressEr: projectAddressEr,
        roadNameEr: roadNameEr,
        builderNameEr: builderNameEr,
        architectNameEr: architectNameEr,
        latEr: latEr,
        lngEr: lngEr,
        mobileNoEr: mobileNoEr,
        cityEr: cityEr,
        amentiesEr: amentiesEr,
        approveBanksEr: approveBanksEr,
        operatingModelEr: operatingModelEr,
        buildingTypeEr: buildingTypeEr,
        tenantTypeEr: tenantTypeEr,
      ),
    );

    // Final result
    return projectNameEr == null &&
        projectAddressEr == null &&
        roadNameEr == null &&
        builderNameEr == null &&
        architectNameEr == null &&
        latEr == null &&
        lngEr == null &&
        mobileNoEr == null &&
        cityEr == null &&
        amentiesEr == null &&
        approveBanksEr == null &&
        operatingModelEr == null &&
        buildingTypeEr == null &&
        tenantTypeEr == null;
  }

  void submitData({
    int? empId,
    String? comQtr,
    String? projectId,
    String? projectName,
    String? projectAddress,
    String? roadName,
    String? builderName,
    String? architectName,
    String? lat,
    String? lng,
    String? mobileNo,
    Map<String, dynamic>? selectedCities,
    List<Map<String, dynamic>>? selectedAmenties,
    List<Map<String, dynamic>>? selectApproveBanks,
    Map<String, dynamic>? selectOperatingModel,
    Map<String, dynamic>? selectBuildingType,
    Map<String, dynamic>? selectTenantType,
  }) async {
    try {
      final validateData = fieldsValidation(
        projectName: projectName,
        projectAddress: projectAddress,
        roadName: roadName,
        builderName: builderName,
        architectName: architectName,
        lat: lat,
        lng: lng,
        mobileNo: mobileNo,
        selectedCities: selectedCities,
        selectedAmenties: selectedAmenties,
        selectApproveBanks: selectApproveBanks,
        selectOperatingModel: selectOperatingModel,
        selectBuildingType: selectBuildingType,
        selectTenantType: selectTenantType,
      );
      if (!validateData) return;
      emit(LoadingState());
      String amenitiesId = "";
      String approveBanksId = "";
      amenitiesId = (selectedAmenties ?? []).map((e) => e["amenitiesId"].toString()).join(",");
      approveBanksId = (selectApproveBanks ?? []).map((e) => e['bankId'].toString()).join(",");
      final timeStamp = DateTime.now();
      final prjId = projectId ?? "${empId}_${timeStamp.microsecondsSinceEpoch}";
      final formatedDate = DateFormat("dd-MMM-yyyy'T'HH:mm:ss").format(timeStamp);
      final comQtrDate = DateTime.tryParse(comQtr ?? '');
      final formattedComQtr = comQtrDate != null ? DateFormat('MMM yyyy').format(comQtrDate) : 'N/A';
      CNewProjectEntity project = CNewProjectEntity(
        prjId: prjId,
        prjName: projectName,
        prjAddr: projectAddress,
        roadName: roadName,
        cityId: selectedCities?["city_id"],
        builderName: builderName,
        architectName: architectName,
        lat: double.tryParse(lat ?? '') ?? 0.0,
        lng: double.tryParse(lng ?? '') ?? 0.0,
        mobile: mobileNo,
        amenitiesIds: amenitiesId,
        approvedBankIds: approveBanksId,
        operatingModelId: selectOperatingModel?['operatingModelId'],
        buildingTypeId: selectBuildingType?['buildingTypeId'],
        tenantMixId: selectTenantType?['tenantMixId'],
        // dos: comQtr,
        dos: formattedComQtr,
        mobileCreatedDatetime: formatedDate,
        localSyncStatus: 1,
        globalSyncStatus: 0,
      );
      final response = await DBHelper.cInsertNewProject(project: project);
      if (response > 0) {
        emit(SuccessState(message: "Your data has been saved successfully."));
      } else {
        emit(InitState());
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }
}
