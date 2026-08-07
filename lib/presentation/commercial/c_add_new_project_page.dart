import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_dimens.dart';
import 'package:lf_survey/constants/app_text_style.dart';
import 'package:lf_survey/constants/snackbar_helper.dart';
import 'package:lf_survey/constants/utils.dart';
import 'package:lf_survey/cubit/commercial/c_add_new_project/c_add_new_prj_cubit.dart';
import 'package:lf_survey/cubit/commercial/c_add_new_project/c_add_new_prj_state.dart';
import 'package:lf_survey/model/db_model/commercial/c_new_project_entity.dart';
import 'package:lf_survey/routes/app_routes_name.dart';
import 'package:lf_survey/widgets/custom_app_bar.dart';
import 'package:lf_survey/widgets/custom_dropdown.dart';
import 'package:lf_survey/widgets/custom_elevated_btn.dart';
import 'package:lf_survey/widgets/custom_multi_dropdown.dart';
import 'package:lf_survey/widgets/custom_textfield.dart';
import 'package:lf_survey/widgets/phone_number_formatter.dart';
import 'package:location/location.dart';

class CAddNewProjectPage extends StatefulWidget {
  final CNewProjectEntity? projectData;
  const CAddNewProjectPage({super.key, this.projectData});

  @override
  State<CAddNewProjectPage> createState() => _CAddNewProjectPageState();
}

class _CAddNewProjectPageState extends State<CAddNewProjectPage> {
  int? empId;
  String? comQtr;
  String? comQtrId;
  TextEditingController projectNameC = TextEditingController();
  TextEditingController addressC = TextEditingController();
  TextEditingController roadC = TextEditingController();
  TextEditingController builderNameC = TextEditingController();
  TextEditingController architectNameC = TextEditingController();
  TextEditingController latC = TextEditingController();
  TextEditingController lngC = TextEditingController();
  TextEditingController mobileC = TextEditingController();

  List<Map<String, dynamic>> cities = [];
  List<Map<String, dynamic>> amenties = [];
  List<Map<String, dynamic>> approveBanks = [];
  List<Map<String, dynamic>> operationModel = [];
  List<Map<String, dynamic>> buildingType = [];
  List<Map<String, dynamic>> tenantType = [];

  Map<String, dynamic>? selectedCity;
  List<Map<String, dynamic>>? selectedAmenties;
  List<Map<String, dynamic>>? selectedApproveBanks;
  Map<String, dynamic>? selectedOperationModel;
  Map<String, dynamic>? selectedBuildingType;
  Map<String, dynamic>? selectedTenantType;
  String? projectNameEr;
  String? projectAddressEr;
  String? roadNameEr;
  String? builderNameEr;
  String? architectNameEr;
  String? latEr;
  String? lngEr;
  String? mobileNoEr;
  String? cityEr;
  String? amentiesEr;
  String? approveBanksEr;
  String? operatingModelEr;
  String? buildingTypeEr;
  String? tenantTypeEr;

  @override
  void initState() {
    super.initState();
    context.read<CAddNewPrjCubit>().fetchData();
    // prefillData(project: widget.projectData);
  }

  @override
  void dispose() {
    super.dispose();
    projectNameC.dispose();
    addressC.dispose();
    roadC.dispose();
    builderNameC.dispose();
    architectNameC.dispose();
    latC.dispose();
    lngC.dispose();
    mobileC.dispose();
  }

  String _formatDos(String? comQtr) {
    if (comQtr == null || comQtr.isEmpty) return "-";

    final date = Utils.tryParseDate(comQtr);
    if (date == null) return "-";

    return DateFormat('MMM yyyy').format(date);
  }

