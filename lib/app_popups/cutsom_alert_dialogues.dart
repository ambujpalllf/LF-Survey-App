import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_text_style.dart';
import 'package:lf_survey/constants/snackbar_helper.dart';
import 'package:lf_survey/cubit/residential/project/project_cubit.dart';
import 'package:lf_survey/cubit/residential/project/project_state.dart' as projectstate;
import 'package:lf_survey/cubit/residential/project_edit/project_edit_cubit.dart';
import 'package:lf_survey/cubit/residential/project_edit/project_edit_state.dart';
import 'package:lf_survey/cubit/residential/sub_project/sprj_flat_details/s_prj_flat_details_cubit.dart';
import 'package:lf_survey/cubit/residential/sub_project/sprj_flat_details/s_prj_flat_details_state.dart';
import 'package:lf_survey/model/db_model/residential/flat_entity.dart';
import 'package:lf_survey/model/db_model/residential/project_entity.dart';
import 'package:lf_survey/model/db_model/residential/sub_prj_entity.dart';
import 'package:lf_survey/model/residential/project_response.dart';
import 'package:lf_survey/model/residential/project_spinner.dart';
import 'package:lf_survey/widgets/custom_dropdown.dart';
import 'package:lf_survey/widgets/custom_elevated_btn.dart';
import 'package:lf_survey/widgets/custom_multi_dropdown.dart';
import 'package:lf_survey/widgets/custom_textfield.dart';
import 'package:lf_survey/widgets/custom_textform_field.dart';
import 'package:permission_handler/permission_handler.dart';

enum SizeType { saleable, carpet }

