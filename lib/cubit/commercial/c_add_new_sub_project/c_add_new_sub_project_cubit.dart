import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lf_survey/cubit/commercial/c_add_new_sub_project/c_add_new_sub_project_state.dart';
import 'package:lf_survey/database/db_helper.dart';
import 'package:lf_survey/model/db_model/commercial/c_new_sub_project_entity.dart';

class CAddNewSubProjectCubit extends Cubit<CAddNewSubProjectState> {
  CAddNewSubProjectCubit() : super(InitState());

  void fetchData() async {
    try {
      final response = await DBHelper.cGetConstProgress();
      if (response.isNotEmpty) {
        emit(LocalDbState(constProjgress: response));
      } else {
        emit(LocalDbState(constProjgress: []));
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void selectRateType({required String value}) {
    emit(RateTypeState(rateType: value));
  }

  void selectConstProgress({required dynamic value}) {
    emit(SelectConstState(constType: value));
  }

  void validateSingleField(String? value, String key, String label) {
    if (state is! ValidationState) return;
    final currentState = state as ValidationState;
    // Copy existing errors
    final Map<String, String> errors = Map.from(currentState.errors);
    bool isEmpty(String? value) => value == null || value.trim().isEmpty;
    if (isEmpty(value)) {
      errors[key] = "$label is required";
    } else {
      // Remove error if field becomes valid
      errors.remove(key);
    }
    emit(currentState.copyWith(errors: errors));
  }

  void validateDateField(DateTime? value, String key, String label) {
    if (state is! ValidationState) return;
    final currentState = state as ValidationState;
    // Copy existing errors
    final Map<String, String> errors = Map.from(currentState.errors);
    bool isEmpty(DateTime? value) => value == null;
    if (isEmpty(value)) {
      errors[key] = "$label is required";
    } else {
      // Remove error if field becomes valid
      errors.remove(key);
    }
    emit(currentState.copyWith(errors: errors));
  }

  bool validateFields({
    String? subProjectName,
    String? storey,
    String? scr,
    String? maintenance,
    String? floorPlate,
    String? leaseBarshell,
    String? leaseWarmshell,
    String? leaseFullyFurnished,
    String? outrightBarshell,
    String? outrightWarmshell,
    String? outrightFullyFurnished,
    DateTime? launchDate,
    DateTime? endDate,
    Map<String, dynamic>? selectedConstProgress,
    String? totalSupply,
    String? soldAreaSqft,
    String? soldAreaPerc,
    String? unsoldAreaSqft,
    String? unsoldAreaPerc,
    String? leaseAreaSqft,
    String? leasePercent,
    String? vacancyArea,
    String? vacancyPerc,
    String? reraNo,
    required bool isValidateFloorSlab,
    String? floorSlab,
  }) {
    final Map<String, String> errors = {};

    // Helper
    bool isEmpty(String? value) => value == null || value.trim().isEmpty;

    // Required text fields
    if (isEmpty(subProjectName)) {
      errors["subProjectName"] = "Sub-project name is required";
    }

    if (isEmpty(storey)) {
      errors["storey"] = "Storey is required";
    }

    if (isEmpty(scr)) {
      errors["scr"] = "SCR is required";
    }

    if (isEmpty(maintenance)) {
      errors["maintenance"] = "Maintenance cost is required";
    }

    if (isEmpty(floorPlate)) {
      errors["floorPlate"] = "Floor plate is required";
    }
    if (isEmpty(leaseBarshell)) {
      errors["leaseBarshell"] = "Bareshell is required";
    }
    if (isEmpty(leaseWarmshell)) {
      errors["leaseWarmshell"] = "Warmshell is required";
    }
    if (isEmpty(leaseFullyFurnished)) {
      errors["leaseFullyFurnished"] = "Fully furnished is required";
    }
    if (isEmpty(outrightBarshell)) {
      errors["outrightBarshell"] = "Bareshell is required";
    }
    if (isEmpty(outrightWarmshell)) {
      errors["outrightWarmshell"] = "Warmshell is required";
    }
    if (isEmpty(outrightFullyFurnished)) {
      errors["outrightFullyFurnished"] = "Fully furnished is required";
    }
    if (launchDate == null) {
      errors["launchDate"] = "Launch Date is required";
    }

    if (endDate == null) {
      errors["endDate"] = "End Date is required";
    }
    if (launchDate != null && endDate != null) {
      if (!endDate.isAfter(launchDate)) {
        errors["endDate"] = "End Date must be after launch date";
      }
    }
    if (selectedConstProgress == null || selectedConstProgress.isEmpty) {
      errors["constProgress"] = "Construction Progress is required";
    }
    if (isEmpty(totalSupply)) {
      errors["totalSupply"] = "Total supply is required";
    }
    if (isEmpty(soldAreaSqft)) {
      errors["soldAreaSqft"] = "Sold area is required";
    }
    if (isEmpty(soldAreaPerc)) {
      errors["soldAreaPerc"] = "Sold Percentage is required";
    }
    if (isEmpty(unsoldAreaSqft)) {
      errors["unsoldAreaSqft"] = "Unsold Area is required";
    }
    if (isEmpty(unsoldAreaPerc)) {
      errors["unsoldAreaPerc"] = "Unsold percentage is required";
    }
    if (isEmpty(leaseAreaSqft)) {
      errors["leaseAreaSqft"] = "Lease(occupaied) area is required";
    }
    if (isEmpty(leasePercent)) {
      errors["leasePercent"] = "Lease percentage is required";
    }
    if (isEmpty(vacancyArea)) {
      errors["vacancyArea"] = "Vacancy area is required";
    }
    if (isEmpty(vacancyPerc)) {
      errors["vacancyPerc"] = "Vacancy percentage is required";
    }
    if (isEmpty(reraNo)) {
      errors["reraNo"] = "Rera number is required";
    }
    if (isValidateFloorSlab == true && isEmpty(floorSlab)) {
      errors["floorSlab"] = "Floor Slab is required";
    }
    emit(ValidationState(errors: errors));
    return errors.isEmpty;
  }

  Map<String, dynamic> calculateFromPercentage({
    required String totalSupply,
    String? soldPerc,
    String? unsoldPerc,
    String? soldEr,
    String? unsoldEr,
    String? soldErKey,
    String? unsoldErKey,
    required bool isSoldInput,
  }) {
    try {
      // if (state is! ValidationState) return {};
      final double ts = double.tryParse(totalSupply) ?? 0.0;

      double sp = double.tryParse(soldPerc ?? "") ?? 0.0;
      double usp = double.tryParse(unsoldPerc ?? "") ?? 0.0;
      String? error;
      if (ts == 0) {
        return {"soldArea": 0.0, "unsoldArea": 0.0, "soldPerc": 0, "unsoldPerc": 0};
      }

      //  Clamp individual values to 100
      if (sp > 100) {
        sp = 100;
        emit(ValidationState(errors: {"$soldErKey": "$soldEr % cannot exceed 100."}));
        // error = "Sold % cannot exceed 100.";
      }

      if (usp > 100) {
        usp = 100;
        // error = "Unsold % cannot exceed 100.";
        emit(ValidationState(errors: {"$unsoldErKey": "$unsoldEr % cannot exceed 100."}));
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

  void submitData({
    String? projectId,
    int? prjIdLF,
    String? subProjectName,
    String? storey,
    String? scr,
    String? maintenance,
    String? floorPlate,
    String? selectedArea,
    String? leaseBareshell,
    String? leaseWarmshell,
    String? leaseFullyFurnished,
    String? outrightBarshell,
    String? outrightWarmshell,
    String? outrightFullyFurnished,
    DateTime? launchDate,
    DateTime? endDate,
    Map<String, dynamic>? selectedConstProgress,
    String? floorSlab,
    String? totalSupply,
    String? soldAreaSqft,
    String? soldAreaPerc,
    String? unsoldAreaSqft,
    String? unsoldAreaPerc,
    String? leaseAreaSqft,
    String? leasePercent,
    String? vacancyArea,
    String? vacancyPerc,
    String? reraNo,
    String? remarks,
    String? dos,
    required bool isValidateFloorSlab,
  }) async {
    try {
      bool isValidate = validateFields(
        subProjectName: subProjectName,
        storey: storey,
        scr: scr,
        maintenance: maintenance,
        floorPlate: floorPlate,
        leaseBarshell: leaseBareshell,
        leaseWarmshell: leaseWarmshell,
        leaseFullyFurnished: leaseFullyFurnished,
        outrightBarshell: outrightBarshell,
        outrightWarmshell: outrightWarmshell,
        outrightFullyFurnished: outrightFullyFurnished,
        launchDate: launchDate,
        endDate: endDate,
        selectedConstProgress: selectedConstProgress,
        totalSupply: totalSupply,
        soldAreaSqft: soldAreaSqft,
        soldAreaPerc: soldAreaPerc,
        unsoldAreaSqft: unsoldAreaSqft,
        unsoldAreaPerc: unsoldAreaPerc,
        leaseAreaSqft: leaseAreaSqft,
        leasePercent: leasePercent,
        vacancyArea: vacancyArea,
        vacancyPerc: vacancyPerc,
        reraNo: reraNo,
        isValidateFloorSlab: isValidateFloorSlab,
        floorSlab: floorSlab,
      );
      if (!isValidate) return;
      DateTime currentTime = DateTime.now();
      String timeStamp = DateFormat("dd-MMM-yyyy'T'HH:mm:ss").format(currentTime);
      String subPrjId = "";
      if (prjIdLF != 0) {
        subPrjId = "${prjIdLF}_${currentTime.millisecondsSinceEpoch}";
      } else {
        subPrjId = "${projectId}_${currentTime.microsecondsSinceEpoch}";
      }
      final subProjectEntity = CNewSubProjectEntity(
        subPrjId: subPrjId,
        prjId: projectId,
        prjIdLF: prjIdLF,
        subPrjName: subProjectName,
        storey: int.tryParse(storey ?? "") ?? 0,
        scr: int.tryParse(scr ?? "") ?? 0,
        maintenance: double.tryParse(maintenance ?? ""),
        floorPlate: int.tryParse(floorPlate ?? ""),
        carpetOrSaleable: selectedArea,
        leaseBareshell: double.tryParse(leaseBareshell ?? "") ?? 0.0,
        leaseWarmshell: double.tryParse(leaseWarmshell ?? ""),
        leaseFullyFurnished: double.tryParse(leaseFullyFurnished ?? ""),
        outrightBareshell: double.tryParse(outrightBarshell ?? ""),
        outrightWarmshell: double.tryParse(outrightWarmshell ?? ""),
        outrightFullyFurnished: double.tryParse(outrightFullyFurnished ?? ""),
        launchDate: launchDate != null ? DateFormat("dd MMM yyyy").format(launchDate) : null,
        endDate: endDate != null ? DateFormat("dd MMM yyyy").format(endDate) : null,
        constructionStageId: selectedConstProgress?["constProgressId"],
        floorSlab: int.tryParse(floorSlab ?? ""),
        totalSupply: double.tryParse(totalSupply ?? ""),
        soldPercent: double.tryParse(soldAreaPerc ?? ""),
        unsoldPercent: double.tryParse(unsoldAreaPerc ?? ""),
        leasePercent: double.tryParse(leasePercent ?? ""),
        vacantPercent: double.tryParse(vacancyPerc ?? ""),
        reraNo: reraNo,
        remark: remarks,
        dos: dos ?? "",
        mobileCreatedDatetime: timeStamp,
        localSyncStatus: 1,
        globalSyncStatus: 0,
      );

      final response = await DBHelper.cInsertNewSubProject(subproject: subProjectEntity);

      if (response > 0) {
        emit(SuccessState(message: "Your data has been saved successfully."));
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }
}