  void prefillData({CNewProjectEntity? project}) {
    if (project != null) {
      projectNameC.text = project.prjName ?? "";
      addressC.text = project.prjAddr ?? "";
      roadC.text = project.roadName ?? "";
      selectedCity = cities.cast<Map<String, dynamic>>().firstWhere(
        (e) => e["city_id"] == project.cityId,
        orElse: () => {},
      );

      builderNameC.text = project.builderName ?? "";
      architectNameC.text = project.architectName ?? "";
      latC.text = project.lat?.toString() ?? "";
      lngC.text = project.lng?.toString() ?? "";
      mobileC.text = project.mobile ?? "";
      final amentiesIds = (project.amenitiesIds ?? "").split(',').map((e) => e.trim()).toSet();
      selectedAmenties = amenties
          .cast<Map<String, dynamic>>()
          .where((e) => amentiesIds.contains(e["amenitiesId"].toString()))
          .toList();

      final banksId = (project.approvedBankIds ?? "").split(",").map((e) => e.trim()).toSet();
      selectedApproveBanks = approveBanks
          .cast<Map<String, dynamic>>()
          .where((e) => banksId.contains(e["bankId"].toString()))
          .toList();
      // for (var i in approveBanks) {
      //   debugPrint("SHSHSHHSHSSHSHHS: ${i["bankId"].runtimeType}");
      // }
      selectedOperationModel = operationModel.cast<Map<String, dynamic>>().firstWhere(
        (e) => e["operatingModelId"] == project.operatingModelId,
        orElse: () => {},
      );
      selectedBuildingType = buildingType.cast<Map<String, dynamic>>().firstWhere(
        (e) => e["buildingTypeId"] == project.buildingTypeId,
        orElse: () => {},
      );
      selectedTenantType = tenantType.cast<Map<String, dynamic>>().firstWhere(
        (e) => e['tenantMixId'] == project.tenantMixId,
        orElse: () => {},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final CAddNewPrjCubit cAddNewPrjCubit = context.read<CAddNewPrjCubit>();
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: CustomAppBar(title: "Add New CProject"),
      body: SafeArea(
        child: Padding(
          padding: AppDimens.hvPadding,
          child: BlocListener<CAddNewPrjCubit, CAddNewPrjState>(
            listener: (context, state) {
              if (state is ErrorState) {
                CustomSnackHelper.customToastMsg(
                  context: context,
                  message: state.message,
                  bgColor: AppColors.white,
                  textColor: AppColors.black,
                );
              } else if (state is SuccessState) {
                Navigator.pop(context);
                CustomSnackHelper.customToastMsg(
                  context: context,
                  message: state.message,
                  bgColor: AppColors.white,
                  textColor: AppColors.black,
                );
              } else if (state is LocalDbState) {
                cities.clear();
                amenties.clear();
                approveBanks.clear();
                operationModel.clear();
                buildingType.clear();
                tenantType.clear();
                cities.addAll(state.cities);
                amenties.addAll(state.amenties);
                approveBanks.addAll(state.approvedBanks);
                operationModel.addAll(state.operationModel);
                buildingType.addAll(state.buildingType);
                tenantType.addAll(state.tenantType);
                empId = state.empId;
                comQtr = state.comQtr;
                comQtrId = state.comQtrId;
                prefillData(project: widget.projectData);
              } else if (state is FieldsValidation) {
                projectNameEr = state.projectNameEr;
                projectAddressEr = state.projectAddressEr;
                roadNameEr = state.roadNameEr;
                builderNameEr = state.builderNameEr;
                architectNameEr = state.architectNameEr;
                latEr = state.latEr;
                lngEr = state.lngEr;
                mobileNoEr = state.mobileNoEr;
                cityEr = state.cityEr;
                amentiesEr = state.amentiesEr;
                approveBanksEr = state.approveBanksEr;
                operatingModelEr = state.operatingModelEr;
                buildingTypeEr = state.buildingTypeEr;
                tenantTypeEr = state.tenantTypeEr;
              }
            },
            child: Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(color: AppColors.white),
              child: SingleChildScrollView(
                child: BlocBuilder<CAddNewPrjCubit, CAddNewPrjState>(
                  builder: (context, state) {
                    return Column(
                      spacing: 8.0,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("(DOS : ${_formatDos(comQtr)})", style: AppTextStyle.ts12RB),
                        CustomTextField(
                          isRequired: true,
                          controller: projectNameC,
                          labelText: "Project Name",
                          errorText: projectNameEr,
                          suffixIcon: (projectNameEr != null) ? const Icon(Icons.error, color: Colors.red) : null,
                        ),
                        CustomTextField(
                          isRequired: true,
                          controller: addressC,
                          labelText: "Project Address",
                          errorText: projectAddressEr,
                          suffixIcon: (projectAddressEr != null) ? const Icon(Icons.error, color: Colors.red) : null,
                        ),
                        CustomTextField(
                          isRequired: true,
                          controller: roadC,
                          labelText: "Road Name",
                          errorText: roadNameEr,
                          suffixIcon: (projectNameEr != null) ? const Icon(Icons.error, color: Colors.red) : null,
                        ),
                        BlocBuilder<CAddNewPrjCubit, CAddNewPrjState>(
                          buildWhen: (previous, current) => current is LocalDbState,
                          builder: (context, state) {
                            return CustomDropdown(
                              initialValue: selectedCity,
                              isRequired: true,
                              items: cities,
                              labelKey: "city",
                              lableText: "City",
                              hintText: "Select City",
                              errorText: cityEr,
                              onChanged: (value) {
                                selectedCity = value;
                              },
                            );
                          },
                        ),
                        CustomTextField(
                          isRequired: true,
                          controller: builderNameC,
                          labelText: "Builder Name",
                          errorText: builderNameEr,
                          suffixIcon: (builderNameEr != null) ? const Icon(Icons.error, color: Colors.red) : null,
                        ),
                        CustomTextField(
                          isRequired: true,
                          controller: architectNameC,
                          labelText: "Architect Name",
                          errorText: architectNameEr,
                          suffixIcon: (architectNameEr != null) ? const Icon(Icons.error, color: Colors.red) : null,
                        ),
                        Row(
                          children: [
                            Flexible(
                              child: InkWell(
                                onLongPress: () async {
                                  try {
                                    final result = await Utils.checkLocationAndGpsPermission(context);
                                    if (result == true) {
                                      LocationData? locationData = await Utils.getCurrentLocation();
                                      if (locationData != null) {
                                        latC.text = locationData.latitude.toString();
                                        lngC.text = locationData.longitude.toString();
                                      }
                                    }
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    CustomSnackHelper.customToastMsg(context: context, message: e.toString());
                                  }
                                },
                                child: IgnorePointer(
                                  child: CustomTextField(
                                    isRequired: true,
                                    controller: latC,
                                    labelText: "Latitude (press & hold for 2 sec)",
                                    errorText: latEr,
                                  ),
                                ),
                              ),
                            ),
                            Text("OR", style: AppTextStyle.ts16MB),
                            IconButton(
                              onPressed: () async {
                                final result = await Utils.checkLocationAndGpsPermission(context);
                                if (result == true) {
                                  if (!context.mounted) return;
                                  final result = await context.push(AppRoutesName.mapPage);
                                  if (result != null && result is LatLng) {
                                    latC.text = result.latitude.toString();
                                    lngC.text = result.longitude.toString();
                                  }
                                }
                              },
                              icon: Icon(Icons.location_on, color: AppColors.red),
                            ),
                          ],
                        ),
                        InkWell(
                          onLongPress: () async {
                            try {
                              final result = await Utils.checkLocationAndGpsPermission(context);
                              if (result == true) {
                                LocationData? locationData = await Utils.getCurrentLocation();
                                if (locationData != null) {
                                  latC.text = locationData.latitude.toString();
                                  lngC.text = locationData.longitude.toString();
                                }
                              }
                            } catch (e) {
                              if (!context.mounted) return;
                              CustomSnackHelper.customToastMsg(context: context, message: e.toString());
                            }
                          },
                          child: IgnorePointer(
                            child: CustomTextField(
                              isRequired: true,
                              controller: lngC,
                              labelText: "Longitude (press & hold for 2 sec)",
                              errorText: lngEr,
                            ),
                          ),
                        ),
                        CustomTextField(
                          isRequired: true,
                          controller: mobileC,
                          labelText: "Mobile Number",
                          keyboardType: TextInputType.number,
                          inputFormatters: [PhoneNumberFormatter()],
                          errorText: mobileNoEr,
                          suffixIcon: (mobileNoEr != null) ? const Icon(Icons.error, color: Colors.red) : null,
                        ),
                        BlocBuilder<CAddNewPrjCubit, CAddNewPrjState>(
                          buildWhen: (previous, current) => current is LocalDbState,
                          builder: (context, state) {
                            return Column(
                              spacing: 12.0,
                              children: [
                                SizedBox(),
                                CustomMultiSelectDropdown(
                                  isRequired: true,
                                  key: ValueKey('amenities_${selectedAmenties?.length}'),
                                  initialValues: selectedAmenties,
                                  items: amenties,
                                  labelKey: "amenities",
                                  labelText: "Amenties:",
                                  hintText: "Select Amenties",
                                  onChanged: (value) {
                                    selectedAmenties =
                                        (value as List?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ??
                                        [];
                                  },
                                  errorText: amentiesEr,
                                ),
                                CustomMultiSelectDropdown(
                                  isRequired: true,
                                  key: ValueKey('banks_${selectedApproveBanks?.length}'),
                                  initialValues: selectedApproveBanks,
                                  items: approveBanks,
                                  labelKey: "bankName",
                                  labelText: "Approve Banks:",
                                  hintText: "Select Approve Banks",
                                  onChanged: (value) {
                                    selectedApproveBanks =
                                        (value as List?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ??
                                        [];
                                  },
                                  errorText: approveBanksEr,
                                ),
                                CustomDropdown(
                                  isRequired: true,
                                  initialValue: selectedOperationModel,
                                  items: operationModel,
                                  labelKey: "operatingModel",
                                  lableText: "Operating Model:",
                                  hintText: "Select Operating Model",
                                  onChanged: (value) {
                                    selectedOperationModel = value;
                                  },
                                  errorText: operatingModelEr,
                                ),
                                CustomDropdown(
                                  isRequired: true,
                                  initialValue: selectedBuildingType,
                                  items: buildingType,
                                  labelKey: "buildingType",
                                  lableText: "Building Type:",
                                  hintText: "Select Building Type",
                                  onChanged: (value) {
                                    selectedBuildingType = value;
                                  },
                                  errorText: buildingTypeEr,
                                ),
                                CustomDropdown(
                                  isRequired: true,
                                  items: tenantType,
                                  initialValue: selectedTenantType,
                                  labelKey: "tenantMix",
                                  lableText: "Tenant Type:",
                                  hintText: "Select Tenant Type",
                                  onChanged: (value) {
                                    selectedTenantType = value;
                                  },
                                  errorText: tenantTypeEr,
                                ),
                              ],
                            );
                          },
                        ),
                        SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: BlocBuilder<CAddNewPrjCubit, CAddNewPrjState>(
                            builder: (context, state) {
                              return CustomElevatedButton(
                                isLoading: state is LoadingState,
                                backgroundColor: AppColors.red,
                                text: "SAVE",
                                onPressed: () {
                                  cAddNewPrjCubit.submitData(
                                    empId: empId,
                                    comQtr: comQtr,
                                    projectId: widget.projectData?.prjId,
                                    projectName: projectNameC.text,
                                    projectAddress: addressC.text,
                                    roadName: roadC.text,
                                    builderName: builderNameC.text,
                                    architectName: architectNameC.text,
                                    lat: latC.text,
                                    lng: lngC.text,
                                    mobileNo: mobileC.text,
                                    selectedCities: selectedCity,
                                    selectedAmenties: selectedAmenties,
                                    selectApproveBanks: selectedApproveBanks,
                                    selectOperatingModel: selectedOperationModel,
                                    selectBuildingType: selectedBuildingType,
                                    selectTenantType: selectedTenantType,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: CustomElevatedButton(
                            backgroundColor: AppColors.red,
                            text: "CANCEL",
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        SizedBox(height: 30),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
