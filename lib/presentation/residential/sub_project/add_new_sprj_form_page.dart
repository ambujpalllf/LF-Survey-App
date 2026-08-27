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
import 'package:lf_survey/cubit/residential/sub_project/add_sprj_form/add_sprj_cubit.dart';
import 'package:lf_survey/cubit/residential/sub_project/add_sprj_form/add_sprj_form_state.dart';
import 'package:lf_survey/model/db_model/residential/new_sub_project_entity.dart';
import 'package:lf_survey/model/residential/project_spinner.dart';
import 'package:lf_survey/widgets/custom_app_bar.dart';
import 'package:lf_survey/widgets/custom_date_picker.dart';
import 'package:lf_survey/widgets/custom_dropdown.dart';
import 'package:lf_survey/widgets/custom_elevated_btn.dart';
import 'package:lf_survey/widgets/custom_textfield.dart';
import 'package:lf_survey/widgets/number_comma_input_formatters.dart';

enum AreaType { saleable, carpet }

class AddNewSPrjFormPage extends StatefulWidget {
  final String formType;
  final String newProjectId;
  final int projectId;
  final int cityId;
  final String reraNo;
  final NewSubProjectEntity? newSubPrjEntity;
  final bool? isFreeze;
  const AddNewSPrjFormPage({
    super.key,
    required this.formType,
    required this.cityId,
    required this.newProjectId,
    required this.projectId,
    required this.reraNo,
    this.newSubPrjEntity,
    this.isFreeze,
  });

  @override
  State<AddNewSPrjFormPage> createState() => _AddNewSPrjFormPageState();
}

class _AddNewSPrjFormPageState extends State<AddNewSPrjFormPage> {
  int qtrId = 0;
  String qtr = "";
  DateTime? qtrDate;
  AreaType _selectedType = AreaType.saleable;
  List<CityList> cities = [];
  List<Map<String, dynamic>> flatGroup = [
    {"id": 1, "title": "Apartments"},
    {"id": 2, "title": "Villas & Bunglows"},
    {"id": 3, "title": "Open Plots"},
    {"id": 4, "title": "Floors"},
  ];
  List<Map<String, dynamic>> constructionProgress = [];
  List<Map<String, dynamic>> tempConstructionProgress = [];
  List<ProjectStatusList> projectStatus = [];
  Map<String, dynamic>? selectedFlatGroup;
  Map<String, dynamic>? selectedConstProgress;
  ProjectStatusList? selectedProjectStaus;
  TextEditingController subProjectNameC = TextEditingController();
  TextEditingController storeyC = TextEditingController();
  TextEditingController scrC = TextEditingController();
  TextEditingController maintenanceC = TextEditingController();
  TextEditingController flatC = TextEditingController();
  TextEditingController saleableLaunchPriceC = TextEditingController();
  TextEditingController carpetLaunchPriceC = TextEditingController();
  TextEditingController floorRiseC = TextEditingController();
  TextEditingController launchDateC = TextEditingController();
  TextEditingController endDateC = TextEditingController();
  TextEditingController projectStatusC = TextEditingController();
  TextEditingController floorSlabC = TextEditingController();
  TextEditingController stiltParkingC = TextEditingController(text: "0.0");
  TextEditingController openParkingC = TextEditingController(text: "0.0");
  TextEditingController podiumParkingC = TextEditingController(text: "0.0");
  TextEditingController doublePodiumParkingC = TextEditingController(text: "0.0");
  TextEditingController basementParkingC = TextEditingController(text: "0.0");
  TextEditingController reraNoC = TextEditingController();
  TextEditingController remarkC = TextEditingController();
  bool isReadOnly = false;
  bool isFreeze = false;

  final FocusNode storeyFN = FocusNode();
  final FocusNode scrFN = FocusNode();
  final FocusNode maintenanceFN = FocusNode();
  final FocusNode flatFN = FocusNode();
  final FocusNode saleableLaunchPriceFN = FocusNode();
  final FocusNode carpetLaunchPriceFN = FocusNode();
  final FocusNode floorRiseFN = FocusNode();
  final FocusNode launchDateFN = FocusNode();
  final FocusNode endDateFN = FocusNode();
  final FocusNode projectStatusFN = FocusNode();
  final FocusNode floorSlabFN = FocusNode();
  final FocusNode stiltParkingFN = FocusNode();
  final FocusNode openParkingFN = FocusNode();
  final FocusNode podiumParkingFN = FocusNode();
  final FocusNode doublePodiumParkingFN = FocusNode();
  final FocusNode basementParkingFN = FocusNode();
  final FocusNode reraNoFN = FocusNode();
  final FocusNode remarkFN = FocusNode();

