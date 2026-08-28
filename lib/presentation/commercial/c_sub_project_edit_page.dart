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
import 'package:lf_survey/cubit/commercial/c_sub_project_edit/c_sub_prj_edit_cubit.dart';
import 'package:lf_survey/cubit/commercial/c_sub_project_edit/c_sub_prj_edit_state.dart';
import 'package:lf_survey/model/db_model/commercial/c_sub_project_entity.dart';
import 'package:lf_survey/widgets/custom_app_bar.dart';
import 'package:lf_survey/widgets/custom_date_picker.dart';
import 'package:lf_survey/widgets/custom_dropdown.dart';
import 'package:lf_survey/widgets/custom_elevated_btn.dart';
import 'package:lf_survey/widgets/custom_textfield.dart';

class CSubProjectEditPage extends StatefulWidget {
  final CSubProjectEntity subProjectData;
  const CSubProjectEditPage({super.key, required this.subProjectData});

  @override
  State<CSubProjectEditPage> createState() => _CSubProjectEditPageState();
}

class _CSubProjectEditPageState extends State<CSubProjectEditPage> {
  TextEditingController basementC = TextEditingController();
  TextEditingController podiumC = TextEditingController();
  TextEditingController serviceC = TextEditingController();
  TextEditingController habitableC = TextEditingController();
  TextEditingController constStartDateC = TextEditingController();
  TextEditingController constEndDateC = TextEditingController();
  TextEditingController marketStartDateC = TextEditingController();
  TextEditingController marketEndDateC = TextEditingController();
  TextEditingController totalSupplyC = TextEditingController();
  TextEditingController soldAreaSqftC = TextEditingController();
  TextEditingController soldAreaPercC = TextEditingController();
  TextEditingController unSoldAreaSqftC = TextEditingController();
  TextEditingController unSoldAreaPercC = TextEditingController();
  TextEditingController leasedAreaSqftC = TextEditingController();
  TextEditingController leasedAreaPercC = TextEditingController();
  TextEditingController vacancyAreaSqftC = TextEditingController();
  TextEditingController vacancyAreaPercC = TextEditingController();
  TextEditingController minimumC = TextEditingController();
  TextEditingController maximumC = TextEditingController();
  TextEditingController outrightBareshellC = TextEditingController();
  TextEditingController outrightWarmshellC = TextEditingController();
  TextEditingController outrightFullyFurnishedC = TextEditingController();
  TextEditingController leaseBareshellC = TextEditingController();
  TextEditingController leaseWarmshellC = TextEditingController();
  TextEditingController leaseFullyFurnishedC = TextEditingController();
  TextEditingController floorSlabC = TextEditingController();
  TextEditingController remarkC = TextEditingController();
  final FocusNode basementF = FocusNode();
  final FocusNode podiumF = FocusNode();
  final FocusNode serviceF = FocusNode();
  final FocusNode habitableF = FocusNode();
  final FocusNode totalSupplyF = FocusNode();
  final FocusNode soldAreaSqftF = FocusNode();
  final FocusNode soldAreaPercF = FocusNode();
  final FocusNode unSoldAreaSqftF = FocusNode();
  final FocusNode unSoldAreaPercF = FocusNode();
  final FocusNode leasedAreaSqftF = FocusNode();
  final FocusNode leasedAreaPercF = FocusNode();
  final FocusNode vacancyAreaSqftF = FocusNode();
  final FocusNode vacancyAreaPercF = FocusNode();
  final FocusNode minimumF = FocusNode();
  final FocusNode maximumF = FocusNode();
  final FocusNode outrightBareshellF = FocusNode();
  final FocusNode outrightWarmshellF = FocusNode();
  final FocusNode outrightFullyFurnishedF = FocusNode();
  final FocusNode leaseBareshellF = FocusNode();
  final FocusNode leaseWarmshellF = FocusNode();
  final FocusNode leaseFullyFurnishedF = FocusNode();
  final FocusNode remarkF = FocusNode();
  DateTime? constEndFirstDate;
  DateTime? marketinEndFirstDate;
  List<Map<String, dynamic>> constProgress = [];
  List<Map<String, dynamic>> buildingType = [];
  List<Map<String, dynamic>> operationModel = [];
  List<Map<String, dynamic>> projectStatus = [];
  Map<String, dynamic>? selectedConstProgress;
  Map<String, dynamic>? selectedBuildingType;
  Map<String, dynamic>? selectedOperationModel;
  Map<String, dynamic>? selectedProjectStatus;

