import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_text_style.dart';
import 'package:lf_survey/constants/snackbar_helper.dart';
import 'package:lf_survey/constants/utils.dart';
import 'package:lf_survey/cubit/pams_survey/ps_land_form/ps_land_form_cubit.dart';
import 'package:lf_survey/cubit/pams_survey/ps_land_form/ps_land_form_state.dart';
import 'package:lf_survey/model/pams_survey/land_response.dart';
import 'package:lf_survey/model/pams_survey/ps_prj_response.dart';
import 'package:lf_survey/widgets/custom_app_bar.dart';
import 'package:lf_survey/widgets/custom_dropdown.dart';
import 'package:lf_survey/widgets/custom_elevated_btn.dart';
import 'package:lf_survey/widgets/custom_textform_field.dart';

class PsLandFormPage extends StatefulWidget {
  final PsPrjDatum prjDatum;
  const PsLandFormPage({super.key, required this.prjDatum});

  @override
  State<PsLandFormPage> createState() => _PsLandFormPageState();
}

class _PsLandFormPageState extends State<PsLandFormPage> {
  bool isUpdate = false;
  PsLandDatum? landDatum;
  List<Map<String, dynamic>> roadType = [
    {"id": 1, "title": "Tar"},
    {"id": 2, "title": "Cement Concrete Road"},
    {"id": 3, "title": "Kachha Road"},
    {"id": 4, "title": "Bitumen Road"},
    {"id": 5, "title": "Paver Block Road"},
  ];
  List<Map<String, dynamic>> approachRoadWidthType = [
    {"id": 1, "title": "Below 9 Mt"},
    {"id": 2, "title": "9m but below 12 Mt"},
    {"id": 3, "title": "12 Mt. but below 15 Mt"},
    {"id": 4, "title": "15 Mt but below 24 Mt"},
    {"id": 5, "title": "24 Mt but below 30 Mt"},
    {"id": 6, "title": "30 Mt and Above"},
  ];
  List<Map<String, dynamic>> constructionStatus = [
    {"id": 1, "title": "Ongoing"},
    {"id": 2, "title": "Stopped"},
    {"id": 3, "title": "Slow Constuction"},
  ];
  List<Map<String, dynamic>> materialStatus = [
    {"id": 1, "title": "Good"},
    {"id": 2, "title": "Average"},
    {"id": 3, "title": "Not available"},
  ];
  List<Map<String, dynamic>> proneArea = [
    {"id": 1, "title": "Yes"},
    {"id": 2, "title": "No"},
  ];

  Map<String, dynamic>? selectedRoadType;
  Map<String, dynamic>? selectedApproachRoadWidthType;
  Map<String, dynamic>? selectedConstructionStatus;
  Map<String, dynamic>? selectedMaterialStatus;
  Map<String, dynamic>? selectedLabourStatus;
  Map<String, dynamic>? selectedProneArea;
  Map<String, dynamic>? selectedRoadWidening;
  Map<String, dynamic>? selectedRailwayDistance;
  Map<String, dynamic>? selectedPropertyNearLines;
  Map<String, dynamic>? selectedWaterBody;
  Map<String, dynamic>? selectedFSI;
  Map<String, dynamic>? selectedVerticalDeviation;
  Map<String, dynamic>? selectedUnitDeviation;
  Map<String, dynamic>? selectedReservation;

  TextEditingController sbESiteC = TextEditingController();
  // TextEditingController sbEDocumentC = TextEditingController();
  // TextEditingController sbEReraC = TextEditingController();
  // TextEditingController sbESiteBoundariesC = TextEditingController();

  TextEditingController sbWSiteC = TextEditingController();
  // TextEditingController sbWDocumentC = TextEditingController();
  // TextEditingController sbWReraC = TextEditingController();
  // TextEditingController sbWSiteBoundariesC = TextEditingController();

  TextEditingController sbNSiteC = TextEditingController();
  // TextEditingController sbNDocumentC = TextEditingController();
  // TextEditingController sbNReraC = TextEditingController();
  // TextEditingController sbNSiteBoundariesC = TextEditingController();

  TextEditingController sbSSiteC = TextEditingController();
  // TextEditingController sbSDocumentC = TextEditingController();
  // TextEditingController sbSReraC = TextEditingController();
  // TextEditingController sbSSiteBoundariesC = TextEditingController();

  TextEditingController accessRoadC = TextEditingController();

