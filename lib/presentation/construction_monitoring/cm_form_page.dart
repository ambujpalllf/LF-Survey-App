import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_dimens.dart';
import 'package:lf_survey/constants/app_text_style.dart';
import 'package:lf_survey/constants/snackbar_helper.dart';
import 'package:lf_survey/constants/utils.dart';
import 'package:lf_survey/cubit/construction_monitering/cm_form/cm_form_state.dart';
import 'package:lf_survey/cubit/construction_monitering/cm_form/cm_form_cubit.dart';
import 'package:lf_survey/model/construction_monitoring/cm_survey_model.dart';
import 'package:lf_survey/model/construction_monitoring/cm_wing_response.dart';
import 'package:lf_survey/widgets/custom_app_bar.dart';
import 'package:lf_survey/widgets/custom_elevated_btn.dart';
import 'package:lf_survey/widgets/custom_textform_field.dart';

class CMFormPage extends StatefulWidget {
  final WingData wingData;
  final CmSurveyModel? surveyData;
  final bool isViewOnly;
  const CMFormPage({super.key, required this.wingData, this.surveyData, this.isViewOnly = false});

  @override
  State<CMFormPage> createState() => _CMFormPageState();
}

class _CMFormPageState extends State<CMFormPage> {
  bool isViewOnly = false;
  bool isSaleableReadOnly = false;
  bool isCarpetReadOnly = false;
  TextEditingController floorsC = TextEditingController();
  TextEditingController slabsC = TextEditingController();
  TextEditingController plinthC = TextEditingController();
  TextEditingController rccC = TextEditingController();
  TextEditingController uptoSlabC = TextEditingController();
  TextEditingController plasteringInternalC = TextEditingController();
  TextEditingController plasteringExternalC = TextEditingController();
  TextEditingController flooringC = TextEditingController();
  TextEditingController electricC = TextEditingController();
  TextEditingController plumbingC = TextEditingController();
  TextEditingController woodWorkC = TextEditingController();
  TextEditingController paintingC = TextEditingController();
  TextEditingController remarksC = TextEditingController();

  TextEditingController totalUnitsC = TextEditingController();
  TextEditingController totalSoldC = TextEditingController();
  TextEditingController totalSoldPercentageC = TextEditingController();
  TextEditingController totalUnsoldC = TextEditingController();
  TextEditingController totalUnsoldPercentageC = TextEditingController();
  TextEditingController saleableRateC = TextEditingController();
  TextEditingController carpetRateC = TextEditingController();
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
  String? wooWorkErMsg;
  String? paintingErMsg;
  String? totalUnitsErMsg;
  String? soldUnitsErMsg;
  String? soldPercErMsg;
  String? unsoldErMsg;
  String? unsoldPercErMsg;
  String? saleableErMsg;
  String? carpetErMsg;

  bool isPlinthComplete = false;

  @override
  void initState() {
    super.initState();
    isViewOnly = widget.isViewOnly;
    prefillFields();
  }

  void prefillFields() {
    if (widget.surveyData != null) {
      floorsC.text = widget.surveyData!.noOfFloors ?? "";
      int floors = int.parse(floorsC.text);
      slabsC.text = (floors + 1).toString();
      plinthC.text = widget.surveyData!.plinth ?? "";
      int? plinthValue = int.tryParse(plinthC.text);
      if (plinthValue != null && plinthValue < 100) {
        isPlinthComplete = false;
      } else {
        isPlinthComplete = true;
      }
      totalUnitsC.text = widget.surveyData!.totalUnits.toString();
      totalSoldC.text = widget.surveyData!.soldUnits.toString();
      totalUnsoldC.text = widget.surveyData!.unsoldUnits.toString();
      totalSoldPercentageC.text = widget.surveyData!.soldPercentage.toString();
      totalUnsoldPercentageC.text = widget.surveyData!.unsoldPercentage.toString();
      carpetRateC.text = widget.surveyData!.carpetRate.toString();
      saleableRateC.text = widget.surveyData!.saleableRate.toString();
    }
    if (isViewOnly && widget.surveyData != null) {
      rccC.text = widget.surveyData!.flooring ?? "";
      uptoSlabC.text = widget.surveyData!.brickWork ?? "";
      plasteringInternalC.text = widget.surveyData!.plasteringInternal ?? "";
      plasteringExternalC.text = widget.surveyData!.plasteringExternal ?? "";
      flooringC.text = widget.surveyData!.flooring ?? "";
      electricC.text = widget.surveyData!.electrict ?? "";
      plumbingC.text = widget.surveyData!.plumbing ?? "";
      woodWorkC.text = widget.surveyData!.woodWork ?? "";
      paintingC.text = widget.surveyData!.painting ?? "";
      remarksC.text = widget.surveyData!.remarks ?? "";
    }
  }

