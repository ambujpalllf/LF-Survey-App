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
import 'package:lf_survey/cubit/residential/sub_project/sprj_details_form/sprj_details_form_cubit.dart';
import 'package:lf_survey/cubit/residential/sub_project/sprj_details_form/sprj_details_form_state.dart';
import 'package:lf_survey/model/db_model/residential/sub_prj_entity.dart';
// import 'package:lf_survey/model/residential/project_response.dart';
import 'package:lf_survey/model/residential/project_spinner.dart';
import 'package:lf_survey/widgets/custom_app_bar.dart';
import 'package:lf_survey/widgets/custom_date_picker.dart';
import 'package:lf_survey/widgets/custom_dropdown.dart';
import 'package:lf_survey/widgets/custom_elevated_btn.dart';
import 'package:lf_survey/widgets/custom_textfield.dart';
import 'package:lf_survey/widgets/number_comma_input_formatters.dart';
import 'package:lf_survey/widgets/sub_project_multi_dropdown.dart';

enum AreaType { saleable, carpet }

// ignore: must_be_immutable
class SubProjectDetailsFormPage extends StatefulWidget {
  // SubProjectsDatum subProjectsDatum;
  SubProjectEntity subProjectsDatum;
  SubProjectDetailsFormPage({super.key, required this.subProjectsDatum});

  @override
  State<SubProjectDetailsFormPage> createState() => _SubProjectDetailsFormPageState();
}

class _SubProjectDetailsFormPageState extends State<SubProjectDetailsFormPage> {
  late FocusNode scrFocusNode;
  AreaType _selectedType = AreaType.saleable;
  TextEditingController storeyC = TextEditingController();
  TextEditingController flatC = TextEditingController();
  TextEditingController scrC = TextEditingController();
  TextEditingController saleableRateC = TextEditingController();
  TextEditingController carpetRateC = TextEditingController();
  TextEditingController startDateC = TextEditingController();
  TextEditingController endDateC = TextEditingController();
  TextEditingController floorSlabC = TextEditingController();
  TextEditingController projectStatusC = TextEditingController();
  TextEditingController remarkC = TextEditingController();
  TextEditingController maintenanceC = TextEditingController();
  TextEditingController stiltParkingChargeC = TextEditingController();
  TextEditingController openParkingChargeC = TextEditingController();
  TextEditingController podiumParkingChargeC = TextEditingController();
  TextEditingController doublePodiumParkingChargeC = TextEditingController();
  TextEditingController basementParkingChargeC = TextEditingController();
  TextEditingController floorRiseC = TextEditingController();

  // villa section
  TextEditingController vilaStartedC = TextEditingController();
  TextEditingController vilaPilingC = TextEditingController();
  TextEditingController vilaPlinthC = TextEditingController();
  TextEditingController vilaFloorSlabC = TextEditingController();
  TextEditingController vilaInternalWC = TextEditingController();
  TextEditingController vilaExternalC = TextEditingController();
  TextEditingController vilaCompleteC = TextEditingController();

  List<Map<String, dynamic>> constructionProgress = [];
  List<Map<String, dynamic>> bookingRemarks = [];
  List<Map<String, dynamic>> deleteSubProjectRemarks = [];
  List<ProjectStatusList> projectStatus = [];
  ProjectStatusList? selectedProjectStaus;
  Map<String, dynamic>? selectedConstructionProgress;
  List? selectedBookingRemarks;
  List? selectedDeleteRemarks;
  bool isBooking = false;
  bool isDeleteSubProject = false;

  String scrErrorMsg = '';

