import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lf_survey/constants/storage_function.dart';
import 'package:lf_survey/constants/storage_key.dart';
import 'package:lf_survey/cubit/residential/project_edit/project_edit_state.dart';
import 'package:lf_survey/database/db_helper.dart';
import 'package:lf_survey/model/db_model/residential/project_entity.dart';
import 'package:lf_survey/model/db_model/residential/sub_prj_entity.dart';
import 'package:lf_survey/model/residential/archi_response.dart';
import 'package:lf_survey/model/residential/project_response.dart';
import 'package:lf_survey/model/residential/project_scheme_entity.dart';
import 'package:lf_survey/model/residential/project_spinner.dart';
// import 'package:lf_survey/services/api_client.dart';
import 'package:lf_survey/services/work_manager_task_register.dart';

class ProjectEditCubit extends Cubit<ProjectEditState> {
  ProjectEditCubit() : super(InitState());

  Future<void> fetchLocalData({required int projectId}) async {
    try {
      final results = await Future.wait([
        DBHelper.getAreaUnit(),
        DBHelper.getSchemes(),
        DBHelper.getFlatType(),
        DBHelper.getCostIncluded(),
        DBHelper.fetchAllSprjEntityByPrjId(projectId: projectId),
        DBHelper.getCity(),
        DBHelper.getArchitects(),
        DBHelper.getAllProjectsSchemes(projectId: projectId),
        DBHelper.getApprovedBank(),
      ]);

      // Properly typed results
      final List areaUnitResponse = results[0] as List;
      final List schemeResponse = results[1] as List;
      final List flatTypeResponse = results[2] as List;
      final List costIncludedResponse = results[3] as List;
      final List sprjResponse = results[4] as List;
      final List cityResponse = results[5] as List;
      final List archiResponse = results[6] as List;
      final List prjSchemeResponse = results[7] as List;
      final List approveBanksResponse = results[8] as List;

      // Parse area units
      final List<AreaUnitList> areaUnit = areaUnitResponse.map((e) => AreaUnitList.fromJson(e)).toList();

      // Parse schemes
      final List<SchemesList> schemes = schemeResponse.map((e) => SchemesList.fromJson(e)).toList();
      final List<FlatTypeList> flatType = flatTypeResponse.map((e) => FlatTypeList.fromJson(e)).toList();
      final List<CostIncludedList> costIncluded = costIncludedResponse
          .map((e) => CostIncludedList.fromJson(e))
          .toList();
      final List<SubProjectEntity> sprj = sprjResponse.map((e) => SubProjectEntity.fromJson(e)).toList();

      final List<CityList> cities = cityResponse.map((e) => CityList.fromJson(e)).toList();
      final List<ArchitectDataum> architects = archiResponse.map((e) => ArchitectDataum.fromJson(e)).toList();
      final List<ProjectSchemeEntity> prjschemes = prjSchemeResponse
          .map((e) => ProjectSchemeEntity.fromJson(e))
          .toList();
      final List<ApprovedBankList> approveBanks = approveBanksResponse
          .map((e) => ApprovedBankList.fromJson(e))
          .toList();
      // Emit combined state
      emit(
        LocalDbState(
          areaUnit: areaUnit,
          schmeData: schemes,
          flatType: flatType,
          costIncluded: costIncluded,
          subProjects: sprj,
          cities: cities,
          architects: architects,
          prjschemes: prjschemes,
          approveBanks: approveBanks,
        ),
      );
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void fetchPrjSchems({required int projectId}) async {
    try {
      final response = await DBHelper.getAllProjectsSchemes(projectId: projectId);
      if (response.isNotEmpty) {
        final List<ProjectSchemeEntity> prjschemes = response.map((e) => ProjectSchemeEntity.fromJson(e)).toList();
        emit(PrjSchemState(prjschemes: prjschemes));
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  // When User update the project casting value then it call for showing latest data
  void fetchPrjCasting({required int projectId}) async {
    try {
      final response = await DBHelper.getSingleProject(projectId: projectId);
      if (response != null) {
        final ProjectEntity project = ProjectEntity.fromJson(response);
        emit(PrjCastingState(project: project));
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  bool editDialogueValidation({
    required bool isSaleable,
    required String saleable,
    required String carpet,
    required Map<String, dynamic>? flatType,
  }) {
    String saleError = "";
    String carpetError = "";
    String flatTypeError = "";

    if ((saleable.isEmpty || saleable == "0" || saleable == "0.0") && isSaleable) {
      saleError = "Please enter saleable size";
    }

    if ((carpet.isEmpty || carpet == "0" || carpet == "0.0") && isSaleable == false) {
      carpetError = "Please enter carpet size";
    }

    if (flatType == null) {
      flatTypeError = "Please select flat type";
    }

    // Emit state so UI updates
    emit(EditDialogueState(saleError: saleError, carpetError: carpetError, flatTypeError: flatTypeError));

    // Return success or failure
    return saleError.isEmpty && carpetError.isEmpty && flatTypeError.isEmpty;
  }

  void updateProjectCosting({
    required BuildContext context,
    required bool isSaleable,
    required ProjectEntity projectData,
    required ProjectCosting projectCostData,
    required String saleableSize,
    required String carpetSize,
    required String referenceSize,
    required Map<String, dynamic>? flatType,
    required String costIncluded,
    required String title,
  }) async {
    try {
      final result = editDialogueValidation(
        isSaleable: isSaleable,
        saleable: saleableSize,
        carpet: carpetSize,
        flatType: flatType,
      );
      if (result == false) return;
      if (title == "Base Cost") {
        projectCostData.baseCostSaleableSize = double.tryParse(saleableSize) ?? 0.0;
        projectCostData.baseCostCarpetSize = double.tryParse(carpetSize) ?? 0.0;
        projectCostData.baseCostReferenceUnitNumber = double.tryParse(referenceSize) ?? 0.0;
        projectCostData.baseCostFlatId = flatType!["id"];
        projectCostData.baseCostIncluded = costIncluded;
      } else if (title == "Agreement Cost") {
        projectCostData.agreementCostSaleableSize = double.tryParse(saleableSize) ?? 0.0;
        projectCostData.agreementCostCarpetSize = double.tryParse(carpetSize) ?? 0.0;
        projectCostData.agreementCostReferenceUnitNumber = double.tryParse(referenceSize) ?? 0.0;
        projectCostData.agreementCostFlatId = flatType!["id"];
        projectCostData.agreementCostIncluded = costIncluded;
      } else if (title == "All Inclusive Cost") {
        projectCostData.allInclusiveCostSaleableSize = double.tryParse(saleableSize) ?? 0.0;
        projectCostData.allInclusiveCostCarpetSize = double.tryParse(carpetSize) ?? 0.0;
        projectCostData.allInclusiveCostReferenceUnitNumber = double.tryParse(referenceSize) ?? 0.0;
        projectCostData.allInclusiveCostFlatId = flatType!["id"];
        projectCostData.allInclusiveCostIncluded = costIncluded;
      }
      debugPrint("Title: $title Body Data: ${projectCostData.toJson()}");
      projectData.projectCosting = jsonEncode(projectCostData.toJson());
      final response = await DBHelper.updateProject(projectData);
      if (response > 0) {
        if (!context.mounted) return;
        context.pop();
        // emit(SuccessSate(message: "Data saved succesfully"));
        emit(PrjUpdateCastingState());
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void searchArchi({required String searchText, required List<ArchitectDataum> allArchitects}) {
    if (searchText.isEmpty) {
      return;
    }
    if (searchText.length >= 3) {
      final query = searchText.toLowerCase().trim();
      List<ArchitectDataum> searchedArchi = allArchitects
          .where((e) => (e.architectName ?? '').toLowerCase().contains(query))
          .toList();
      emit(SearchArchiState(architects: searchedArchi));
    }
  }

  void selectArchi({required ArchitectDataum archiData}) {
    emit(SelectArchiState(architect: archiData));
  }

  bool projectValidation({
    required int syncGlobalStatus,
    required List selectedSchemes,
    required bool isBooking,
    required String baseCost,
    required String agreementCost,
    required String allInclusiveCost,
    required bool isNewPrjUpdate,
    required String prjLat,
    required String prjLong,
    required String prjAddress,
    required String prjBuilderAdd,
    required Map<String, dynamic> selectedAreaUnit,
  }) {
    if (syncGlobalStatus == 1) {
      emit(ErrorState(message: "You cannot edit the project now"));
      return false;
    }
    if (selectedSchemes.isEmpty) {
      emit(ErrorState(message: "Please select scheme to proceed"));
      return false;
    }
    // This code is comment because base cost, agreement cost, or all inclusive cast is not mandatory
    // if (isBooking == false) {
    //   if ((baseCost.isEmpty || baseCost == "0" || baseCost == "0.0") &&
    //       (agreementCost.isEmpty || agreementCost == "0" || agreementCost == "0.0") &&
    //       (allInclusiveCost.isEmpty || allInclusiveCost == "0" || allInclusiveCost == "0.0")) {
    //     emit(ErrorState(message: "Please enter base cost or agreement cost or all inclusive cost to proceed"));
    //     return false;
    //   }
    // }
    if (isNewPrjUpdate == false) {
      if (prjLat.isEmpty || prjLat == "0" || prjLat == "0.0") {
        emit(ErrorState(message: "Please enter Correct Latitude to proceed"));
        return false;
      }
      if (prjLong.isEmpty || prjLong == "0" || prjLong == "0.0") {
        emit(ErrorState(message: "Please enter Correct Longitude to proceed"));
        return false;
      }
    }

    if (prjAddress.trim().isEmpty) {
      emit(ErrorState(message: "Please enter Correct Project Address to proceed"));
      return false;
    }

    if (prjBuilderAdd.trim().isEmpty) {
      emit(ErrorState(message: "Please enter builder address"));
      return false;
    }

    if (selectedAreaUnit.isEmpty) {
      emit(ErrorState(message: "Please select area unit to proceed"));
      return false;
    }

    return true;
  }

  void saveProjectData({
    required ProjectEntity projectData,
    required ProjectCosting projectCostData,
    required String prjPhoneNo,
    required String prjMobileNo,
    required bool isNewPrjUpdate,
    required String prjLat,
    required String prjLong,
    required String prjAddress,
    required String prjBuilderAdd,
    required String prjBuilderPhoneNo,
    required String prjBuilderMobileNo,
    required String drinkingWater,
    required String modularKitchen,
    required int architectId,
    required String architectName,
    required String reraNo,
    required String cinNo,
    required String totalWings,
    required String marketableWings,
    required String totalSupplyUnits,
    required String landParcelSize,
    required Map<String, dynamic> selectedAreaUnit,
    required bool redevelopment,
    required int syncGlobalStatus,
    required List selectedSchemes,
    required bool isBooking,
    required String baseCost,
    required String agreementCost,
    required String allInclusiveCost,
  }) async {
    try {
      final userId = await StorageFunction.readIntData(StorageKey.userId);
      projectData.projectPhoneNo = prjPhoneNo;
      projectData.projectMobileNo = prjMobileNo;
      projectData.pxval = double.tryParse(prjLat);
      projectData.pyval = double.tryParse(prjLong);
      projectData.projectAddress = prjAddress;
      projectData.builderAddress = prjBuilderAdd;
      projectData.builderPhoneNo = prjBuilderPhoneNo;
      projectData.builderMobileNo = prjBuilderMobileNo;
      projectData.drinkingWater = drinkingWater;
      projectData.modularKitchenBrand = modularKitchen;
      projectData.architectId = architectId;
      projectData.architectName = architectName;
      projectData.isWrongPXValPYVal = 0;
      projectData.syncLocalStatus = 1;
      if (projectData.rejectId! > 0 && projectData.fixedBy == 0) {
        projectData.fixedBy = userId;
      }
      if (selectedAreaUnit.isNotEmpty) {
        projectData.landParcelSizeUnit = selectedAreaUnit["id"];
      }
      projectData.reraNo = reraNo;
      projectData.cinNo = cinNo;
      projectData.totalWings = int.tryParse(totalWings);
      projectData.marketableWings = int.tryParse(marketableWings);
      projectData.totalSupplyUnits = int.tryParse(totalSupplyUnits);
      projectData.landParcelSize = double.tryParse(landParcelSize);
      projectData.reDevelopment = redevelopment == true ? 1 : 0;
      projectCostData.baseCost = double.tryParse(baseCost);
      projectCostData.agreementCost = double.tryParse(agreementCost);
      projectCostData.allInclusiveCost = double.tryParse(allInclusiveCost);
      String prjCosting = jsonEncode(projectCostData.toJson());
      projectData.projectCosting = prjCosting;

      final response = await DBHelper.updateProject(projectData);
      // await ApiClient.updateProject(projectEntity: [projectData]);
      WorkManagerTaskRegister.updateProject(projectId: projectData.projectId!);
      if (response > 0) {
        emit(SuccessSate(message: "Data saved succesfully."));
      }
    } catch (e) {
      String erStr = e.toString().split(":").last;
      emit(ErrorState(message: erStr));
    }
  }
}