  String? subPrjNameErMsg;
  String? flatgroupErMsg;
  String? storeyErMsg;
  String? scrErMsg;
  String? maintenanceErMsg;
  String? flatsErMsg;
  String? saleablePriceErMsg;
  String? carpetPriceErMsg;
  String? floorRiseErMsg;
  String? launchDateErMsg;
  String? endDateErMsg;
  String? constructionProgressErMsg;
  String? floorSlabErMsg;
  String? remarkErMsg;

  @override
  void initState() {
    super.initState();
    context.read<AddNewSprjCubit>().fetchData();
    context.read<AddNewSprjCubit>().fetchUserData();
  }

  void prefillFields({NewSubProjectEntity? newSpjData}) {
    if (newSpjData != null) {
      subProjectNameC.text = newSpjData.subPrjName ?? "";
      storeyC.text = newSpjData.storey.toString();
      scrC.text = newSpjData.scr.toString();
      maintenanceC.text = newSpjData.maintenance.toString();
      flatC.text = newSpjData.flatsPerFloor.toString();
      saleableLaunchPriceC.text = "${newSpjData.saleableLaunchPrice ?? 0.0}";
      carpetLaunchPriceC.text = "${newSpjData.carpetLaunchPrice ?? 0.0}";
      floorRiseC.text = newSpjData.floorRise.toString();
      launchDateC.text = newSpjData.launchDate ?? "";
      endDateC.text = newSpjData.endDate ?? "";
      floorSlabC.text = newSpjData.floorSlab.toString();
      stiltParkingC.text = newSpjData.stiltParking ?? "";
      openParkingC.text = newSpjData.openParking ?? "";
      podiumParkingC.text = newSpjData.podiumParking ?? "";
      doublePodiumParkingC.text = newSpjData.doublePodiumParking ?? "";
      basementParkingC.text = newSpjData.basementParking ?? "";
      reraNoC.text = newSpjData.reraNo ?? "";
      remarkC.text = newSpjData.remarks ?? "";
      setState(() {
        selectedFlatGroup = flatGroup.firstWhere((e) => e["id"] == newSpjData.flatGroup, orElse: () => {});
        selectedConstProgress = constructionProgress.firstWhere(
          (e) => e["id"] == newSpjData.constructionProgressId,
          orElse: () => {},
        );

        final isComplete = selectedConstProgress?["title"] == "Complete";

        selectedProjectStaus = projectStatus.firstWhere(
          (e) => e.projectStatus == (isComplete ? "Ready" : "UC"),
          orElse: () => ProjectStatusList(),
        );

        projectStatusC.text = selectedProjectStaus?.projectStatus ?? "";
      });
    }
  }

  void clearFields() {
    subProjectNameC.clear();
    storeyC.clear();
    scrC.clear();
    maintenanceC.clear();
    flatC.clear();
    saleableLaunchPriceC.clear();
    carpetLaunchPriceC.clear();
    floorRiseC.clear();
    launchDateC.clear();
    endDateC.clear();
    projectStatusC.clear();
    floorSlabC.clear();
    stiltParkingC.clear();
    openParkingC.clear();
    podiumParkingC.clear();
    doublePodiumParkingC.clear();
    basementParkingC.clear();
    reraNoC.clear();
    remarkC.clear();
    setState(() {
      selectedFlatGroup = null;
      selectedConstProgress = null;
      selectedProjectStaus = null;
    });
  }

  @override
  void dispose() {
    super.dispose();
    subProjectNameC.dispose();
    storeyC.dispose();
    scrC.dispose();
    maintenanceC.dispose();
    flatC.dispose();
    saleableLaunchPriceC.dispose();
    carpetLaunchPriceC.dispose();
    floorRiseC.dispose();
    launchDateC.dispose();
    endDateC.dispose();
    projectStatusC.dispose();
    floorSlabC.dispose();
    stiltParkingC.dispose();
    openParkingC.dispose();
    podiumParkingC.dispose();
    doublePodiumParkingC.dispose();
    basementParkingC.dispose();
    reraNoC.dispose();
    remarkC.dispose();

    storeyFN.dispose();
    scrFN.dispose();
    maintenanceFN.dispose();
    flatFN.dispose();
    saleableLaunchPriceFN.dispose();
    carpetLaunchPriceFN.dispose();
    floorRiseFN.dispose();
    launchDateFN.dispose();
    endDateFN.dispose();
    projectStatusFN.dispose();
    floorSlabFN.dispose();
    stiltParkingFN.dispose();
    openParkingFN.dispose();
    podiumParkingFN.dispose();
    doublePodiumParkingFN.dispose();
    basementParkingFN.dispose();
    reraNoFN.dispose();
    remarkFN.dispose();
  }