  String? projectStatusEr;
  String? floorSlabEr;
  String? marketingStartDateEr;
  String? marketingEndDateEr;
  @override
  void initState() {
    super.initState();
    context.read<CSubPrjEditCubit>().fetchData();
    prefillFields(subProjectData: widget.subProjectData);
  }

  void prefillFields({required CSubProjectEntity subProjectData}) {
    basementC.text = subProjectData.storeyBasement?.toString() ?? "";
    podiumC.text = subProjectData.storeyPodium?.toString() ?? "";
    serviceC.text = subProjectData.storeyService?.toString() ?? "";
    habitableC.text = subProjectData.storeyHabitable?.toString() ?? "";
    constStartDateC.text = formattedDate(date: subProjectData.constStartDate ?? "");
    constEndDateC.text = formattedDate(date: subProjectData.constEndDate ?? "");
    marketStartDateC.text = formattedDate(date: subProjectData.marketingStartDate ?? "");
    marketEndDateC.text = formattedDate(date: subProjectData.marketingEndDate ?? "");
    totalSupplyC.text = subProjectData.totalSupplySqft?.toString() ?? "";
    soldAreaSqftC.text = subProjectData.soldAreaSqft?.toString() ?? "";
    unSoldAreaSqftC.text = subProjectData.unsoldAreaSqft?.toString() ?? "";
    leasedAreaSqftC.text = subProjectData.leasedOccupiedArea?.toString() ?? "";
    vacancyAreaSqftC.text = subProjectData.vacancyArea?.toString() ?? "";
    minimumC.text = subProjectData.minFloorplate?.toString() ?? "";
    maximumC.text = subProjectData.maxFloorplate?.toString() ?? "";
    outrightBareshellC.text = subProjectData.orBareshell?.toString() ?? "";
    outrightWarmshellC.text = subProjectData.orWarmshell?.toString() ?? "";
    outrightFullyFurnishedC.text = subProjectData.orFullyFurnished?.toString() ?? "";
    leaseBareshellC.text = subProjectData.lrBareshell?.toString() ?? "";
    leaseWarmshellC.text = subProjectData.lrWarmshell?.toString() ?? "";
    leaseFullyFurnishedC.text = subProjectData.lrFullyFurnished?.toString() ?? "";
    floorSlabC.text = subProjectData.floorSlab?.toString() ?? "";
    remarkC.text = subProjectData.remarks ?? "";
    final resonse = context.read<CSubPrjEditCubit>().calculatePercentage(
      totalSupply: totalSupplyC.text,
      soldArea: soldAreaSqftC.text,
      isSoldInput: true,
    );
    if (resonse.isNotEmpty) {
      soldAreaPercC.text = resonse["soldPerc"].toString();
      unSoldAreaPercC.text = resonse["unsoldPerc"].toString();
    }
    final leaseResponse = context.read<CSubPrjEditCubit>().calculatePercentage(
      totalSupply: totalSupplyC.text,
      soldArea: leasedAreaSqftC.text,
      isSoldInput: true,
    );
    if (leaseResponse.isNotEmpty) {
      leasedAreaPercC.text = leaseResponse["soldPerc"].toString();
      vacancyAreaPercC.text = leaseResponse["unsoldPerc"].toString();
    }

    var constEndDate = DateTime.tryParse(subProjectData.constStartDate ?? "");
    if (constEndDate != null) {
      constEndFirstDate = DateTime(constEndDate.year, constEndDate.month + 5, constEndDate.day + 1);
    }
    var marketingStartDate = DateTime.tryParse(subProjectData.marketingStartDate ?? "");
    if (marketingStartDate != null) {
      marketinEndFirstDate = DateTime(marketingStartDate.year, marketingStartDate.month, marketingStartDate.day + 1);
    }
  }

