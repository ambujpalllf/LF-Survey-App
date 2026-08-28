import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lf_survey/app_popups/custom_bottomsheet.dart';
import 'package:lf_survey/app_popups/cutsom_alert_dialogues.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_dimens.dart';
import 'package:lf_survey/constants/app_text_style.dart';
import 'package:lf_survey/constants/snackbar_helper.dart';
import 'package:lf_survey/constants/utils.dart';
import 'package:lf_survey/cubit/residential/project_edit/project_edit_cubit.dart';
import 'package:lf_survey/cubit/residential/project_edit/project_edit_state.dart';
import 'package:lf_survey/model/db_model/residential/project_entity.dart';
import 'package:lf_survey/model/db_model/residential/sub_prj_entity.dart';
import 'package:lf_survey/model/residential/archi_response.dart';
import 'package:lf_survey/model/residential/project_response.dart';
import 'package:lf_survey/model/residential/project_scheme_entity.dart';
import 'package:lf_survey/model/residential/project_spinner.dart';
import 'package:lf_survey/routes/app_routes_name.dart';
import 'package:lf_survey/widgets/custom_app_bar.dart';
import 'package:lf_survey/widgets/custom_dropdown.dart';
import 'package:lf_survey/widgets/custom_elevated_btn.dart';
import 'package:lf_survey/widgets/custom_textfield.dart';
import 'package:lf_survey/widgets/custom_textform_field.dart';
import 'package:lf_survey/widgets/phone_number_formatter.dart';
import 'package:location/location.dart';

class ProjectEditFormPage extends StatefulWidget {
  final ProjectEntity projectData;
  const ProjectEditFormPage({super.key, required this.projectData});

  @override
  State<ProjectEditFormPage> createState() => _ProjectEditFormPageState();
}

class _ProjectEditFormPageState extends State<ProjectEditFormPage> {
  String propertyType = "Saleable";
  bool isRedevelopment = false;
  bool isNewPrjUpdate = false;
  bool isBookingStop = false;
  ArchitectDataum? selectedArchi;
  ProjectCosting? projectCostingData;
  List<Map<String, dynamic>> areaUnit = [];
  List<SchemesList> schemes = [];
  List<ProjectSchemeEntity> selectedSchemes = [];
  List<Map<String, dynamic>> flatType = [];
  List<Map<String, dynamic>> costIncluded = [];
  List<SubProjectEntity> sprjData = [];
  List<CityList> allCity = [];
  List<ArchitectDataum> allArchitects = [];
  List<ArchitectDataum> searchedArchitects = [];
  List<Map<String, dynamic>> approveBanks = [];

  Map<String, dynamic>? selectedAreaUnit;
  Map<String, dynamic>? selectedBaseCostFlatTypes;
  Map<String, dynamic>? selectedAgreementCostFlatTypes;
  Map<String, dynamic>? selectedAllInclusiveFlatTypes;
  List selectedApproveBanks = [];

  TextEditingController baseSaleableC = TextEditingController();
  TextEditingController baseCarpetC = TextEditingController();
  TextEditingController baseReferenceC = TextEditingController();
  TextEditingController agreementSaleableC = TextEditingController();
  TextEditingController agreementCarpetC = TextEditingController();
  TextEditingController agreementReferenceC = TextEditingController();
  TextEditingController allInclusiveSaleableC = TextEditingController();
  TextEditingController allInclusiveCarpetC = TextEditingController();
  TextEditingController allInclusiveReferenceC = TextEditingController();

  List baseCostIncluded = [];
  List agreementCostIncluded = [];
  List allInclusiveCostIncluded = [];

  TextEditingController phoneC = TextEditingController();
  TextEditingController mobileC = TextEditingController();
  TextEditingController latC = TextEditingController();
  TextEditingController longC = TextEditingController();
  TextEditingController projectAddressC = TextEditingController();
  TextEditingController builderAddressC = TextEditingController();
  TextEditingController bPhoneC = TextEditingController();
  TextEditingController bMobileC = TextEditingController();
  TextEditingController drinkingWaterC = TextEditingController();
  TextEditingController modularKitchenNameC = TextEditingController();
  TextEditingController architectNameC = TextEditingController();
  TextEditingController reraNumberC = TextEditingController();
  TextEditingController cinC = TextEditingController();
  TextEditingController totalWingsC = TextEditingController();
  TextEditingController marketableWingsC = TextEditingController();
  TextEditingController totalSupplyUnitsC = TextEditingController();
  TextEditingController landParcelSizeC = TextEditingController();
  TextEditingController baseCostC = TextEditingController();
  TextEditingController agreementCostC = TextEditingController();
  TextEditingController allInculsiveCostC = TextEditingController();

