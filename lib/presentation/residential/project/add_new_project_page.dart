import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lf_survey/app_popups/custom_bottomsheet.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_dimens.dart';
import 'package:lf_survey/constants/app_text_style.dart';
import 'package:lf_survey/constants/snackbar_helper.dart';
import 'package:lf_survey/constants/utils.dart';
import 'package:lf_survey/cubit/residential/add_new_project/add_new_prj_cubit.dart';
import 'package:lf_survey/cubit/residential/add_new_project/add_new_prj_state.dart';
import 'package:lf_survey/model/residential/project_spinner.dart';
import 'package:lf_survey/model/residential/rera_details_response.dart';
import 'package:lf_survey/model/residential/rera_response.dart';
import 'package:lf_survey/routes/app_routes_name.dart';
import 'package:lf_survey/widgets/custom_app_bar.dart';
import 'package:lf_survey/widgets/custom_dropdown.dart';
import 'package:lf_survey/widgets/custom_elevated_btn.dart';
import 'package:lf_survey/widgets/custom_textfield.dart';
import 'package:lf_survey/widgets/custom_textform_field.dart';
import 'package:location/location.dart';

class AddNewProjectPage extends StatefulWidget {
  const AddNewProjectPage({super.key});

  @override
  State<AddNewProjectPage> createState() => _AddNewProjectPageState();
}

class _AddNewProjectPageState extends State<AddNewProjectPage> {
  int qtrId = 0;
  String qtr = "";
  bool isReraLaunch = false;
  bool isLottery = false;
  bool isRedevelopment = false;
  List<ReraDatum> reraList = [];
  List<ReraDetails> reraDetailsList = [];
  List<CityList> cities = [];
  List<Map<String, dynamic>> amenties = [];
  List<Map<String, dynamic>> approveBanks = [];
  List<Map<String, dynamic>> projectScales = [];
  List<Map<String, dynamic>> projectTypes = [
    {"id": 1, "title": "RERA Project"},
    {"id": 2, "title": "Non-RERA Project"},
    {"id": 3, "title": "RERA pre-Launch"},
  ];
  CityList? selectedCity;
  Map<String, dynamic>? selectedPrjType;
  List<Map<String, dynamic>> selectedAmenties = [];
  List<Map<String, dynamic>> selectedBanks = [];
  Map<String, dynamic>? selectedPrjScales;
  TextEditingController reraNoC = TextEditingController();
  TextEditingController prjNameC = TextEditingController();
  TextEditingController prjAddressC = TextEditingController();
  TextEditingController cityC = TextEditingController();
  TextEditingController builderNameC = TextEditingController();
  TextEditingController architectNameC = TextEditingController();
  TextEditingController latC = TextEditingController();
  TextEditingController longC = TextEditingController();
  TextEditingController mobileC = TextEditingController();
  TextEditingController amentiesC = TextEditingController();
  TextEditingController approvedBankC = TextEditingController();