  @override
  void dispose() {
    super.dispose();
    floorsC.dispose();
    slabsC.dispose();
    plinthC.dispose();
    rccC.dispose();
    uptoSlabC.dispose();
    plasteringInternalC.dispose();
    plasteringExternalC.dispose();
    flooringC.dispose();
    electricC.dispose();
    plumbingC.dispose();
    woodWorkC.dispose();
    paintingC.dispose();
  }

  bool _isUpdating = false;

  void calculateUnits({required String field}) {
    if (_isUpdating) return;

    int? total = int.tryParse(totalUnitsC.text.trim());
    int? sold = int.tryParse(totalSoldC.text.trim());
    int? unsold = int.tryParse(totalUnsoldC.text.trim());
    double? soldPer = double.tryParse(totalSoldPercentageC.text.trim());
    double? unsoldPer = double.tryParse(totalUnsoldPercentageC.text.trim());

    if (total == null || total <= 0) return;

    int finalSold = sold ?? 0;
    int finalUnsold = unsold ?? 0;

    _isUpdating = true;

    switch (field) {
      /// USER CHANGED TOTAL
      case "total":
        if (sold != null) {
          finalSold = sold.clamp(0, total);
          finalUnsold = total - finalSold;
        } else if (unsold != null) {
          finalUnsold = unsold.clamp(0, total);
          finalSold = total - finalUnsold;
        }
        break;

      /// USER CHANGED SOLD
      case "sold":
        if (sold == null) break;
        finalSold = sold.clamp(0, total);
        finalUnsold = total - finalSold;
        break;

      /// USER CHANGED UNSOLD
      case "unsold":
        if (unsold == null) break;
        finalUnsold = unsold.clamp(0, total);
        finalSold = total - finalUnsold;
        break;

      /// USER CHANGED SOLD %
      case "soldPer":
        if (soldPer == null) break;
        finalSold = ((soldPer / 100) * total).round();
        finalUnsold = total - finalSold;
        break;

      /// USER CHANGED UNSOLD %
      case "unsoldPer":
        if (unsoldPer == null) break;
        finalUnsold = ((unsoldPer / 100) * total).round();
        finalSold = total - finalUnsold;
        break;
    }

    double finalSoldPer = (finalSold / total) * 100;
    double finalUnsoldPer = (finalUnsold / total) * 100;

    if (field != "sold") {
      totalSoldC.text = finalSold.toString();
    }

    if (field != "unsold") {
      totalUnsoldC.text = finalUnsold.toString();
    }

    if (field != "soldPer") {
      totalSoldPercentageC.text = finalSoldPer.toStringAsFixed(2);
    }

    if (field != "unsoldPer") {
      totalUnsoldPercentageC.text = finalUnsoldPer.toStringAsFixed(2);
    }

    _isUpdating = false;
  }