  String formattedDate({required String date}) {
    try {
      final raw = date;

      if (raw.isNotEmpty) {
        final date = DateTime.tryParse(raw);

        if (date != null) {
          return DateFormat("dd MMM yyyy").format(date);
        } else {
          return "";
        }
      } else {
        return "";
      }
    } catch (_) {
      CustomSnackHelper.customToastMsg(
        context: context,
        message: "Something went wrong with date",
        textColor: AppColors.black,
        bgColor: AppColors.white,
      );
      return "";
    }
  }

  @override
  void dispose() {
    basementC.dispose();
    podiumC.dispose();
    serviceC.dispose();
    habitableC.dispose();
    constStartDateC.dispose();
    constEndDateC.dispose();
    marketStartDateC.dispose();
    marketEndDateC.dispose();
    totalSupplyC.dispose();
    soldAreaSqftC.dispose();
    soldAreaPercC.dispose();
    unSoldAreaSqftC.dispose();
    unSoldAreaPercC.dispose();
    leasedAreaSqftC.dispose();
    leasedAreaPercC.dispose();
    vacancyAreaSqftC.dispose();
    vacancyAreaPercC.dispose();
    minimumC.dispose();
    maximumC.dispose();
    outrightBareshellC.dispose();
    outrightWarmshellC.dispose();
    outrightFullyFurnishedC.dispose();
    leaseBareshellC.dispose();
    leaseWarmshellC.dispose();
    leaseFullyFurnishedC.dispose();
    remarkC.dispose();
    basementF.dispose();
    podiumF.dispose();
    serviceF.dispose();
    habitableF.dispose();
    totalSupplyF.dispose();
    soldAreaSqftF.dispose();
    soldAreaPercF.dispose();
    unSoldAreaSqftF.dispose();
    unSoldAreaPercF.dispose();
    leasedAreaSqftF.dispose();
    leasedAreaPercF.dispose();
    vacancyAreaSqftF.dispose();
    vacancyAreaPercF.dispose();
    minimumF.dispose();
    maximumF.dispose();
    outrightBareshellF.dispose();
    outrightWarmshellF.dispose();
    outrightFullyFurnishedF.dispose();
    leaseBareshellF.dispose();
    leaseWarmshellF.dispose();
    leaseFullyFurnishedF.dispose();
    floorSlabC.dispose();
    remarkF.dispose();
    super.dispose();
  }

