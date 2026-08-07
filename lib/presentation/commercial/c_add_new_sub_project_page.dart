import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_dimens.dart';
import 'package:lf_survey/constants/app_text_style.dart';
import 'package:lf_survey/constants/snackbar_helper.dart';
import 'package:lf_survey/constants/utils.dart';
import 'package:lf_survey/cubit/commercial/c_add_new_sub_project/c_add_new_sub_project_cubit.dart';
import 'package:lf_survey/cubit/commercial/c_add_new_sub_project/c_add_new_sub_project_state.dart';
import 'package:lf_survey/model/db_model/commercial/c_new_project_entity.dart';
import 'package:lf_survey/model/db_model/commercial/c_new_sub_project_entity.dart';
import 'package:lf_survey/model/db_model/commercial/c_project_entity.dart';
import 'package:lf_survey/widgets/custom_app_bar.dart';
import 'package:lf_survey/widgets/custom_date_picker.dart';
import 'package:lf_survey/widgets/custom_dropdown.dart';
import 'package:lf_survey/widgets/custom_elevated_btn.dart';
import 'package:lf_survey/widgets/custom_textfield.dart';

class CAddNewSubProjectPage extends StatefulWidget {
  final CNewProjectEntity? cNewProjectEntity;
  final CProjectEntity? project;
  final CNewSubProjectEntity? cNewSubProjects;
  const CAddNewSubProjectPage({super.key, this.cNewProjectEntity, this.project, this.cNewSubProjects});

  @override
  State<CAddNewSubProjectPage> createState() => _CAddNewSubProjectPageState();
}

class _CAddNewSubProjectPageState extends State<CAddNewSubProjectPage> {
  TextEditingController subProjectNameC = TextEditingController();
  TextEditingController storeyC = TextEditingController();
  TextEditingController scrC = TextEditingController();
  TextEditingController maintenanceC = TextEditingController();
  TextEditingController floorPlateC = TextEditingController();
  TextEditingController leaseBareshellC = TextEditingController();
  TextEditingController leaseWarmshellC = TextEditingController();
  TextEditingController leaseFullyFurnishedC = TextEditingController();
  TextEditingController outRightBareshellC = TextEditingController();
  TextEditingController outRightWarmshellC = TextEditingController();
  TextEditingController outRightFullyFurnishedC = TextEditingController();
  TextEditingController totalSupplyC = TextEditingController();
  TextEditingController soldAreaSQFTC = TextEditingController();
  TextEditingController soldAreaPerC = TextEditingController();
  TextEditingController unsoldAreaSQFTC = TextEditingController();
  TextEditingController unsoldAreaPerC = TextEditingController();
  TextEditingController leasedAreaSQFTC = TextEditingController();
  TextEditingController leasedPercC = TextEditingController();
  TextEditingController vacancyAreaC = TextEditingController();
  TextEditingController vacancyPercC = TextEditingController();
  TextEditingController reraNoC = TextEditingController();
  TextEditingController remarkC = TextEditingController();
  TextEditingController floorSlabC = TextEditingController();

  List<Map<String, dynamic>> constProgress = [];
  Map<String, dynamic>? selectedConstProgress;
  String selectedArea = 'saleable';
  DateTime? launchDate;
  DateTime? endDate;
  String? subProjectNameEr;
  String? storeyEr;
  String? scrEr;
  String? maintenanceEr;
  String? floorPlateEr;
  String? leaseBarshellEr;
  String? leaseWarmshellEr;
  String? leaseFullyFurnishedEr;
  String? outrightBarshellEr;
  String? outrightWarmshellEr;
  String? outrightFullyFurnishedEr;
  String? launchDateEr;
  String? endDateEr;
  String? constProgressEr;
  String? totalSupplyEr;
  String? soldAreaSqftEr;
  String? soldAreaPercEr;
  String? unsoldAreaSqftEr;
  String? unsoldAreaPercEr;
  String? leaseAreaSqftEr;
  String? leasePercentEr;
  String? vacancyAreaEr;
  String? vacancyPercEr;
  String? reraNoEr;
  String? floorSlabEr;
  bool isValidateFloorSlab = false;
  @override
  void initState() {
    super.initState();
    context.read<CAddNewSubProjectCubit>().fetchData();
    // prefillFields(subProjects: widget.cNewSubProjects);
  }