  FocusNode prjmobileFN = FocusNode();
  FocusNode addressFN = FocusNode();
  FocusNode bPhoneFN = FocusNode();
  FocusNode bMobileFN = FocusNode();
  FocusNode waterFN = FocusNode();
  FocusNode kitchenFN = FocusNode();
  FocusNode archiNameFN = FocusNode();
  FocusNode cinNoFN = FocusNode();
  FocusNode totalWingsFN = FocusNode();
  FocusNode marketableWingsFN = FocusNode();
  FocusNode supplyUnitsFN = FocusNode();
  FocusNode landParcelFN = FocusNode();
  FocusNode baseCostFN = FocusNode();
  FocusNode agreementCostFN = FocusNode();
  FocusNode inclusiveCostFN = FocusNode();
  @override
  void initState() {
    super.initState();
    context.read<ProjectEditCubit>().fetchLocalData(projectId: widget.projectData.projectId!);
    String prjCostIng = widget.projectData.projectCosting ?? "";
    if (prjCostIng.isNotEmpty) {
      final Map<String, dynamic> jsonMap = jsonDecode(prjCostIng);
      projectCostingData = ProjectCosting.fromJson(jsonMap);
    }
  }

  @override
  void dispose() {
    super.dispose();
    baseSaleableC.dispose();
    baseCarpetC.dispose();
    baseReferenceC.dispose();
    agreementSaleableC.dispose();
    agreementCarpetC.dispose();
    agreementReferenceC.dispose();
    allInclusiveSaleableC.dispose();
    allInclusiveCarpetC.dispose();
    allInclusiveReferenceC.dispose();
    phoneC.dispose();
    mobileC.dispose();
    latC.dispose();
    longC.dispose();
    projectAddressC.dispose();
    builderAddressC.dispose();
    bPhoneC.dispose();
    drinkingWaterC.dispose();
    modularKitchenNameC.dispose();
    architectNameC.dispose();
    reraNumberC.dispose();
    cinC.dispose();
    totalWingsC.dispose();
    marketableWingsC.dispose();
    totalSupplyUnitsC.dispose();
    landParcelSizeC.dispose();
    baseCostC.dispose();
    agreementCostC.dispose();
    allInculsiveCostC.dispose();

    prjmobileFN.dispose();
    addressFN.dispose();
    bPhoneFN.dispose();
    bMobileFN.dispose();
    waterFN.dispose();
    kitchenFN.dispose();
    archiNameFN.dispose();
    cinNoFN.dispose();
    totalWingsFN.dispose();
    marketableWingsFN.dispose();
    supplyUnitsFN.dispose();
    landParcelFN.dispose();
    baseCostFN.dispose();
    agreementCostFN.dispose();
    inclusiveCostFN.dispose();
  }

