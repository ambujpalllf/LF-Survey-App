import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lf_survey/cubit/construction_monitering/cm_form/cm_form_state.dart';
import 'package:lf_survey/database/db_helper.dart';
import 'package:lf_survey/model/construction_monitoring/cm_survey_model.dart';
import 'package:lf_survey/services/work_manager_task_register.dart';

class CMFormCubit extends Cubit<CMFormState> {
  CMFormCubit() : super(InitState());

  bool formValidation({
    required String floors,
    required String slabs,
    required String plinth,
    required String rCC,
    required String uptoSlab,
    required String plasteringIn,
    required String plasteringExternal,
    required String flooring,
    required String electric,
    required String plumbing,
    required String woodWork,
    required String painting,
    required String totalUnits,
    required String soldUnits,
    required String soldPerc,
    required String unsoldUnits,
    required String unsoldPerc,
    required String saleableRate,
    required String carpetRate,
    required bool isSaleable,
    required bool isCarpet,
  }) {
    String? floorsErMsg;
    String? slabErMsg;
    String? plinthErMsg;
    String? rccErMsg;
    String? uptoSlabErMsg;
    String? pInternalErMsg;
    String? pExternalErMsg;
    String? flooringErMsg;
    String? electricErMsg;
    String? plumbingErMsg;
    String? woodWorkErMsg;
    String? paintingErMsg;

    String? totalUnitsErMsg;
    String? soldUnitsErMsg;
    String? soldPercErMsg;
    String? unsoldErMsg;
    String? unsoldPercErMsg;
    String? saleableErMsg;
    String? carpetErMsg;

    bool isPlinthComplete = false;

    final slabsValue = int.tryParse(slabs) ?? 0;

    /// BASIC REQUIRED VALIDATION
    if (floors.isEmpty) floorsErMsg = "Number of floors is required";
    if (slabs.isEmpty) slabErMsg = "Number of slabs is required";
    // It can be required later
    // if (totalUnits.isEmpty) totalUnitsErMsg = "Total units is required";
    // if (soldUnits.isEmpty) soldUnitsErMsg = "Total sold units is required";
    // if (soldPerc.isEmpty) soldPercErMsg = "Sold units percentage is required";
    // if (unsoldUnits.isEmpty) unsoldErMsg = "Total unsold units is required";
    // if (unsoldPerc.isEmpty) unsoldPercErMsg = "Unsold units percentage is required";
    // if (isSaleable && saleableRate.isEmpty) saleableErMsg = "Saleable is required";
    // if (isCarpet && carpetRate.isEmpty) carpetErMsg = "Carpet is required";
    // if (saleableRate.isEmpty && carpetRate.isEmpty) {
    //   saleableErMsg = "Saleable or Carpet is required";
    // }

    if (totalUnits.isNotEmpty) {
      final totalValue = int.tryParse(totalUnits) ?? 0;
      final soldValue = int.tryParse(soldUnits) ?? 0;
      final unsoldValue = int.tryParse(unsoldUnits) ?? 0;

      if (soldValue > totalValue) {
        soldUnitsErMsg = "Sold units cannot be greater than total units";
      }

      if (unsoldValue > totalValue) {
        unsoldErMsg = "Unsold units cannot be greater than total units";
      }
    }

    if (totalUnits.isNotEmpty) {
      final soldPerValue = double.tryParse(soldPerc) ?? 0.0;
      final unsoldPerValue = double.tryParse(unsoldPerc) ?? 0.0;

      if (soldPerValue > 100) {
        soldPercErMsg = "Sold units percentage cannot be greater than 100";
      }

      if (unsoldPerValue > 100) {
        unsoldPercErMsg = "Unsold units percentage cannot be greater than 100";
      }
    }

    /// PLINTH VALIDATION
    if (plinth.isEmpty) {
      plinthErMsg = "Plinth is required";
    } else {
      final plinthValue = double.tryParse(plinth) ?? 0;

      if (plinthValue > 100) {
        plinthErMsg = "You cannot enter above 100";
      } else if (plinthValue == 100) {
        isPlinthComplete = true;
      }
    }

    /// SLAB BASED VALIDATION
    if (isPlinthComplete) {
      int? rccValue = int.tryParse(rCC);
      int? uptoSlabValue = int.tryParse(uptoSlab);
      int? internalValue = int.tryParse(plasteringIn);
      int? externalValue = int.tryParse(plasteringExternal);
      int? flooringValue = int.tryParse(flooring);
      int? electricValue = int.tryParse(electric);
      int? plumbingValue = int.tryParse(plumbing);
      int? woodValue = int.tryParse(woodWork);
      int? paintingValue = int.tryParse(painting);

      if (rCC.isEmpty) {
        rccErMsg = "RCC is required";
      } else if ((rccValue ?? 0) > slabsValue) {
        rccErMsg = "RCC cannot exceed slabs";
      }

      if (uptoSlab.isEmpty) {
        uptoSlabErMsg = "Up to slab is required";
      } else if ((uptoSlabValue ?? 0) > slabsValue) {
        uptoSlabErMsg = "Up to slab cannot exceed slabs";
      }

      if (plasteringIn.isEmpty) {
        pInternalErMsg = "Internal plastering is required";
      } else if ((internalValue ?? 0) > slabsValue) {
        pInternalErMsg = "Internal plastering cannot exceed slabs";
      }

      if (plasteringExternal.isEmpty) {
        pExternalErMsg = "External plastering is required";
      } else if ((externalValue ?? 0) > slabsValue) {
        pExternalErMsg = "External plastering cannot exceed slabs";
      }

      if (flooring.isEmpty) {
        flooringErMsg = "Flooring is required";
      } else if ((flooringValue ?? 0) > slabsValue) {
        flooringErMsg = "Flooring cannot exceed slabs";
      }

      if (electric.isEmpty) {
        electricErMsg = "Electrical work is required";
      } else if ((electricValue ?? 0) > slabsValue) {
        electricErMsg = "Electrical work cannot exceed slabs";
      }

      if (plumbing.isEmpty) {
        plumbingErMsg = "Plumbing is required";
      } else if ((plumbingValue ?? 0) > slabsValue) {
        plumbingErMsg = "Plumbing cannot exceed slabs";
      }

      if (woodWork.isEmpty) {
        woodWorkErMsg = "Wood work is required";
      } else if ((woodValue ?? 0) > slabsValue) {
        woodWorkErMsg = "Wood work cannot exceed slabs";
      }

      if (painting.isEmpty) {
        paintingErMsg = "Painting is required";
      } else if ((paintingValue ?? 0) > slabsValue) {
        paintingErMsg = "Painting cannot exceed slabs";
      }
    }

    /// EMIT VALIDATION STATE
    emit(
      ValidationState(
        floorsErMsg: floorsErMsg,
        slabErMsg: slabErMsg,
        plinthErMsg: plinthErMsg,
        rccErMsg: rccErMsg,
        uptoSlabErMsg: uptoSlabErMsg,
        pInternalErMsg: pInternalErMsg,
        pExternalErMsg: pExternalErMsg,
        flooringErMsg: flooringErMsg,
        electricErMsg: electricErMsg,
        plumbingErMsg: plumbingErMsg,
        woodWorkErMsg: woodWorkErMsg,
        paintingErMsg: paintingErMsg,
        totalUnitsErMsg: totalUnitsErMsg,
        soldUnitsErMsg: soldUnitsErMsg,
        soldPercErMsg: soldPercErMsg,
        unsoldErMsg: unsoldErMsg,
        unsoldPercErMsg: unsoldPercErMsg,
        isPlinthComplete: isPlinthComplete,
        saleableErMsg: saleableErMsg,
        carpetErMsg: carpetErMsg,
      ),
    );

    /// CHECK IF ANY ERROR EXISTS
    final hasError = [
      floorsErMsg,
      slabErMsg,
      plinthErMsg,
      rccErMsg,
      uptoSlabErMsg,
      pInternalErMsg,
      pExternalErMsg,
      flooringErMsg,
      electricErMsg,
      plumbingErMsg,
      woodWorkErMsg,
      paintingErMsg,
      totalUnitsErMsg,
      soldUnitsErMsg,
      soldPercErMsg,
      unsoldErMsg,
      unsoldPercErMsg,
      saleableErMsg,
    ].any((msg) => msg != null);

    return !hasError;
  }