class CutsomAlertDialogues {
  static void customDialog({
    required BuildContext context,
    String? title,
    List<Widget>? actionsWidget,
    required String message,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(),
        actionsPadding: EdgeInsets.zero,
        title: Text(title ?? "Warning", style: AppTextStyle.ts18MB),
        content: Text(message, style: AppTextStyle.ts14RB),
        actions:
            actionsWidget ??
            [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK', style: AppTextStyle.ts16MB),
              ),
            ],
      ),
    );
  }

  static void showPermissionSettingsDialog(BuildContext context, {required String permissionName}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: Text(
          '$permissionName permission is permanently denied. '
          'Please enable it in app settings.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.of(context).pop();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  static void deleteDialogue({required BuildContext context, String title = "", required VoidCallback onDelete}) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(8.0)),
          title: Text("Delete", style: AppTextStyle.ts16BB),
          content: Text("Are you sure want to delete $title ?", style: AppTextStyle.ts14RB),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel", style: AppTextStyle.ts14BB),
            ),
            TextButton(
              onPressed: onDelete,
              child: Text("Delete", style: AppTextStyle.ts14BB.copyWith(color: AppColors.red)),
            ),
          ],
        );
      },
    );
  }

  static void subProjectDetailsComfirmDialogue({
    required BuildContext context,
    String title = "",
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(8.0)),
          title: Text("Confirm", style: AppTextStyle.ts16BB),
          content: Text("Are you sure want to save selected value ?", style: AppTextStyle.ts14RB),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel", style: AppTextStyle.ts14BB.copyWith(color: AppColors.red)),
            ),
            TextButton(
              onPressed: onConfirm,
              child: Text("OK", style: AppTextStyle.ts14BB.copyWith(color: AppColors.primaryDarkColor)),
            ),
          ],
        );
      },
    );
  }

  static void projectEditCostDialogue({
    required String propertyType,
    required BuildContext context,
    required ProjectCosting prjCostData,
    required ProjectEntity projectData,
    String title = "",
    String singleDropLableText = "",
    String singleDropHintText = "",
    String multiDropLableText = "",
    String multiDropHintText = "",
    required TextEditingController saleableSizeC,
    required TextEditingController carpetSizeC,
    required TextEditingController referenceSizeC,

    required List<Map<String, dynamic>> singleDropDownList,
    Map<String, dynamic>? singleSelectdropDownValue,
    required List<Map<String, dynamic>> multiDropDownList,
    List? multiSelectdropDownValue,
  }) {
    bool isSaleable = propertyType.toLowerCase() == "saleable";
    debugPrint("Is saleable ${prjCostData.toJson()}");
    String saleErMsg = "";
    String carpetErMsg = "";
    String flatTypeErMsg = "";
    if (title == "Base Cost") {
      saleableSizeC.text = prjCostData.baseCostSaleableSize.toString();
      carpetSizeC.text = prjCostData.baseCostCarpetSize.toString();
      referenceSizeC.text = prjCostData.baseCostReferenceUnitNumber.toString();
    } else if (title == "Agreement Cost") {
      saleableSizeC.text = prjCostData.agreementCostSaleableSize.toString();
      carpetSizeC.text = prjCostData.agreementCostCarpetSize.toString();
      referenceSizeC.text = prjCostData.agreementCostReferenceUnitNumber.toString();
    } else if (title == "All Inclusive Cost") {
      saleableSizeC.text = prjCostData.allInclusiveCostSaleableSize.toString();
      carpetSizeC.text = prjCostData.allInclusiveCostCarpetSize.toString();
      referenceSizeC.text = prjCostData.allInclusiveCostReferenceUnitNumber.toString();
    }
    final projectEditCubit = context.read<ProjectEditCubit>();
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(8.0)),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Parameter For $title", style: AppTextStyle.ts16BB),
              Divider(color: AppColors.greyLite),
            ],
          ),
          content: BlocConsumer<ProjectEditCubit, ProjectEditState>(
            listener: (context, state) {
              if (state is EditDialogueState) {
                saleErMsg = state.saleError;
                flatTypeErMsg = state.flatTypeError;
                carpetErMsg = state.carpetError;

                if (flatTypeErMsg.isNotEmpty) {
                  CustomSnackHelper.customToastMsg(
                    context: context,
                    message: flatTypeErMsg,
                    bgColor: Colors.white,
                    textColor: Colors.black,
                    toastGravity: ToastGravity.CENTER,
                  );
                }
              }
            },
            builder: (context, state) {
              return SingleChildScrollView(
                child: Column(
                  // spacing: 12.0,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField(
                      controller: saleableSizeC,
                      keyboardType: TextInputType.number,
                      labelText: "Saleable Size (Sqft)",
                      readOnly: isSaleable ? false : true,
                      filled: isSaleable ? false : true,
                      fillColor: isSaleable == false ? Colors.grey.shade200 : null,
                      borderColor: isSaleable == false ? Colors.grey.shade200 : null,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      suffixIcon: saleErMsg.isEmpty ? null : Icon(Icons.error, color: AppColors.red),
                      onChanged: (value) {
                        if (value.isEmpty) return;
                        projectEditCubit.editDialogueValidation(
                          saleable: saleableSizeC.text,
                          carpet: carpetSizeC.text,
                          flatType: singleSelectdropDownValue,
                          isSaleable: isSaleable,
                        );
                      },
                    ),
                    saleErMsg.isEmpty ? Container() : CustomSnackHelper.errorWidget(messgage: saleErMsg),
                    SizedBox(height: 12.0),
                    CustomTextField(
                      controller: carpetSizeC,
                      readOnly: isSaleable ? true : false,
                      filled: isSaleable ? true : false,
                      fillColor: isSaleable ? Colors.grey.shade200 : null,
                      borderColor: isSaleable ? Colors.grey.shade200 : null,
                      keyboardType: TextInputType.number,
                      labelText: "Carpet Size (Sqft)",
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      suffixIcon: carpetErMsg.isEmpty ? null : Icon(Icons.error, color: AppColors.red),
                    ),
                    carpetErMsg.isEmpty ? Container() : CustomSnackHelper.errorWidget(messgage: carpetErMsg),
                    SizedBox(height: 12.0),
                    CustomTextField(
                      controller: referenceSizeC,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      labelText: "Reference Unit Number ",
                    ),
                    SizedBox(height: 12.0),
                    CustomDropdown(
                      // initialValue: singleSelectdropDownValue ?? singleDropDownList.first,
                      initialValue: singleSelectdropDownValue,
                      items: singleDropDownList,
                      labelKey: "title",
                      hintText: singleDropHintText,
                      lableText: singleDropLableText,
                      onChanged: (value) {
                        singleSelectdropDownValue = value;
                      },
                    ),
                    SizedBox(height: 12.0),
                    CustomMultiSelectDropdown(
                      initialValues: multiSelectdropDownValue,
                      items: multiDropDownList,
                      labelKey: "title",
                      hintText: multiDropHintText,
                      labelText: multiDropLableText,
                      onChanged: (value) {
                        multiSelectdropDownValue = value;
                        debugPrint('Selected multi values: $multiSelectdropDownValue');
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                saleableSizeC.clear();
                carpetSizeC.clear();
                referenceSizeC.clear();
                singleSelectdropDownValue = null;
                Navigator.pop(context);
              },
              child: Text("Cancel", style: AppTextStyle.ts14BB.copyWith(color: AppColors.red)),
            ),
            TextButton(
              onPressed: () {
                String costIncluded = "";
                if (multiSelectdropDownValue != null) {
                  costIncluded = multiSelectdropDownValue!.map((e) => e["title"]).join(",");
                }
                projectEditCubit.updateProjectCosting(
                  context: context,
                  projectData: projectData,
                  isSaleable: isSaleable,
                  projectCostData: prjCostData,
                  saleableSize: saleableSizeC.text,
                  carpetSize: carpetSizeC.text,
                  referenceSize: referenceSizeC.text,
                  flatType: singleSelectdropDownValue,
                  costIncluded: costIncluded,
                  title: title,
                );
              },
              child: Text("OK", style: AppTextStyle.ts14BB.copyWith(color: AppColors.primaryColor)),
            ),
          ],
        );
      },
    );
  }

  static void bookingStopDialogue({required BuildContext context, required VoidCallback accept}) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(8.0)),
          title: Text("Booking Stopped", style: AppTextStyle.ts16BB),
          content: Text(
            "Booking is currently stopped, so flat details cannot be edited.\n\n"
            "Would you like to reopen bookings?",
            style: AppTextStyle.ts14RB,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("NO", style: AppTextStyle.ts14BB),
            ),
            TextButton(
              onPressed: accept,
              child: Text("YES", style: AppTextStyle.ts14BB.copyWith(color: AppColors.red)),
            ),
          ],
        );
      },
    );
  }

  static void subprojectFlatDetailsDialgoue({
    required BuildContext context,
    // required SubProjectsDatum subProjectsDatum,
    required SubProjectEntity subProjectsDatum,
    // required FlatsData flatData,
    required FlatEntity flatData,
    required FlatTypeList flatTypeData,
    required int totalFlats,
    required String flatCount,
    required String rateType,
    required TextEditingController scrC,
    required TextEditingController totalFlatsC,
    required TextEditingController flatSoldC,
    required TextEditingController flatUnSoldC,
    required TextEditingController saleableSizeC,
    required TextEditingController carpetFlatSizeC,
  }) {
    final flatDatilsCubit = context.read<SPrjFlatDetailsCubit>();
    totalFlatsC.text = "$totalFlats";

    showDialog(
      context: context,
      builder: (_) {
        SizeType selectedType = rateType.toLowerCase() == "saleable" ? SizeType.saleable : SizeType.carpet;
        bool isSaleable = rateType.toLowerCase() == "saleable" ? true : false;
        String scrMsg = "";
        String flatSoldMsg = "";
        String saleableSizeMsg = "";
        String carpetFlatMsg = "";

        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
          titlePadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),

          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(flatCount, style: AppTextStyle.ts16MB),
              ),
              Divider(color: AppColors.greyLite),
            ],
          ),

          content: BlocConsumer<SPrjFlatDetailsCubit, SPrjFlatDetailsState>(
            buildWhen: (previous, current) => current is ValidationState || current is FlatUnsoldCount,
            listener: (context, state) {
              if (state is ValidationState) {
                scrMsg = state.scrMsg;
                flatSoldMsg = state.flatSoldMsg;
                saleableSizeMsg = state.slaeableSizeMsg;
                carpetFlatMsg = state.carpetFlatSizeMsg;
              } else if (state is SuccessState) {
                scrC.clear();
                flatSoldC.clear();
                flatUnSoldC.clear();
                saleableSizeC.clear();
                carpetFlatSizeC.clear();
              } else if (state is FlatUnsoldCount) {
                flatUnSoldC.text = state.unsoldFlat;
              }
            },
            builder: (context, state) {
              return SingleChildScrollView(
                child: Column(
                  // spacing: 12.0,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField(
                      labelText: "SCR",
                      controller: scrC,
                      keyboardType: TextInputType.number,
                      suffixIcon: scrMsg.isEmpty ? null : Icon(Icons.error, color: AppColors.red),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                      onChanged: (value) {
                        if (value.isEmpty) return;
                        flatDatilsCubit.fieldsValidation(
                          totalFlats: totalFlats,
                          flatTypeData: flatTypeData,
                          scr: value,
                          flatSold: flatSoldC.text,
                          saleableSize: saleableSizeC.text,
                          carpetFlatSize: carpetFlatSizeC.text,
                          isSaleble: isSaleable,
                        );
                      },
                    ),
                    scrMsg.isEmpty ? SizedBox.shrink() : CustomSnackHelper.errorWidget(messgage: scrMsg),
                    CustomTextField(
                      readOnly: true,
                      controller: totalFlatsC,
                      labelText: "Total Flats",
                      style: TextStyle(color: Colors.grey.shade400),
                      lableTextColor: Colors.grey.shade400,
                      hintTextColor: Colors.grey.shade400,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                    ),
                    CustomTextField(
                      labelText: "Flat Sold",
                      controller: flatSoldC,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                      suffixIcon: flatSoldMsg.isEmpty ? null : Icon(Icons.error, color: AppColors.red),
                      onChanged: (value) {
                        if (value.isEmpty) return;
                        flatDatilsCubit.fieldsValidation(
                          totalFlats: totalFlats,
                          flatTypeData: flatTypeData,
                          scr: scrC.text,
                          flatSold: value,
                          saleableSize: saleableSizeC.text,
                          carpetFlatSize: carpetFlatSizeC.text,
                          isSaleble: isSaleable,
                        );
                        flatUnSoldC.text = "${totalFlats - int.parse(value)}";
                        flatDatilsCubit.calculateFlatUnsold(flatUnsold: flatUnSoldC.text);
                      },
                    ),
                    flatSoldMsg.isEmpty ? SizedBox.shrink() : CustomSnackHelper.errorWidget(messgage: flatSoldMsg),
                    CustomTextField(
                      readOnly: true,
                      style: TextStyle(color: Colors.grey.shade400),
                      lableTextColor: Colors.grey.shade400,
                      hintTextColor: Colors.grey.shade400,
                      labelText: "Flat Unsold",
                      controller: flatUnSoldC,
                      keyboardType: TextInputType.number,
                    ),

                    RadioGroup<SizeType>(
                      groupValue: selectedType,
                      onChanged: (vallue) {}, // disabled
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: RadioListTile<SizeType>(
                              enabled: false,
                              value: SizeType.saleable,
                              title: Text("Saleable", style: AppTextStyle.ts14RB.copyWith(color: Colors.grey.shade400)),
                              visualDensity: VisualDensity.compact,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          Flexible(
                            child: RadioListTile<SizeType>(
                              enabled: false,
                              value: SizeType.carpet,
                              title: Text("Carpet", style: AppTextStyle.ts14RB.copyWith(color: Colors.grey.shade400)),
                              visualDensity: VisualDensity.compact,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ),

                    CustomTextField(
                      readOnly: rateType.toLowerCase() == "saleable" ? false : true,
                      style: TextStyle(
                        color: rateType.toLowerCase() == "saleable" ? Colors.black : Colors.grey.shade400,
                      ),
                      lableTextColor: rateType.toLowerCase() == "saleable" ? Colors.black : Colors.grey.shade400,
                      hintTextColor: rateType.toLowerCase() == "saleable" ? Colors.black : Colors.grey.shade400,
                      labelText: "Saleable Size",
                      controller: saleableSizeC,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,]'))],
                      suffixIcon: saleableSizeMsg.isEmpty ? null : Icon(Icons.error, color: AppColors.red),
                      onChanged: (value) {
                        if (value.isEmpty) return;
                        flatDatilsCubit.fieldsValidation(
                          totalFlats: totalFlats,
                          flatTypeData: flatTypeData,
                          scr: scrC.text,
                          flatSold: flatSoldC.text,
                          saleableSize: value,
                          carpetFlatSize: carpetFlatSizeC.text,
                          isSaleble: isSaleable,
                        );
                      },
                    ),
                    saleableSizeMsg.isEmpty
                        ? SizedBox.shrink()
                        : CustomSnackHelper.errorWidget(messgage: saleableSizeMsg),
                    CustomTextField(
                      readOnly: rateType.toLowerCase() == "saleable" ? true : false,
                      style: TextStyle(
                        color: rateType.toLowerCase() != "saleable" ? Colors.black : Colors.grey.shade400,
                      ),
                      lableTextColor: rateType.toLowerCase() != "saleable" ? Colors.black : Colors.grey.shade400,
                      hintTextColor: rateType.toLowerCase() != "saleable" ? Colors.black : Colors.grey.shade400,
                      labelText: "Carpet Flat Size",
                      controller: carpetFlatSizeC,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,]'))],
                      suffixIcon: carpetFlatMsg.isEmpty ? null : Icon(Icons.error, color: AppColors.red),
                      onChanged: (value) {
                        if (value.isEmpty) return;
                        flatDatilsCubit.fieldsValidation(
                          totalFlats: totalFlats,
                          flatTypeData: flatTypeData,
                          scr: scrC.text,
                          flatSold: flatSoldC.text,
                          saleableSize: saleableSizeC.text,
                          carpetFlatSize: value,
                          isSaleble: isSaleable,
                        );
                      },
                    ),
                    carpetFlatMsg.isEmpty ? SizedBox.shrink() : CustomSnackHelper.errorWidget(messgage: carpetFlatMsg),
                  ],
                ),
              );
            },
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: AppTextStyle.ts14MB.copyWith(color: AppColors.red)),
            ),
            TextButton(
              onPressed: () {
                final result = flatDatilsCubit.fieldsValidation(
                  scr: scrC.text,
                  flatSold: flatSoldC.text,
                  totalFlats: totalFlats,
                  carpetFlatSize: carpetFlatSizeC.text,
                  flatTypeData: flatTypeData,
                  isSaleble: isSaleable,
                  saleableSize: saleableSizeC.text,
                );
                if (result == true) {
                  flatDatilsCubit.updateFlatDetails(
                    context: context,
                    subProjectsDatum: subProjectsDatum,
                    flatData: flatData,
                    flatSold: flatSoldC.text,
                    totalFlats: totalFlats,
                    scr: scrC.text,
                    carpetFlatSize: carpetFlatSizeC.text,
                    saleableSize: saleableSizeC.text,
                    isSaleable: isSaleable,
                  );
                }
              },
              child: Text("SAVE", style: AppTextStyle.ts14MB.copyWith(color: AppColors.green)),
            ),
          ],
        );
      },
    );
  }

  static Future<String?> addCommentDialogue({required BuildContext context}) async {
    TextEditingController commentC = TextEditingController();

    return await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text("Add Comment"),
          content: Column(
            mainAxisSize: MainAxisSize.min, // IMPORTANT
            children: [
              CustomTextField(controller: commentC, labelText: "Comment"),
              SizedBox(height: 20),
              CustomElevatedButton(
                text: "Add",
                onPressed: () {
                  Navigator.pop(dialogContext, commentC.text); // Return comment
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<String?> projectFixDialogue({required BuildContext context}) async {
    final TextEditingController remarkC = TextEditingController();
    String errorText = "";
    final result = await showDialog<String>(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.white,
              shape: RoundedRectangleBorder(),
              title: const Text("Fix Project"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextformField(
                    controller: remarkC,
                    labelText: "Remark",
                    minLines: 1,
                    maxHintLines: 2000,
                    errorText: errorText.isEmpty ? null : errorText,
                    onChanged: (value) {
                      setState(() {
                        errorText = "";
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomElevatedButton(
                    borderRadius: 1.0,
                    text: "Submit",
                    onPressed: () {
                      if (remarkC.text.isEmpty) {
                        setState(() {
                          errorText = "This feild is required";
                        });
                      } else {
                        Navigator.pop(context, remarkC.text);
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    return result;
  }

  static Future<String?> mapTypeDialogue({required BuildContext context, required String selectedType}) {
    List<String> mapTypes = ["Normal", "Satellite", "Terrain", "Hybrid"];

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Select Map Type", style: AppTextStyle.ts16BB),
                    const SizedBox(height: 10),
                    Column(
                      children: mapTypes.map((type) {
                        return RadioListTile<String>(
                          title: Text(type),
                          value: type,
                          // ignore: deprecated_member_use
                          groupValue: selectedType,
                          // ignore: deprecated_member_use
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedType = value;
                              });
                              Navigator.pop(context, selectedType);
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static void finalSubmitPrjDialogue({
    required BuildContext context,
    String title = "",
    required VoidCallback confirm,
  }) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(8.0)),
          title: Text("Final Submit Project", style: AppTextStyle.ts16BB),
          content: Text(
            "Are you sure you want to submit the $title?\n"
            "Once submitted, you will not be able to add, update $title or upload photos for this project.\n\n"
            "If your survey data or images are not synced, please sync them first and then proceed with the final submission.",
            style: AppTextStyle.ts14RB,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel", style: AppTextStyle.ts14BB),
            ),
            TextButton(
              onPressed: confirm,
              child: Text("Submit", style: AppTextStyle.ts14BB.copyWith(color: AppColors.red)),
            ),
          ],
        );
      },
    );
  }

  static void finalSubmitWingDialogue({
    required BuildContext context,
    String title = "",
    required VoidCallback confirm,
  }) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(8.0)),
          title: Text("Final Submit Sub-Project", style: AppTextStyle.ts16BB),
          content: Text(
            // "Are you sure you want to submit the $title?\nOnce submitted, you will not be able to add, update $title or upload photos for this wing.",
            "Are you sure you want to submit the $title?\n"
            "Once submitted, you will not be able to add or update $title or upload photos for this wing.\n\n"
            "If your survey data or images are not synced, please sync them first and then proceed with the final submission.",
            style: AppTextStyle.ts14RB,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel", style: AppTextStyle.ts14BB),
            ),
            TextButton(
              onPressed: confirm,
              child: Text("Submit", style: AppTextStyle.ts14BB.copyWith(color: AppColors.red)),
            ),
          ],
        );
      },
    );
  }

  static void clearDBDialogue({required BuildContext context, String title = "", required VoidCallback confirm}) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(8.0)),
          title: Text("Clear Local Data", style: AppTextStyle.ts16BB),
          content: Text(
            // "Are you sure you want to clear all locally stored data ? "
            // "This action will permanently remove all saved project data and photos from this device.",
            "Are you sure you want to clear all locally stored data?\n"
            "This action will permanently remove all saved project data and photos from this device.\n"
            "If your data has not been synced, please sync it before clearing to avoid permanent data loss.",
            style: AppTextStyle.ts14RB,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel", style: AppTextStyle.ts14BB),
            ),
            TextButton(
              onPressed: confirm,
              child: Text("Clear DB", style: AppTextStyle.ts14BB.copyWith(color: AppColors.red)),
            ),
          ],
        );
      },
    );
  }

  static void syncCountDialogue({required BuildContext context, required int surveyCount, required int imageCount}) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(8.0)),
          title: Text("Pending Data Sync", style: AppTextStyle.ts16BB),
          content: Text(
            "Unsync Survey Count :  $surveyCount\n"
            "Unsync Images Count : $imageCount\n\n"
            "Your survey data or images are not synced, please sync them first and then proceed with the final submission.",
            style: AppTextStyle.ts14RB,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("OK", style: AppTextStyle.ts14BB),
            ),
          ],
        );
      },
    );
  }

  static void dataAlertDialogue({required BuildContext context}) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          title: Text("Incomplete Submission", style: AppTextStyle.ts16BB),
          content: Text(
            "To proceed with the final submission, please ensure the following:\n\n"
            "• At least one image is uploaded.\n"
            "• All required survey details are filled.\n"
            "• Your survey data and images are fully synced.\n\n"
            "Kindly complete and sync the required information before submitting.",
            style: AppTextStyle.ts14RB,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("OK", style: AppTextStyle.ts14BB),
            ),
          ],
        );
      },
    );
  }

  static void syncCMCountDialogue({required BuildContext context, required int surveyCount}) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          title: Text("Pending Data Sync", style: AppTextStyle.ts16BB),
          content: Text(
            "There ${surveyCount == 1 ? "is" : "are"} $surveyCount "
            "unsynced wing survey${surveyCount == 1 ? "" : "s"}.\n\n"
            "Please sync all pending survey data before proceeding with the final submission.",
            style: AppTextStyle.ts14RB,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("OK", style: AppTextStyle.ts14BB),
            ),
          ],
        );
      },
    );
  }

  static void rejectDetailsDialogue({required BuildContext context}) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          titlePadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(2.0)),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.95,
            minWidth: MediaQuery.sizeOf(context).width * 0.9,
            maxHeight: MediaQuery.sizeOf(context).height * 0.4,
          ),
          title: Column(
            spacing: 8.0,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 5.0),
              Text("Reject Details", style: AppTextStyle.ts16MB),
              Divider(color: Colors.grey.shade500),
              SizedBox(height: 5.0),
            ],
          ),
          content: BlocBuilder<ProjectCubit, projectstate.ProjectState>(
            builder: (context, state) {
              if (state is projectstate.RejectLoadingState) {
                return SizedBox(
                  height: 120,
                  child: Center(child: CircularProgressIndicator(color: AppColors.red)),
                );
              }
              if (state is projectstate.ErrorState) {
                return SizedBox(
                  height: 120,
                  child: Center(child: Text(state.message, style: AppTextStyle.ts14RB)),
                );
              }
              if (state is projectstate.RejectState) {
                final rejectData = state.rejectData;
                if (rejectData.isEmpty) {
                  return SizedBox(
                    height: 120,
                    child: Center(child: Text("No Data Found", style: AppTextStyle.ts14RB)),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: rejectData.length,
                  itemBuilder: (_, index) {
                    final data = rejectData[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SizedBox(width: 130, child: Text("Reject By", style: AppTextStyle.ts14MB)),
                            Text(": "),
                            Expanded(child: Text(data.rejectByName ?? "", style: AppTextStyle.ts14RB)),
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(width: 130, child: Text("Reject Reason", style: AppTextStyle.ts14MB)),
                            Text(": "),
                            Expanded(child: Text(data.rejectReason ?? "", style: AppTextStyle.ts14RB)),
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(width: 130, child: Text("Fixed By", style: AppTextStyle.ts14MB)),
                            Text(": "),
                            Expanded(child: Text(data.fixedByName ?? "", style: AppTextStyle.ts14RB)),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 130, child: Text("Fixed Remark", style: AppTextStyle.ts14MB)),
                            Text(": "),
                            Expanded(child: Text(data.fixedRemarks ?? "", style: AppTextStyle.ts14RB)),
                          ],
                        ),
                        Divider(color: Colors.grey.shade400),
                      ],
                    );
                  },
                );
              }

              return SizedBox();
            },
          ),
        );
      },
    );
  }

  static void showImageDialogue({
    required BuildContext context,
    required File imageFile,
    required VoidCallback confirm,
  }) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          title: Text("Selected Image", style: AppTextStyle.ts16MB),
          content: Image.file(imageFile, height: 200, width: 200, fit: BoxFit.fill),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("CANCEL", style: AppTextStyle.ts14BB.copyWith(color: AppColors.red)),
            ),
            TextButton(
              onPressed: confirm,
              child: Text("OK", style: AppTextStyle.ts14BB.copyWith(color: AppColors.red)),
            ),
          ],
        );
      },
    );
  }

  static void addBuildingDialogue({
    required BuildContext context,
    required TextEditingController buildingC,
    required String title,
    required VoidCallback addBuilding,
  }) {
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Add $title", style: AppTextStyle.ts16MB),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  buildingC.clear();
                },
                child: Container(
                  padding: EdgeInsets.all(2.0),
                  decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(100)),
                  child: Icon(Icons.close, size: 20, color: AppColors.white),
                ),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              spacing: 25,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextformField(
                  filled: true,
                  fillColor: Colors.blueGrey.shade50,
                  controller: buildingC,
                  labelText: "$title Name",
                  hintText: "Enter $title Name",
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '$title name is required';
                    }
                    return null;
                  },
                ),
                CustomElevatedButton(
                  backgroundColor: AppColors.red,
                  text: "Add $title",
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      addBuilding();
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