  @override
  Widget build(BuildContext context) {
    final CMFormCubit cmFormCubit = context.read<CMFormCubit>();
    return Scaffold(
      appBar: CustomAppBar(title: "Construction Monitoring Form"),
      body: BlocListener<CMFormCubit, CMFormState>(
        listener: (context, state) {
          if (state is ValidationState) {
            floorsErMsg = state.floorsErMsg;
            slabErMsg = state.slabErMsg;
            plinthErMsg = state.plinthErMsg;
            rccErMsg = state.rccErMsg;
            uptoSlabErMsg = state.uptoSlabErMsg;
            pInternalErMsg = state.pInternalErMsg;
            pExternalErMsg = state.pExternalErMsg;
            flooringErMsg = state.flooringErMsg;
            electricErMsg = state.electricErMsg;
            plumbingErMsg = state.plumbingErMsg;
            wooWorkErMsg = state.woodWorkErMsg;
            paintingErMsg = state.paintingErMsg;
            isPlinthComplete = state.isPlinthComplete;
            totalUnitsErMsg = state.totalUnitsErMsg;
            soldUnitsErMsg = state.soldUnitsErMsg;
            soldPercErMsg = state.soldPercErMsg;
            unsoldErMsg = state.unsoldErMsg;
            unsoldPercErMsg = state.unsoldPercErMsg;
            saleableErMsg = state.saleableErMsg;
            carpetErMsg = state.carpetErMsg;
          } else if (state is SuccessState) {
            CustomSnackHelper.customToastMsg(
              context: context,
              message: state.message,
              bgColor: AppColors.white,
              textColor: AppColors.black,
            );
            context.pop();
          } else if (state is ErrorState) {
            CustomSnackHelper.customToastMsg(
              context: context,
              message: state.message,
              bgColor: AppColors.white,
              textColor: AppColors.black,
            );
          }
        },
        child: SafeArea(
          child: Padding(
            padding: AppDimens.hvPadding,
            child: SingleChildScrollView(
              child: BlocBuilder<CMFormCubit, CMFormState>(
                builder: (context, state) {
                  return Stack(
                    children: [
                      IgnorePointer(
                        ignoring: isViewOnly,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 12.0,
                          children: [
                            const SizedBox(),
                            RichText(
                              text: TextSpan(
                                text: "Date Of Survey : ",
                                style: AppTextStyle.ts14MB,
                                children: [
                                  TextSpan(
                                    text: DateFormat("dd MMM yyyy").format(DateTime.now()),
                                    style: AppTextStyle.ts14RB,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(),
                            CustomTextformField(
                              controller: floorsC,
                              labelText: "Number of Floors",
                              keyboardType: TextInputType.number,
                              maxLength: 3,
                              counterText: "",
                              errorText: floorsErMsg,
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  int floors = int.parse(value);
                                  slabsC.text = (floors + 1).toString();
                                } else {
                                  slabsC.clear();
                                }
                                cmFormCubit.formValidation(
                                  floors: floorsC.text,
                                  slabs: slabsC.text,
                                  plinth: plinthC.text,
                                  rCC: rccC.text,
                                  uptoSlab: uptoSlabC.text,
                                  plasteringIn: plasteringInternalC.text,
                                  plasteringExternal: plasteringExternalC.text,
                                  flooring: flooringC.text,
                                  electric: electricC.text,
                                  plumbing: plumbingC.text,
                                  woodWork: woodWorkC.text,
                                  painting: paintingC.text,
                                  totalUnits: totalUnitsC.text,
                                  soldUnits: totalSoldC.text,
                                  soldPerc: totalSoldPercentageC.text,
                                  unsoldUnits: totalUnsoldC.text,
                                  unsoldPerc: totalUnsoldPercentageC.text,
                                  saleableRate: saleableRateC.text,
                                  carpetRate: carpetRateC.text,
                                  isSaleable: isSaleableReadOnly,
                                  isCarpet: isCarpetReadOnly,
                                );
                              },
                            ),
                            CustomTextformField(
                              readOnly: true,
                              controller: slabsC,
                              filled: true,
                              textStyle: TextStyle(color: Colors.grey.shade500),
                              fillColor: Colors.grey.shade100,
                              labelText: "Number of Slabs",
                              keyboardType: TextInputType.number,
                              maxLength: 3,
                              counterText: "",
                              errorText: slabErMsg,
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                            ),

                            const SizedBox(height: 10),
                            Text("Sales & Pricing :", style: AppTextStyle.ts18MB),
                            const SizedBox(),
                            CustomTextformField(
                              controller: totalUnitsC,
                              labelText: "Total Units",
                              keyboardType: TextInputType.number,
                              maxLength: 3,
                              counterText: "",
                              errorText: totalUnitsErMsg,
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                              onChanged: (value) {
                                calculateUnits(field: "total");
                                cmFormCubit.formValidation(
                                  floors: floorsC.text,
                                  slabs: slabsC.text,
                                  plinth: plinthC.text,
                                  rCC: rccC.text,
                                  uptoSlab: uptoSlabC.text,
                                  plasteringIn: plasteringInternalC.text,
                                  plasteringExternal: plasteringExternalC.text,
                                  flooring: flooringC.text,
                                  electric: electricC.text,
                                  plumbing: plumbingC.text,
                                  woodWork: woodWorkC.text,
                                  painting: paintingC.text,
                                  totalUnits: totalUnitsC.text,
                                  soldUnits: totalSoldC.text,
                                  soldPerc: totalSoldPercentageC.text,
                                  unsoldUnits: totalUnsoldC.text,
                                  unsoldPerc: totalUnsoldPercentageC.text,
                                  saleableRate: saleableRateC.text,
                                  carpetRate: carpetRateC.text,
                                  isSaleable: isSaleableReadOnly,
                                  isCarpet: isCarpetReadOnly,
                                );
                              },
                            ),
                            Row(
                              spacing: 16.0,
                              children: [
                                Flexible(
                                  child: CustomTextformField(
                                    controller: totalSoldC,
                                    labelText: "Total Sold Units",
                                    keyboardType: TextInputType.number,
                                    maxLength: 3,
                                    counterText: "",
                                    errorText: soldUnitsErMsg,
                                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                                    onChanged: (value) {
                                      calculateUnits(field: "sold");
                                      cmFormCubit.formValidation(
                                        floors: floorsC.text,
                                        slabs: slabsC.text,
                                        plinth: plinthC.text,
                                        rCC: rccC.text,
                                        uptoSlab: uptoSlabC.text,
                                        plasteringIn: plasteringInternalC.text,
                                        plasteringExternal: plasteringExternalC.text,
                                        flooring: flooringC.text,
                                        electric: electricC.text,
                                        plumbing: plumbingC.text,
                                        woodWork: woodWorkC.text,
                                        painting: paintingC.text,
                                        totalUnits: totalUnitsC.text,
                                        soldUnits: totalSoldC.text,
                                        soldPerc: totalSoldPercentageC.text,
                                        unsoldUnits: totalUnsoldC.text,
                                        unsoldPerc: totalUnsoldPercentageC.text,
                                        saleableRate: saleableRateC.text,
                                        carpetRate: carpetRateC.text,
                                        isSaleable: isSaleableReadOnly,
                                        isCarpet: isCarpetReadOnly,
                                      );
                                    },
                                  ),
                                ),
                                Flexible(
                                  child: CustomTextformField(
                                    controller: totalSoldPercentageC,
                                    labelText: "Total Sold Units Percentage",
                                    keyboardType: TextInputType.number,
                                    maxLength: 6,
                                    counterText: "",
                                    suffixText: "%",
                                    errorText: soldPercErMsg,
                                    errorMaxLine: 3,
                                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                                    onChanged: (value) {
                                      calculateUnits(field: "soldPer");
                                      cmFormCubit.formValidation(
                                        floors: floorsC.text,
                                        slabs: slabsC.text,
                                        plinth: plinthC.text,
                                        rCC: rccC.text,
                                        uptoSlab: uptoSlabC.text,
                                        plasteringIn: plasteringInternalC.text,
                                        plasteringExternal: plasteringExternalC.text,
                                        flooring: flooringC.text,
                                        electric: electricC.text,
                                        plumbing: plumbingC.text,
                                        woodWork: woodWorkC.text,
                                        painting: paintingC.text,
                                        totalUnits: totalUnitsC.text,
                                        soldUnits: totalSoldC.text,
                                        soldPerc: totalSoldPercentageC.text,
                                        unsoldUnits: totalUnsoldC.text,
                                        unsoldPerc: totalUnsoldPercentageC.text,
                                        saleableRate: saleableRateC.text,
                                        carpetRate: carpetRateC.text,
                                        isSaleable: isSaleableReadOnly,
                                        isCarpet: isCarpetReadOnly,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),

                            Row(
                              spacing: 16.0,
                              children: [
                                Flexible(
                                  child: CustomTextformField(
                                    controller: totalUnsoldC,
                                    labelText: "Total Unsold Units",
                                    keyboardType: TextInputType.number,
                                    maxLength: 3,
                                    counterText: "",
                                    errorText: unsoldErMsg,
                                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                                    onChanged: (value) {
                                      calculateUnits(field: "unsold");
                                      cmFormCubit.formValidation(
                                        floors: floorsC.text,
                                        slabs: slabsC.text,
                                        plinth: plinthC.text,
                                        rCC: rccC.text,
                                        uptoSlab: uptoSlabC.text,
                                        plasteringIn: plasteringInternalC.text,
                                        plasteringExternal: plasteringExternalC.text,
                                        flooring: flooringC.text,
                                        electric: electricC.text,
                                        plumbing: plumbingC.text,
                                        woodWork: woodWorkC.text,
                                        painting: paintingC.text,
                                        totalUnits: totalUnitsC.text,
                                        soldUnits: totalSoldC.text,
                                        soldPerc: totalSoldPercentageC.text,
                                        unsoldUnits: totalUnsoldC.text,
                                        unsoldPerc: totalUnsoldPercentageC.text,
                                        saleableRate: saleableRateC.text,
                                        carpetRate: carpetRateC.text,
                                        isSaleable: isSaleableReadOnly,
                                        isCarpet: isCarpetReadOnly,
                                      );
                                    },
                                  ),
                                ),
                                Flexible(
                                  child: CustomTextformField(
                                    controller: totalUnsoldPercentageC,
                                    labelText: "Total Unsold Units Percentage",
                                    keyboardType: TextInputType.number,
                                    maxLength: 6,
                                    counterText: "",
                                    suffixText: "%",
                                    errorText: unsoldPercErMsg,
                                    errorMaxLine: 3,
                                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                                    onChanged: (value) {
                                      calculateUnits(field: "unsoldPer");
                                      cmFormCubit.formValidation(
                                        floors: floorsC.text,
                                        slabs: slabsC.text,
                                        plinth: plinthC.text,
                                        rCC: rccC.text,
                                        uptoSlab: uptoSlabC.text,
                                        plasteringIn: plasteringInternalC.text,
                                        plasteringExternal: plasteringExternalC.text,
                                        flooring: flooringC.text,
                                        electric: electricC.text,
                                        plumbing: plumbingC.text,
                                        woodWork: woodWorkC.text,
                                        painting: paintingC.text,
                                        totalUnits: totalUnitsC.text,
                                        soldUnits: totalSoldC.text,
                                        soldPerc: totalSoldPercentageC.text,
                                        unsoldUnits: totalUnsoldC.text,
                                        unsoldPerc: totalUnsoldPercentageC.text,
                                        saleableRate: saleableRateC.text,
                                        carpetRate: carpetRateC.text,
                                        isSaleable: isSaleableReadOnly,
                                        isCarpet: isCarpetReadOnly,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),

                            BlocBuilder<CMFormCubit, CMFormState>(
                              builder: (context, state) {
                                if (state is RateState) {
                                  isSaleableReadOnly = state.isSaleable;
                                  isCarpetReadOnly = state.isCarpet;
                                }

                                return Column(
                                  spacing: 12,
                                  children: [
                                    CustomTextformField(
                                      readOnly: isSaleableReadOnly,
                                      controller: saleableRateC,
                                      labelText: "Saleable Rate",
                                      keyboardType: TextInputType.number,
                                      maxLength: 9,
                                      counterText: "",
                                      filled: isSaleableReadOnly,
                                      fillColor: Colors.grey.shade200,
                                      errorText: saleableErMsg,
                                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                                      onChanged: (value) {
                                        cmFormCubit.formValidation(
                                          floors: floorsC.text,
                                          slabs: slabsC.text,
                                          plinth: plinthC.text,
                                          rCC: rccC.text,
                                          uptoSlab: uptoSlabC.text,
                                          plasteringIn: plasteringInternalC.text,
                                          plasteringExternal: plasteringExternalC.text,
                                          flooring: flooringC.text,
                                          electric: electricC.text,
                                          plumbing: plumbingC.text,
                                          woodWork: woodWorkC.text,
                                          painting: paintingC.text,
                                          totalUnits: totalUnitsC.text,
                                          soldUnits: totalSoldC.text,
                                          soldPerc: totalSoldPercentageC.text,
                                          unsoldUnits: totalUnsoldC.text,
                                          unsoldPerc: totalUnsoldPercentageC.text,
                                          saleableRate: saleableRateC.text,
                                          carpetRate: carpetRateC.text,
                                          isSaleable: isSaleableReadOnly,
                                          isCarpet: isCarpetReadOnly,
                                        );
                                        cmFormCubit.changeRateValue(saleableValue: value);
                                      },
                                    ),
                                    CustomTextformField(
                                      readOnly: isCarpetReadOnly,
                                      controller: carpetRateC,
                                      labelText: "Carpet Rate",
                                      keyboardType: TextInputType.number,
                                      maxLength: 9,
                                      counterText: "",
                                      filled: isCarpetReadOnly,
                                      errorText: saleableErMsg,
                                      fillColor: Colors.grey.shade200,
                                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                                      onChanged: (value) {
                                        cmFormCubit.formValidation(
                                          floors: floorsC.text,
                                          slabs: slabsC.text,
                                          plinth: plinthC.text,
                                          rCC: rccC.text,
                                          uptoSlab: uptoSlabC.text,
                                          plasteringIn: plasteringInternalC.text,
                                          plasteringExternal: plasteringExternalC.text,
                                          flooring: flooringC.text,
                                          electric: electricC.text,
                                          plumbing: plumbingC.text,
                                          woodWork: woodWorkC.text,
                                          painting: paintingC.text,
                                          totalUnits: totalUnitsC.text,
                                          soldUnits: totalSoldC.text,
                                          soldPerc: totalSoldPercentageC.text,
                                          unsoldUnits: totalUnsoldC.text,
                                          unsoldPerc: totalUnsoldPercentageC.text,
                                          saleableRate: saleableRateC.text,
                                          carpetRate: carpetRateC.text,
                                          isSaleable: isSaleableReadOnly,
                                          isCarpet: isCarpetReadOnly,
                                        );
                                        cmFormCubit.changeRateValue(carpetValue: value);
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            Text("Construction Progress :", style: AppTextStyle.ts18MB),
                            const SizedBox(),
                            CustomTextformField(
                              controller: plinthC,
                              labelText: "Plinth",
                              keyboardType: TextInputType.number,
                              maxLength: 3,
                              counterText: "",
                              suffixText: "%",
                              errorText: plinthErMsg,
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                              onChanged: (value) {
                                cmFormCubit.formValidation(
                                  floors: floorsC.text,
                                  slabs: slabsC.text,
                                  plinth: plinthC.text,
                                  rCC: rccC.text,
                                  uptoSlab: uptoSlabC.text,
                                  plasteringIn: plasteringInternalC.text,
                                  plasteringExternal: plasteringExternalC.text,
                                  flooring: flooringC.text,
                                  electric: electricC.text,
                                  plumbing: plumbingC.text,
                                  woodWork: woodWorkC.text,
                                  painting: paintingC.text,
                                  totalUnits: totalUnitsC.text,
                                  soldUnits: totalSoldC.text,
                                  soldPerc: totalSoldPercentageC.text,
                                  unsoldUnits: totalUnsoldC.text,
                                  unsoldPerc: totalUnsoldPercentageC.text,
                                  saleableRate: saleableRateC.text,
                                  carpetRate: carpetRateC.text,
                                  isSaleable: isSaleableReadOnly,
                                  isCarpet: isCarpetReadOnly,
                                );
                              },
                            ),
                            Stack(
                              children: [
                                IgnorePointer(
                                  ignoring: isPlinthComplete == false ? true : false,
                                  child: Column(
                                    spacing: 12.0,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CustomTextformField(
                                        controller: rccC,
                                        labelText: "RCC (Nos of Slabs Completed)",
                                        keyboardType: TextInputType.number,
                                        maxLength: 3,
                                        counterText: "",
                                        errorText: rccErMsg,
                                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                                        onChanged: (value) {
                                          cmFormCubit.formValidation(
                                            floors: floorsC.text,
                                            slabs: slabsC.text,
                                            plinth: plinthC.text,
                                            rCC: rccC.text,
                                            uptoSlab: uptoSlabC.text,
                                            plasteringIn: plasteringInternalC.text,
                                            plasteringExternal: plasteringExternalC.text,
                                            flooring: flooringC.text,
                                            electric: electricC.text,
                                            plumbing: plumbingC.text,
                                            woodWork: woodWorkC.text,
                                            painting: paintingC.text,
                                            totalUnits: totalUnitsC.text,
                                            soldUnits: totalSoldC.text,
                                            soldPerc: totalSoldPercentageC.text,
                                            unsoldUnits: totalUnsoldC.text,
                                            unsoldPerc: totalUnsoldPercentageC.text,
                                            saleableRate: saleableRateC.text,
                                            carpetRate: carpetRateC.text,
                                            isSaleable: isSaleableReadOnly,
                                            isCarpet: isCarpetReadOnly,
                                          );
                                        },
                                      ),
                                      CustomTextformField(
                                        controller: uptoSlabC,
                                        labelText: "B/W upto Slab",
                                        keyboardType: TextInputType.number,
                                        maxLength: 3,
                                        counterText: "",
                                        errorText: uptoSlabErMsg,
                                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                                        onChanged: (value) {
                                          cmFormCubit.formValidation(
                                            floors: floorsC.text,
                                            slabs: slabsC.text,
                                            plinth: plinthC.text,
                                            rCC: rccC.text,
                                            uptoSlab: uptoSlabC.text,
                                            plasteringIn: plasteringInternalC.text,
                                            plasteringExternal: plasteringExternalC.text,
                                            flooring: flooringC.text,
                                            electric: electricC.text,
                                            plumbing: plumbingC.text,
                                            woodWork: woodWorkC.text,
                                            painting: paintingC.text,
                                            totalUnits: totalUnitsC.text,
                                            soldUnits: totalSoldC.text,
                                            soldPerc: totalSoldPercentageC.text,
                                            unsoldUnits: totalUnsoldC.text,
                                            unsoldPerc: totalUnsoldPercentageC.text,
                                            saleableRate: saleableRateC.text,
                                            carpetRate: carpetRateC.text,
                                            isSaleable: isSaleableReadOnly,
                                            isCarpet: isCarpetReadOnly,
                                          );
                                        },
                                      ),
                                      CustomTextformField(
                                        controller: plasteringInternalC,
                                        labelText: "Plastering (internal)",
                                        keyboardType: TextInputType.number,
                                        maxLength: 3,
                                        counterText: "",
                                        errorText: pInternalErMsg,
                                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                                        onChanged: (value) {
                                          cmFormCubit.formValidation(
                                            floors: floorsC.text,
                                            slabs: slabsC.text,
                                            plinth: plinthC.text,
                                            rCC: rccC.text,
                                            uptoSlab: uptoSlabC.text,
                                            plasteringIn: plasteringInternalC.text,
                                            plasteringExternal: plasteringExternalC.text,
                                            flooring: flooringC.text,
                                            electric: electricC.text,
                                            plumbing: plumbingC.text,
                                            woodWork: woodWorkC.text,
                                            painting: paintingC.text,
                                            totalUnits: totalUnitsC.text,
                                            soldUnits: totalSoldC.text,
                                            soldPerc: totalSoldPercentageC.text,
                                            unsoldUnits: totalUnsoldC.text,
                                            unsoldPerc: totalUnsoldPercentageC.text,
                                            saleableRate: saleableRateC.text,
                                            carpetRate: carpetRateC.text,
                                            isSaleable: isSaleableReadOnly,
                                            isCarpet: isCarpetReadOnly,
                                          );
                                        },
                                      ),
                                      CustomTextformField(
                                        controller: plasteringExternalC,
                                        labelText: "Plastering (external)",
                                        keyboardType: TextInputType.number,
                                        maxLength: 3,
                                        counterText: "",
                                        errorText: pExternalErMsg,
                                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                                        onChanged: (value) {
                                          cmFormCubit.formValidation(
                                            floors: floorsC.text,
                                            slabs: slabsC.text,
                                            plinth: plinthC.text,
                                            rCC: rccC.text,
                                            uptoSlab: uptoSlabC.text,
                                            plasteringIn: plasteringInternalC.text,
                                            plasteringExternal: plasteringExternalC.text,
                                            flooring: flooringC.text,
                                            electric: electricC.text,
                                            plumbing: plumbingC.text,
                                            woodWork: woodWorkC.text,
                                            painting: paintingC.text,
                                            totalUnits: totalUnitsC.text,
                                            soldUnits: totalSoldC.text,
                                            soldPerc: totalSoldPercentageC.text,
                                            unsoldUnits: totalUnsoldC.text,
                                            unsoldPerc: totalUnsoldPercentageC.text,
                                            saleableRate: saleableRateC.text,
                                            carpetRate: carpetRateC.text,
                                            isSaleable: isSaleableReadOnly,
                                            isCarpet: isCarpetReadOnly,
                                          );
                                        },
                                      ),
                                      CustomTextformField(
                                        controller: flooringC,
                                        labelText: "Flooring",
                                        keyboardType: TextInputType.number,
                                        maxLength: 3,
                                        counterText: "",
                                        errorText: flooringErMsg,
                                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                                        onChanged: (value) {
                                          cmFormCubit.formValidation(
                                            floors: floorsC.text,
                                            slabs: slabsC.text,
                                            plinth: plinthC.text,
                                            rCC: rccC.text,
                                            uptoSlab: uptoSlabC.text,
                                            plasteringIn: plasteringInternalC.text,
                                            plasteringExternal: plasteringExternalC.text,
                                            flooring: flooringC.text,
                                            electric: electricC.text,
                                            plumbing: plumbingC.text,
                                            woodWork: woodWorkC.text,
                                            painting: paintingC.text,
                                            totalUnits: totalUnitsC.text,
                                            soldUnits: totalSoldC.text,
                                            soldPerc: totalSoldPercentageC.text,
                                            unsoldUnits: totalUnsoldC.text,
                                            unsoldPerc: totalUnsoldPercentageC.text,
                                            saleableRate: saleableRateC.text,
                                            carpetRate: carpetRateC.text,
                                            isSaleable: isSaleableReadOnly,
                                            isCarpet: isCarpetReadOnly,
                                          );
                                        },
                                      ),
                                      CustomTextformField(
                                        controller: electricC,
                                        labelText: "Electric",
                                        keyboardType: TextInputType.number,
                                        maxLength: 3,
                                        counterText: "",
                                        errorText: electricErMsg,
                                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                                        onChanged: (value) {
                                          cmFormCubit.formValidation(
                                            floors: floorsC.text,
                                            slabs: slabsC.text,
                                            plinth: plinthC.text,
                                            rCC: rccC.text,
                                            uptoSlab: uptoSlabC.text,
                                            plasteringIn: plasteringInternalC.text,
                                            plasteringExternal: plasteringExternalC.text,
                                            flooring: flooringC.text,
                                            electric: electricC.text,
                                            plumbing: plumbingC.text,
                                            woodWork: woodWorkC.text,
                                            painting: paintingC.text,
                                            totalUnits: totalUnitsC.text,
                                            soldUnits: totalSoldC.text,
                                            soldPerc: totalSoldPercentageC.text,
                                            unsoldUnits: totalUnsoldC.text,
                                            unsoldPerc: totalUnsoldPercentageC.text,
                                            saleableRate: saleableRateC.text,
                                            carpetRate: carpetRateC.text,
                                            isSaleable: isSaleableReadOnly,
                                            isCarpet: isCarpetReadOnly,
                                          );
                                        },
                                      ),
                                      CustomTextformField(
                                        controller: plumbingC,
                                        labelText: "Plumbing",
                                        keyboardType: TextInputType.number,
                                        maxLength: 3,
                                        counterText: "",
                                        errorText: plumbingErMsg,
                                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                                        onChanged: (value) {
                                          cmFormCubit.formValidation(
                                            floors: floorsC.text,
                                            slabs: slabsC.text,
                                            plinth: plinthC.text,
                                            rCC: rccC.text,
                                            uptoSlab: uptoSlabC.text,
                                            plasteringIn: plasteringInternalC.text,
                                            plasteringExternal: plasteringExternalC.text,
                                            flooring: flooringC.text,
                                            electric: electricC.text,
                                            plumbing: plumbingC.text,
                                            woodWork: woodWorkC.text,
                                            painting: paintingC.text,
                                            totalUnits: totalUnitsC.text,
                                            soldUnits: totalSoldC.text,
                                            soldPerc: totalSoldPercentageC.text,
                                            unsoldUnits: totalUnsoldC.text,
                                            unsoldPerc: totalUnsoldPercentageC.text,
                                            saleableRate: saleableRateC.text,
                                            carpetRate: carpetRateC.text,
                                            isSaleable: isSaleableReadOnly,
                                            isCarpet: isCarpetReadOnly,
                                          );
                                        },
                                      ),
                                      CustomTextformField(
                                        controller: woodWorkC,
                                        labelText: "Woodwork",
                                        keyboardType: TextInputType.number,
                                        maxLength: 3,
                                        counterText: "",
                                        errorText: wooWorkErMsg,
                                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                                        onChanged: (value) {
                                          cmFormCubit.formValidation(
                                            floors: floorsC.text,
                                            slabs: slabsC.text,
                                            plinth: plinthC.text,
                                            rCC: rccC.text,
                                            uptoSlab: uptoSlabC.text,
                                            plasteringIn: plasteringInternalC.text,
                                            plasteringExternal: plasteringExternalC.text,
                                            flooring: flooringC.text,
                                            electric: electricC.text,
                                            plumbing: plumbingC.text,
                                            woodWork: woodWorkC.text,
                                            painting: paintingC.text,
                                            totalUnits: totalUnitsC.text,
                                            soldUnits: totalSoldC.text,
                                            soldPerc: totalSoldPercentageC.text,
                                            unsoldUnits: totalUnsoldC.text,
                                            unsoldPerc: totalUnsoldPercentageC.text,
                                            saleableRate: saleableRateC.text,
                                            carpetRate: carpetRateC.text,
                                            isSaleable: isSaleableReadOnly,
                                            isCarpet: isCarpetReadOnly,
                                          );
                                        },
                                      ),
                                      CustomTextformField(
                                        controller: paintingC,
                                        labelText: "Painting",
                                        keyboardType: TextInputType.number,
                                        maxLength: 3,
                                        counterText: "",
                                        errorText: paintingErMsg,
                                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                                        onChanged: (value) {
                                          cmFormCubit.formValidation(
                                            floors: floorsC.text,
                                            slabs: slabsC.text,
                                            plinth: plinthC.text,
                                            rCC: rccC.text,
                                            uptoSlab: uptoSlabC.text,
                                            plasteringIn: plasteringInternalC.text,
                                            plasteringExternal: plasteringExternalC.text,
                                            flooring: flooringC.text,
                                            electric: electricC.text,
                                            plumbing: plumbingC.text,
                                            woodWork: woodWorkC.text,
                                            painting: paintingC.text,
                                            totalUnits: totalUnitsC.text,
                                            soldUnits: totalSoldC.text,
                                            soldPerc: totalSoldPercentageC.text,
                                            unsoldUnits: totalUnsoldC.text,
                                            unsoldPerc: totalUnsoldPercentageC.text,
                                            saleableRate: saleableRateC.text,
                                            carpetRate: carpetRateC.text,
                                            isSaleable: isSaleableReadOnly,
                                            isCarpet: isCarpetReadOnly,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                if (!isPlinthComplete)
                                  Positioned.fill(
                                    child: Container(
                                      color: Colors.white54, // white shade overlay
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text("Additional Information :", style: AppTextStyle.ts18MB),
                            const SizedBox(),
                            CustomTextformField(controller: remarksC, labelText: "Remarks"),
                            SizedBox(
                              width: double.infinity,
                              child: BlocBuilder<CMFormCubit, CMFormState>(
                                builder: (context, state) {
                                  return CustomElevatedButton(
                                    isLoading: state is LoadingState,
                                    text: "Submit",
                                    onPressed: () async {
                                      if (!await Utils.checkLocationAndGpsPermission(context)) return;
                                      cmFormCubit.submit(
                                        surveyData: widget.surveyData,
                                        floors: floorsC.text,
                                        slabs: slabsC.text,
                                        plinth: plinthC.text,
                                        rCC: rccC.text,
                                        uptoSlab: uptoSlabC.text,
                                        plasteringIn: plasteringInternalC.text,
                                        plasteringExternal: plasteringExternalC.text,
                                        flooring: flooringC.text,
                                        electric: electricC.text,
                                        plumbing: plumbingC.text,
                                        woodWork: woodWorkC.text,
                                        painting: paintingC.text,
                                        projectId: widget.wingData.projectId ?? 0,
                                        wingId: widget.wingData.wingId,
                                        buildingId: widget.wingData.buildingId,
                                        localWingId: widget.wingData.createdWingId,
                                        localBuildingId: widget.wingData.createdBuildingId,
                                        remarks: remarksC.text,
                                        totalUnits: totalUnitsC.text,
                                        soldUnits: totalSoldC.text,
                                        soldPerc: totalSoldPercentageC.text,
                                        unsoldUnits: totalUnsoldC.text,
                                        unsoldPerc: totalUnsoldPercentageC.text,
                                        saleableRate: saleableRateC.text,
                                        carpetRate: carpetRateC.text,
                                        isSaleable: isSaleableReadOnly,
                                        isCarpet: isCarpetReadOnly,
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isViewOnly)
                        Positioned.fill(
                          child: Container(
                            color: Colors.white54, // white shade overlay
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