  TextEditingController sesmicC = TextEditingController();
  TextEditingController coastalRegulartyC = TextEditingController();
  TextEditingController zoningDevelopmentPlanC = TextEditingController();
  TextEditingController habitationC = TextEditingController();
  TextEditingController remarksC = TextEditingController();

  TextEditingController bankNameC = TextEditingController();
  TextEditingController loanBankNameC = TextEditingController();
  TextEditingController visitChargesC = TextEditingController();
  TextEditingController revisitRemarksC = TextEditingController();

  double latitude = 0.0;
  double longitude = 0.0;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    context.read<PsLandFormCubit>().getLands(projectId: widget.prjDatum.projectId!);
  }

  @override
  void dispose() {
    sbESiteC.dispose();
    // sbEDocumentC.dispose();
    // sbEReraC.dispose();
    // sbESiteBoundariesC.dispose();
    sbWSiteC.dispose();
    // sbWDocumentC.dispose();
    // sbWReraC.dispose();
    // sbWSiteBoundariesC.dispose();
    sbNSiteC.dispose();
    // sbNDocumentC.dispose();
    // sbNReraC.dispose();
    // sbNSiteBoundariesC.dispose();
    sbSSiteC.dispose();
    // sbSDocumentC.dispose();
    // sbSReraC.dispose();
    // sbSSiteBoundariesC.dispose();
    sesmicC.dispose();
    coastalRegulartyC.dispose();
    zoningDevelopmentPlanC.dispose();
    habitationC.dispose();
    remarksC.dispose();
    bankNameC.dispose();
    loanBankNameC.dispose();
    visitChargesC.dispose();
    revisitRemarksC.dispose();
    super.dispose();
  }

  void prefillFields({PsLandDatum? landData}) {
    if (landData != null) {
      latitude = landData.lat ?? 0.0;
      longitude = landData.lng ?? 0.0;
      sbESiteC.text = landData.eastAsPerSite ?? "";
      // sbEDocumentC.text = landData.eastAsPerDocument ?? "";
      // sbEReraC.text = landData.eastAsPerRera ?? "";
      // sbESiteBoundariesC.text = landData.eastDeviation ?? "";
      sbWSiteC.text = landData.westAsPerSite ?? "";
      // sbWDocumentC.text = landData.westAsPerDocument ?? "";
      // sbWReraC.text = landData.westAsPerRera ?? "";
      // sbWSiteBoundariesC.text = landData.westDeviation ?? "";
      sbNSiteC.text = landData.northAsPerSite ?? "";
      // sbNDocumentC.text = landData.northAsPerDocument ?? "";
      // sbNReraC.text = landData.northAsPerRera ?? "";
      // sbNSiteBoundariesC.text = landData.northDeviation ?? "";
      sbSSiteC.text = landData.southAsPerSite ?? "";
      // sbSDocumentC.text = landData.southAsPerDocument ?? "";
      // sbSReraC.text = landData.southAsPerRera ?? "";
      // sbSSiteBoundariesC.text = landData.southDeviation ?? "";
      accessRoadC.text = landData.widthOfAccesssRoad ?? "";
      sesmicC.text = landData.criticalParametersSeismicZone ?? "";
      coastalRegulartyC.text = landData.criticalParametersCoastalRegulatoryZone ?? "";
      zoningDevelopmentPlanC.text = landData.criticalParametersZoningAsPerDevelopmentPlan ?? "";
      habitationC.text = landData.criticalParametersHabitation ?? "";
      remarksC.text = landData.criticalParametersRemarks ?? "";
      bankNameC.text = landData.projectCFByWhichBank ?? "";
      loanBankNameC.text = landData.projectHomeloanAvailble ?? "";
      revisitRemarksC.text = landData.revisitRemarks ?? "";
      visitChargesC.text = landData.visitCharges ?? "";

      selectedRoadType = roadType
          .where((e) => e["title"].toString().toLowerCase() == landData.typeOfAccessRoad?.toLowerCase())
          .cast<Map<String, dynamic>>()
          .firstOrNull;
      selectedApproachRoadWidthType = approachRoadWidthType
          .where((e) => e["title"].toString().toLowerCase() == landData.widthOfAccesssRoad?.toLowerCase())
          .cast<Map<String, dynamic>>()
          .firstOrNull;
      selectedConstructionStatus = constructionStatus
          .where((e) => e["title"].toString().toLowerCase() == landData.constructionStatus?.toLowerCase())
          .cast<Map<String, dynamic>>()
          .firstOrNull;
      selectedMaterialStatus = materialStatus
          .where((e) => e["title"].toString().toLowerCase() == landData.constructionMaterialStatus?.toLowerCase())
          .cast<Map<String, dynamic>>()
          .firstOrNull;
      selectedLabourStatus = materialStatus
          .where((e) => e["title"].toString().toLowerCase() == landData.labourStatusonSite?.toLowerCase())
          .cast<Map<String, dynamic>>()
          .firstOrNull;
      selectedProneArea = proneArea
          .where((e) => e["title"].toString().toLowerCase() == landData.criticalParametersFloodProneArea?.toLowerCase())
          .cast<Map<String, dynamic>>()
          .firstOrNull;
      selectedRoadWidening = proneArea
          .where(
            (e) => e["title"].toString().toLowerCase() == landData.criticalParametersFallingInPresent?.toLowerCase(),
          )
          .cast<Map<String, dynamic>>()
          .firstOrNull;
      selectedRailwayDistance = proneArea
          .where(
            (e) =>
                e["title"].toString().toLowerCase() ==
                landData.criticalParametersPropertyWithin30MFromRailway?.toLowerCase(),
          )
          .cast<Map<String, dynamic>>()
          .firstOrNull;
      selectedPropertyNearLines = proneArea
          .where(
            (e) =>
                e["title"].toString().toLowerCase() == landData.criticalParametersPropertyNearHtLtLines?.toLowerCase(),
          )
          .cast<Map<String, dynamic>>()
          .firstOrNull;
      selectedWaterBody = proneArea
          .where(
            (e) =>
                e["title"].toString().toLowerCase() ==
                landData.criticalParametersPresenceOfNallahWaterBodyNearby?.toLowerCase(),
          )
          .cast<Map<String, dynamic>>()
          .firstOrNull;
      selectedFSI = proneArea
          .where((e) => e["title"].toString().toLowerCase() == landData.criticalParametersFsiDeviation?.toLowerCase())
          .cast<Map<String, dynamic>>()
          .firstOrNull;
      selectedVerticalDeviation = proneArea
          .where(
            (e) => e["title"].toString().toLowerCase() == landData.criticalParametersVerticalDeviation?.toLowerCase(),
          )
          .cast<Map<String, dynamic>>()
          .firstOrNull;
      selectedUnitDeviation = proneArea
          .where((e) => e["title"].toString().toLowerCase() == landData.criticalParametersUnitDeviation?.toLowerCase())
          .cast<Map<String, dynamic>>()
          .firstOrNull;
      selectedReservation = proneArea
          .where(
            (e) =>
                e["title"].toString().toLowerCase() == landData.criticalParametersFallingInReservation?.toLowerCase(),
          )
          .cast<Map<String, dynamic>>()
          .firstOrNull;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: CustomAppBar(title: "Project Technical Info"),
      body: BlocListener<PsLandFormCubit, PsLandFormState>(
        listener: (context, state) {
          if (state is LoadingState) {
            isLoading = true;
          } else if (state is LoadedState) {
            isUpdate = true;

            landDatum = state.lands.first;
            prefillFields(landData: landDatum);
          } else if (state is ErrorState) {
            isLoading = false;
            CustomSnackHelper.customToastMsg(
              context: context,
              message: state.message,
              bgColor: AppColors.white,
              textColor: AppColors.black,
            );
          } else if (state is SucccessState) {
            isLoading = false;
            CustomSnackHelper.customToastMsg(
              context: context,
              message: state.message,
              bgColor: AppColors.white,
              textColor: AppColors.black,
            );
            context.pop();
          } else if (state is LocLoadedState) {
            latitude = state.location.latitude ?? 0.0;
            longitude = state.location.longitude ?? 0.0;
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  IgnorePointer(
                    ignoring: widget.prjDatum.apfStatus == 1,
                    child: Column(
                      children: [
                        BlocBuilder<PsLandFormCubit, PsLandFormState>(
                          buildWhen: (previous, current) =>
                              current is LoadedState || current is LocaLoadingState || current is LocLoadedState,
                          builder: (context, state) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 12,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                                        decoration: BoxDecoration(border: Border.all(color: AppColors.greyLite)),
                                        child: Column(
                                          spacing: 4.0,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text("Latitude: $latitude", style: AppTextStyle.ts12RB),
                                            Text("Langitude $longitude", style: AppTextStyle.ts12RB),
                                          ],
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: state is LocaLoadingState
                                          ? null
                                          : () {
                                              context.read<PsLandFormCubit>().getLocation(context: context);
                                            },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                                        decoration: BoxDecoration(
                                          color: AppColors.secondaryColor,
                                          borderRadius: BorderRadius.circular(6.0),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            if (state is LocaLoadingState) ...[
                                              SizedBox(
                                                height: 16,
                                                width: 16,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text("Fetching...", style: AppTextStyle.ts12BW),
                                            ] else ...[
                                              const Icon(Icons.my_location, color: Colors.white, size: 16),
                                              const SizedBox(width: 6),
                                              Text("Get Location", style: AppTextStyle.ts12BW),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text("Site Boundaries", style: AppTextStyle.ts14BB),
                                SizedBox(height: 4.0),
                                Text("East:", style: AppTextStyle.ts14MB),
                                CustomTextformField(controller: sbESiteC, labelText: "As Per Site"),
                                // CustomTextformField(
                                //   controller: sbEDocumentC,
                                //   labelText: "As Per Document",
                                //   keyboardType: TextInputType.number,
                                // ),
                                // CustomTextformField(
                                //   controller: sbEReraC,
                                //   labelText: "As Per Rera",
                                //   keyboardType: TextInputType.number,
                                // ),
                                // CustomTextformField(
                                //   controller: sbESiteBoundariesC,
                                //   labelText: "East Site Boundaries",
                                //   keyboardType: TextInputType.number,
                                // ),
                                SizedBox(height: 4.0),
                                Text("West:", style: AppTextStyle.ts14MB),
                                CustomTextformField(controller: sbWSiteC, labelText: "As Per Site"),
                                // CustomTextformField(
                                //   controller: sbWDocumentC,
                                //   labelText: "As Per Document",
                                //   keyboardType: TextInputType.number,
                                // ),
                                // CustomTextformField(
                                //   controller: sbWReraC,
                                //   labelText: "As Per Rera",
                                //   keyboardType: TextInputType.number,
                                // ),
                                // CustomTextformField(
                                //   controller: sbWSiteBoundariesC,
                                //   labelText: "West Site Boundaries",
                                //   keyboardType: TextInputType.number,
                                // ),
                                SizedBox(height: 4.0),
                                Text("North:", style: AppTextStyle.ts14MB),
                                CustomTextformField(controller: sbNSiteC, labelText: "As Per Site"),
                                // CustomTextformField(
                                //   controller: sbNDocumentC,
                                //   labelText: "As Per Document",
                                //   keyboardType: TextInputType.number,
                                // ),
                                // CustomTextformField(
                                //   controller: sbNReraC,
                                //   labelText: "As Per Rera",
                                //   keyboardType: TextInputType.number,
                                // ),
                                // CustomTextformField(
                                //   controller: sbNSiteBoundariesC,
                                //   labelText: "North Site Boundaries",
                                //   keyboardType: TextInputType.number,
                                // ),
                                SizedBox(height: 4.0),
                                Text("South:", style: AppTextStyle.ts14MB),
                                CustomTextformField(controller: sbSSiteC, labelText: "As Per Site"),
                                // CustomTextformField(
                                //   controller: sbSDocumentC,
                                //   labelText: "As Per Document",
                                //   keyboardType: TextInputType.number,
                                // ),
                                // CustomTextformField(
                                //   controller: sbSReraC,
                                //   labelText: "As Per Rera",
                                //   keyboardType: TextInputType.number,
                                // ),
                                // CustomTextformField(
                                //   controller: sbSSiteBoundariesC,
                                //   labelText: "South Site Boundaries",
                                //   keyboardType: TextInputType.number,
                                // ),
                                SizedBox(height: 4.0),
                                Text("Access Road", style: AppTextStyle.ts14BB),
                                SizedBox(height: 2.0),
                                // CustomTextformField(
                                //   controller: accessRoadC,
                                //   labelText: "Width of Access Road",
                                //   keyboardType: TextInputType.number,
                                // ),
                                CustomDropdown(
                                  lableText: "Types of Access Road",
                                  initialValue: selectedRoadType,
                                  items: roadType,
                                  labelKey: "title",
                                  onChanged: (value) {
                                    selectedRoadType = value;
                                  },
                                ),
                                CustomDropdown(
                                  lableText: "Approach Road Width",
                                  initialValue: selectedApproachRoadWidthType,
                                  items: approachRoadWidthType,
                                  labelKey: "title",
                                  onChanged: (value) {
                                    selectedApproachRoadWidthType = value;
                                  },
                                ),
                                SizedBox(height: 4.0),
                                Text("Construction Status", style: AppTextStyle.ts14BB),
                                SizedBox(height: 2.0),
                                CustomDropdown(
                                  lableText: "Construction Status",
                                  initialValue: selectedConstructionStatus,
                                  items: constructionStatus,
                                  labelKey: "title",
                                  onChanged: (value) {
                                    selectedConstructionStatus = value;
                                  },
                                ),
                                CustomDropdown(
                                  lableText: "Material on Site",
                                  initialValue: selectedMaterialStatus,
                                  items: materialStatus,
                                  labelKey: "title",
                                  onChanged: (value) {
                                    selectedMaterialStatus = value;
                                  },
                                ),
                                CustomDropdown(
                                  lableText: "Labour on Site",
                                  initialValue: selectedLabourStatus,
                                  items: materialStatus,
                                  labelKey: "title",
                                  onChanged: (value) {
                                    selectedLabourStatus = value;
                                  },
                                ),
                                CustomTextformField(
                                  controller: bankNameC,
                                  labelText: "Project CF By Which Bank as per board/project",
                                  hintText: "Please mention the name of bank",
                                ),
                                CustomTextformField(
                                  controller: loanBankNameC,
                                  labelText: "Project Home Loan Available From as Per Site",
                                  hintText: "Please mention the name of bank",
                                ),
                                SizedBox(height: 4.0),

                                // Text("Critical Parameters", style: AppTextStyle.ts14BB),
                                // SizedBox(height: 2.0),
                                // CustomTextformField(controller: sesmicC, labelText: "Sesmic Zone"),
                                // CustomDropdown(
                                //   lableText: "Flood Prone Area",
                                //   initialValue: selectedProneArea,
                                //   items: proneArea,
                                //   labelKey: "title",
                                //   onChanged: (value) {
                                //     selectedProneArea = value;
                                //   },
                                // ),
                                // CustomTextformField(controller: coastalRegulartyC, labelText: "Coastal Regularty Zone"),
                                // CustomTextformField(
                                //   controller: zoningDevelopmentPlanC,
                                //   labelText: "Zoninng As Per Development Plan",
                                // ),
                                // CustomDropdown(
                                //   lableText: "Falling in Present or Proposed Road Widening",
                                //   initialValue: selectedRoadWidening,
                                //   items: proneArea,
                                //   labelKey: "title",
                                //   onChanged: (value) {
                                //     selectedRoadWidening = value;
                                //   },
                                // ),
                                // CustomDropdown(
                                //   lableText: "Property Within 30m From Railway",
                                //   initialValue: selectedRailwayDistance,
                                //   items: proneArea,
                                //   labelKey: "title",
                                //   onChanged: (value) {
                                //     selectedRailwayDistance = value;
                                //   },
                                // ),
                                // CustomDropdown(
                                //   lableText: "Property near HT/LT Lines",
                                //   initialValue: selectedPropertyNearLines,
                                //   items: proneArea,
                                //   labelKey: "title",
                                //   onChanged: (value) {
                                //     selectedPropertyNearLines = value;
                                //   },
                                // ),
                                // CustomDropdown(
                                //   lableText: "Presence of Nallah / Water Body Nearby",
                                //   initialValue: selectedWaterBody,
                                //   items: proneArea,
                                //   labelKey: "title",
                                //   onChanged: (value) {
                                //     selectedWaterBody = value;
                                //   },
                                // ),
                                // CustomDropdown(
                                //   lableText: "FSI Deviation",
                                //   initialValue: selectedFSI,
                                //   items: proneArea,
                                //   labelKey: "title",
                                //   onChanged: (value) {
                                //     selectedFSI = value;
                                //   },
                                // ),
                                // CustomDropdown(
                                //   lableText: "Vertical Deviation",
                                //   initialValue: selectedVerticalDeviation,
                                //   items: proneArea,
                                //   labelKey: "title",
                                //   onChanged: (value) {
                                //     selectedVerticalDeviation = value;
                                //   },
                                // ),
                                // CustomDropdown(
                                //   lableText: "Unit Deviation",
                                //   initialValue: selectedUnitDeviation,
                                //   items: proneArea,
                                //   labelKey: "title",
                                //   onChanged: (value) {
                                //     selectedUnitDeviation = value;
                                //   },
                                // ),
                                // CustomTextformField(controller: habitationC, labelText: "Habitation (%) within 1 KM"),
                                // CustomDropdown(
                                //   lableText: "Falling in Reservation as per Development",
                                //   initialValue: selectedReservation,
                                //   items: proneArea,
                                //   labelKey: "title",
                                //   onChanged: (value) {
                                //     selectedReservation = value;
                                //   },
                                // ),
                                // CustomTextformField(controller: remarksC, labelText: "Remarks (if project affected)"),
                                SizedBox(height: 4.0),
                                Text("Visit Status", style: AppTextStyle.ts14BB),
                                SizedBox(height: 2.0),
                                CustomTextformField(controller: visitChargesC, labelText: "Visit Charges"),
                                CustomTextformField(controller: revisitRemarksC, labelText: "Revisit Remarks"),
                              ],
                            );
                          },
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: BlocBuilder<PsLandFormCubit, PsLandFormState>(
                            builder: (context, state) {
                              return CustomElevatedButton(
                                isLoading: state is LoadingState,
                                text: isUpdate ? "Update" : "Submit",
                                onPressed: () async {
                                  final locPermission = await Utils.checkLocationAndGpsPermission(context);
                                  if (!context.mounted) return;
                                  if (!locPermission) {
                                    CustomSnackHelper.errorToast(message: "Please enable location permission and GPS");
                                    return;
                                  }
                                  context.read<PsLandFormCubit>().submitMethod(
                                    projectId: widget.prjDatum.projectId!,
                                    lat: latitude,
                                    lng: longitude,
                                    eSite: sbESiteC.text,
                                    // eDocument: sbEDocumentC.text,
                                    // eRera: sbEReraC.text,
                                    // eSiteBoundaries: sbESiteBoundariesC.text,
                                    wSite: sbWSiteC.text,
                                    // wDocument: sbWDocumentC.text,
                                    // wRera: sbWReraC.text,
                                    // wSiteBoundaries: sbWSiteBoundariesC.text,
                                    nSite: sbNSiteC.text,
                                    // nDocument: sbNDocumentC.text,
                                    // nRera: sbNReraC.text,
                                    // nSiteBoundaries: sbNSiteBoundariesC.text,
                                    sSite: sbSSiteC.text,
                                    // sDocument: sbSDocumentC.text,
                                    // sRera: sbSReraC.text,
                                    // sSiteBoundaries: sbSSiteBoundariesC.text,
                                    typeAccessRoad: selectedRoadType?["title"] ?? "",
                                    widthAccessRoad: selectedApproachRoadWidthType?["title"] ?? "",
                                    constructionStatus: selectedConstructionStatus?["title"] ?? "",
                                    materialStatus: selectedMaterialStatus?["title"] ?? "",
                                    labourStatus: selectedLabourStatus?["title"] ?? "",
                                    bankName: bankNameC.text,
                                    loanBankName: loanBankNameC.text,
                                    // seismicZone: sesmicC.text,
                                    // proneArea: selectedProneArea?["title"] ?? "",
                                    // coastalRegZone: coastalRegulartyC.text,
                                    // zoningAPDevPlan: zoningDevelopmentPlanC.text,
                                    // faillingPresent: selectedRoadWidening?["title"] ?? "",
                                    // within30FromRailway: selectedRailwayDistance?["title"] ?? "",
                                    // propertyNearHTLines: selectedPropertyNearLines?["title"] ?? "",
                                    // presenceNallah: selectedWaterBody?["title"] ?? "",
                                    // fsiDeviation: selectedFSI?["title"] ?? "",
                                    // verticalDeviation: selectedVerticalDeviation?["title"] ?? "",
                                    // unitDeviation: selectedUnitDeviation?["title"] ?? "",
                                    // habitation: habitationC.text,
                                    // fallingReservationAPDev: selectedReservation?["title"] ?? "",
                                    // remarks: remarksC.text,
                                    allocationId: widget.prjDatum.allocationId ?? 0,
                                    visitCharges: visitChargesC.text,
                                    revisitRemarks: revisitRemarksC.text,
                                    isUpdate: isUpdate,
                                    projectLandId: landDatum?.projectLandId ?? 0,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.prjDatum.apfStatus == 1) Positioned.fill(child: Container(color: Colors.white54)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