  void submit({
    required int projectId,
    int? wingId,
    int? buildingId,
    String? localWingId,
    String? localBuildingId,
    required String floors,
    required String slabs,
    required String plinth,
    required String rCC,
    required String uptoSlab,
    required String plasteringIn,
    required String plasteringExternal,
    required String flooring,
    required String electric,
    required String plumbing,
    required String woodWork,
    required String painting,
    required String remarks,
    required String totalUnits,
    required String soldUnits,
    required String soldPerc,
    required String unsoldUnits,
    required String unsoldPerc,
    required String saleableRate,
    required String carpetRate,
    required bool isSaleable,
    required bool isCarpet,
    CmSurveyModel? surveyData,
  }) async {
    if (!formValidation(
      floors: floors,
      slabs: slabs,
      plinth: plinth,
      rCC: rCC,
      uptoSlab: uptoSlab,
      plasteringIn: plasteringIn,
      plasteringExternal: plasteringExternal,
      flooring: flooring,
      electric: electric,
      plumbing: plumbing,
      woodWork: woodWork,
      painting: painting,
      totalUnits: totalUnits,
      soldUnits: soldUnits,
      soldPerc: soldPerc,
      unsoldUnits: unsoldUnits,
      unsoldPerc: unsoldPerc,
      saleableRate: saleableRate,
      carpetRate: carpetRate,
      isSaleable: isSaleable,
      isCarpet: isCarpet,
    )) {
      return;
    }
    if (surveyData != null &&
        !hasChanges(
          oldData: surveyData,
          floors: floors,
          slabs: slabs,
          plinth: plinth,
          rCC: rCC,
          uptoSlab: uptoSlab,
          plasteringIn: plasteringIn,
          plasteringExternal: plasteringExternal,
          flooring: flooring,
          electric: electric,
          plumbing: plumbing,
          woodWork: woodWork,
          painting: painting,
          remarks: remarks,
          totalUnits: totalUnits,
          soldUnits: soldUnits,
          soldPerc: soldPerc,
          unsoldUnits: unsoldUnits,
          unsoldPerc: unsoldPerc,
          saleableRate: saleableRate,
          carpetRate: carpetRate,
        )) {
      emit(ErrorState(message: "No changes detected. Please modify at least one field before saving."));
      return;
    }
    try {
      emit(LoadingState());
      String surveyDate = DateTime.now().toIso8601String();
      final CmSurveyModel surveyData = CmSurveyModel(
        projectId: projectId,
        buildingId: buildingId,
        wingId: wingId,
        localBuildingId: localBuildingId,
        localWingId: localWingId,
        noOfFloors: floors,
        survayDate: surveyDate,
        plinth: plinth,
        noOfSlabsCompleted: rCC,
        brickWork: uptoSlab,
        plasteringInternal: plasteringIn,
        plasteringExternal: plasteringExternal,
        flooring: flooring,
        electrict: electric,
        plumbing: plumbing,
        woodWork: woodWork,
        painting: painting,
        localSync: 1,
        globalSync: 0,
        remarks: remarks,
        totalUnits: totalUnits.isEmpty ? 0 : int.parse(totalUnits),
        soldUnits: soldUnits.isEmpty ? 0 : int.parse(soldUnits),
        soldPercentage: soldPerc.isEmpty ? 0.0 : double.parse(soldPerc),
        unsoldUnits: unsoldUnits.isEmpty ? 0 : int.parse(unsoldUnits),
        unsoldPercentage: unsoldPerc.isEmpty ? 0.0 : double.parse(unsoldPerc),
        saleableRate: saleableRate.isEmpty ? 0 : int.parse(saleableRate),
        carpetRate: carpetRate.isEmpty ? 0 : int.parse(carpetRate),
      );
      final int insertId = await DBHelper.cmInsertWingSurvey(surveyData: surveyData);

      if (insertId > 0) {
        emit(SuccessState(message: "Survey saved successfully"));
        WorkManagerTaskRegister.syncCmSurvey();
      } else {
        emit(ErrorState(message: "Failed to save survey locally"));
      }
    } catch (e) {
      String erMsg = e.toString().split(":").last;
      emit(ErrorState(message: erMsg));
    }
  }