  bool isReadOnly = false;
  DateTime? endFirstDate;
  @override
  void initState() {
    super.initState();
    scrFocusNode = FocusNode();

    scrFocusNode.addListener(() {
      if (scrFocusNode.hasFocus) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Please check if Car Parking,Floor Rise or any amenities charges are included in this rate."),
            duration: Duration(seconds: 3),
          ),
        );
      }
    });
    context.read<SPrjDetailsFormCubit>().fetchData(
      subProjectId: widget.subProjectsDatum.subProjectId!,
      projectId: widget.subProjectsDatum.projectId!,
    );
    _selectedType = widget.subProjectsDatum.rateType!.toLowerCase() == "saleable" ? AreaType.saleable : AreaType.carpet;
    prefillFields(widget.subProjectsDatum);
  }

  void prefillFields(SubProjectEntity subProjectsDatum) {
    storeyC.text = subProjectsDatum.storey.toString();
    flatC.text = subProjectsDatum.flatsPerFloor.toString();
    scrC.text = subProjectsDatum.scr.toString();
    saleableRateC.text = subProjectsDatum.saleableRatepsf.toString();
    carpetRateC.text = subProjectsDatum.carpetRatepsf.toString();
    startDateC.text = (subProjectsDatum.startDate == null)
        ? ""
        : DateFormat('dd MMM yyyy').format(Utils.tryParseDate(subProjectsDatum.startDate!)!);
    final startDate = Utils.tryParseDate(subProjectsDatum.startDate!);
    if (startDate != null) {
      endFirstDate = DateTime(startDate.year, startDate.month + 5, startDate.day + 1);
    }
    endDateC.text = (subProjectsDatum.endDate == null)
        ? ""
        : DateFormat('dd MMM yyyy').format(Utils.tryParseDate(subProjectsDatum.endDate!)!);
    floorSlabC.text = subProjectsDatum.floorSlab.toString();
    // projectStatusC.text = subProjectsDatum
    remarkC.text = subProjectsDatum.remarks ?? "";
    maintenanceC.text = subProjectsDatum.maintenancePersqft.toString();
    stiltParkingChargeC.text = subProjectsDatum.stiltPark ?? "";
    openParkingChargeC.text = subProjectsDatum.openPark ?? "";
    podiumParkingChargeC.text = subProjectsDatum.podium ?? "";
    doublePodiumParkingChargeC.text = subProjectsDatum.doublePodium ?? "";
    basementParkingChargeC.text = subProjectsDatum.basementPark ?? "";
    floorRiseC.text = subProjectsDatum.floorRise.toString();
    setState(() {
      selectedConstructionProgress = constructionProgress.firstWhere(
        (i) => i["id"] == widget.subProjectsDatum.constructionProgressId,
        orElse: () => {},
      );

      String progressTitle = selectedConstructionProgress?["title"] ?? "";

      if (progressTitle == "Complete") {
        selectedProjectStaus = projectStatus.firstWhere(
          (e) => e.projectStatus == "Ready",
          orElse: () => ProjectStatusList(),
        );
      } else {
        selectedProjectStaus = projectStatus.firstWhere(
          (e) => e.projectStatus == "UC",
          orElse: () => ProjectStatusList(),
        );
      }
      projectStatusC.text = selectedProjectStaus?.projectStatus ?? "";
      isBooking = subProjectsDatum.bookingStop == 0 ? false : true;
      isDeleteSubProject = subProjectsDatum.deleteFlag == 1;
      isReadOnly = subProjectsDatum.syncGlobalStatus == 1 ? true : false;
    });
    vilaStartedC.text = subProjectsDatum.percVilaStarted ?? "";
    vilaPilingC.text = subProjectsDatum.percVilaPiling ?? "";
    vilaPlinthC.text = subProjectsDatum.percVilaPlinth ?? "";
    vilaFloorSlabC.text = subProjectsDatum.percVilaFloorslab ?? "";
    vilaInternalWC.text = subProjectsDatum.percVilaInternalWork ?? "";
    vilaExternalC.text = subProjectsDatum.percVilaExternal ?? "";
    vilaCompleteC.text = subProjectsDatum.percVilaComplete ?? "";
  }

  @override
  void dispose() {
    super.dispose();
    storeyC.dispose();
    flatC.dispose();
    scrC.dispose();
    saleableRateC.dispose();
    carpetRateC.dispose();
    startDateC.dispose();
    endDateC.dispose();
    floorSlabC.dispose();
    projectStatusC.dispose();
    remarkC.dispose();
    maintenanceC.dispose();
    stiltParkingChargeC.dispose();
    openParkingChargeC.dispose();
    podiumParkingChargeC.dispose();
    doublePodiumParkingChargeC.dispose();
    basementParkingChargeC.dispose();
    floorRiseC.dispose();
    vilaStartedC.dispose();
    vilaPilingC.dispose();
    vilaPlinthC.dispose();
    vilaFloorSlabC.dispose();
    vilaInternalWC.dispose();
    vilaExternalC.dispose();
    vilaCompleteC.dispose();
    scrFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SPrjDetailsFormCubit sPrjDetailsFormCubit = context.read<SPrjDetailsFormCubit>();
    return BlocListener<SPrjDetailsFormCubit, SPrjDetailsFormState>(
      listener: (context, state) {
        if (state is ErrorState) {
          scrErrorMsg = state.scrMsg;
          if (state.message != "") {
            CustomSnackHelper.customToastMsg(
              context: context,
              message: state.message,
              bgColor: AppColors.white,
              textColor: AppColors.black,
            );
          }
        } else if (state is LocalDbState) {
          constructionProgress.clear();
          bookingRemarks.clear();
          deleteSubProjectRemarks.clear();
          projectStatus.clear();
          setState(() {
            // if project is open plot then remove these ids otherwise remains all.
            if (widget.subProjectsDatum.flatgroupid == 13) {
              final excludedIds = [2, 3, 4, 5, 9, 10];
              constructionProgress = state.constProgress
                  .where((e) => !excludedIds.contains(e.constProgressId))
                  .map((e) => {"id": e.constProgressId, "title": e.constProgress})
                  .toList();
            } else {
              constructionProgress = state.constProgress
                  .map((e) => {"id": e.constProgressId, "title": e.constProgress})
                  .toList();
            }
            bookingRemarks = state.bookingStopRemarks.map((e) => {"id": e.remarksId, "title": e.remarks}).toList();
            bookingRemarks.add({"id": 0, "title": "Other"});
            deleteSubProjectRemarks = state.subProjectDeleteRemarks
                .map((e) => {"id": e.remarksId, "title": e.remarks})
                .toList();
            projectStatus = state.projectStatus;
            widget.subProjectsDatum = state.subProjectsDatum;
            prefillFields(widget.subProjectsDatum);
          });
        } else if (state is SuccessState) {
          context.pop();
          CustomSnackHelper.succesSnackbar(context: context, message: state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.appBg,
        appBar: CustomAppBar(title: "Sub Project Details Form"),
        body: SafeArea(
          child: Padding(
            padding: AppDimens.hvPadding,
            child: Container(
              padding: EdgeInsets.all(8.0),
              color: AppColors.white,
              child: SingleChildScrollView(
                child: Column(
                  spacing: 12.0,
                  children: [
                    CustomTextField(
                      // you can not change for existing project. It can be only change for new assign project which is not open plot
                      readOnly:
                          widget.subProjectsDatum.assignedNewPrj == 0 ||
                          widget.subProjectsDatum.syncGlobalStatus == 1 ||
                          widget.subProjectsDatum.flatgroupid == 13,
                      style: widget.subProjectsDatum.assignedNewPrj == 1
                          ? AppTextStyle.ts14MB
                          : TextStyle(color: Colors.grey.shade400),
                      borderColor: widget.subProjectsDatum.assignedNewPrj == 1
                          ? AppColors.greyLite
                          : Colors.grey.shade200,
                      lableTextColor: widget.subProjectsDatum.assignedNewPrj == 1
                          ? AppColors.black
                          : Colors.grey.shade400,
                      labelText: "Storey",
                      controller: storeyC,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                    ),
                    CustomTextField(
                      // you can not change for existing project. It can be only change for new assign project which is not open plot.
                      readOnly:
                          widget.subProjectsDatum.assignedNewPrj == 0 ||
                          widget.subProjectsDatum.syncGlobalStatus == 1 ||
                          widget.subProjectsDatum.flatgroupid == 13,
                      style: widget.subProjectsDatum.assignedNewPrj == 1
                          ? AppTextStyle.ts14MB
                          : TextStyle(color: Colors.grey.shade400),
                      borderColor: widget.subProjectsDatum.assignedNewPrj == 1
                          ? AppColors.greyLite
                          : Colors.grey.shade200,
                      lableTextColor: widget.subProjectsDatum.assignedNewPrj == 1
                          ? AppColors.black
                          : Colors.grey.shade400,
                      labelText: "Flats / floor",
                      controller: flatC,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                    ),
                    BlocBuilder<SPrjDetailsFormCubit, SPrjDetailsFormState>(
                      buildWhen: (previous, current) => current is ErrorState,
                      builder: (context, state) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomTextField(
                              readOnly: isReadOnly,
                              labelText: "SCR*",
                              controller: scrC,
                              focusNode: scrFocusNode,
                              keyboardType: TextInputType.number,
                              maxLength: 2,
                              counterText: "",
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                              suffixIcon: scrErrorMsg.isEmpty ? null : Icon(Icons.error, color: AppColors.red),
                              onChanged: (value) {
                                if (value.isEmpty) return;
                                sPrjDetailsFormCubit.validationFields(
                                  subProjectData: widget.subProjectsDatum,
                                  storey: storeyC.text,
                                  scr: value,
                                  // flatGroupId: widget.subProjectsDatum.flatgroupid!,
                                );
                              },
                            ),
                            scrErrorMsg.isEmpty ? Container() : CustomSnackHelper.errorWidget(messgage: scrErrorMsg),
                          ],
                        );
                      },
                    ),

                    RadioGroup<AreaType>(
                      groupValue: _selectedType,
                      onChanged: (AreaType? newValue) {
                        // setState(() {
                        //   _selectedType = newValue!;
                        // });
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            flex: 1,
                            child: RadioListTile<AreaType>(
                              enabled: false,
                              value: AreaType.saleable,
                              title: Text("Saleable", style: AppTextStyle.ts14RB),
                              visualDensity: VisualDensity.compact,
                              contentPadding: EdgeInsets.zero,
                              activeColor: AppColors.red,
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: RadioListTile<AreaType>(
                              value: AreaType.carpet,
                              enabled: false,
                              title: Text("Carpet", style: AppTextStyle.ts14RB),
                              visualDensity: VisualDensity.compact,
                              contentPadding: EdgeInsets.zero,
                              activeColor: AppColors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CustomTextField(
                      readOnly: isReadOnly == true
                          ? true
                          : widget.subProjectsDatum.rateType!.toLowerCase() == "saleable"
                          ? false
                          : true,
                      style: TextStyle(
                        color: widget.subProjectsDatum.rateType!.toLowerCase() != "saleable"
                            ? Colors.grey.shade400
                            : Colors.black,
                      ),
                      borderColor: widget.subProjectsDatum.rateType!.toLowerCase() != "saleable"
                          ? Colors.grey.shade200
                          : AppColors.greyLite,
                      lableTextColor: widget.subProjectsDatum.rateType!.toLowerCase() != "saleable"
                          ? Colors.grey.shade400
                          : Colors.black,
                      labelText: "Saleable Rate PSF*",
                      controller: saleableRateC,
                      maxLength: 9,
                      counterText: "",
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                    ),
                    CustomTextField(
                      readOnly: isReadOnly == true
                          ? true
                          : widget.subProjectsDatum.rateType!.toLowerCase() == "saleable"
                          ? true
                          : false,
                      labelText: "Carpet Rate PSF*",
                      style: TextStyle(
                        color: widget.subProjectsDatum.rateType!.toLowerCase() == "saleable"
                            ? Colors.grey.shade400
                            : Colors.black,
                      ),
                      borderColor: widget.subProjectsDatum.rateType!.toLowerCase() == "saleable"
                          ? Colors.grey.shade200
                          : AppColors.greyLite,
                      lableTextColor: widget.subProjectsDatum.rateType!.toLowerCase() == "saleable"
                          ? Colors.grey.shade400
                          : Colors.black,
                      controller: carpetRateC,
                      maxLength: 8,
                      counterText: "",
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                    ),
                    CustomDatePickerFormField(enabled: false, labelText: "Start Date*", controller: startDateC),
                    CustomDatePickerFormField(
                      enabled: isReadOnly == true ? false : true,
                      // firstDate: DateTime.now(),
                      firstDate: endFirstDate,
                      labelText: "End Date*",
                      controller: endDateC,
                      onDateSelected: (value) {
                        endDateC.text = DateFormat("dd MMM yyyy").format(value);
                      },
                    ),
                    BlocBuilder<SPrjDetailsFormCubit, SPrjDetailsFormState>(
                      buildWhen: (previous, current) => current is LocalDbState,
                      builder: (context, state) {
                        return CustomDropdown(
                          disabled: isReadOnly,
                          initialValue:
                              selectedConstructionProgress ??
                              constructionProgress.firstWhere(
                                (i) => i["id"] == widget.subProjectsDatum.constructionProgressId,
                                orElse: () => {},
                              ),

                          items: constructionProgress,
                          labelKey: "title",
                          hintText: "Select",
                          lableText: "Construction Progress",
                          onChanged: (value) {
                            setState(() {
                              selectedConstructionProgress = value;
                              if (selectedConstructionProgress!["title"] == "Complete") {
                                selectedProjectStaus = selectedProjectStaus = projectStatus.firstWhere(
                                  (e) => e.projectStatus == "Ready",
                                );
                                projectStatusC.text = selectedProjectStaus?.projectStatus ?? "";
                              } else {
                                selectedProjectStaus = selectedProjectStaus = projectStatus.firstWhere(
                                  (e) => e.projectStatus == "UC",
                                );
                                projectStatusC.text = selectedProjectStaus?.projectStatus ?? "";
                                // projectStatusC.text = "UC";
                              }
                            });
                          },
                        );
                      },
                    ),
                    selectedConstructionProgress?["title"] == "Floor Slab"
                        ? CustomTextField(
                            readOnly: isReadOnly,
                            labelText: "Floor Slab",
                            controller: floorSlabC,
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            counterText: "",
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                          )
                        : SizedBox.shrink(),
                    IgnorePointer(
                      ignoring: true,
                      child: CustomTextField(
                        filled: true,
                        fillColor: AppColors.greyLite,
                        labelText: "Project Status",
                        controller: projectStatusC,
                        lableTextColor: Colors.grey,
                      ),
                    ),
                    CustomTextField(readOnly: isReadOnly, labelText: "Remark", controller: remarkC),
                    CustomTextField(
                      readOnly: isReadOnly,
                      labelText: "Maintenance (Rs/Sqft)*",
                      controller: maintenanceC,
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      counterText: "",
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                    ),
                    CustomTextField(
                      readOnly: isReadOnly,
                      labelText: "Stilt Parking Charges (Rs)",
                      controller: stiltParkingChargeC,
                      maxLength: 12,
                      counterText: "",
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, NumberCommaInputFormatter()],
                    ),
                    CustomTextField(
                      readOnly: isReadOnly,
                      labelText: "Open Parking Charges (Rs)",
                      controller: openParkingChargeC,
                      maxLength: 12,
                      counterText: "",
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, NumberCommaInputFormatter()],
                    ),
                    CustomTextField(
                      readOnly: isReadOnly,
                      labelText: "Podium Parking Charges (Rs)",
                      controller: podiumParkingChargeC,
                      maxLength: 12,
                      counterText: "",
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, NumberCommaInputFormatter()],
                    ),
                    CustomTextField(
                      readOnly: isReadOnly,
                      labelText: "Double Podium Parking Charges (Rs)",
                      controller: doublePodiumParkingChargeC,
                      maxLength: 12,
                      counterText: "",
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, NumberCommaInputFormatter()],
                    ),
                    CustomTextField(
                      readOnly: isReadOnly,
                      labelText: "Basement Parking Charges (Rs)",
                      controller: basementParkingChargeC,
                      keyboardType: TextInputType.number,
                      maxLength: 12,
                      counterText: "",
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, NumberCommaInputFormatter()],
                    ),
                    CheckboxListTile(
                      enabled: isReadOnly == true ? false : true,
                      visualDensity: VisualDensity.compact,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      checkColor: AppColors.white,
                      activeColor: AppColors.red,
                      value: isBooking,
                      onChanged: (value) {
                        setState(() {
                          isBooking = value!;
                        });
                      },
                      title: Text("Booking Stop", style: AppTextStyle.ts14RB),
                    ),
                    isBooking
                        ? SubProjectMultiSelectDropdown(
                            items: bookingRemarks,
                            labelKey: "title",
                            labelText: "Booking Remarks",
                            hintText: "Select Booking Stop Remarks",
                            onChanged: (value) {
                              selectedBookingRemarks?.clear();
                              selectedBookingRemarks = value;
                            },
                          )
                        : SizedBox.shrink(),
                    CustomTextField(
                      readOnly: isReadOnly,
                      labelText: "Floor Rise",
                      controller: floorRiseC,
                      maxLength: 4,
                      counterText: "",
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    CheckboxListTile(
                      enabled: isReadOnly == true ? false : true,
                      visualDensity: VisualDensity.compact,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      checkColor: AppColors.white,
                      activeColor: AppColors.red,
                      value: isDeleteSubProject,
                      onChanged: (value) {
                        setState(() {
                          isDeleteSubProject = value!;
                        });
                      },
                      title: Text("Delete Sub Project", style: AppTextStyle.ts14RB),
                    ),
                    isDeleteSubProject
                        ? SubProjectMultiSelectDropdown(
                            disabled: isReadOnly,
                            items: deleteSubProjectRemarks,
                            labelKey: "title",
                            labelText: "Delete Sub Project Remarks",
                            hintText: "Select Delete Remarks",
                            onChanged: (value) {
                              if (value.isEmpty) return;
                              selectedDeleteRemarks?.clear();
                              selectedDeleteRemarks = value;
                            },
                          )
                        : SizedBox.shrink(),
                    // widget.subProjectsDatum.hasVillas == true
                    widget.subProjectsDatum.hasVillas == 1
                        ? villaWidget(
                            vilaStartedC: vilaStartedC,
                            vilaPilingC: vilaPilingC,
                            vilaPlinthC: vilaPlinthC,
                            vilaFloorSlabC: vilaFloorSlabC,
                            vilaInternalWC: vilaInternalWC,
                            vilaExternalC: vilaExternalC,
                            vilaCompleteC: vilaCompleteC,
                            isReadOnly: isReadOnly,
                          )
                        : SizedBox.shrink(),
                    SizedBox(height: 20),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: BlocBuilder<SPrjDetailsFormCubit, SPrjDetailsFormState>(
                        builder: (context, state) {
                          bool isLoading = false;
                          if (state is LoadingState) {
                            isLoading = true;
                          } else {
                            isLoading = false;
                          }
                          return CustomElevatedButton(
                            isLoading: isLoading,
                            backgroundColor: AppColors.red,
                            text: "SAVE",
                            onPressed: () async {
                              if (!await Utils.checkLocationAndGpsPermission(context)) return;
                              if (!context.mounted) return;
                              bool result = context.read<SPrjDetailsFormCubit>().validationFields(
                                subProjectData: widget.subProjectsDatum,
                                storey: storeyC.text,
                                scr: scrC.text,
                                saleableRatePSF: saleableRateC.text,
                                carpetRatePSF: carpetRateC.text,
                                constProgress: selectedConstructionProgress,
                                endDate: endDateC.text,
                                floorSlab: floorSlabC.text,
                                selectedBookingRemarks: selectedBookingRemarks ?? [],
                                selectedDeleteRemarks: selectedDeleteRemarks ?? [],
                                isBooking: isBooking,
                                isDeleteSubProject: isDeleteSubProject,
                              );
                              if (result == true) {
                                context.read<SPrjDetailsFormCubit>().updateSubProject(
                                  subProjectData: widget.subProjectsDatum,
                                  storey: storeyC.text,
                                  flatsPerFloor: flatC.text,
                                  scr: scrC.text,
                                  isSaleable: widget.subProjectsDatum.rateType!.toLowerCase() == "saleable"
                                      ? true
                                      : false,
                                  saleableRatePSF: saleableRateC.text,
                                  carpetRatePSF: carpetRateC.text,
                                  endDate: endDateC.text,
                                  constructionProgressId: selectedConstructionProgress!["id"],
                                  projectStatus: selectedProjectStaus!,
                                  floorSlab: floorSlabC.text,
                                  remark: remarkC.text,
                                  maintenancePerSqft: maintenanceC.text,
                                  stiltParking: stiltParkingChargeC.text,
                                  openParking: openParkingChargeC.text,
                                  podiumParking: podiumParkingChargeC.text,
                                  doublePodiumParking: doublePodiumParkingChargeC.text,
                                  basementParking: basementParkingChargeC.text,
                                  isBooking: isBooking,
                                  bookingRemark: selectedBookingRemarks ?? [],
                                  floorRise: floorRiseC.text,
                                  isDeleteSubProject: isDeleteSubProject,
                                  deleteRemark: selectedDeleteRemarks ?? [],
                                  percVilaStarted: vilaStartedC.text,
                                  percVilaPiling: vilaPilingC.text,
                                  percVilaPlinth: vilaPlinthC.text,
                                  percVilaFloorslab: vilaFloorSlabC.text,
                                  percVilaInternalWork: vilaInternalWC.text,
                                  percVilaExternal: vilaExternalC.text,
                                  percVilaComplete: vilaCompleteC.text,
                                );
                              }
                            },
                          );
                        },
                      ),
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

  Widget villaWidget({
    required TextEditingController vilaStartedC,
    required TextEditingController vilaPilingC,
    required TextEditingController vilaPlinthC,
    required TextEditingController vilaFloorSlabC,
    required TextEditingController vilaInternalWC,
    required TextEditingController vilaExternalC,
    required TextEditingController vilaCompleteC,
    required bool isReadOnly,
  }) {
    return Column(
      spacing: 12.0,
      children: [
        CustomTextField(readOnly: isReadOnly, labelText: "Vila Started", controller: vilaStartedC),
        CustomTextField(readOnly: isReadOnly, labelText: "Vila Piling", controller: vilaPilingC),
        CustomTextField(readOnly: isReadOnly, labelText: "Vila Plinth", controller: vilaPlinthC),
        CustomTextField(readOnly: isReadOnly, labelText: "Vila Floor Slab", controller: vilaFloorSlabC),
        CustomTextField(readOnly: isReadOnly, labelText: "Vila Internal Work", controller: vilaInternalWC),
        CustomTextField(readOnly: isReadOnly, labelText: "Vila External", controller: vilaExternalC),
        CustomTextField(readOnly: isReadOnly, labelText: "Vila Complete", controller: vilaCompleteC),
      ],
    );
  }
}
