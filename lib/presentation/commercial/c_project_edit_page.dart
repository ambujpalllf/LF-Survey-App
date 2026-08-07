import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_dimens.dart';
import 'package:lf_survey/constants/snackbar_helper.dart';
import 'package:lf_survey/cubit/commercial/c_project_edit/c_project_edit_cubit.dart';
import 'package:lf_survey/cubit/commercial/c_project_edit/c_project_edit_state.dart';
import 'package:lf_survey/model/db_model/commercial/c_project_entity.dart';
import 'package:lf_survey/widgets/custom_app_bar.dart';
import 'package:lf_survey/widgets/custom_dropdown.dart';
import 'package:lf_survey/widgets/custom_elevated_btn.dart';
import 'package:lf_survey/widgets/custom_textfield.dart';

class CProjectEditPage extends StatefulWidget {
  final CProjectEntity projectEntity;
  const CProjectEditPage({super.key, required this.projectEntity});

  @override
  State<CProjectEditPage> createState() => _CProjectEditPageState();
}

class _CProjectEditPageState extends State<CProjectEditPage> {
  TextEditingController reraNoC = TextEditingController();
  TextEditingController cinNoC = TextEditingController();
  TextEditingController openParkingC = TextEditingController();
  TextEditingController stackedParkingC = TextEditingController();
  TextEditingController stiltParkingC = TextEditingController();
  TextEditingController basementParkingC = TextEditingController();
  TextEditingController podiumParkingC = TextEditingController();
  TextEditingController parkingRatioC = TextEditingController();
  TextEditingController scrC = TextEditingController();
  TextEditingController maintenanceC = TextEditingController();
  TextEditingController propertyTaxC = TextEditingController();
  TextEditingController landParcelSizeC = TextEditingController();
  List<Map<String, dynamic>> areaUnit = [];
  List<Map<String, dynamic>> tenantMix = [];

  Map<String, dynamic>? selectedAreaUnit;
  Map<String, dynamic>? selectedTenantMix;
  @override
  void initState() {
    super.initState();
    context.read<CProjectEditCubit>().fetchData();
    prefillFields(projectData: widget.projectEntity);
  }

  void prefillFields({required CProjectEntity projectData}) {
    reraNoC.text = projectData.rerano ?? "";
    openParkingC.text = projectData.parkingOpen?.toString() ?? "";
    stackedParkingC.text = projectData.parkingStacked?.toString() ?? "";
    stiltParkingC.text = projectData.parkingStacked?.toString() ?? "";
    basementParkingC.text = projectData.parkingBasement?.toString() ?? "";
    podiumParkingC.text = projectData.parkingPodium?.toString() ?? "";
    parkingRatioC.text = projectData.parkingRatio?.toString() ?? "";
    scrC.text = projectData.scr?.toString() ?? "";
    maintenanceC.text = projectData.maintenancePerSqft?.toString() ?? "";
    propertyTaxC.text = projectData.propertyTax?.toString() ?? "";
    landParcelSizeC.text = projectData.landParcelSize?.toString() ?? "";
  }