  void prefillFields({CNewSubProjectEntity? subProjects}) {
    if (subProjects != null) {
      subProjectNameC.text = subProjects.subPrjName ?? "";
      storeyC.text = subProjects.storey?.toString() ?? "";
      scrC.text = subProjects.scr?.toString() ?? "";
      maintenanceC.text = subProjects.maintenance?.toString() ?? "";
      floorPlateC.text = subProjects.floorPlate?.toString() ?? "";
      leaseBareshellC.text = subProjects.leaseBareshell?.toString() ?? "";
      leaseWarmshellC.text = subProjects.leaseWarmshell?.toString() ?? "";
      leaseFullyFurnishedC.text = subProjects.leaseFullyFurnished?.toString() ?? "";
      outRightBareshellC.text = subProjects.outrightBareshell?.toString() ?? "";
      outRightWarmshellC.text = subProjects.outrightBareshell?.toString() ?? "";
      outRightFullyFurnishedC.text = subProjects.outrightFullyFurnished?.toString() ?? "";
      totalSupplyC.text = subProjects.totalSupply?.toString() ?? "";
      soldAreaPerC.text = subProjects.soldPercent?.toString() ?? "";
      unsoldAreaPerC.text = subProjects.unsoldPercent?.toString() ?? "";
      leasedPercC.text = subProjects.leasePercent?.toString() ?? "";
      vacancyPercC.text = subProjects.vacantPercent?.toString() ?? "";
      reraNoC.text = subProjects.reraNo ?? "";
      remarkC.text = subProjects.remark ?? "";
      floorSlabC.text = subProjects.floorSlab?.toString() ?? "";
      selectedArea = subProjects.carpetOrSaleable ?? "";
      selectedConstProgress = constProgress
          .where((e) => e["constProgressId"] == subProjects.constructionStageId)
          .cast<Map<String, dynamic>?>()
          .firstOrNull;
      launchDate = Utils.tryParseDate(subProjects.launchDate ?? "");
      endDate = Utils.tryParseDate(subProjects.endDate ?? "");
      var result = context.read<CAddNewSubProjectCubit>().calculateFromPercentage(
        totalSupply: totalSupplyC.text,
        soldPerc: soldAreaPerC.text,
        soldEr: "Sold",
        soldErKey: "soldAreaPerc",
        isSoldInput: true,
      );
      if (result.isNotEmpty) {
        unsoldAreaSQFTC.text = result["unsoldArea"].toString();
        unsoldAreaPerC.text = result["unsoldPerc"].toString();
        soldAreaSQFTC.text = result["soldArea"].toString();
      }

      var resultLR = context.read<CAddNewSubProjectCubit>().calculateFromPercentage(
        totalSupply: totalSupplyC.text,
        soldPerc: leasedPercC.text,
        soldEr: "Leased",
        soldErKey: "leasePercent",
        isSoldInput: true,
      );
      if (resultLR.isNotEmpty) {
        vacancyAreaC.text = resultLR["unsoldArea"].toString();
        vacancyPercC.text = resultLR["unsoldPerc"].toString();
        leasedAreaSQFTC.text = resultLR["soldArea"].toString();
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    subProjectNameC.dispose();
    storeyC.dispose();
    scrC.dispose();
    maintenanceC.dispose();
    floorPlateC.dispose();
    leaseBareshellC.dispose();
    leaseWarmshellC.dispose();
    leaseFullyFurnishedC.dispose();
    outRightBareshellC.dispose();
    outRightWarmshellC.dispose();
    outRightFullyFurnishedC.dispose();
    totalSupplyC.dispose();
    soldAreaSQFTC.dispose();
    soldAreaPerC.dispose();
    unsoldAreaSQFTC.dispose();
    unsoldAreaPerC.dispose();
    leasedAreaSQFTC.dispose();
    leasedPercC.dispose();
    vacancyAreaC.dispose();
    vacancyPercC.dispose();
    reraNoC.dispose();
    remarkC.dispose();
    floorSlabC.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subProjectCubit = context.read<CAddNewSubProjectCubit>();
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: CustomAppBar(title: "Add New CSub-Project"),
      body: SafeArea(
        child: BlocListener<CAddNewSubProjectCubit, CAddNewSubProjectState>(
          listener: (context, state) {
            if (state is LocalDbState) {
              constProgress.clear();
              constProgress.addAll(state.constProjgress);
              // Prefill data after loading the construction progress list
              // from the local database to ensure the construction status is set correctly.
              prefillFields(subProjects: widget.cNewSubProjects);
            } else if (state is RateTypeState) {
              selectedArea = state.rateType;
            } else if (state is SelectConstState) {
              selectedConstProgress = state.constType;
              isValidateFloorSlab = selectedConstProgress?["constProgress"] == "Floor Slab";
            } else if (state is ValidationState) {
              subProjectNameEr = state.errors['subProjectName'];
              storeyEr = state.errors['storey'];
              scrEr = state.errors['scr'];
              maintenanceEr = state.errors['maintenance'];
              floorPlateEr = state.errors['floorPlate'];
              leaseBarshellEr = state.errors['leaseBarshell'];
              leaseWarmshellEr = state.errors['leaseWarmshell'];
              leaseFullyFurnishedEr = state.errors['leaseFullyFurnished'];
              outrightBarshellEr = state.errors['outrightBarshell'];
              outrightWarmshellEr = state.errors['outrightWarmshell'];
              outrightFullyFurnishedEr = state.errors['outrightFullyFurnished'];
              launchDateEr = state.errors['launchDate'];
              endDateEr = state.errors['endDate'];
              constProgressEr = state.errors['constProgress'];
              floorSlabEr = state.errors['floorSlab'];
              totalSupplyEr = state.errors['totalSupply'];
              soldAreaSqftEr = state.errors['soldAreaSqft'];
              soldAreaPercEr = state.errors['soldAreaPerc'];
              unsoldAreaSqftEr = state.errors['unsoldAreaSqft'];
              unsoldAreaPercEr = state.errors['unsoldAreaPerc'];
              leaseAreaSqftEr = state.errors['leaseAreaSqft'];
              leasePercentEr = state.errors['leasePercent'];
              leasePercentEr = state.errors['leasePercent'];
              vacancyAreaEr = state.errors['vacancyArea'];
              vacancyPercEr = state.errors['vacancyPerc'];
              reraNoEr = state.errors['reraNo'];
            } else if (state is ErrorState) {
              CustomSnackHelper.customToastMsg(
                context: context,
                message: state.message,
                bgColor: AppColors.white,
                textColor: AppColors.black,
              );
            } else if (state is SuccessState) {
              context.pop();
              CustomSnackHelper.customToastMsg(
                context: context,
                message: state.message,
                bgColor: AppColors.white,
                textColor: AppColors.black,
              );
            }
          },
          child: Padding(
            padding: AppDimens.hvPadding,
            child: Container(
              color: AppColors.white,
              padding: EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Stack(
                  children: [
                    Column(
                      children: [
                        BlocBuilder<CAddNewSubProjectCubit, CAddNewSubProjectState>(
                          buildWhen: (previous, current) => current is ValidationState || current is RateTypeState,
                          builder: (context, state) {
                            return Column(
                              spacing: 8.0,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomTextField(
                                  controller: subProjectNameC,
                                  labelText: "Sub Project Name",
                                  errorText: subProjectNameEr,
                                  onChanged: (value) {
                                    subProjectCubit.validateSingleField(value, "subProjectName", "Sub-Project");
                                  },
                                ),
                                CustomTextField(
                                  controller: storeyC,
                                  labelText: "Storey",
                                  errorText: storeyEr,
                                  maxLength: 2,
                                  counterText: "",
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  onChanged: (value) {
                                    subProjectCubit.validateSingleField(value, "storey", "Storey");
                                  },
                                ),
                                CustomTextField(
                                  controller: scrC,
                                  labelText: "SCR",
                                  errorText: scrEr,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [decimalFormatter],
                                  onChanged: (value) {
                                    subProjectCubit.validateSingleField(value, "scr", "SCR");
                                  },
                                ),
                                CustomTextField(
                                  controller: maintenanceC,
                                  labelText: "Maintenance",
                                  errorText: maintenanceEr,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [decimalFormatter],
                                  onChanged: (value) {
                                    subProjectCubit.validateSingleField(value, "maintenance", "Maintenance");
                                  },
                                ),
                                CustomTextField(
                                  controller: floorPlateC,
                                  labelText: "Floor Plate",
                                  errorText: floorPlateEr,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [decimalFormatter],
                                  onChanged: (value) {
                                    subProjectCubit.validateSingleField(value, "floorPlate", "Floor Plate");
                                  },
                                ),
                                BlocBuilder<CAddNewSubProjectCubit, CAddNewSubProjectState>(
                                  buildWhen: (previous, current) => current is RateTypeState,
                                  builder: (context, state) {
                                    return RadioGroup<String>(
                                      groupValue: selectedArea,
                                      onChanged: (value) {
                                        if (value != null) {
                                          subProjectCubit.selectRateType(value: value);
                                        }
                                      },
                                      child: Row(
                                        children: [
                                          Flexible(
                                            child: RadioListTile<String>(
                                              contentPadding: EdgeInsets.zero,
                                              visualDensity: VisualDensity.compact,
                                              dense: true,
                                              tileColor: AppColors.red,
                                              activeColor: AppColors.red,
                                              title: Text('Saleable'),
                                              value: 'saleable',
                                            ),
                                          ),
                                          Flexible(
                                            child: RadioListTile<String>(
                                              contentPadding: EdgeInsets.zero,
                                              visualDensity: VisualDensity.compact,
                                              dense: true,
                                              tileColor: AppColors.red,
                                              activeColor: AppColors.red,
                                              title: Text('Carpet'),
                                              value: 'carpet',
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: 8.0),
                                Text("Lease Rate(RS/Sqft)", style: AppTextStyle.ts14MB),
                                CustomTextField(
                                  controller: leaseBareshellC,
                                  labelText: "Bareshell",
                                  errorText: leaseBarshellEr,
                                  maxLength: 8,
                                  counterText: "",
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  onChanged: (value) {
                                    subProjectCubit.validateSingleField(value, "leaseBarshell", "Bareshell");
                                  },
                                ),
                                CustomTextField(
                                  controller: leaseWarmshellC,
                                  labelText: "Warmshell",
                                  errorText: leaseWarmshellEr,
                                  maxLength: 8,
                                  counterText: "",
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  onChanged: (value) {
                                    subProjectCubit.validateSingleField(value, "leaseWarmshell", "Warmshell");
                                  },
                                ),
                                CustomTextField(
                                  controller: leaseFullyFurnishedC,
                                  labelText: "Fully Furnished",
                                  errorText: leaseFullyFurnishedEr,
                                  maxLength: 8,
                                  counterText: "",
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  onChanged: (value) {
                                    subProjectCubit.validateSingleField(
                                      value,
                                      "leaseFullyFurnished",
                                      "Fully Furnished",
                                    );
                                  },
                                ),
                                SizedBox(height: 8.0),
                                Text("Outright Rate(RS/Sqft)", style: AppTextStyle.ts14MB),
                                CustomTextField(
                                  controller: outRightBareshellC,
                                  labelText: "Bareshell",
                                  errorText: outrightBarshellEr,
                                  maxLength: 8,
                                  counterText: "",
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  onChanged: (value) {
                                    subProjectCubit.validateSingleField(value, "outrightBarshell", "Bareshell");
                                  },
                                ),
                                CustomTextField(
                                  controller: outRightWarmshellC,
                                  labelText: "Warmshell",
                                  errorText: outrightWarmshellEr,
                                  maxLength: 8,
                                  counterText: "",
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  onChanged: (value) {
                                    subProjectCubit.validateSingleField(value, "outrightWarmshell", "Warmshell");
                                  },
                                ),
                                CustomTextField(
                                  controller: outRightFullyFurnishedC,
                                  labelText: "Fully Furnished",
                                  errorText: outrightFullyFurnishedEr,
                                  maxLength: 8,
                                  counterText: "",
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  onChanged: (value) {
                                    subProjectCubit.validateSingleField(
                                      value,
                                      "outrightFullyFurnished",
                                      "Fully Furnished",
                                    );
                                  },
                                ),
                                CustomDatePickerFormField(
                                  initialDate: launchDate,
                                  labelText: "Launch Date",
                                  hintText: "Select launch date",
                                  errorText: launchDateEr,
                                  onDateSelected: (value) {
                                    launchDate = value;
                                    subProjectCubit.validateDateField(value, "launchDate", "Launch Date");
                                  },
                                ),
                                CustomDatePickerFormField(
                                  initialDate: endDate,
                                  firstDate: launchDate,
                                  labelText: "End Date",
                                  hintText: "Select end date",
                                  errorText: endDateEr,
                                  onDateSelected: (value) {
                                    endDate = value;
                                    subProjectCubit.validateDateField(value, "endDate", "End Date");
                                  },
                                ),
                                SizedBox(height: 4),
                                BlocBuilder<CAddNewSubProjectCubit, CAddNewSubProjectState>(
                                  buildWhen: (previous, current) =>
                                      current is LocalDbState || current is SelectConstState,
                                  builder: (context, state) {
                                    return Column(
                                      spacing: 8.0,
                                      children: [
                                        CustomDropdown(
                                          initialValue: selectedConstProgress,
                                          lableText: "Construction Progress",
                                          hintText: "Select construction progress",
                                          items: constProgress,
                                          labelKey: "constProgress",
                                          errorText: constProgressEr,
                                          onChanged: (value) {
                                            subProjectCubit.selectConstProgress(value: value);
                                          },
                                        ),
                                        if (selectedConstProgress?["constProgress"] == "Floor Slab")
                                          CustomTextField(
                                            controller: floorSlabC,
                                            labelText: "Floor Slab",
                                            errorText: floorSlabEr,
                                            maxLength: 2,
                                            counterText: "",
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                            onChanged: (value) {
                                              subProjectCubit.validateSingleField(value, "floorSlab", "Floor Slab");
                                            },
                                          ),
                                      ],
                                    );
                                  },
                                ),

                                CustomTextField(
                                  controller: totalSupplyC,
                                  labelText: "Total Supply",
                                  errorText: totalSupplyEr,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [decimalFormatter],
                                  onChanged: (value) {
                                    subProjectCubit.validateSingleField(value, "totalSupply", "Total Supply");
                                  },
                                ),
                                CustomTextField(
                                  readOnly: true,
                                  disable: true,
                                  controller: soldAreaSQFTC,
                                  labelText: "Sold Area(Sqft)",
                                  errorText: soldAreaSqftEr,
                                  onChanged: (value) {
                                    subProjectCubit.validateSingleField(value, "soldAreaSqft", "Sold Area(Sqft)");
                                  },
                                ),
                                CustomTextField(
                                  controller: soldAreaPerC,
                                  labelText: "Sold Percent",
                                  errorText: soldAreaPercEr,
                                  onChanged: (value) {
                                    subProjectCubit.validateSingleField(value, "soldAreaPerc", "Sold Percentage");
                                    var result = subProjectCubit.calculateFromPercentage(
                                      totalSupply: totalSupplyC.text,
                                      soldPerc: value,
                                      soldEr: "Sold",
                                      soldErKey: "soldAreaPerc",
                                      isSoldInput: true,
                                    );
                                    if (result.isNotEmpty) {
                                      unsoldAreaSQFTC.text = result["unsoldArea"].toString();
                                      unsoldAreaPerC.text = result["unsoldPerc"].toString();
                                      soldAreaSQFTC.text = result["soldArea"].toString();
                                    }
                                  },
                                ),
                                CustomTextField(
                                  disable: true,
                                  readOnly: true,
                                  controller: unsoldAreaSQFTC,
                                  labelText: "Unsold Area(Sqft)",
                                  errorText: unsoldAreaSqftEr,
                                  onChanged: (value) {
                                    subProjectCubit.validateSingleField(value, "unsoldAreaSqft", "Unsold Area(Sqft)");
                                  },
                                ),
                                CustomTextField(
                                  controller: unsoldAreaPerC,
                                  labelText: "Unsold Percent",
                                  errorText: unsoldAreaPercEr,
                                  onChanged: (value) {
                                    subProjectCubit.validateSingleField(value, "unsoldAreaPerc", "Unsold Percentage");
                                    var result = subProjectCubit.calculateFromPercentage(
                                      totalSupply: totalSupplyC.text,
                                      unsoldPerc: value,
                                      unsoldEr: "Unsold",
                                      unsoldErKey: "unsoldAreaPerc",
                                      isSoldInput: false,
                                    );
                                    if (result.isNotEmpty) {
                                      unsoldAreaSQFTC.text = result["unsoldArea"].toString();
                                      soldAreaPerC.text = result["soldPerc"].toString();
                                      soldAreaSQFTC.text = result["soldArea"].toString();
                                    }
                                  },
                                ),
                                CustomTextField(
                                  disable: true,
                                  readOnly: true,
                                  controller: leasedAreaSQFTC,
                                  labelText: "Lease / Occupaied Area(Sqft)",
                                  errorText: leaseAreaSqftEr,
                                  onChanged: (value) {
                                    subProjectCubit.validateSingleField(
                                      value,
                                      "leaseAreaSqft",
                                      "Lease(occupaied) area",
                                    );
                                  },
                                ),
                                CustomTextField(
                                  controller: leasedPercC,
                                  labelText: "Lease Percent",
                                  errorText: leasePercentEr,
                                  onChanged: (value) {
                                    subProjectCubit.validateSingleField(value, "leasePercent", "Lease percentage");
                                    var result = subProjectCubit.calculateFromPercentage(
                                      totalSupply: totalSupplyC.text,
                                      soldPerc: value,
                                      soldEr: "Leased",
                                      soldErKey: "leasePercent",
                                      isSoldInput: true,
                                    );
                                    if (result.isNotEmpty) {
                                      vacancyAreaC.text = result["unsoldArea"].toString();
                                      vacancyPercC.text = result["unsoldPerc"].toString();
                                      leasedAreaSQFTC.text = result["soldArea"].toString();
                                    }
                                  },
                                ),
                                CustomTextField(
                                  disable: true,
                                  controller: vacancyAreaC,
                                  labelText: "Vacancy Area(Sqft)",
                                  errorText: vacancyAreaEr,
                                  onChanged: (value) {
                                    subProjectCubit.validateSingleField(value, "vacancyArea", "Vacancy Area");
                                  },
                                ),
                                CustomTextField(
                                  controller: vacancyPercC,
                                  labelText: "Vacancy Percent",
                                  errorText: vacancyPercEr,
                                  onChanged: (value) {
                                    subProjectCubit.validateSingleField(value, "vacancyPerc", "Vacancy percentage");
                                    var result = subProjectCubit.calculateFromPercentage(
                                      totalSupply: totalSupplyC.text,
                                      unsoldPerc: value,
                                      unsoldEr: "Vacancy",
                                      unsoldErKey: "vacancyPerc",
                                      isSoldInput: false,
                                    );
                                    if (result.isNotEmpty) {
                                      vacancyAreaC.text = result["unsoldArea"].toString();
                                      leasedPercC.text = result["soldPerc"].toString();
                                      leasedAreaSQFTC.text = result["soldArea"].toString();
                                    }
                                  },
                                ),
                                CustomTextField(
                                  controller: reraNoC,
                                  labelText: "Rera No",
                                  errorText: reraNoEr,
                                  onChanged: (value) {
                                    subProjectCubit.validateSingleField(value, "reraNo", "Rera number");
                                  },
                                ),
                                CustomTextField(controller: remarkC, labelText: "Remarks"),
                                SizedBox(height: 30),
                              ],
                            );
                          },
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: CustomElevatedButton(
                            backgroundColor: AppColors.red,
                            text: "SAVE",
                            onPressed: () {
                              subProjectCubit.submitData(
                                projectId: widget.cNewProjectEntity?.prjId ?? "",
                                dos: widget.project?.dos ?? widget.cNewProjectEntity?.dos,
                                prjIdLF: widget.project?.projectId ?? 0,
                                subProjectName: subProjectNameC.text,
                                storey: storeyC.text,
                                scr: scrC.text,
                                maintenance: maintenanceC.text,
                                floorPlate: floorPlateC.text,
                                selectedArea: selectedArea,
                                leaseBareshell: leaseBareshellC.text,
                                leaseWarmshell: leaseWarmshellC.text,
                                leaseFullyFurnished: leaseFullyFurnishedC.text,
                                outrightBarshell: outRightBareshellC.text,
                                outrightWarmshell: outRightWarmshellC.text,
                                outrightFullyFurnished: outRightFullyFurnishedC.text,
                                launchDate: launchDate,
                                endDate: endDate,
                                selectedConstProgress: selectedConstProgress,
                                isValidateFloorSlab: isValidateFloorSlab,
                                floorSlab: floorSlabC.text,
                                totalSupply: totalSupplyC.text,
                                soldAreaSqft: soldAreaSQFTC.text,
                                soldAreaPerc: soldAreaPerC.text,
                                unsoldAreaSqft: unsoldAreaSQFTC.text,
                                unsoldAreaPerc: unsoldAreaPerC.text,
                                leaseAreaSqft: leasedAreaSQFTC.text,
                                leasePercent: leasedPercC.text,
                                vacancyArea: vacancyAreaC.text,
                                vacancyPerc: vacancyPercC.text,
                                reraNo: reraNoC.text,
                                remarks: remarkC.text,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    if (widget.cNewSubProjects != null && widget.cNewSubProjects?.globalSyncStatus == 1)
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
    );
  }

  TextInputFormatter decimalFormatter = TextInputFormatter.withFunction((oldValue, newValue) {
    final text = newValue.text;
    // Allow empty
    if (text.isEmpty) return newValue;
    // Check if valid decimal with only one dot
    final isValid = RegExp(r'^\d*\.?\d*$').hasMatch(text);
    return isValid ? newValue : oldValue;
  });
}
