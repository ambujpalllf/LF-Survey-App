import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lf_survey/constants/utils.dart';
import 'package:lf_survey/cubit/commercial/c_sub_project_edit/c_sub_prj_edit_state.dart';
import 'package:lf_survey/database/db_helper.dart';
import 'package:lf_survey/model/db_model/commercial/c_sub_project_entity.dart';
import 'package:lf_survey/services/work_manager_task_register.dart';

class CSubPrjEditCubit extends Cubit<CSubPrjEditState> {
  CSubPrjEditCubit() : super(InitState());

  void fetchData() async {
    try {
      final response = await Future.wait([
        DBHelper.cGetConstProgress(),
        DBHelper.cGetBuildingType(),
        DBHelper.cGetOperationModel(),
        DBHelper.cGetProjectStatus(),
      ]);
      if (response.isNotEmpty) {
        emit(
          LocalDbState(
            constProgress: response[0],
            buildingType: response[1],
            operationModel: response[2],
            projectStatus: response[3],
          ),
        );
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  Map<String, int> calculatePercentage({
    required String totalSupply,
    String? soldArea,
    String? unSoldArea,
    bool isSoldInput = false,
  }) {
    try {
      double ts = double.tryParse(totalSupply) ?? 0;
      double sa = double.tryParse(soldArea ?? "") ?? 0;
      double usa = double.tryParse(unSoldArea ?? "") ?? 0;

      if (ts == 0) {
        return {"soldPerc": 0, "unsoldPerc": 0, "soldArea": 0, "unsoldArea": 0};
      }

      // Decide based on which field user is typing
      if (isSoldInput) {
        if (sa > ts) {
          sa = ts;
          // emit(
          //   ErrorState(
          //     message: "Sold area cannot exceed total supply. It has been adjusted to match the total supply.",
          //   ),
          // );
        }
        usa = ts - sa;
      } else {
        if (usa > ts) {
          usa = ts;
          // emit(
          //   ErrorState(
          //     message: "Unsold area cannot exceed total supply. It has been adjusted to match the total supply.",
          //   ),
          // );
        }
        sa = ts - usa;
      }

      int soldAreaInt = sa.round();
      int unsoldAreaInt = usa.round();

      int soldPerc = ((sa * 100) / ts).round();
      int unsoldPerc = ((usa * 100) / ts).round();

      return {"soldPerc": soldPerc, "unsoldPerc": unsoldPerc, "soldArea": soldAreaInt, "unsoldArea": unsoldAreaInt};
    } catch (e) {
      emit(ErrorState(message: e.toString()));
      return {};
    }
  }

  Map<String, dynamic> calculateFromPercentage({
    required String totalSupply,
    String? soldPerc,
    String? unsoldPerc,
    required bool isSoldInput,
  }) {
    try {
      final double ts = double.tryParse(totalSupply) ?? 0;

      double sp = double.tryParse(soldPerc ?? "") ?? 0;
      double usp = double.tryParse(unsoldPerc ?? "") ?? 0;
      String? error;
      if (ts == 0) {
        return {"soldArea": 0, "unsoldArea": 0, "soldPerc": 0, "unsoldPerc": 0};
      }

      //  Clamp individual values to 100
      if (sp > 100) {
        // sp = 100;
        // emit(ErrorState(message: "Sold % cannot exceed 100."));
        error = "Sold % cannot exceed 100.";
      }

      if (usp > 100) {
        // usp = 100;
        error = "Unsold % cannot exceed 100.";
      }

      //  Decide which field user is editing
      if (isSoldInput) {
        if (sp > 100) sp = 100;
        usp = 100 - sp;
      } else {
        if (usp > 100) usp = 100;
        sp = 100 - usp;
      }

      final int spInt = sp.round();
      final int uspInt = usp.round();

      final int soldArea = ((sp * ts) / 100).round();
      final int unsoldArea = ((usp * ts) / 100).round();

      return {"soldArea": soldArea, "unsoldArea": unsoldArea, "soldPerc": spInt, "unsoldPerc": uspInt, "error": error};
    } catch (e) {
      emit(ErrorState(message: e.toString()));
      return {};
    }
  }

  void selectConstProgress({required String constProgress}) {
    if (constProgress.isNotEmpty) {
      emit(SelectConstProgressState());
    }
  }

  void selectProjStatus({
    String? projectStatusEr,
    String? floorSlabEr,
    String? marketingStartDateEr,
    String? marketingEndDateEr,
  }) {
    emit(
      ValidationState(
        projectStatusEr: null,
        floorSlabEr: floorSlabEr,
        marketingStartDateEr: marketingStartDateEr,
        marketingEndDateEr: marketingEndDateEr,
      ),
    );
  }

  bool fieldsValidation({
    String? constProgressStatus,
    String? projectStatus,
    String? floorSlab,
    required String marketingStartDate,
    required String marketingEndDate,
  }) {
    String? projectStatusEr;
    String? floorSlabEr;
    String? marketingStartDateEr;
    String? marketingEndDateEr;

    final constStatus = constProgressStatus?.toLowerCase().trim();
    final projStatus = projectStatus?.toLowerCase().trim();
    // Complete → Project must be Ready
    if (constStatus == "complete" && projStatus != "ready") {
      projectStatusEr = "Project Status can't be other than Ready when Construction Status is Complete";
    }

    // Floor Slab validation
    if (constStatus == "floor slab") {
      final slabValue = floorSlab?.trim();
      final slabInt = int.tryParse(slabValue ?? "");
      if (slabValue == null || slabValue.isEmpty || slabInt == null || slabInt < 1) {
        floorSlabEr = "Floor slab can't be empty or zero when Construction Status is floor slab";
      }
    }

    // Marketing Start Date
    if (marketingStartDate.trim().isEmpty) {
      marketingStartDateEr = "Please enter Marketing Start Date.";
    }

    // Marketing End Date
    if (marketingEndDate.trim().isEmpty) {
      marketingEndDateEr = "Please enter Marketing End Date.";
    }

    // Emit state
    emit(
      ValidationState(
        projectStatusEr: projectStatusEr,
        floorSlabEr: floorSlabEr,
        marketingStartDateEr: marketingStartDateEr,
        marketingEndDateEr: marketingEndDateEr,
      ),
    );

    // Return false if any error exists
    return projectStatusEr == null && floorSlabEr == null && marketingStartDateEr == null && marketingEndDateEr == null;
  }

  void selectDate() {
    emit(SelectDateState());
  }

  Future<void> updateData({
    required CSubProjectEntity subProjectData,
    String? basement,
    String? podium,
    String? service,
    String? habitable,
    String? constStartDate,
    String? constEndDate,
    required String marketingStartDate,
    required String marketingEndDate,
    String? constProgressStatus,
    String? floorSlab,
    int? buildingTypeId,
    int? operatingModelId,
    int? projectStatusId,
    String? projectStatus,
    String? totalSupply,
    String? soldAreaSQFT,
    String? unSoldAreaSQFT,
    String? leasedOccupiedArea,
    String? vacancyAreaSQFT,
    String? minimum,
    String? maximum,
    String? outBareshell,
    String? outWarmeshell,
    String? outFullyFurnished,
    String? leaseBareshell,
    String? leaseWarmeshell,
    String? leaseFullyFurnished,
    String? remarks,
  }) async {
    try {
      final isValid = fieldsValidation(
        floorSlab: floorSlab,
        marketingStartDate: marketingStartDate,
        marketingEndDate: marketingEndDate,
        projectStatus: projectStatus,
        constProgressStatus: constProgressStatus,
      );
      emit(LoadingState());
      if (!isValid) {
        emit(InitState());
        return;
      }

      int? parseInt(String? value) {
        if (value == null || value.trim().isEmpty) return null;
        return int.tryParse(value.trim());
      }

      String fconstStartDate = "${Utils.tryParseDate(constStartDate!)}";
      String fconstEndDate = "${Utils.tryParseDate(constEndDate!)}";
      String fmarketingStartDate = "${Utils.tryParseDate(marketingStartDate)}";
      String fmarketingEndDate = "${Utils.tryParseDate(marketingEndDate)}";
      subProjectData.storeyBasement = parseInt(basement);
      subProjectData.storeyPodium = parseInt(podium);
      subProjectData.storeyService = parseInt(service);
      subProjectData.storeyHabitable = parseInt(habitable);
      subProjectData.constStartDate = fconstStartDate;
      subProjectData.constEndDate = fconstEndDate;
      subProjectData.marketingStartDate = fmarketingStartDate;
      subProjectData.marketingEndDate = fmarketingEndDate;
      subProjectData.floorSlab = parseInt(floorSlab);
      subProjectData.buildingTypeId = buildingTypeId;
      subProjectData.operationModelId = operatingModelId;
      subProjectData.totalSupplySqft = parseInt(totalSupply);
      subProjectData.soldAreaSqft = parseInt(soldAreaSQFT);
      subProjectData.unsoldAreaSqft = parseInt(unSoldAreaSQFT);
      subProjectData.leasedOccupiedArea = parseInt(leasedOccupiedArea);
      subProjectData.vacancyArea = parseInt(vacancyAreaSQFT);
      subProjectData.minFloorplate = parseInt(minimum);
      subProjectData.maxFloorplate = parseInt(maximum);
      subProjectData.orBareshell = parseInt(outBareshell);
      subProjectData.orWarmshell = parseInt(outWarmeshell);
      subProjectData.orFullyFurnished = parseInt(outFullyFurnished);
      subProjectData.lrBareshell = parseInt(leaseBareshell);
      subProjectData.lrWarmshell = parseInt(leaseWarmeshell);
      subProjectData.lrFullyFurnished = parseInt(leaseFullyFurnished);
      subProjectData.projectStatusId = projectStatusId;
      subProjectData.remarks = remarks?.trim();
      subProjectData.syncGlobalStatus = 0;
      subProjectData.syncLocalStatus = 1;
      final response = await DBHelper.cUpdateSubPrj(subPrj: subProjectData);
      if (response > 0) {
        // await ApiClient.cUpdateSubPrj(subProjects: [subProjectData]);
        WorkManagerTaskRegister.cSyncUpdateSubProject(subProjectId: subProjectData.subProjectId ?? 0);
        emit(SuccessState(message: "Data saved successfully"));
      } else {
        emit(ErrorState(message: "Failed to update data. Please try again."));
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }
}