  void prefillData(ProjectEntity itemData, ProjectCosting projectCostData) {
    isRedevelopment = itemData.reDevelopment == 1;
    phoneC.text = itemData.projectPhoneNo ?? "";
    mobileC.text = itemData.projectMobileNo ?? "";
    latC.text = itemData.pxval.toString();
    longC.text = itemData.pyval.toString();
    projectAddressC.text = itemData.projectAddress ?? "";
    builderAddressC.text = itemData.builderAddress ?? "";
    bPhoneC.text = itemData.builderPhoneNo ?? "";
    bMobileC.text = itemData.builderMobileNo ?? "";
    drinkingWaterC.text = itemData.drinkingWater ?? "";
    modularKitchenNameC.text = itemData.modularKitchenBrand ?? "";
    architectNameC.text = itemData.architectName ?? "";
    reraNumberC.text = itemData.reraNo ?? "";
    cinC.text = itemData.cinNo ?? "";
    totalWingsC.text = "${itemData.totalWings}";
    marketableWingsC.text = "${itemData.marketableWings}";
    totalSupplyUnitsC.text = "${itemData.totalSupplyUnits}";
    landParcelSizeC.text = "${itemData.landParcelSize}";
    baseCostC.text = "${projectCostData.baseCost}";
    agreementCostC.text = "${projectCostData.agreementCost}";
    allInculsiveCostC.text = "${projectCostData.allInclusiveCost}";
    baseSaleableC.text = "${projectCostData.baseCostSaleableSize}";
    baseCarpetC.text = projectCostData.baseCostCarpetSize.toString();
    baseReferenceC.text = projectCostData.baseCostReferenceUnitNumber.toString();
    agreementSaleableC.text = projectCostData.agreementCostSaleableSize.toString();
    agreementCarpetC.text = projectCostData.agreementCostCarpetSize.toString();
    agreementReferenceC.text = projectCostData.agreementCostReferenceUnitNumber.toString();
    allInclusiveSaleableC.text = projectCostData.allInclusiveCostSaleableSize.toString();
    allInclusiveCarpetC.text = projectCostData.allInclusiveCostCarpetSize.toString();
    allInclusiveReferenceC.text = projectCostData.allInclusiveCostReferenceUnitNumber.toString();

    selectedBaseCostFlatTypes = flatType.any((i) => i["id"] == projectCostData.baseCostFlatId)
        ? flatType.firstWhere((i) => i["id"] == projectCostData.baseCostFlatId)
        : null;

    selectedAgreementCostFlatTypes = flatType.any((i) => i["id"] == projectCostData.agreementCostFlatId)
        ? flatType.firstWhere((i) => i["id"] == projectCostData.agreementCostFlatId)
        : null;

    selectedAllInclusiveFlatTypes = flatType.any((i) => i["id"] == projectCostData.allInclusiveCostFlatId)
        ? flatType.firstWhere((i) => i["id"] == projectCostData.allInclusiveCostFlatId)
        : null;

    selectedAreaUnit = areaUnit.any((i) => i["id"] == itemData.landParcelSizeUnit)
        ? areaUnit.firstWhere((i) => i["id"] == itemData.landParcelSizeUnit)
        : null;
    selectedArchi = allArchitects.where((e) => e.architectId == itemData.architectId).firstOrNull;
    final baseIncludedList = projectCostData.baseCostIncluded!.split(",");
    final agreementIncludedList = projectCostData.agreementCostIncluded!.split(",");
    final allInclusiveIncludedList = projectCostData.allInclusiveCostIncluded!.split(",");
    baseCostIncluded.clear();
    agreementCostIncluded.clear();
    allInclusiveCostIncluded.clear();
    baseCostIncluded = costIncluded.where((e) => baseIncludedList.contains(e["title"])).toList();
    agreementCostIncluded = costIncluded.where((e) => agreementIncludedList.contains(e["title"])).toList();
    allInclusiveCostIncluded = costIncluded.where((e) => allInclusiveIncludedList.contains(e["title"])).toList();
    // when newProject = false means project can not update otherwise can be update
    isNewPrjUpdate = itemData.assignedNewPrj == 0 ? true : false;
    isBookingStop = sprjData.every((e) => e.bookingStop == 1);
    propertyType = allCity.any((e) => e.cityId == itemData.cityId)
        ? (allCity.firstWhere((e) => e.cityId == itemData.cityId).areaType ?? "Saleable")
        : "Saleable";
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final ProjectEditCubit projectEditCubit = context.read<ProjectEditCubit>();
    return BlocListener<ProjectEditCubit, ProjectEditState>(
      listener: (context, state) {
        if (state is LocalDbState) {
          areaUnit.clear();
          schemes.clear();
          flatType.clear();
          costIncluded.clear();
          sprjData.clear();
          allCity.clear();
          allArchitects.clear();
          selectedSchemes.clear();
          approveBanks.clear();
          areaUnit = state.areaUnit
              .map((e) => {"id": e.areaUnitId, "title": e.areaUnitName, "sqftConvert": e.sqftConvert})
              .toList();
          schemes.addAll(state.schmeData);
          flatType = state.flatType
              .map(
                (e) => {
                  "id": e.flatId,
                  "title": e.flatType,
                  "flatTypeId": e.flatTypeId,
                  "minValue": e.minValue,
                  "maxValue": e.maxValue,
                },
              )
              .toList();
          costIncluded = state.costIncluded.map((e) => {"id": e.costId, "title": e.costType}).toList();
          sprjData.addAll(state.subProjects);
          allCity.addAll(state.cities);
          allArchitects.addAll(state.architects);
          selectedSchemes.addAll(state.prjschemes);
          approveBanks.addAll(state.approveBanks.map((e) => {"id": e.bankId, "title": e.bankName}));
          if (projectCostingData != null) {
            prefillData(widget.projectData, projectCostingData!);
          }
        } else if (state is PrjSchemState) {
          selectedSchemes.clear();
          selectedSchemes.addAll(state.prjschemes);
        } else if (state is PrjUpdateCastingState) {
          context.read<ProjectEditCubit>().fetchPrjCasting(projectId: widget.projectData.projectId!);
        } else if (state is PrjCastingState) {
          String prjCostIng = state.project.projectCosting ?? "";
          if (prjCostIng.isNotEmpty) {
            final Map<String, dynamic> jsonMap = jsonDecode(prjCostIng);
            projectCostingData = ProjectCosting.fromJson(jsonMap);
          }
          selectedBaseCostFlatTypes = flatType.any((i) => i["id"] == projectCostingData?.baseCostFlatId)
              ? flatType.firstWhere((i) => i["id"] == projectCostingData?.baseCostFlatId)
              : null;
          selectedAgreementCostFlatTypes = flatType.any((i) => i["id"] == projectCostingData?.agreementCostFlatId)
              ? flatType.firstWhere((i) => i["id"] == projectCostingData?.agreementCostFlatId)
              : null;
          selectedAllInclusiveFlatTypes = flatType.any((i) => i["id"] == projectCostingData?.allInclusiveCostFlatId)
              ? flatType.firstWhere((i) => i["id"] == projectCostingData?.allInclusiveCostFlatId)
              : null;
          baseCostIncluded = [];
          agreementCostIncluded = [];
          allInclusiveCostIncluded = [];
          final baseIncludedList = (projectCostingData?.baseCostIncluded ?? "").split(",");
          final agreementIncludedList = (projectCostingData?.agreementCostIncluded ?? "").split(",");
          final allInclusiveIncludedList = (projectCostingData?.allInclusiveCostIncluded ?? "").split(",");
          baseCostIncluded = costIncluded.where((e) => baseIncludedList.contains(e["title"])).toList();
          agreementCostIncluded = costIncluded.where((e) => agreementIncludedList.contains(e["title"])).toList();
          allInclusiveCostIncluded = costIncluded.where((e) => allInclusiveIncludedList.contains(e["title"])).toList();
        } else if (state is ErrorState) {
          CustomSnackHelper.customToastMsg(
            context: context,
            message: state.message,
            bgColor: AppColors.white,
            textColor: AppColors.black,
          );
        } else if (state is SuccessSate) {
          projectEditCubit.fetchLocalData(projectId: widget.projectData.projectId!);
          CustomSnackHelper.customToastMsg(
            context: context,
            message: state.message,
            bgColor: AppColors.white,
            textColor: AppColors.black,
          );
        } else if (state is SearchArchiState) {
          searchedArchitects.clear();
          searchedArchitects.addAll(state.architects);
        } else if (state is SelectArchiState) {
          selectedArchi = state.architect;
          if (selectedArchi!.architectId == 8) {
            architectNameC.text = widget.projectData.architectName ?? "";
          } else {
            architectNameC.text = selectedArchi?.architectName ?? "";
          }
          searchedArchitects.clear();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.appBg,
        appBar: CustomAppBar(title: "Project Edit"),
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
                      labelText: "Project Phone No",
                      controller: phoneC,
                      keyboardType: TextInputType.number,
                      // inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                      inputFormatters: [PhoneNumberFormatter()],
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(prjmobileFN);
                      },
                    ),
                    CustomTextField(
                      labelText: "Project Mobile No",
                      controller: mobileC,
                      keyboardType: TextInputType.number,
                      counterText: "",
                      // inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                      inputFormatters: [PhoneNumberFormatter()],
                      focusNode: prjmobileFN,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(addressFN);
                      },
                    ),
                    BlocBuilder<ProjectEditCubit, ProjectEditState>(
                      buildWhen: (previous, current) => current is LocalDbState,
                      builder: (context, state) {
                        return Column(
                          spacing: 8,
                          children: [
                            Row(
                              spacing: 8.0,
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onLongPress: isNewPrjUpdate
                                        ? null
                                        : () async {
                                            final result = await Utils.checkLocationAndGpsPermission(context);
                                            if (result == true) {
                                              LocationData? locationData = await Utils.getCurrentLocation();
                                              if (locationData != null) {
                                                latC.text = locationData.latitude.toString();
                                                longC.text = locationData.longitude.toString();
                                              }
                                            }
                                          },
                                    child: IgnorePointer(
                                      ignoring: true,
                                      child: CustomTextField(
                                        readOnly: isNewPrjUpdate,
                                        controller: latC,
                                        borderColor: isNewPrjUpdate ? Colors.grey.shade400 : null,
                                        lableTextColor: isNewPrjUpdate ? Colors.grey.shade400 : null,
                                        hintTextColor: isNewPrjUpdate ? Colors.grey.shade400 : null,
                                        style: TextStyle(color: isNewPrjUpdate ? Colors.grey.shade400 : Colors.black),
                                        labelText: "Latitude (press & hold for 2 sec)",
                                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                                      ),
                                    ),
                                  ),
                                ),
                                //  In existing ptoject user cann't edit the location. If location coordinates become zero or empty then user can edit the location with location icon.
                                if ((widget.projectData.pxval ?? 0.0) == 0.0)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text("OR", style: AppTextStyle.ts14BB),
                                      IconButton(
                                        onPressed: () async {
                                          final result = await Utils.checkLocationAndGpsPermission(context);
                                          if (result == true) {
                                            if (!context.mounted) return;
                                            final result = await context.push(AppRoutesName.mapPage);
                                            if (result != null && result is LatLng) {
                                              latC.text = result.latitude.toString();
                                              longC.text = result.longitude.toString();
                                            }
                                          }
                                        },
                                        icon: Icon(Icons.location_on, color: AppColors.red),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            InkWell(
                              onLongPress: isNewPrjUpdate
                                  ? null
                                  : () async {
                                      final result = await Utils.checkLocationAndGpsPermission(context);
                                      if (result == true) {
                                        LocationData? locationData = await Utils.getCurrentLocation();
                                        if (locationData != null) {
                                          latC.text = locationData.latitude.toString();
                                          longC.text = locationData.longitude.toString();
                                        }
                                      }
                                    },
                              child: IgnorePointer(
                                ignoring: true,
                                child: CustomTextField(
                                  readOnly: isNewPrjUpdate,
                                  controller: longC,
                                  keyboardType: TextInputType.number,
                                  borderColor: isNewPrjUpdate ? Colors.grey.shade400 : null,
                                  lableTextColor: isNewPrjUpdate ? Colors.grey.shade400 : null,
                                  hintTextColor: isNewPrjUpdate ? Colors.grey.shade400 : null,
                                  style: TextStyle(color: isNewPrjUpdate ? Colors.grey.shade400 : Colors.black),
                                  labelText: "Longitude (press & hold for 2 sec)",
                                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                                ),
                              ),
                            ),
                            CustomTextField(
                              readOnly: isNewPrjUpdate,
                              controller: projectAddressC,
                              borderColor: isNewPrjUpdate ? Colors.grey.shade400 : null,
                              lableTextColor: isNewPrjUpdate ? Colors.grey.shade400 : null,
                              hintTextColor: isNewPrjUpdate ? Colors.grey.shade400 : null,
                              style: TextStyle(color: isNewPrjUpdate ? Colors.grey.shade400 : Colors.black),
                              labelText: "Project Address",
                            ),
                          ],
                        );
                      },
                    ),
                    CustomTextField(
                      controller: builderAddressC,
                      labelText: "Builder Address",
                      focusNode: addressFN,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(bPhoneFN);
                      },
                    ),
                    CustomTextField(
                      controller: bPhoneC,
                      labelText: "Builder Phone No",
                      keyboardType: TextInputType.number,
                      counterText: "",
                      inputFormatters: [PhoneNumberFormatter()],
                      focusNode: bPhoneFN,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(bMobileFN);
                      },
                    ),
                    CustomTextField(
                      controller: bMobileC,
                      labelText: "Builder Mobile No",
                      keyboardType: TextInputType.number,
                      counterText: "",
                      inputFormatters: [PhoneNumberFormatter()],
                      focusNode: bMobileFN,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(waterFN);
                      },
                    ),
                    CustomTextField(
                      controller: drinkingWaterC,
                      labelText: "Drinking Water",
                      focusNode: waterFN,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(kitchenFN);
                      },
                    ),
                    CustomTextField(
                      controller: modularKitchenNameC,
                      labelText: "Modular Kitchen Name",
                      focusNode: kitchenFN,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(archiNameFN);
                      },
                    ),
                    CustomTextField(
                      controller: architectNameC,
                      labelText: "Architect Name",
                      onChanged: (value) {
                        if (value.isEmpty) {
                          searchedArchitects.clear();
                          return;
                        }
                        projectEditCubit.searchArchi(searchText: value, allArchitects: allArchitects);
                      },
                      focusNode: archiNameFN,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(cinNoFN);
                      },
                    ),
                    BlocBuilder<ProjectEditCubit, ProjectEditState>(
                      buildWhen: (previous, current) => current is SearchArchiState || current is SelectArchiState,
                      builder: (_, state) {
                        return searchedArchitects.isEmpty
                            ? Container()
                            : Container(
                                color: AppColors.white,
                                height: width * 0.8,
                                child: ListView.builder(
                                  itemCount: searchedArchitects.length,
                                  itemBuilder: (_, index) {
                                    ArchitectDataum archiData = searchedArchitects[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8.0),
                                      child: InkWell(
                                        onTap: () {
                                          // ArchitectDataum archiData = searchedArchitects[index];
                                          projectEditCubit.selectArchi(archiData: archiData);
                                        },
                                        child: Container(
                                          color: AppColors.greyLite,
                                          padding: EdgeInsets.all(6.0),
                                          child: Text(
                                            searchedArchitects[index].architectName ?? "",
                                            style: AppTextStyle.ts16RB,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                      },
                    ),
                    CustomTextField(
                      readOnly: true,
                      controller: reraNumberC,
                      labelText: "Rera No",
                      borderColor: Colors.grey.shade400,
                      lableTextColor: Colors.grey.shade400,
                      hintTextColor: Colors.grey.shade400,
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                    CustomTextField(
                      controller: cinC,
                      labelText: "CIN No",
                      focusNode: cinNoFN,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(totalWingsFN);
                      },
                    ),
                    CustomTextField(
                      controller: totalWingsC,
                      labelText: "Total Wings",
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                      focusNode: totalWingsFN,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(marketableWingsFN);
                      },
                    ),
                    CustomTextField(
                      controller: marketableWingsC,
                      labelText: "Marketable Wings",
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                      focusNode: marketableWingsFN,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(supplyUnitsFN);
                      },
                    ),
                    CustomTextField(
                      controller: totalSupplyUnitsC,
                      labelText: "Total Supply Units",
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                      focusNode: supplyUnitsFN,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(landParcelFN);
                      },
                    ),
                    CustomTextField(
                      controller: landParcelSizeC,
                      labelText: "Land Parcel Size",
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                      focusNode: landParcelFN,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(baseCostFN);
                      },
                    ),
                    BlocBuilder<ProjectEditCubit, ProjectEditState>(
                      buildWhen: (previous, current) => current is LocalDbState,
                      builder: (context, state) {
                        return CustomDropdown(
                          initialValue: selectedAreaUnit,
                          items: areaUnit,
                          labelKey: "title",
                          hintText: "Select Area Unit",
                          lableText: "Area Unit",
                          onChanged: (value) {
                            setState(() {
                              selectedAreaUnit = value;
                            });
                          },
                        );
                      },
                    ),
                    BlocBuilder<ProjectEditCubit, ProjectEditState>(
                      buildWhen: (previous, current) => current is LocalDbState,
                      builder: (context, state) {
                        return CheckboxListTile(
                          visualDensity: VisualDensity.compact,
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          checkColor: AppColors.white,
                          activeColor: AppColors.red,
                          value: isRedevelopment,
                          onChanged: (value) {
                            setState(() {
                              isRedevelopment = value!;
                            });
                          },
                          title: Text("Re-Development", style: AppTextStyle.ts14RB),
                        );
                      },
                    ),
                    BlocBuilder<ProjectEditCubit, ProjectEditState>(
                      buildWhen: (previous, current) => current is LocalDbState || current is PrjUpdateCastingState,
                      builder: (context, state) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 8.0,
                          children: [
                            CustomTextField(
                              controller: baseCostC,
                              labelText: "Base Cost (Rs)",
                              readOnly: isBookingStop,
                              borderColor: isBookingStop ? Colors.grey.shade400 : null,
                              lableTextColor: isBookingStop ? Colors.grey.shade400 : null,
                              hintTextColor: isBookingStop ? Colors.grey.shade400 : null,
                              style: TextStyle(color: isBookingStop ? Colors.grey.shade400 : Colors.black),
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                              suffixIcon: IconButton(
                                onPressed: isBookingStop
                                    ? null
                                    : () {
                                        CutsomAlertDialogues.projectEditCostDialogue(
                                          projectData: widget.projectData,
                                          propertyType: propertyType,
                                          context: context,
                                          prjCostData: projectCostingData!,
                                          title: "Base Cost",
                                          saleableSizeC: baseSaleableC,
                                          carpetSizeC: baseCarpetC,
                                          referenceSizeC: baseReferenceC,
                                          singleDropHintText: "Select Flat Type Here",
                                          singleDropLableText: "Flat Type",
                                          singleDropDownList: flatType,
                                          singleSelectdropDownValue: selectedBaseCostFlatTypes,
                                          multiDropHintText: "Select Items Included",
                                          multiDropLableText: "List Of Items Included",
                                          multiDropDownList: costIncluded,
                                          multiSelectdropDownValue: baseCostIncluded,
                                        );
                                      },
                                icon: Icon(Icons.edit, color: AppColors.red),
                              ),
                              focusNode: baseCostFN,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) {
                                FocusScope.of(context).requestFocus(agreementCostFN);
                              },
                            ),
                            CustomTextField(
                              controller: agreementCostC,
                              labelText: "Agreement Cost (Rs)",
                              readOnly: isBookingStop,
                              borderColor: isBookingStop ? Colors.grey.shade400 : null,
                              lableTextColor: isBookingStop ? Colors.grey.shade400 : null,
                              hintTextColor: isBookingStop ? Colors.grey.shade400 : null,
                              style: TextStyle(color: isBookingStop ? Colors.grey.shade400 : Colors.black),
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                              suffixIcon: IconButton(
                                onPressed: isBookingStop
                                    ? null
                                    : () {
                                        CutsomAlertDialogues.projectEditCostDialogue(
                                          context: context,
                                          projectData: widget.projectData,
                                          propertyType: propertyType,
                                          title: "Agreement Cost",
                                          prjCostData: projectCostingData!,
                                          saleableSizeC: agreementSaleableC,
                                          carpetSizeC: agreementCarpetC,
                                          referenceSizeC: agreementReferenceC,
                                          singleDropHintText: "Select Flat Type Here",
                                          singleDropLableText: "Flat Type",
                                          singleDropDownList: flatType,
                                          singleSelectdropDownValue: selectedAgreementCostFlatTypes,
                                          multiDropHintText: "Select Items Included",
                                          multiDropLableText: "List Of Items Included",
                                          multiDropDownList: costIncluded,
                                          multiSelectdropDownValue: agreementCostIncluded,
                                        );
                                      },
                                icon: Icon(Icons.edit, color: AppColors.red),
                              ),
                              focusNode: agreementCostFN,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) {
                                FocusScope.of(context).requestFocus(inclusiveCostFN);
                              },
                            ),
                            CustomTextField(
                              controller: allInculsiveCostC,
                              labelText: "All Inclusive Cost (Rs)",
                              readOnly: isBookingStop,
                              borderColor: isBookingStop ? Colors.grey.shade400 : null,
                              lableTextColor: isBookingStop ? Colors.grey.shade400 : null,
                              hintTextColor: isBookingStop ? Colors.grey.shade400 : null,
                              style: TextStyle(color: isBookingStop ? Colors.grey.shade400 : Colors.black),
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                              suffixIcon: IconButton(
                                onPressed: isBookingStop
                                    ? null
                                    : () {
                                        CutsomAlertDialogues.projectEditCostDialogue(
                                          context: context,
                                          propertyType: propertyType,
                                          projectData: widget.projectData,
                                          prjCostData: projectCostingData!,
                                          title: "All Inclusive Cost",
                                          singleDropHintText: "Select Flat Type Here",
                                          singleDropLableText: "Flat Type",
                                          saleableSizeC: allInclusiveSaleableC,
                                          carpetSizeC: allInclusiveCarpetC,
                                          referenceSizeC: allInclusiveReferenceC,
                                          singleDropDownList: flatType,
                                          singleSelectdropDownValue: selectedAllInclusiveFlatTypes,
                                          multiDropHintText: "Select Items Included",
                                          multiDropLableText: "List Of Items Included",
                                          multiDropDownList: costIncluded,
                                          multiSelectdropDownValue: allInclusiveCostIncluded,
                                        );
                                      },
                                icon: Icon(Icons.edit, color: AppColors.red),
                              ),
                              focusNode: inclusiveCostFN,
                            ),
                          ],
                        );
                      },
                    ),
                    BlocBuilder<ProjectEditCubit, ProjectEditState>(
                      buildWhen: (previous, current) => current is LocalDbState || current is PrjSchemState,
                      builder: (context, state) {
                        return CustomTextformField(
                          readOnly: true,
                          hintText: "Seletct Scheme",

                          onTap: () async {
                            final result = await CustomBottomsheet.selectSchemeBottomsheet(
                              context: context,
                              schemes: schemes,
                              selectdSchemes: selectedSchemes,
                              projectData: widget.projectData,
                            );
                            if (result == true) {
                              projectEditCubit.fetchPrjSchems(projectId: widget.projectData.projectId!);
                            }
                          },
                          suffixIcon: Icon(Icons.arrow_drop_down),
                        );
                      },
                    ),

                    // BlocBuilder<ProjectEditCubit, ProjectEditState>(
                    //   builder: (context, state) {
                    //     return CustomMultiSelectDropdown(
                    //       initialValues: selectedApproveBanks,
                    //       labelText: "Banks Providing Construction Finance",
                    //       hintText: "Select Banks Providing Construction Finance",
                    //       items: approveBanks,
                    //       labelKey: "title",
                    //       onChanged: (value) {
                    //         selectedApproveBanks = List.from(value);
                    //       },
                    //     );
                    //   },
                    // ),
                    SizedBox(
                      width: width * 0.7,
                      child: CustomElevatedButton(
                        backgroundColor: AppColors.red,
                        text: "SAVE",
                        onPressed: () async {
                          if (!await Utils.checkLocationAndGpsPermission(context)) return;
                          final result = projectEditCubit.projectValidation(
                            syncGlobalStatus: widget.projectData.syncGlobalStatus!,
                            selectedSchemes: selectedSchemes,
                            isNewPrjUpdate: isNewPrjUpdate,
                            prjLat: latC.text,
                            prjLong: longC.text,
                            prjAddress: projectAddressC.text,
                            prjBuilderAdd: builderAddressC.text,
                            isBooking: isBookingStop,
                            baseCost: baseCostC.text,
                            agreementCost: agreementCostC.text,
                            allInclusiveCost: allInculsiveCostC.text,
                            selectedAreaUnit: selectedAreaUnit ?? {},
                          );
                          if (result) {
                            projectEditCubit.saveProjectData(
                              projectData: widget.projectData,
                              projectCostData: projectCostingData!,
                              prjPhoneNo: phoneC.text,
                              prjMobileNo: mobileC.text,
                              isNewPrjUpdate: isNewPrjUpdate,
                              prjLat: latC.text,
                              prjLong: longC.text,
                              prjAddress: projectAddressC.text,
                              prjBuilderAdd: builderAddressC.text,
                              prjBuilderPhoneNo: bPhoneC.text,
                              prjBuilderMobileNo: bMobileC.text,
                              drinkingWater: drinkingWaterC.text,
                              modularKitchen: modularKitchenNameC.text,
                              architectId: selectedArchi?.architectId ?? 0,
                              architectName: architectNameC.text,
                              reraNo: reraNumberC.text,
                              cinNo: cinC.text,
                              totalWings: totalWingsC.text,
                              marketableWings: marketableWingsC.text,
                              totalSupplyUnits: totalSupplyUnitsC.text,
                              landParcelSize: landParcelSizeC.text,
                              selectedAreaUnit: selectedAreaUnit ?? {},
                              redevelopment: isRedevelopment,
                              syncGlobalStatus: widget.projectData.syncGlobalStatus!,
                              selectedSchemes: selectedSchemes,
                              isBooking: isBookingStop,
                              baseCost: baseCostC.text,
                              agreementCost: agreementCostC.text,
                              allInclusiveCost: allInculsiveCostC.text,
                            );
                          }
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
}