  FocusNode prjAddressFN = FocusNode();
  FocusNode builderNameFN = FocusNode();
  FocusNode archiNameFN = FocusNode();
  FocusNode mobileNumberFN = FocusNode();

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      context.read<AddNewPrjCubit>().downloadProjectSpinner();
    } else {
      context.read<AddNewPrjCubit>().fetchData();
    }

    context.read<AddNewPrjCubit>().fetchUserData();
  }

  @override
  void dispose() {
    super.dispose();
    reraNoC.dispose();
    prjNameC.dispose();
    prjAddressC.dispose();
    cityC.dispose();
    builderNameC.dispose();
    architectNameC.dispose();
    latC.dispose();
    longC.dispose();
    mobileC.dispose();
    amentiesC.dispose();
    approvedBankC.dispose();

    prjAddressFN.dispose();
    builderNameFN.dispose();
    archiNameFN.dispose();
    mobileNumberFN.dispose();
  }

  void clearFields() {
    reraNoC.clear();
    prjNameC.clear();
    prjAddressC.clear();
    cityC.clear();
    builderNameC.clear();
    architectNameC.clear();
    latC.clear();
    longC.clear();
    mobileC.clear();
    amentiesC.clear();
    approvedBankC.clear();
    setState(() {
      selectedPrjType = null;
      selectedPrjScales = null;
      isLottery = false;
      isRedevelopment = false;
    });
  }

  // error handle fields variable
  String reraMsg = "";
  String prjMsg = "";
  String prjAddMsg = "";
  String builderMsg = "";
  String archiMsg = "";
  String latMsg = "";
  String lngMsg = "";
  String mobMsg = "";
  @override
  Widget build(BuildContext context) {
    AddNewPrjCubit addNewPrjCubit = context.read<AddNewPrjCubit>();
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: CustomAppBar(title: "Edit New Project"),
      body: SafeArea(
        child: BlocListener<AddNewPrjCubit, AddNewPrjState>(
          listener: (context, state) {
            if (state is SelectPrjTypeSate) {
              selectedPrjType = state.projectType;
            } else if (state is UserDataState) {
              qtrId = int.tryParse(state.qtrId) ?? 0;
              qtr = DateFormat('MMM yyyy').format(Utils.tryParseDate(state.qtr)!);
            } else if (state is ReraSearch) {
              reraList.clear();
              reraList.addAll(state.reraDatum);
            } else if (state is ReraInfoState) {
              reraList.clear();
            } else if (state is ReraDetailsState) {
              reraList.clear();
              reraDetailsList.clear();
              reraDetailsList.addAll(state.reraDetails);
              var reraData = reraDetailsList.first;
              reraNoC.text = reraData.reraRegNo ?? "";
              prjNameC.text = reraData.projectName ?? "";
              prjAddressC.text = reraData.projectAddress ?? "";
              builderNameC.text = reraData.promoterName ?? "";
            } else if (state is LocalDbState) {
              cities.clear();
              amenties.clear();
              approveBanks.clear();
              projectScales.clear();
              cities.addAll(state.cities);
              amenties.addAll(state.amenties.map((i) => {"id": i.amenitiesId, "title": i.amenities}));
              approveBanks.addAll(state.approveBanks.map((i) => {"id": i.bankId, "title": i.bankName}));
              projectScales.addAll(state.projectScales.map((i) => {"id": i.scaleId, "title": i.projectScale}));
            } else if (state is ReraLaunchState) {
              isReraLaunch = state.isReraLaunch;
            } else if (state is LotteryState) {
              isLottery = state.isLottery;
            } else if (state is RedevelopState) {
              isRedevelopment = state.isRedevelop;
            } else if (state is ErrorState) {
              CustomSnackHelper.customToastMsg(
                context: context,
                message: state.message,
                bgColor: AppColors.white,
                textColor: AppColors.black,
              );
            } else if (state is SuccessState) {
              CustomSnackHelper.customToastMsg(
                context: context,
                message: state.message,
                bgColor: AppColors.white,
                textColor: AppColors.black,
              );
            } else if (state is FieldsValidation) {
              setState(() {
                reraMsg = state.reraMsg;
                prjMsg = state.prjMsg;
                prjAddMsg = state.prjAddMsg;
                builderMsg = state.builderMsg;
                archiMsg = state.archiMsg;
                latMsg = state.latMsg;
                lngMsg = state.lngMsg;
                mobMsg = state.mobMsg;
              });
            }
          },
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: AppDimens.hvPadding,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 16.0),
                  decoration: BoxDecoration(color: AppColors.white),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 12.0,
                      children: [
                        SizedBox(height: 16.0),
                        BlocBuilder<AddNewPrjCubit, AddNewPrjState>(
                          buildWhen: (previous, current) => current is UserDataState,
                          builder: (context, state) {
                            return Text("(DOS: $qtr)", style: AppTextStyle.ts14RB.copyWith(color: Colors.grey));
                          },
                        ),
                        CustomDropdown(
                          items: projectTypes,
                          labelKey: "title",
                          lableText: "Project Type",
                          hintText: "Select project type",
                          onChanged: (value) {
                            if (value != null) {
                              addNewPrjCubit.selectProjectType(value: value);
                            }
                          },
                        ),
                        BlocBuilder<AddNewPrjCubit, AddNewPrjState>(
                          buildWhen: (previous, current) =>
                              current is SelectPrjTypeSate ||
                              current is LoadingState ||
                              current is ErrorState ||
                              current is ReraSearch,
                          builder: (context, state) {
                            return selectedPrjType?["title"] == "Non-RERA Project" || selectedPrjType == null
                                ? SizedBox.shrink()
                                : Column(
                                    children: [
                                      CustomTextField(
                                        controller: reraNoC,
                                        labelText: "Rera No",
                                        lableTextColor: reraMsg.isNotEmpty ? AppColors.red : null,
                                        suffixIcon: reraMsg.isNotEmpty
                                            ? Icon(Icons.error, color: AppColors.red)
                                            : state is LoadingState
                                            ? Padding(
                                                padding: const EdgeInsets.all(12.0),
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: AppColors.red,
                                                  constraints: BoxConstraints(
                                                    maxHeight: 3,
                                                    maxWidth: 3,
                                                    minWidth: 3,
                                                    minHeight: 3,
                                                  ),
                                                ),
                                              )
                                            : null,
                                        errorText: reraMsg.isEmpty ? null : reraMsg,
                                        onChanged: selectedPrjType?["title"] == "RERA pre-Launch"
                                            ? null
                                            : (value) {
                                                if (value.isNotEmpty) {
                                                  addNewPrjCubit.reraSearch(query: value);
                                                }
                                              },
                                      ),

                                      BlocBuilder<AddNewPrjCubit, AddNewPrjState>(
                                        buildWhen: (previous, current) =>
                                            current is ReraSearch ||
                                            current is ReraDetailsState ||
                                            current is ReraInfoState,
                                        builder: (context, state) {
                                          return reraList.isEmpty
                                              ? SizedBox.shrink()
                                              : Column(
                                                  children: [
                                                    SizedBox(height: reraList.isNotEmpty ? 12.0 : 0.0),
                                                    SizedBox(
                                                      height: MediaQuery.of(context).size.height * 0.35,
                                                      child: ListView.builder(
                                                        itemCount: reraList.length,
                                                        itemBuilder: (context, index) {
                                                          return InkWell(
                                                            onTap: () {
                                                              if (reraList[index].projectId != 0) {
                                                                showDialog(
                                                                  context: context,
                                                                  builder: (_) {
                                                                    return AlertDialog(
                                                                      shape: RoundedRectangleBorder(),
                                                                      title: Row(
                                                                        spacing: 8.0,
                                                                        children: [
                                                                          Icon(Icons.info, color: Colors.blueGrey),
                                                                          Flexible(
                                                                            child: Text(
                                                                              "Alert",
                                                                              style: AppTextStyle.ts18MB,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      content: Text(
                                                                        "RERA is already mapped to some other Project.",
                                                                        style: AppTextStyle.ts14RB,
                                                                      ),
                                                                      actions: [
                                                                        TextButton(
                                                                          onPressed: () {
                                                                            addNewPrjCubit.reraInfoAction();
                                                                            reraNoC.clear();
                                                                            context.pop();
                                                                          },
                                                                          child: Text("OK", style: AppTextStyle.ts18MB),
                                                                        ),
                                                                      ],
                                                                    );
                                                                  },
                                                                );
                                                              } else {
                                                                addNewPrjCubit.fetchReraDetails(
                                                                  reraId: reraList[index].id ?? 0,
                                                                );
                                                              }
                                                            },
                                                            child: Padding(
                                                              padding: const EdgeInsets.only(
                                                                bottom: 8.0,
                                                                left: 4.0,
                                                                right: 4.0,
                                                                top: 4.0,
                                                              ),
                                                              child: Container(
                                                                padding: EdgeInsets.all(8.0),
                                                                decoration: BoxDecoration(
                                                                  color: Colors.white,
                                                                  borderRadius: BorderRadius.circular(6),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Colors.black26,
                                                                      blurRadius: 6,
                                                                      offset: const Offset(0, 3),
                                                                    ),
                                                                  ],
                                                                ),
                                                                child: Text(
                                                                  reraList[index].name ?? "",
                                                                  style: AppTextStyle.ts14RB,
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                );
                                        },
                                      ),
                                    ],
                                  );
                          },
                        ),
                        BlocBuilder<AddNewPrjCubit, AddNewPrjState>(
                          buildWhen: (previous, current) => current is SelectPrjTypeSate || current is ReraLaunchState,
                          builder: (context, state) {
                            return selectedPrjType?["id"] == 1
                                ? CheckboxListTile(
                                    dense: true,
                                    visualDensity: VisualDensity.compact,
                                    controlAffinity: ListTileControlAffinity.leading,
                                    contentPadding: EdgeInsets.zero,
                                    activeColor: AppColors.red,
                                    title: Text("Rera Not Launch", style: AppTextStyle.ts14RB),
                                    value: isReraLaunch,
                                    onChanged: (bool? value) {
                                      if (value == null) return;
                                      addNewPrjCubit.selectReraLaunch(isReraLaunch: value);
                                    },
                                  )
                                : SizedBox.shrink();
                          },
                        ),
                        CustomTextField(
                          controller: prjNameC,
                          labelText: "Project Name",
                          lableTextColor: prjMsg.isNotEmpty ? AppColors.red : null,
                          suffixIcon: prjMsg.isNotEmpty ? Icon(Icons.error, color: AppColors.red) : null,
                          errorText: prjMsg.isEmpty ? null : prjMsg,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(prjAddressFN);
                          },
                        ),
                        CustomTextField(
                          controller: prjAddressC,
                          labelText: "Project Address",
                          lableTextColor: prjAddMsg.isNotEmpty ? AppColors.red : null,
                          suffixIcon: prjAddMsg.isNotEmpty ? Icon(Icons.error, color: AppColors.red) : null,
                          errorText: prjAddMsg.isEmpty ? null : prjAddMsg,
                          focusNode: prjAddressFN,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(builderNameFN);
                          },
                        ),
                        InkWell(
                          onTap: () async {
                            final result = await CustomBottomsheet.cityBottomSheet(
                              context: context,
                              cities: cities,
                              initialCity: selectedCity,
                            );
                            if (result == null) return;
                            cityC.text = result.city ?? "";
                            selectedCity = result;
                          },
                          child: IgnorePointer(
                            ignoring: true,
                            child: CustomTextformField(
                              readOnly: true,
                              controller: cityC,
                              labelText: "City",
                              hintText: "Select City",
                              suffixIcon: Icon(Icons.arrow_drop_down),
                            ),
                          ),
                        ),
                        CustomTextField(
                          controller: builderNameC,
                          labelText: "Builder Name",
                          lableTextColor: builderMsg.isNotEmpty ? AppColors.red : null,
                          suffixIcon: builderMsg.isNotEmpty ? Icon(Icons.error, color: AppColors.red) : null,
                          errorText: builderMsg.isEmpty ? null : builderMsg,
                          focusNode: builderNameFN,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(archiNameFN);
                          },
                        ),
                        CustomTextField(
                          controller: architectNameC,
                          labelText: "Architect Name",
                          lableTextColor: archiMsg.isNotEmpty ? AppColors.red : null,
                          suffixIcon: archiMsg.isNotEmpty ? Icon(Icons.error, color: AppColors.red) : null,
                          errorText: archiMsg.isEmpty ? null : archiMsg,
                          focusNode: archiNameFN,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(mobileNumberFN);
                          },
                        ),
                        Row(
                          spacing: 12.0,
                          children: [
                            Expanded(
                              child: InkWell(
                                onLongPress: () async {
                                  try {
                                    final result = await Utils.checkLocationAndGpsPermission(context);
                                    if (result == true) {
                                      // Position locationData = await Geolocator.getCurrentPosition();
                                      LocationData? locationData = await Utils.getCurrentLocation();
                                      if (locationData != null) {
                                        latC.text = locationData.latitude.toString();
                                        longC.text = locationData.longitude.toString();
                                      }
                                    }
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    CustomSnackHelper.customToastMsg(context: context, message: e.toString());
                                  }
                                },
                                child: IgnorePointer(
                                  ignoring: true,
                                  child: CustomTextField(
                                    controller: latC,
                                    labelText: "Latitude(press & hold for 2 sec)",
                                    lableTextColor: latMsg.isNotEmpty ? AppColors.red : null,
                                    suffixIcon: latMsg.isNotEmpty ? Icon(Icons.error, color: AppColors.red) : null,
                                    errorText: latMsg.isEmpty ? null : latMsg,
                                  ),
                                ),
                              ),
                            ),
                            Text("OR", style: AppTextStyle.ts16BB),
                            InkWell(
                              onTap: () async {
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
                              child: Icon(Icons.location_on, color: AppColors.red),
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
                                  longC.text = locationData.longitude.toString();
                                }
                              }
                            } catch (e) {
                              if (!context.mounted) return;
                              CustomSnackHelper.customToastMsg(context: context, message: e.toString());
                            }
                          },
                          child: IgnorePointer(
                            ignoring: true,
                            child: CustomTextField(
                              controller: longC,
                              labelText: "Longitude(press & hold for 2 sec)",
                              lableTextColor: lngMsg.isNotEmpty ? AppColors.red : null,
                              suffixIcon: lngMsg.isNotEmpty ? Icon(Icons.error, color: AppColors.red) : null,
                              errorText: lngMsg.isEmpty ? null : lngMsg,
                            ),
                          ),
                        ),
                        CustomTextField(
                          focusNode: mobileNumberFN,
                          controller: mobileC,
                          labelText: "Mobile Number",
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,]'))],
                          lableTextColor: mobMsg.isNotEmpty ? AppColors.red : null,
                          suffixIcon: mobMsg.isNotEmpty ? Icon(Icons.error, color: AppColors.red) : null,
                          errorText: mobMsg.isEmpty ? null : mobMsg,
                        ),
                        InkWell(
                          onTap: () async {
                            final result = await CustomBottomsheet.amentieBottomSheet(
                              context: context,
                              dataList: amenties,
                              title: 'Amenties',
                              initialSelectedItems: selectedAmenties,
                            );
                            if (result.isNotEmpty) {
                              amentiesC.clear();
                              selectedAmenties.clear();
                              selectedAmenties.addAll(result);
                              amentiesC.text = selectedAmenties.map((i) => i["title"]).join(", ");
                            } else {
                              amentiesC.clear();
                              selectedAmenties.clear();
                            }
                          },
                          child: IgnorePointer(
                            ignoring: true,
                            child: CustomTextformField(
                              readOnly: true,
                              minLines: 1,
                              maxLines: 500,
                              controller: amentiesC,
                              labelText: "Amenties",
                              hintText: "Select Amenties",
                              suffixIcon: Icon(Icons.arrow_drop_down),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            final result = await CustomBottomsheet.amentieBottomSheet(
                              context: context,
                              dataList: approveBanks,
                              title: 'Approved Banks',
                              initialSelectedItems: selectedBanks,
                            );
                            if (result.isNotEmpty) {
                              approvedBankC.clear();
                              selectedBanks.clear();
                              selectedBanks.addAll(result);
                              approvedBankC.text = selectedBanks.map((i) => i["title"]).join(", ");
                            } else {
                              approvedBankC.clear();
                              selectedBanks.clear();
                            }
                          },
                          child: IgnorePointer(
                            ignoring: true,
                            child: CustomTextformField(
                              readOnly: true,
                              minLines: 1,
                              maxLines: 500,
                              suffixIcon: Icon(Icons.arrow_drop_down),
                              controller: approvedBankC,
                              labelText: "Approved Banks",
                              hintText: "Select Banks",
                            ),
                          ),
                        ),
                        BlocBuilder<AddNewPrjCubit, AddNewPrjState>(
                          buildWhen: (previous, current) => current is LocalDbState,
                          builder: (context, state) {
                            return CustomDropdown(
                              initialValue: selectedPrjScales,
                              items: projectScales,
                              labelKey: "title",
                              lableText: "Project Scale",
                              hintText: "Select project scale",
                              onChanged: (value) {
                                if (value != null) {
                                  selectedPrjScales = value;
                                }
                              },
                            );
                          },
                        ),
                        BlocBuilder<AddNewPrjCubit, AddNewPrjState>(
                          buildWhen: (previous, current) => current is LotteryState,
                          builder: (context, state) {
                            return CheckboxListTile(
                              dense: true,
                              visualDensity: VisualDensity.compact,
                              controlAffinity: ListTileControlAffinity.leading,
                              activeColor: AppColors.red,
                              title: Text("Lottery", style: AppTextStyle.ts14RB),
                              value: isLottery,
                              onChanged: (bool? value) {
                                if (value == null) return;
                                addNewPrjCubit.selectLottery(isLottery: value);
                              },
                            );
                          },
                        ),
                        BlocBuilder<AddNewPrjCubit, AddNewPrjState>(
                          buildWhen: (previous, current) => current is RedevelopState,
                          builder: (context, state) {
                            return CheckboxListTile(
                              dense: true,
                              visualDensity: VisualDensity.compact,
                              activeColor: AppColors.red,
                              controlAffinity: ListTileControlAffinity.leading,
                              title: Text("Re-Development", style: AppTextStyle.ts14RB),
                              value: isRedevelopment,
                              onChanged: (bool? value) {
                                if (value == null) return;
                                addNewPrjCubit.selectRedevlopment(isRedevelopment: value);
                              },
                            );
                          },
                        ),

                        SizedBox(
                          width: double.infinity,
                          child: CustomElevatedButton(
                            backgroundColor: AppColors.red,
                            text: "SAVE",
                            onPressed: () async {
                              final result = await addNewPrjCubit.saveProject(
                                qtrId: qtrId,
                                qtr: qtr,
                                projectType: selectedPrjType,
                                reraNo: reraNoC.text,
                                projectName: prjNameC.text,
                                projectAddress: prjAddressC.text,
                                cityId: selectedCity?.cityId ?? 0,
                                builderName: builderNameC.text,
                                architectName: architectNameC.text,
                                lat: latC.text,
                                lng: longC.text,
                                mobileNumber: mobileC.text,
                                selectedAmenties: selectedAmenties,
                                selectedBanks: selectedBanks,
                                selectedPrjScales: selectedPrjScales,
                                lottery: isLottery,
                                redevelopment: isRedevelopment,
                                reraNotLaunch: isReraLaunch,
                              );
                              if (result == true) {
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
                              clearFields();
                              context.pop();
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
        ),
      ),
    );
  }
}