  String? error;
  @override
  Widget build(BuildContext context) {
    final cSubPrjEditCubit = context.read<CSubPrjEditCubit>();
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: CustomAppBar(title: "Sub Project Edit"),
      body: SafeArea(
        child: BlocListener<CSubPrjEditCubit, CSubPrjEditState>(
          listener: (context, state) {
            if (state is ErrorState) {
              CustomSnackHelper.customToastMsg(
                context: context,
                message: state.message,
                textColor: AppColors.black,
                bgColor: AppColors.white,
              );
            } else if (state is SuccessState) {
              context.pop();
              CustomSnackHelper.customToastMsg(
                context: context,
                message: state.message,
                textColor: AppColors.black,
                bgColor: AppColors.white,
              );
            } else if (state is LocalDbState) {
              constProgress.clear();
              buildingType.clear();
              operationModel.clear();
              projectStatus.clear();
              constProgress.addAll(state.constProgress);
              buildingType.addAll(state.buildingType);
              operationModel.addAll(state.operationModel);
              projectStatus.addAll(state.projectStatus);
              // Prefill the dropdowns value
              var scp = constProgress.where(
                (e) => e["constProgressId"] == widget.subProjectData.constructionProgressId,
              );
              var sbt = buildingType.where((e) => e["buildingTypeId"] == widget.subProjectData.buildingTypeId);
              var sop = operationModel.where((e) => e["operatingModelId"] == widget.subProjectData.operationModelId);
              var sps = projectStatus.where((e) => e["projectStatusId"] == widget.subProjectData.projectStatusId);
              selectedConstProgress = scp.isNotEmpty ? scp.first : null;
              selectedBuildingType = sbt.isNotEmpty ? sbt.first : null;
              selectedOperationModel = sop.isNotEmpty ? sop.first : null;
              selectedProjectStatus = sps.isNotEmpty ? sps.first : null;
            } else if (state is ValidationState) {
              projectStatusEr = state.projectStatusEr;
              floorSlabEr = state.floorSlabEr;
              marketingStartDateEr = state.marketingStartDateEr;
              marketingEndDateEr = state.marketingEndDateEr;
            }
          },
          child: Padding(
            padding: AppDimens.hvPadding,
            child: Container(
              color: AppColors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Stack(
                    children: [
                      Column(
                        spacing: 12.0,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Number of Storey :", style: AppTextStyle.ts16MB),
                          CustomTextField(
                            labelText: "Basement",
                            focusNode: basementF,
                            controller: basementC,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(podiumF),
                          ),
                          CustomTextField(
                            focusNode: podiumF,
                            controller: podiumC,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            labelText: "Podium",
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(serviceF),
                          ),
                          CustomTextField(
                            focusNode: serviceF,
                            labelText: "Service",
                            controller: serviceC,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(habitableF),
                          ),
                          CustomTextField(
                            focusNode: habitableF,
                            labelText: "Habitable",
                            controller: habitableC,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(totalSupplyF),
                          ),
                          CustomDatePickerFormField(
                            enabled: false,
                            controller: constStartDateC,
                            labelText: "Construction Start Date",
                          ),
                          dateWidgets(cubit: cSubPrjEditCubit),
                          dropdownWidget(cubit: cSubPrjEditCubit),
                          CustomTextField(
                            focusNode: totalSupplyF,
                            labelText: "Total Supply(sqft)",
                            controller: totalSupplyC,
                            maxLength: 8,
                            counterText: "",
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(soldAreaSqftF),
                          ),
                          Row(
                            spacing: 20.0,
                            children: [
                              Flexible(
                                child: CustomTextField(
                                  focusNode: soldAreaSqftF,
                                  labelText: "Sold Area(sqft)",
                                  controller: soldAreaSqftC,
                                  maxLength: 8,
                                  counterText: "",
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  textInputAction: TextInputAction.next,
                                  onChanged: (value) {
                                    final resonse = cSubPrjEditCubit.calculatePercentage(
                                      totalSupply: totalSupplyC.text,
                                      soldArea: value,
                                      isSoldInput: true,
                                    );
                                    if (resonse.isNotEmpty) {
                                      soldAreaSqftC.text = resonse["soldArea"].toString();
                                      soldAreaPercC.text = resonse["soldPerc"].toString();
                                      unSoldAreaSqftC.text = resonse["unsoldArea"].toString();
                                      unSoldAreaPercC.text = resonse["unsoldPerc"].toString();
                                    }
                                  },
                                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(soldAreaPercF),
                                ),
                              ),
                              Flexible(
                                child: CustomTextField(
                                  focusNode: soldAreaPercF,
                                  labelText: "Sold Area %",
                                  controller: soldAreaPercC,
                                  maxLength: 3,
                                  counterText: "",
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                                  textInputAction: TextInputAction.next,
                                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(unSoldAreaSqftF),
                                  onChanged: (value) {
                                    final response = cSubPrjEditCubit.calculateFromPercentage(
                                      totalSupply: totalSupplyC.text,
                                      isSoldInput: true,
                                      soldPerc: value,
                                    );
                                    if (response.isNotEmpty) {
                                      soldAreaSqftC.text = response["soldArea"].toString();
                                      soldAreaPercC.text = response["soldPerc"].toString();
                                      unSoldAreaSqftC.text = response["unsoldArea"].toString();
                                      unSoldAreaPercC.text = response["unsoldPerc"].toString();
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          Row(
                            spacing: 20,
                            children: [
                              Flexible(
                                child: CustomTextField(
                                  focusNode: unSoldAreaSqftF,
                                  labelText: "Unsold Area(sqft)",
                                  controller: unSoldAreaSqftC,
                                  maxLength: 8,
                                  counterText: "",
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  textInputAction: TextInputAction.next,
                                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(unSoldAreaPercF),
                                  onChanged: (value) {
                                    final resonse = cSubPrjEditCubit.calculatePercentage(
                                      totalSupply: totalSupplyC.text,
                                      unSoldArea: value,
                                      soldArea: soldAreaSqftC.text,
                                    );
                                    if (resonse.isNotEmpty) {
                                      soldAreaSqftC.text = resonse["soldArea"].toString();
                                      soldAreaPercC.text = resonse["soldPerc"].toString();
                                      unSoldAreaSqftC.text = resonse["unsoldArea"].toString();
                                      unSoldAreaPercC.text = resonse["unsoldPerc"].toString();
                                    }
                                  },
                                ),
                              ),
                              Flexible(
                                child: CustomTextField(
                                  focusNode: unSoldAreaPercF,
                                  labelText: "Unsold Area %",
                                  controller: unSoldAreaPercC,
                                  maxLength: 3,
                                  counterText: "",
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                                  textInputAction: TextInputAction.next,
                                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(leasedAreaSqftF),
                                  onChanged: (value) {
                                    final response = cSubPrjEditCubit.calculateFromPercentage(
                                      totalSupply: totalSupplyC.text,
                                      isSoldInput: false,
                                      unsoldPerc: value,
                                    );
                                    if (response.isNotEmpty) {
                                      soldAreaSqftC.text = response["soldArea"].toString();
                                      soldAreaPercC.text = response["soldPerc"].toString();
                                      unSoldAreaSqftC.text = response["unsoldArea"].toString();
                                      unSoldAreaPercC.text = response["unsoldPerc"].toString();
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),

                          Row(
                            spacing: 20,
                            children: [
                              Flexible(
                                child: CustomTextField(
                                  focusNode: leasedAreaSqftF,
                                  labelText: "Leased / Occupied Area(Sqft)",
                                  controller: leasedAreaSqftC,
                                  maxLength: 8,
                                  counterText: "",
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  textInputAction: TextInputAction.next,
                                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(leasedAreaPercF),
                                  onChanged: (value) {
                                    final resonse = cSubPrjEditCubit.calculatePercentage(
                                      totalSupply: totalSupplyC.text,
                                      soldArea: value,
                                      isSoldInput: true,
                                    );
                                    if (resonse.isNotEmpty) {
                                      leasedAreaSqftC.text = resonse["soldArea"].toString();
                                      leasedAreaPercC.text = resonse["soldPerc"].toString();
                                      vacancyAreaSqftC.text = resonse["unsoldArea"].toString();
                                      vacancyAreaPercC.text = resonse["unsoldPerc"].toString();
                                    }
                                  },
                                ),
                              ),
                              Flexible(
                                child: CustomTextField(
                                  focusNode: leasedAreaPercF,
                                  labelText: "Leased / Occupied Area %",
                                  controller: leasedAreaPercC,
                                  maxLength: 3,
                                  counterText: "",
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                                  textInputAction: TextInputAction.next,
                                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(vacancyAreaSqftF),
                                ),
                              ),
                            ],
                          ),

                          Row(
                            spacing: 20,
                            children: [
                              Flexible(
                                child: CustomTextField(
                                  focusNode: vacancyAreaSqftF,
                                  labelText: "Vacancy Area(sqft)",
                                  controller: vacancyAreaSqftC,
                                  maxLength: 8,
                                  counterText: "",
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  textInputAction: TextInputAction.next,
                                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(vacancyAreaPercF),
                                  onChanged: (value) {
                                    final resonse = cSubPrjEditCubit.calculatePercentage(
                                      totalSupply: totalSupplyC.text,
                                      soldArea: value,
                                      unSoldArea: value,
                                      isSoldInput: false,
                                    );
                                    if (resonse.isNotEmpty) {
                                      leasedAreaSqftC.text = resonse["soldArea"].toString();
                                      leasedAreaPercC.text = resonse["soldPerc"].toString();
                                      vacancyAreaSqftC.text = resonse["unsoldArea"].toString();
                                      vacancyAreaPercC.text = resonse["unsoldPerc"].toString();
                                    }
                                  },
                                ),
                              ),
                              Flexible(
                                child: CustomTextField(
                                  focusNode: vacancyAreaPercF,
                                  labelText: "Vacancy Area %",
                                  controller: vacancyAreaPercC,
                                  keyboardType: TextInputType.number,
                                  maxLength: 3,
                                  counterText: "",
                                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                                  textInputAction: TextInputAction.next,
                                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(minimumF),
                                ),
                              ),
                            ],
                          ),

                          Text("Floor Plate :", style: AppTextStyle.ts16MB),
                          CustomTextField(
                            focusNode: minimumF,
                            labelText: "Minimum",
                            controller: minimumC,
                            maxLength: 6,
                            counterText: "",
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(maximumF),
                          ),
                          CustomTextField(
                            focusNode: maximumF,
                            labelText: "Maximum",
                            controller: maximumC,
                            maxLength: 6,
                            counterText: "",
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(outrightBareshellF),
                          ),
                          Text("Outright Rate(Rs/sqft) :", style: AppTextStyle.ts16MB),
                          CustomTextField(
                            focusNode: outrightBareshellF,
                            labelText: "Bareshell",
                            controller: outrightBareshellC,
                            maxLength: 8,
                            counterText: "",
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(outrightWarmshellF),
                          ),
                          CustomTextField(
                            focusNode: outrightWarmshellF,
                            labelText: "Warmshell",
                            controller: outrightWarmshellC,
                            maxLength: 8,
                            counterText: "",
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(outrightFullyFurnishedF),
                          ),
                          CustomTextField(
                            focusNode: outrightFullyFurnishedF,
                            labelText: "Fully Furnished",
                            controller: outrightFullyFurnishedC,
                            maxLength: 8,
                            counterText: "",
                            minLines: 2,
                            maxLines: 10000,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(leaseBareshellF),
                          ),
                          Text("Lease Rate(Rs/sqft) :", style: AppTextStyle.ts16MB),
                          CustomTextField(
                            focusNode: leaseBareshellF,
                            labelText: "Bareshell",
                            controller: leaseBareshellC,
                            maxLength: 8,
                            counterText: "",
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(leaseWarmshellF),
                          ),
                          CustomTextField(
                            focusNode: leaseWarmshellF,
                            labelText: "Warmshell",
                            controller: leaseWarmshellC,
                            maxLength: 8,
                            counterText: "",
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(leaseFullyFurnishedF),
                          ),
                          CustomTextField(
                            focusNode: leaseFullyFurnishedF,
                            labelText: "Fully Furnished",
                            controller: leaseFullyFurnishedC,
                            maxLength: 8,
                            counterText: "",
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(remarkF),
                          ),
                          CustomTextField(focusNode: remarkF, labelText: "Remark", controller: remarkC),
                          SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            child: BlocBuilder<CSubPrjEditCubit, CSubPrjEditState>(
                              builder: (context, state) {
                                return CustomElevatedButton(
                                  isLoading: state is LoadingState,
                                  backgroundColor: AppColors.red,
                                  text: "Save",
                                  onPressed: () async {
                                    if (!await Utils.checkLocationAndGpsPermission(context)) return;
                                    cSubPrjEditCubit.updateData(
                                      subProjectData: widget.subProjectData,
                                      basement: basementC.text,
                                      podium: podiumC.text,
                                      service: serviceC.text,
                                      habitable: habitableC.text,
                                      constStartDate: constStartDateC.text,
                                      constEndDate: constEndDateC.text,
                                      marketingStartDate: marketStartDateC.text,
                                      marketingEndDate: marketEndDateC.text,
                                      constProgressStatus: selectedConstProgress?["constProgress"],
                                      floorSlab: floorSlabC.text,
                                      buildingTypeId: selectedBuildingType?["buildingTypeId"],
                                      operatingModelId: selectedOperationModel?["operatingModelId"],
                                      projectStatusId: selectedProjectStatus?["projectStatusId"],
                                      projectStatus: selectedProjectStatus?["projectStatus"],
                                      totalSupply: totalSupplyC.text,
                                      soldAreaSQFT: soldAreaSqftC.text,
                                      unSoldAreaSQFT: unSoldAreaSqftC.text,
                                      leasedOccupiedArea: leasedAreaSqftC.text,
                                      vacancyAreaSQFT: vacancyAreaSqftC.text,
                                      minimum: minimumC.text,
                                      maximum: maximumC.text,
                                      outBareshell: outrightBareshellC.text,
                                      outWarmeshell: outrightWarmshellC.text,
                                      outFullyFurnished: outrightFullyFurnishedC.text,
                                      leaseBareshell: leaseBareshellC.text,
                                      leaseWarmeshell: leaseWarmshellC.text,
                                      leaseFullyFurnished: leaseFullyFurnishedC.text,
                                      remarks: remarkC.text,
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      if (widget.subProjectData.syncLocalStatus == 1 || widget.subProjectData.syncGlobalStatus == 1)
                        Positioned.fill(
                          child: AbsorbPointer(child: ColoredBox(color: Colors.white60)),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  BlocBuilder<CSubPrjEditCubit, CSubPrjEditState> dateWidgets({required CSubPrjEditCubit cubit}) {
    return BlocBuilder<CSubPrjEditCubit, CSubPrjEditState>(
      buildWhen: (previous, current) => current is ValidationState || current is SelectDateState,
      builder: (context, state) {
        return Column(
          spacing: 12.0,
          children: [
            CustomDatePickerFormField(
              controller: constEndDateC,
              firstDate: constEndFirstDate,
              lastDate: DateTime(2100),
              labelText: "Construction End Date",
              onDateSelected: (DateTime value) {
                constEndDateC.text = DateFormat("dd MMM yyyy").format(value);
              },
            ),
            CustomDatePickerFormField(
              controller: marketStartDateC,
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
              errorText: marketingStartDateEr,
              labelText: "Marketing Start Date",
              onDateSelected: (DateTime value) {
                marketStartDateC.text = DateFormat("dd MMM yyyy").format(value);
                marketinEndFirstDate = DateTime(value.year, value.month, value.day + 1);
                cubit.selectDate();
              },
            ),
            CustomDatePickerFormField(
              controller: marketEndDateC,
              firstDate: marketinEndFirstDate,
              lastDate: DateTime(2100),
              labelText: "Marketing End Date",
              errorText: marketingEndDateEr,
              onDateSelected: (DateTime value) {
                marketEndDateC.text = DateFormat("dd MMM yyyy").format(value);
                cubit.selectDate();
              },
            ),
          ],
        );
      },
    );
  }

  BlocBuilder<CSubPrjEditCubit, CSubPrjEditState> dropdownWidget({required CSubPrjEditCubit cubit}) {
    return BlocBuilder<CSubPrjEditCubit, CSubPrjEditState>(
      buildWhen: (previous, current) =>
          current is LocalDbState || current is SelectConstProgressState || current is ValidationState,
      builder: (context, state) {
        return Column(
          spacing: 12.0,
          children: [
            CustomDropdown(
              initialValue: selectedConstProgress,
              items: constProgress,
              labelKey: "constProgress",
              lableText: "Construction Progress",
              onChanged: (value) {
                if (value != null) {
                  selectedConstProgress = value;
                  cubit.selectConstProgress(constProgress: selectedConstProgress?["constProgress"]);
                }
              },
            ),
            if (selectedConstProgress?["constProgress"] == "Floor Slab")
              CustomTextField(
                labelText: "Floor Slab",
                controller: floorSlabC,
                maxLength: 4,
                counterText: "",
                errorText: floorSlabEr,
                errorMaxLines: 2,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  cubit.fieldsValidation(
                    floorSlab: value,
                    marketingStartDate: marketStartDateC.text,
                    marketingEndDate: marketEndDateC.text,
                    projectStatus: selectedProjectStatus?["projectStatus"],
                    constProgressStatus: selectedConstProgress?["constProgress"],
                  );
                },
              ),
            CustomDropdown(
              initialValue: selectedBuildingType,
              items: buildingType,
              labelKey: "buildingType",
              lableText: "Building Type",
              onChanged: (value) {
                if (value != null) {
                  selectedBuildingType = value;
                }
              },
            ),
            CustomDropdown(
              initialValue: selectedOperationModel,
              items: operationModel,
              labelKey: "operatingModel",
              lableText: "Operating Model",
              onChanged: (value) {
                if (value != null) {
                  selectedOperationModel = value;
                }
              },
            ),
            CustomDropdown(
              initialValue: selectedProjectStatus,
              items: projectStatus,
              labelKey: "projectStatus",
              lableText: "Project Status",
              errorText: projectStatusEr,
              errorMaxLines: 2,
              onChanged: (value) {
                if (value != null) {
                  selectedProjectStatus = value;
                  cubit.selectProjStatus(
                    projectStatusEr: null,
                    floorSlabEr: floorSlabEr,
                    marketingStartDateEr: marketingStartDateEr,
                    marketingEndDateEr: marketingEndDateEr,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