  void selectFlatgroup(Map<String, dynamic> flatGroup) {
    if (flatGroup["title"] == "Open Plots") {
      isReadOnly = true;
      storeyC.text = "0";
      flatC.text = "0";
      scrC.text = "1";
      maintenanceC.text = "0";
      _selectedType = AreaType.saleable;
      constructionProgress = tempConstructionProgress
          .where((item) => item["title"] == "Not Started" || item["title"] == "Complete")
          .toList();
    } else {
      constructionProgress = tempConstructionProgress;
      isReadOnly = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AddNewSprjCubit subProjectFormCubit = context.read<AddNewSprjCubit>();
    return BlocListener<AddNewSprjCubit, AddNewSprjFormState>(
      listener: (context, state) {
        if (state is ErrorState) {
          CustomSnackHelper.customToastMsg(
            message: state.message,
            context: context,
            bgColor: AppColors.white,
            textColor: AppColors.black,
          );
        } else if (state is ValidateState) {
          subPrjNameErMsg = state.errors['subPrjName'];
          flatgroupErMsg = state.errors['flatGroup'];
          storeyErMsg = state.errors['storey'];
          scrErMsg = state.errors['scr'];
          maintenanceErMsg = state.errors['maintenance'];
          flatsErMsg = state.errors['flats'];
          saleablePriceErMsg = state.errors['saleableLaunchPrice'];
          carpetPriceErMsg = state.errors['carpetLaunchPrice'];
          floorRiseErMsg = state.errors['floorrise'];
          launchDateErMsg = state.errors['launchdate'];
          endDateErMsg = state.errors['endDate'];
          floorSlabErMsg = state.errors['floorSlab'];
          constructionProgressErMsg = state.errors['constructionProgress'];
          remarkErMsg = state.errors['remark'];
        } else if (state is UserDataState) {
          qtrId = int.tryParse(state.qtrId) ?? 0;
          qtr = state.qtr;
          qtrDate = Utils.tryParseDate(state.qtr);
        } else if (state is LocalState) {
          cities.clear();
          constructionProgress.clear();
          projectStatus.clear();
          tempConstructionProgress.clear();
          setState(() {
            constructionProgress = state.constProgress
                .map((e) => {"id": e.constProgressId, "title": e.constProgress})
                .toList();
            tempConstructionProgress = state.constProgress
                .map((e) => {"id": e.constProgressId, "title": e.constProgress})
                .toList();
            projectStatus = state.prjStatus;
            cities = state.cities;
            CityList city = cities.firstWhere((e) => e.cityId == widget.cityId, orElse: () => CityList());
            _selectedType = city.areaType?.toLowerCase() == "saleable" ? AreaType.saleable : AreaType.carpet;
            isFreeze = city.areaTypeFreeze == 0;
          });

          prefillFields(newSpjData: widget.newSubPrjEntity);
        } else if (state is SuccessState) {
          CustomSnackHelper.succesSnackbar(context: context, message: state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.appBg,
        appBar: CustomAppBar(title: "New Sub Project"),
        body: SafeArea(
          child: Padding(
            padding: AppDimens.hvPadding,
            child: Container(
              padding: EdgeInsets.all(8.0),
              color: AppColors.white,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: AbsorbPointer(
                      absorbing: widget.isFreeze ?? false,
                      child: BlocBuilder<AddNewSprjCubit, AddNewSprjFormState>(
                        builder: (context, state) {
                          return Column(
                            spacing: 12.0,
                            children: [
                              CustomTextField(
                                labelText: "Sub Project Name",
                                controller: subProjectNameC,
                                errorText: subPrjNameErMsg,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (value) {
                                  FocusScope.of(context).requestFocus(storeyFN);
                                },
                              ),
                              CustomDropdown(
                                initialValue: selectedFlatGroup,
                                items: flatGroup,
                                labelKey: "title",
                                hintText: "Select",
                                lableText: "Flat Group",
                                errorText: flatgroupErMsg,
                                onChanged: (value) {
                                  setState(() {
                                    selectedFlatGroup = value;
                                    selectedConstProgress = null;
                                    selectFlatgroup(selectedFlatGroup!);
                                  });
                                },
                              ),
                              CustomTextField(
                                disable: isReadOnly,
                                readOnly: isReadOnly,
                                labelText: "Storey",
                                controller: storeyC,
                                maxLength: 2,
                                counterText: "",
                                focusNode: storeyFN,
                                textInputAction: TextInputAction.next,
                                errorText: storeyErMsg,
                                onFieldSubmitted: (value) {
                                  FocusScope.of(context).requestFocus(scrFN);
                                },
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              ),
                              CustomTextField(
                                labelText: "SCR",
                                controller: scrC,
                                maxLength: 2,
                                counterText: "",
                                keyboardType: TextInputType.number,
                                errorText: scrErMsg,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                focusNode: scrFN,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (value) {
                                  FocusScope.of(context).requestFocus(maintenanceFN);
                                },
                              ),
                              CustomTextField(
                                disable: isReadOnly,
                                readOnly: isReadOnly,
                                labelText: "Maintenance",
                                controller: maintenanceC,
                                maxLength: 8,
                                counterText: "",
                                keyboardType: TextInputType.number,
                                errorText: maintenanceErMsg,
                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                                focusNode: maintenanceFN,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (value) {
                                  FocusScope.of(context).requestFocus(flatFN);
                                },
                              ),
                              CustomTextField(
                                disable: isReadOnly,
                                readOnly: isReadOnly,
                                labelText: "Flats / Floor",
                                controller: flatC,
                                maxLength: 2,
                                counterText: "",
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                                focusNode: flatFN,
                                errorText: flatsErMsg,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (value) {
                                  FocusScope.of(context).requestFocus(floorRiseFN);
                                },
                              ),
                              RadioGroup<AreaType>(
                                groupValue: _selectedType,
                                // onChanged: isReadOnly == true
                                //     ? (AreaType? newValue) {}
                                //     : (AreaType? newValue) {
                                //         setState(() {
                                //           _selectedType = newValue!;
                                //         });
                                //       },
                                onChanged: (AreaType? newValue) {},
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      flex: 1,
                                      child: RadioListTile<AreaType>(
                                        // enabled: isReadOnly == true ? false : true,
                                        // enabled: false,
                                        enabled: isFreeze,
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
                                        // enabled: isReadOnly == true ? false : true,
                                        // enabled: false,
                                        enabled: isFreeze,
                                        value: AreaType.carpet,
                                        title: Text("Carpet", style: AppTextStyle.ts14RB),
                                        visualDensity: VisualDensity.compact,
                                        contentPadding: EdgeInsets.zero,
                                        activeColor: AppColors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IgnorePointer(
                                ignoring: _selectedType == AreaType.saleable ? false : true,
                                child: CustomTextField(
                                  readOnly: _selectedType == AreaType.saleable ? false : true,
                                  filled: _selectedType == AreaType.saleable ? false : true,
                                  fillColor: Colors.grey.shade200,
                                  counterText: "",
                                  maxLength: 8,
                                  labelText: "Saleable Launch Price",
                                  controller: saleableLaunchPriceC,
                                  errorText: saleablePriceErMsg,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                                ),
                              ),
                              IgnorePointer(
                                ignoring: _selectedType == AreaType.carpet ? false : true,
                                child: CustomTextField(
                                  readOnly: _selectedType == AreaType.carpet ? false : true,
                                  filled: _selectedType == AreaType.carpet ? false : true,
                                  fillColor: Colors.grey.shade200,
                                  labelText: "Carpet Launch Price",
                                  counterText: "",
                                  maxLength: 8,
                                  controller: carpetLaunchPriceC,
                                  errorText: carpetPriceErMsg,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                                ),
                              ),
                              CustomTextField(
                                controller: floorRiseC,
                                labelText: "Floor Rise",
                                counterText: "",
                                maxLength: 4,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                                focusNode: floorRiseFN,
                                textInputAction: TextInputAction.next,
                                errorText: floorRiseErMsg,
                                onFieldSubmitted: (value) {
                                  FocusScope.of(context).requestFocus(stiltParkingFN);
                                },
                              ),
                              BlocBuilder<AddNewSprjCubit, AddNewSprjFormState>(
                                buildWhen: (previous, current) => current is UserDataState || current is ValidateState,
                                builder: (context, state) {
                                  return CustomDatePickerFormField(
                                    firstDate: DateTime(2000),
                                    lastDate: qtrDate,
                                    calendarhintText: "Launch Date",
                                    labelText: "Launch Date",
                                    controller: launchDateC,
                                    errorText: launchDateErMsg,
                                    onDateSelected: (value) {
                                      launchDateC.text = DateFormat("dd-MMM-yyyy").format(value);
                                      context.read<AddNewSprjCubit>().selectDate(selectDate: value);
                                    },
                                  );
                                },
                              ),
                              BlocBuilder<AddNewSprjCubit, AddNewSprjFormState>(
                                buildWhen: (previous, current) =>
                                    current is UserDataState || current is SelectDateState || current is ValidateState,
                                builder: (context, state) {
                                  return CustomDatePickerFormField(
                                    // firstDate: selectedConstProgress != null && selectedConstProgress!['id'] == 8
                                    //     ? Utils.tryParseDate(launchDateC.text)
                                    //     : qtrDate,
                                    firstDate: Utils.tryParseDate(launchDateC.text)?.add(Duration(days: 1)),
                                    lastDate: DateTime(2050),
                                    calendarhintText: "End Date (Possession)",
                                    labelText: "End Date (Possession)",
                                    controller: endDateC,
                                    errorText: endDateErMsg,
                                    onDateSelected: (value) {
                                      if (launchDateC.text.isEmpty) {
                                        CustomSnackHelper.customToastMsg(
                                          message: "Please select launch date first.",
                                          context: context,
                                          bgColor: AppColors.white,
                                          textColor: AppColors.black,
                                        );
                                        endDateC.text = "";
                                      } else {
                                        endDateC.text = DateFormat("dd-MMM-yyyy").format(value);
                                      }
                                    },
                                  );
                                },
                              ),
                              CustomDropdown(
                                initialValue: selectedConstProgress,
                                disabled: selectedFlatGroup == null ? true : false,
                                items: constructionProgress,
                                labelKey: "title",
                                hintText: "Select",
                                lableText: "Construction Progress",
                                errorText: constructionProgressErMsg,
                                onChanged: (value) {
                                  setState(() {
                                    selectedConstProgress = value;
                                    if (selectedConstProgress!["title"] == "Complete") {
                                      selectedProjectStaus = selectedProjectStaus = projectStatus.firstWhere(
                                        (e) => e.projectStatus == "Ready",
                                      );
                                      projectStatusC.text = selectedProjectStaus?.projectStatus ?? "";
                                    } else {
                                      selectedProjectStaus = selectedProjectStaus = projectStatus.firstWhere(
                                        (e) => e.projectStatus == "UC",
                                      );
                                      projectStatusC.text = selectedProjectStaus?.projectStatus ?? "";
                                    }
                                  });
                                },
                              ),
                              selectedConstProgress?["title"] == "Floor Slab"
                                  ? CustomTextField(
                                      readOnly: isReadOnly,
                                      labelText: "Floor Slab",
                                      controller: floorSlabC,
                                      keyboardType: TextInputType.number,
                                      maxLength: 4,
                                      counterText: "",
                                      errorText: floorSlabErMsg,
                                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                                    )
                                  : SizedBox.shrink(),
                              IgnorePointer(
                                ignoring: true,
                                child: CustomTextField(
                                  filled: true,
                                  fillColor: Colors.grey.shade200,
                                  labelText: "Project Status",
                                  controller: projectStatusC,
                                  lableTextColor: Colors.grey,
                                ),
                              ),
                              CustomTextField(
                                labelText: "Stilt Parking Charges (Rs)",
                                controller: stiltParkingC,
                                keyboardType: TextInputType.number,
                                maxLength: 12,
                                counterText: "",
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly, NumberCommaInputFormatter()],
                                focusNode: stiltParkingFN,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (value) {
                                  FocusScope.of(context).requestFocus(openParkingFN);
                                },
                              ),
                              CustomTextField(
                                labelText: "Open Parking Charges (Rs)",
                                controller: openParkingC,
                                keyboardType: TextInputType.number,
                                maxLength: 12,
                                counterText: "",
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly, NumberCommaInputFormatter()],
                                focusNode: openParkingFN,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (value) {
                                  FocusScope.of(context).requestFocus(podiumParkingFN);
                                },
                              ),
                              CustomTextField(
                                labelText: "Podium Parking Charges (Rs)",
                                controller: podiumParkingC,
                                keyboardType: TextInputType.number,
                                maxLength: 12,
                                counterText: "",
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly, NumberCommaInputFormatter()],
                                focusNode: podiumParkingFN,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (value) {
                                  FocusScope.of(context).requestFocus(doublePodiumParkingFN);
                                },
                              ),
                              CustomTextField(
                                labelText: "Double Podium Parking Charges (Rs)",
                                controller: doublePodiumParkingC,
                                keyboardType: TextInputType.number,
                                maxLength: 12,
                                counterText: "",
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly, NumberCommaInputFormatter()],
                                focusNode: doublePodiumParkingFN,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (value) {
                                  FocusScope.of(context).requestFocus(basementParkingFN);
                                },
                              ),
                              CustomTextField(
                                labelText: "Basement Parking Charges (Rs)",
                                controller: basementParkingC,
                                keyboardType: TextInputType.number,
                                maxLength: 12,
                                counterText: "",
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly, NumberCommaInputFormatter()],
                                focusNode: basementParkingFN,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (value) {
                                  FocusScope.of(context).requestFocus(remarkFN);
                                },
                              ),
                              // CustomTextField(labelText: "Rera No", controller: reraNoC),
                              CustomTextField(
                                focusNode: remarkFN,
                                labelText: "Remark",
                                controller: remarkC,
                                errorText: remarkErMsg,
                              ),
                              SizedBox(height: 12.0),
                              SizedBox(
                                width: double.infinity,
                                child: CustomElevatedButton(
                                  backgroundColor: AppColors.primaryDarkColor,
                                  text: widget.formType.toLowerCase().trim() == "update" ? "UPDATE" : "SAVE",
                                  onPressed: () async {
                                    final locPermission = await Utils.checkLocationAndGpsPermission(context);
                                    if (!context.mounted) return;
                                    if (!locPermission) {
                                      CustomSnackHelper.errorToast(
                                        message: "Please enable location permission and GPS",
                                      );
                                      return;
                                    }
                                    final resp = await subProjectFormCubit.addSubProject(
                                      formType: widget.formType,
                                      subPrjId: widget.newSubPrjEntity?.subPrjid.toString() ?? "",
                                      flatGroup: selectedFlatGroup,
                                      constructionProgress: selectedConstProgress,
                                      subProjectName: subProjectNameC.text,
                                      storey: storeyC.text,
                                      scr: scrC.text,
                                      maintenance: maintenanceC.text,
                                      flats: flatC.text,
                                      priceType: _selectedType == AreaType.carpet ? "Carpet" : "Saleable",
                                      isSaleable: _selectedType == AreaType.carpet ? false : true,
                                      saleableLaunchPrice: saleableLaunchPriceC.text,
                                      carpetLaunchPrice: carpetLaunchPriceC.text,
                                      floorRise: floorRiseC.text,
                                      launchDate: launchDateC.text,
                                      endDate: endDateC.text,
                                      stiltParking: stiltParkingC.text,
                                      openParking: openParkingC.text,
                                      podiumParking: podiumParkingC.text,
                                      doublePodiumParking: doublePodiumParkingC.text,
                                      basementParking: basementParkingC.text,
                                      remark: remarkC.text,
                                      isFloorSlab: selectedConstProgress?["title"] == "Floor Slab",
                                      floorSlab: floorSlabC.text,
                                      flatGroupId: selectedFlatGroup != null ? selectedFlatGroup!["id"] : 0,
                                      selectedConstProgress: selectedConstProgress != null
                                          ? selectedConstProgress!["title"]
                                          : "",
                                      selectedConstProgressId: selectedConstProgress != null
                                          ? selectedConstProgress!["id"]
                                          : 0,
                                      dos: qtrDate!,
                                      projectId: widget.projectId,
                                      newPrjId: widget.newProjectId,
                                      projectStatusId: selectedProjectStaus != null
                                          ? selectedProjectStaus!.projectStatusId!
                                          : 0,
                                      qtrId: qtrId,
                                      qtr: qtr,
                                      reraNo: widget.reraNo,
                                    );
                                    if (resp == true) {
                                      clearFields();
                                      if (!context.mounted) return;
                                      context.pop();
                                    }
                                  },
                                ),
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: CustomElevatedButton(
                                  backgroundColor: AppColors.red,
                                  text: "CANCEL",
                                  onPressed: () {
                                    context.pop();
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),

                  Positioned.fill(
                    child: IgnorePointer(
                      ignoring: widget.isFreeze ?? true,
                      child: Container(color: widget.isFreeze == true ? Colors.white54 : Colors.transparent),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