  @override
  void dispose() {
    super.dispose();
    reraNoC.dispose();
    cinNoC.dispose();
    openParkingC.dispose();
    stackedParkingC.dispose();
    stiltParkingC.dispose();
    basementParkingC.dispose();
    podiumParkingC.dispose();
    parkingRatioC.dispose();
    scrC.dispose();
    maintenanceC.dispose();
    propertyTaxC.dispose();
    landParcelSizeC.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CProjectEditCubit projectEditCubit = context.read<CProjectEditCubit>();
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: CustomAppBar(title: "Project Edit"),
      body: SafeArea(
        child: BlocListener<CProjectEditCubit, CProjectEditState>(
          listener: (context, state) {
            if (state is ErrorState) {
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
            } else if (state is LocalDbState) {
              areaUnit.clear();
              tenantMix.clear();
              areaUnit.addAll(state.areaUnit);
              tenantMix.addAll(state.tenant);
              final areaUnitL = areaUnit.where((e) => e["areaUnitId"] == widget.projectEntity.landParcelSizeUnit);
              final tenantL = tenantMix.where((e) => e["tenantMixId"] == widget.projectEntity.tenantMixId);
              selectedAreaUnit = areaUnitL.isNotEmpty ? areaUnitL.first : null;
              selectedTenantMix = tenantL.isNotEmpty ? tenantL.first : null;
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
                        children: [
                          CustomTextField(controller: reraNoC, labelText: "Rera No."),
                          CustomTextField(controller: cinNoC, labelText: "Cin No."),
                          CustomTextField(
                            controller: openParkingC,
                            labelText: "Open Parking",
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            textInputAction: TextInputAction.next,
                          ),
                          CustomTextField(
                            controller: stackedParkingC,
                            labelText: "Stacked Parking",
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            textInputAction: TextInputAction.next,
                          ),
                          CustomTextField(
                            controller: stiltParkingC,
                            labelText: "Stilt Parking",
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            textInputAction: TextInputAction.next,
                          ),
                          CustomTextField(
                            controller: basementParkingC,
                            labelText: "Basement Parking",
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            textInputAction: TextInputAction.next,
                          ),
                          CustomTextField(
                            controller: podiumParkingC,
                            labelText: "Podium Parking",
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            textInputAction: TextInputAction.next,
                          ),
                          CustomTextField(
                            controller: parkingRatioC,
                            labelText: "Parking Ratio Sqft/Car",
                            keyboardType: TextInputType.number,
                            inputFormatters: [decimalFormatter],
                            textInputAction: TextInputAction.next,
                          ),
                          CustomTextField(
                            controller: scrC,
                            labelText: "SCR",
                            maxLength: 2,
                            counterText: "",
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            textInputAction: TextInputAction.next,
                          ),
                          CustomTextField(
                            controller: maintenanceC,
                            labelText: "Maintenance Rs/Sqft",
                            keyboardType: TextInputType.number,
                            inputFormatters: [decimalFormatter],
                            textInputAction: TextInputAction.next,
                          ),
                          CustomTextField(
                            controller: propertyTaxC,
                            labelText: "Property Tax",
                            minLines: 1,
                            maxLines: 5,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            textInputAction: TextInputAction.next,
                          ),
                          BlocBuilder<CProjectEditCubit, CProjectEditState>(
                            buildWhen: (previous, current) => current is LocalDbState || current is ErrorState,
                            builder: (context, state) {
                              return Column(
                                spacing: 12.0,
                                children: [
                                  CustomDropdown(
                                    initialValue: selectedAreaUnit,
                                    lableText: "Area Unit",
                                    hintText: "Select Area Unit",
                                    items: areaUnit,
                                    labelKey: "areaUnitName",
                                    onChanged: (value) {
                                      selectedAreaUnit = value;
                                    },
                                  ),
                                  CustomTextField(
                                    controller: landParcelSizeC,
                                    labelText: "Land Parcel Size",
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [decimalFormatter],
                                  ),
                                  CustomDropdown(
                                    initialValue: selectedTenantMix,
                                    lableText: "Tenant Mix",
                                    hintText: "Select Tenant",
                                    items: tenantMix,
                                    labelKey: "tenantMix",
                                    onChanged: (value) {
                                      selectedTenantMix = value;
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                          SizedBox(height: 30),
                          BlocBuilder<CProjectEditCubit, CProjectEditState>(
                            builder: (context, state) {
                              return SizedBox(
                                width: double.infinity,
                                child: CustomElevatedButton(
                                  isLoading: state is LoadingState,
                                  backgroundColor: AppColors.red,
                                  text: "Save",
                                  onPressed: () {
                                    projectEditCubit.updateProject(
                                      projectData: widget.projectEntity,
                                      reraNo: reraNoC.text,
                                      openParking: openParkingC.text,
                                      stackedParking: stackedParkingC.text,
                                      stiltParking: stiltParkingC.text,
                                      basementParking: basementParkingC.text,
                                      podiumParking: podiumParkingC.text,
                                      parkingRatio: parkingRatioC.text,
                                      scr: scrC.text,
                                      maintenance: maintenanceC.text,
                                      propertyTax: propertyTaxC.text,
                                      selectedAreaUnitId: selectedAreaUnit?["areaUnitId"],
                                      landParcelSize: landParcelSizeC.text,
                                      tenantId: selectedTenantMix?['tenantMixId'],
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      if (widget.projectEntity.syncLocalStatus == 1)
                        Positioned.fill(
                          child: Container(
                            color: Colors.white54, // white shade overlay
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