  bool hasChanges({
    required CmSurveyModel oldData,
    required String floors,
    required String slabs,
    required String plinth,
    required String rCC,
    required String uptoSlab,
    required String plasteringIn,
    required String plasteringExternal,
    required String flooring,
    required String electric,
    required String plumbing,
    required String woodWork,
    required String painting,
    required String remarks,
    required String totalUnits,
    required String soldUnits,
    required String soldPerc,
    required String unsoldUnits,
    required String unsoldPerc,
    required String saleableRate,
    required String carpetRate,
  }) {
    return oldData.noOfFloors != floors ||
        oldData.plinth != plinth ||
        oldData.noOfSlabsCompleted != rCC ||
        oldData.brickWork != uptoSlab ||
        oldData.plasteringInternal != plasteringIn ||
        oldData.plasteringExternal != plasteringExternal ||
        oldData.flooring != flooring ||
        oldData.electrict != electric ||
        oldData.plumbing != plumbing ||
        oldData.woodWork != woodWork ||
        oldData.painting != painting ||
        oldData.remarks != remarks ||
        oldData.totalUnits.toString() != totalUnits ||
        oldData.soldUnits.toString() != soldUnits ||
        oldData.soldPercentage.toString() != soldPerc ||
        oldData.unsoldUnits.toString() != unsoldUnits ||
        oldData.unsoldPercentage.toString() != unsoldPerc ||
        oldData.saleableRate.toString() != saleableRate ||
        oldData.carpetRate.toString() != carpetRate;
  }

  void changeRateValue({String carpetValue = "", String saleableValue = ""}) {
    final hasCarpet = carpetValue.trim().isNotEmpty;
    final hasSaleable = saleableValue.trim().isNotEmpty;

    if (!hasCarpet && !hasSaleable) {
      emit(RateState(isSaleable: false, isCarpet: false));
    } else if (hasSaleable) {
      emit(RateState(isSaleable: false, isCarpet: true));
    } else if (hasCarpet) {
      emit(RateState(isSaleable: true, isCarpet: false));
    }
  }
}
