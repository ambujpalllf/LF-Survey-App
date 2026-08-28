import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_dimens.dart';
import 'package:lf_survey/constants/app_text_style.dart';
import 'package:lf_survey/constants/snackbar_helper.dart';
import 'package:lf_survey/constants/utils.dart';
import 'package:lf_survey/cubit/commercial/c_prj_image/c_prj_img_cubit.dart';
import 'package:lf_survey/cubit/pams_survey/ps_photo/ps_photo_cubit.dart';
import 'package:lf_survey/cubit/pams_survey/ps_photo/ps_photo_state.dart';
import 'package:lf_survey/cubit/residential/new_project_image/new_prj_img_cubit.dart';
import 'package:lf_survey/cubit/residential/project_image/prj_img_cubit.dart';
import 'package:lf_survey/cubit/residential/sub_project/new_flats/new_flats_cubit.dart';
import 'package:lf_survey/database/db_helper.dart';
import 'package:lf_survey/model/db_model/residential/new_flat_entity.dart';
import 'package:lf_survey/model/db_model/residential/project_entity.dart';
import 'package:lf_survey/model/pams_survey/ps_prj_response.dart';
import 'package:lf_survey/model/residential/project_scheme_entity.dart';
import 'package:lf_survey/model/residential/project_spinner.dart';
import 'package:lf_survey/routes/app_routes_name.dart';
import 'package:lf_survey/widgets/custom_dropdown.dart';
import 'package:lf_survey/widgets/custom_elevated_btn.dart';
import 'package:lf_survey/widgets/custom_textfield.dart';
import 'package:lf_survey/widgets/custom_textform_field.dart';

enum SizeType { saleable, carpet }

class CustomBottomsheet {
  static Future<bool?> selectSchemeBottomsheet({
    required ProjectEntity projectData,
    required BuildContext context,
    required List<SchemesList> schemes,
    required List<ProjectSchemeEntity> selectdSchemes,
  }) async {
    List<ProjectSchemeEntity> tempSelectedSchemes = selectdSchemes.map((e) => e).toList();
    List<ProjectSchemeEntity> unSelectdSchemes = [];
    List<bool> isSelect = List.generate(schemes.length, (i) => false);
    List<TextEditingController> detailsC = List.generate(schemes.length, (i) => TextEditingController());
    // Initialize state
    for (int i = 0; i < schemes.length; i++) {
      final found = tempSelectedSchemes.firstWhere(
        (e) => e.schemeId == schemes[i].schemesId,
        orElse: () => ProjectSchemeEntity(),
      );
      detailsC[i].text = found.openText ?? "";
      isSelect[i] = found.schemeId != null;
    }

    final result = await showModalBottomSheet<bool>(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (_, innerState) {
            return Padding(
              padding: AppDimens.hvPadding,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: (schemes.length / 2).ceil(),
                      itemBuilder: (context, index) {
                        int firstIndex = index * 2;
                        int secondIndex = firstIndex + 1;
                        Widget buildItem(int i) {
                          if (i >= schemes.length) {
                            return const SizedBox();
                          }
                          var item = schemes[i];

                          return Column(
                            children: [
                              CheckboxListTile(
                                visualDensity: VisualDensity.compact,
                                contentPadding: EdgeInsets.zero,
                                controlAffinity: ListTileControlAffinity.leading,
                                checkColor: AppColors.white,
                                activeColor: AppColors.red,
                                value: isSelect[i],
                                onChanged: (value) {
                                  innerState(() {
                                    isSelect[i] = value!;
                                    var scheme = schemes[i];
                                    ProjectSchemeEntity schemeData = ProjectSchemeEntity(
                                      projectId: projectData.projectId,
                                      qtrId: projectData.qtrId,
                                      schemeId: scheme.schemesId,
                                      openText: detailsC[i].text,
                                    );
                                    if (value) {
                                      if (!tempSelectedSchemes.any((e) => e.schemeId == schemeData.schemeId)) {
                                        tempSelectedSchemes.add(schemeData);
                                      }
                                      unSelectdSchemes.removeWhere((e) => e.schemeId == schemeData.schemeId);
                                    } else {
                                      tempSelectedSchemes.removeWhere((e) => e.schemeId == schemeData.schemeId);

                                      if (!unSelectdSchemes.any((e) => e.schemeId == schemeData.schemeId)) {
                                        unSelectdSchemes.add(schemeData);
                                      }
                                    }
                                  });
                                },
                                title: Text(item.schemesType ?? "", style: AppTextStyle.ts14RB),
                              ),

                              if (item.isOpenText == true && isSelect[i])
                                CustomTextField(hintText: "Enter Details", controller: detailsC[i]),
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(child: buildItem(firstIndex)),
                            Expanded(child: buildItem(secondIndex)),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: CustomElevatedButton(
                            text: "CANCEL",
                            onPressed: () {
                              context.pop(false);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomElevatedButton(
                            text: "OK",
                            onPressed: () async {
                              for (int i = 0; i < schemes.length; i++) {
                                if (isSelect[i]) {
                                  var scheme = schemes[i];
                                  ProjectSchemeEntity model = tempSelectedSchemes.firstWhere(
                                    (e) => e.schemeId == scheme.schemesId,
                                    orElse: () => ProjectSchemeEntity(
                                      projectId: projectData.projectId,
                                      qtrId: projectData.qtrId,
                                      schemeId: scheme.schemesId,
                                    ),
                                  );
                                  model.openText = detailsC[i].text.trim();
                                  if (scheme.isOpenText == true && model.openText!.isEmpty) {
                                    CustomSnackHelper.customToastMsg(
                                      context: context,
                                      message: "Please enter details for ${scheme.schemesType}",
                                    );
                                    return;
                                  }
                                  if (!tempSelectedSchemes.contains(model)) {
                                    tempSelectedSchemes.add(model);
                                  }
                                }
                              }
                              selectdSchemes
                                ..clear()
                                ..addAll(tempSelectedSchemes);
                              await DBHelper.insertProjectScheme(selectdSchemes);
                              if (unSelectdSchemes.isNotEmpty) {
                                await DBHelper.deletePrjScheme(unSelectdSchemes);
                              }
                              if (!context.mounted) return;
                              context.pop(true);
                              for (var c in detailsC) {
                                c.dispose();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    return result;
  }

  static void addPrjImgBottomSheet({
    required BuildContext context,
    required int projectId,
    required int subProjectId,
    required String dos,
    required String appBarTitle,
  }) {
    final PrjImgCubit prjImgCubit = context.read<PrjImgCubit>();
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Padding(
          padding: AppDimens.hvPadding,
          child: appBarTitle == "Sub-Project Image"
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      spacing: 12.0,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        addImgWidget(
                          context: context,
                          icon: Icons.image,
                          onPressed: () {
                            prjImgCubit.pickImgGallery(
                              context: context,
                              projectId: projectId,
                              subProjectId: subProjectId,
                              dos: dos,
                              imageTitle: "p",
                            );
                          },
                          title: 'Add Project Picture Gallery',
                        ),
                        addImgWidget(
                          context: context,
                          icon: Icons.camera_alt,
                          onPressed: () {
                            context.pop();
                            prjImgCubit.pickImgCamera(
                              context: context,
                              projectId: projectId,
                              subProjectId: subProjectId,
                              dos: dos,
                              imageTitle: "p",
                            );
                          },
                          title: 'Add Project Picture Camera',
                        ),
                        SizedBox(height: 25.0),
                      ],
                    ),
                  ],
                )
              : Column(
                  spacing: 12.0,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                    //   children: [
                    //     addImgWidget(
                    //       icon: Icons.add_card,
                    //       onPressed: () {
                    //         prjImgCubit.pickImgGallery(
                    //           context: context,
                    //           projectId: projectId,
                    //           subProjectId: subProjectId,
                    //           dos: dos,
                    //           imageTitle: "vc",
                    //         );
                    //       },
                    //       title: 'Add Visiting Card Gallery',
                    //     ),
                    //     addImgWidget(
                    //       icon: Icons.camera_alt,
                    //       onPressed: () {
                    //         context.pop();
                    //         // prjImgCubit.pickImgCamera(context: context, projectData: projectData);
                    //         prjImgCubit.pickImgCamera(
                    //           context: context,
                    //           projectId: projectId,
                    //           subProjectId: subProjectId,
                    //           dos: dos,
                    //           imageTitle: "vc",
                    //         );
                    //       },
                    //       title: 'Add Visiting Card Camera',
                    //     ),
                    //   ],
                    // ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        addImgWidget(
                          context: context,
                          icon: Icons.bar_chart,
                          onPressed: () {
                            prjImgCubit.pickImgGallery(
                              context: context,
                              projectId: projectId,
                              subProjectId: subProjectId,
                              dos: dos,
                              imageTitle: "c",
                            );
                          },
                          // title: 'Add Project Chart Gallery',
                          title: 'Add Price Chart Gallery',
                        ),
                        addImgWidget(
                          context: context,
                          icon: Icons.bar_chart,
                          onPressed: () {
                            context.pop();
                            // prjImgCubit.pickImgCamera(context: context, projectData: projectData);
                            prjImgCubit.pickImgCamera(
                              context: context,
                              projectId: projectId,
                              subProjectId: subProjectId,
                              dos: dos,
                              imageTitle: "c",
                            );
                          },
                          // title: 'Add Project Chart Camera',
                          title: 'Add Price Chart Camera',
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        addImgWidget(
                          context: context,
                          icon: Icons.image,
                          onPressed: () {
                            prjImgCubit.pickImgGallery(
                              context: context,
                              projectId: projectId,
                              subProjectId: subProjectId,
                              dos: dos,
                              imageTitle: "p",
                            );
                          },
                          // title: 'Add Project Picture Gallery',
                          title: 'Add Construction Picture Gallery',
                        ),
                        addImgWidget(
                          context: context,
                          icon: Icons.camera_alt,
                          onPressed: () {
                            context.pop();
                            // prjImgCubit.pickImgCamera(context: context, projectData: projectData);
                            prjImgCubit.pickImgCamera(
                              context: context,
                              projectId: projectId,
                              subProjectId: subProjectId,
                              dos: dos,
                              imageTitle: "p",
                            );
                          },
                          // title: 'Add Project Picture Camera',
                          title: 'Add Construction Picture Camera',
                        ),
                      ],
                    ),
                    SizedBox(height: 25.0),
                  ],
                ),
        );
      },
    );
  }

  static Widget addImgWidget({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onPressed,
    required String title,
  }) {
    return Flexible(
      child: InkWell(
        // onTap: onPressed,
        onTap: () async {
          if (!await Utils.checkLocationAndGpsPermission(context)) return;
          onPressed();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 8.0,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.red, size: 22),
            Text(title, style: AppTextStyle.ts12RB, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  static Future<CityList?> cityBottomSheet({
    required BuildContext context,
    required List<CityList> cities,
    CityList? initialCity,
  }) async {
    return await showModalBottomSheet<CityList>(
      backgroundColor: AppColors.white,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        CityList? selectedCity = initialCity;
        List<CityList> filteredCities = List.from(cities);
        final TextEditingController searchController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setState) {
            void filterCities(String query) {
              setState(() {
                filteredCities = cities
                    .where((city) => city.city!.toLowerCase().contains(query.toLowerCase()))
                    .toList();
              });
            }

            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
                child: Padding(
                  padding: AppDimens.hvPadding,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Select City", style: AppTextStyle.ts18MB),
                      const SizedBox(height: 12),
                      CustomTextformField(
                        controller: searchController,
                        hintText: "Search city",
                        onChanged: filterCities,
                      ),
                      const SizedBox(height: 12),
                      Flexible(
                        child: filteredCities.isEmpty
                            ? const Center(child: Text("No city found"))
                            : RadioGroup<CityList>(
                                groupValue: selectedCity,
                                onChanged: (CityList? value) {
                                  setState(() {
                                    selectedCity = value;
                                  });
                                },
                                child: ListView.builder(
                                  itemCount: filteredCities.length,
                                  itemBuilder: (context, index) {
                                    final city = filteredCities[index];
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        RadioListTile<CityList>(
                                          dense: true,
                                          activeColor: AppColors.red,
                                          title: Text(city.city ?? ""),
                                          value: city,
                                        ),
                                        Divider(color: AppColors.greyLite),
                                      ],
                                    );
                                  },
                                ),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 24.0),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context, selectedCity);
                            },
                            child: Text("OK", style: AppTextStyle.ts16BB.copyWith(color: AppColors.primaryDarkColor)),
                          ),
                        ),
                      ),
                      SizedBox(height: 30.0),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Future<List<Map<String, dynamic>>> amentieBottomSheet({
    required BuildContext context,
    required String title,
    required List<Map<String, dynamic>> dataList,
    required List<Map<String, dynamic>> initialSelectedItems,
  }) async {
    return await showModalBottomSheet<List<Map<String, dynamic>>>(
          backgroundColor: AppColors.white,
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
          builder: (context) {
            // List<Map<String, dynamic>> selectedItems = [];
            List<Map<String, dynamic>> selectedItems = initialSelectedItems
                .map((e) => Map<String, dynamic>.from(e))
                .toList();
            List<Map<String, dynamic>> filteredItems = List.from(dataList);
            final TextEditingController searchController = TextEditingController();

            return StatefulBuilder(
              builder: (context, setState) {
                void filterItems(String query) {
                  setState(() {
                    filteredItems = dataList
                        .where((item) => item["title"].toString().toLowerCase().contains(query.toLowerCase()))
                        .toList();
                  });
                }

                bool isSelected(Map<String, dynamic> item) {
                  return selectedItems.any((e) => e["id"] == item["id"]);
                }

                return Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
                    child: Padding(
                      padding: AppDimens.hvPadding,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(title, style: AppTextStyle.ts18MB),
                          const SizedBox(height: 12),
                          CustomTextformField(controller: searchController, hintText: "Search", onChanged: filterItems),
                          const SizedBox(height: 12),
                          Flexible(
                            child: filteredItems.isEmpty
                                ? const Center(child: Text("No item found"))
                                : ListView.builder(
                                    itemCount: filteredItems.length,
                                    itemBuilder: (context, index) {
                                      final item = filteredItems[index];
                                      final checked = isSelected(item);

                                      return Column(
                                        children: [
                                          CheckboxListTile(
                                            dense: true,
                                            activeColor: AppColors.red,
                                            title: Text(item["title"] ?? ""),
                                            value: checked,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                if (value == true) {
                                                  selectedItems.add(item);
                                                } else {
                                                  selectedItems.removeWhere((e) => e["id"] == item["id"]);
                                                }
                                              });
                                            },
                                          ),
                                          Divider(color: AppColors.greyLite),
                                        ],
                                      );
                                    },
                                  ),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectedItems.clear();
                                    });
                                    Navigator.pop(context, selectedItems);
                                  },
                                  child: Text(
                                    "CLEAR All",
                                    style: AppTextStyle.ts16BB.copyWith(color: AppColors.primaryDarkColor),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    List<Map<String, dynamic>> initItems = initialSelectedItems
                                        .map((e) => Map<String, dynamic>.from(e))
                                        .toList();
                                    Navigator.pop(context, initItems);
                                  },
                                  child: Text(
                                    "CANCEL",
                                    style: AppTextStyle.ts16BB.copyWith(color: AppColors.primaryDarkColor),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context, selectedItems);
                                  },
                                  child: Text(
                                    "OK",
                                    style: AppTextStyle.ts16BB.copyWith(color: AppColors.primaryDarkColor),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ) ??
        [];
  }

  static Future<bool?> addNewFlatBtmSheet({
    required BuildContext context,
    required String subPrjId,
    required List<FlatTypeList> flatsType,
    // FlatTypeList? selectedFlatType,
    Map<String, dynamic>? selectedFlatType,
    required List<NewFlatEntity> flats,
    required String rateType,
    required TextEditingController saleableFaltC,
    required TextEditingController carpetFlatC,
    required TextEditingController flatSoldC,
    required TextEditingController totalFlatC,
    required FocusNode flatSoldFN,
    required FocusNode totalFlatsFN,
    int? selectedflatId,
    bool isUpdate = false,
    String flatId = "",
  }) async {
    NewFlatsCubit newFlatsCubit = context.read<NewFlatsCubit>();
    List<Map<String, dynamic>> flatsList = flatsType
        .map((e) => {"flatId": e.flatId, "flatType": e.flatType, "min_value": e.minValue, "max_value": e.maxValue})
        .toList();
    SizeType selectedRateType = rateType.toLowerCase() == "saleable" ? SizeType.saleable : SizeType.carpet;
    if (selectedflatId != null) {
      selectedFlatType = flatsList.firstWhere((e) => e["flatId"] == selectedflatId, orElse: () => {});
    }
    final result = await showModalBottomSheet(
      isScrollControlled: true,
      isDismissible: false,
      // constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (_, innerState) {
            final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
            return Padding(
              padding: EdgeInsets.only(bottom: keyboardHeight),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Padding(
                  padding: AppDimens.hvPadding,
                  child: SingleChildScrollView(
                    child: Column(
                      spacing: 12.0,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Flat Info", style: AppTextStyle.ts16MB),
                        CustomDropdown(
                          menuMaxHeight: MediaQuery.sizeOf(context).height * 0.4,
                          initialValue: selectedFlatType,
                          items: flatsList,
                          lableText: "Unit Type",
                          labelKey: "flatType",
                          onChanged: (value) {
                            innerState(() {
                              selectedFlatType = value;
                            });
                          },
                        ),
                        RadioGroup<SizeType>(
                          groupValue: selectedRateType,
                          onChanged: (vallue) {}, // disabled
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: RadioListTile<SizeType>(
                                  enabled: false,
                                  value: SizeType.saleable,
                                  title: Text(
                                    "Saleable",
                                    style: AppTextStyle.ts14RB.copyWith(color: Colors.grey.shade400),
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                              Flexible(
                                child: RadioListTile<SizeType>(
                                  enabled: false,
                                  value: SizeType.carpet,
                                  title: Text(
                                    "Carpet",
                                    style: AppTextStyle.ts14RB.copyWith(color: Colors.grey.shade400),
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CustomTextField(
                          readOnly: rateType.toLowerCase() != "saleable",
                          filled: rateType.toLowerCase() != "saleable",
                          fillColor: Colors.grey.shade300,
                          borderColor: Colors.grey.shade300,
                          labelText: "Salebale Flat Size",
                          controller: saleableFaltC,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,]'))],
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(flatSoldFN);
                          },
                        ),
                        CustomTextField(
                          readOnly: rateType.toLowerCase() == "saleable",
                          filled: rateType.toLowerCase() == "saleable",
                          fillColor: Colors.grey.shade300,
                          borderColor: Colors.grey.shade300,
                          labelText: "Carpet Flat Size",
                          controller: carpetFlatC,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,]'))],
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(flatSoldFN);
                          },
                        ),
                        CustomTextField(
                          labelText: "Flat Sold",
                          controller: flatSoldC,
                          maxLength: 4,
                          counterText: "",
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          focusNode: flatSoldFN,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(totalFlatsFN);
                          },
                        ),
                        CustomTextField(
                          labelText: "Total Flats",
                          controller: totalFlatC,
                          maxLength: 4,
                          counterText: "",
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          focusNode: totalFlatsFN,
                        ),
                        SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.8,
                          child: CustomElevatedButton(
                            backgroundColor: AppColors.red,
                            text: "SAVE",
                            onPressed: () async {
                              final result = await newFlatsCubit.saveMethod(
                                flats: flats,
                                selectedFlatType: selectedFlatType,
                                rateType: rateType,
                                salebaleFlat: saleableFaltC.text,
                                carpetFlat: carpetFlatC.text,
                                soldFlats: flatSoldC.text,
                                totalFlats: totalFlatC.text,
                                subPrjId: subPrjId,
                                isUpdate: isUpdate,
                                preFlatId: flatId,
                              );
                              if (result == true) {
                                if (!context.mounted) return;
                                context.pop(true);
                                selectedFlatType = null;
                                saleableFaltC.clear();
                                carpetFlatC.clear();
                                flatSoldC.clear();
                                totalFlatC.clear();
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.8,
                          child: CustomElevatedButton(
                            backgroundColor: AppColors.red,
                            text: "CANCEL",
                            onPressed: () {
                              context.pop();
                              selectedFlatType = null;
                              saleableFaltC.clear();
                              carpetFlatC.clear();
                              flatSoldC.clear();
                              totalFlatC.clear();
                            },
                          ),
                        ),
                        SizedBox(height: 25.0),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
    return result;
  }

  static void addNewProjectImgBottomSheet({
    required BuildContext context,
    required String projectId,
    String? projectType,
  }) {
    final NewPrjImgCubit newPrjImgCubit = context.read<NewPrjImgCubit>();
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Padding(
          padding: AppDimens.hvPadding,
          child: Column(
            spacing: 12.0,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  addImgWidget(
                    context: context,
                    icon: Icons.add_card,
                    onPressed: () {
                      newPrjImgCubit.pickImgGallery(
                        context: context,
                        projectId: projectId,
                        imageTitle: "vc",
                        projectType: projectType,
                      );
                    },
                    title: 'Add VC (Gallery)',
                  ),
                  addImgWidget(
                    context: context,
                    icon: Icons.camera_alt,
                    onPressed: () {
                      context.pop();
                      newPrjImgCubit.pickImgCamera(
                        context: context,
                        projectId: projectId,
                        imageTitle: "vc",
                        projectType: projectType,
                      );
                    },
                    title: 'Add VC (Camera)',
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  addImgWidget(
                    context: context,
                    icon: Icons.bar_chart,
                    onPressed: () {
                      newPrjImgCubit.pickImgGallery(
                        context: context,
                        projectId: projectId,
                        imageTitle: "c",
                        projectType: projectType,
                      );
                    },
                    title: 'Add Chart (Gallery)',
                  ),
                  addImgWidget(
                    context: context,
                    icon: Icons.camera_alt,
                    onPressed: () {
                      context.pop();
                      newPrjImgCubit.pickImgCamera(
                        context: context,
                        projectId: projectId,
                        imageTitle: "c",
                        projectType: projectType,
                      );
                    },
                    title: 'Add Chart (Camera)',
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  addImgWidget(
                    context: context,
                    icon: Icons.image,
                    onPressed: () {
                      newPrjImgCubit.pickImgGallery(
                        context: context,
                        projectId: projectId,
                        imageTitle: "p",
                        projectType: projectType,
                      );
                    },
                    title: 'Add Picture (Gallery)',
                  ),
                  addImgWidget(
                    context: context,
                    icon: Icons.camera_alt,
                    onPressed: () {
                      context.pop();
                      newPrjImgCubit.pickImgCamera(
                        context: context,
                        projectId: projectId,
                        imageTitle: "p",
                        projectType: projectType,
                      );
                    },
                    title: 'Add Picture (Camera)',
                  ),
                ],
              ),
              SizedBox(height: 25.0),
            ],
          ),
        );
      },
    );
  }

  // commercial Module
  static void cAddPrjImgBottomSheet({
    required BuildContext context,
    required int projectId,
    required int subProjectId,
    required String dos,
    required String appBarTitle,
    required CPrjImgCubit cPrjImgCubit,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Padding(
          padding: AppDimens.hvPadding,
          child: appBarTitle == "Sub-Project Image"
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      spacing: 12.0,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        addImgWidget(
                          context: context,
                          icon: Icons.image,
                          onPressed: () {
                            cPrjImgCubit.pickImgGallery(
                              context: context,
                              projectId: projectId,
                              subProjectId: subProjectId,
                              dos: dos,
                              imageTitle: "p",
                            );
                          },
                          title: 'Add Project Picture Gallery',
                        ),
                        addImgWidget(
                          context: context,
                          icon: Icons.camera_alt,
                          onPressed: () {
                            context.pop();
                            cPrjImgCubit.pickImgCamera(
                              context: context,
                              projectId: projectId,
                              subProjectId: subProjectId,
                              dos: dos,
                              imageTitle: "p",
                            );
                          },
                          title: 'Add Project Picture Camera',
                        ),
                        SizedBox(height: 25.0),
                      ],
                    ),
                  ],
                )
              : Column(
                  spacing: 12.0,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        addImgWidget(
                          context: context,
                          icon: Icons.add_card,
                          onPressed: () {
                            cPrjImgCubit.pickImgGallery(
                              context: context,
                              projectId: projectId,
                              subProjectId: subProjectId,
                              dos: dos,
                              imageTitle: "vc",
                            );
                          },
                          title: 'Add Visiting Card Gallery',
                        ),
                        addImgWidget(
                          context: context,
                          icon: Icons.camera_alt,
                          onPressed: () {
                            context.pop();
                            cPrjImgCubit.pickImgCamera(
                              context: context,
                              projectId: projectId,
                              subProjectId: subProjectId,
                              dos: dos,
                              imageTitle: "vc",
                            );
                          },
                          title: 'Add Visiting Card Camera',
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        addImgWidget(
                          context: context,
                          icon: Icons.bar_chart,
                          onPressed: () {
                            cPrjImgCubit.pickImgGallery(
                              context: context,
                              projectId: projectId,
                              subProjectId: subProjectId,
                              dos: dos,
                              imageTitle: "c",
                            );
                          },
                          title: 'Add Project Chart Gallery',
                        ),
                        addImgWidget(
                          context: context,
                          icon: Icons.camera_alt,
                          onPressed: () {
                            context.pop();
                            cPrjImgCubit.pickImgCamera(
                              context: context,
                              projectId: projectId,
                              subProjectId: subProjectId,
                              dos: dos,
                              imageTitle: "c",
                            );
                          },
                          title: 'Add Project Chart Camera',
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        addImgWidget(
                          context: context,
                          icon: Icons.image,
                          onPressed: () {
                            cPrjImgCubit.pickImgGallery(
                              context: context,
                              projectId: projectId,
                              subProjectId: subProjectId,
                              dos: dos,
                              imageTitle: "p",
                            );
                          },
                          title: 'Add Project Picture Gallery',
                        ),
                        addImgWidget(
                          context: context,
                          icon: Icons.camera_alt,
                          onPressed: () {
                            context.pop();
                            cPrjImgCubit.pickImgCamera(
                              context: context,
                              projectId: projectId,
                              subProjectId: subProjectId,
                              dos: dos,
                              imageTitle: "p",
                            );
                          },
                          title: 'Add Project Picture Camera',
                        ),
                      ],
                    ),
                    SizedBox(height: 25.0),
                  ],
                ),
        );
      },
    );
  }

  // Pams Surveyor Module
  static void addInfoSheet({required BuildContext context, required PsPrjDatum prjData}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.only(topLeft: Radius.circular(8.0), topRight: Radius.circular(8.0)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 16.0, vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Add Projects Info", style: AppTextStyle.ts16BB),
              SizedBox(height: 16.0),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text("Add Project Images", style: AppTextStyle.ts14MB),
                onTap: () {
                  context.pop();
                  context.pushNamed(AppRoutesName.psPhotoPage, extra: {"projectData": prjData});
                },
              ),
              ListTile(
                leading: Icon(Icons.description),
                title: Text("Add Project Technical Info", style: AppTextStyle.ts14MB),
                onTap: () {
                  context.pop();
                  context.pushNamed(AppRoutesName.psLandFormPage, extra: {"projectData": prjData});
                  // context.pushNamed(AppRoutesName.psLandsPage, extra: {"projectData": prjData});
                },
              ),
              SizedBox(height: 30.0),
            ],
          ),
        );
      },
    );
  }

  static void addPhotoSheet({
    required BuildContext context,
    required int projectId,
    required List<Map<String, dynamic>> photoCategory,
    required TextEditingController remarkC,
  }) {
    String imageCategory = "";
    String imagePath = "";

    final photoCubit = context.read<PsPhotoCubit>();
    showModalBottomSheet(
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.white,
      context: context,
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                spacing: 15.0,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Photo Details", style: AppTextStyle.ts16BB),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    spacing: 15.0,
                    children: [
                      BlocBuilder<PsPhotoCubit, PsPhotoState>(
                        builder: (context, state) {
                          String erMsg = "";
                          if (state is ValidateState) {
                            erMsg = state.categoryError ?? "";
                          } else {
                            erMsg = "";
                          }
                          return CustomDropdown(
                            items: photoCategory,
                            labelKey: "title",
                            lableText: "Photo Category",
                            hintText: "Select category",
                            errorText: erMsg.isNotEmpty ? erMsg : null,
                            onChanged: (value) {
                              if (value != null) {
                                // innerState(() {
                                imageCategory = value["title"];
                                // });
                                photoCubit.fieldsValidate(imgType: imageCategory, imgPath: imagePath);
                              }
                            },
                          );
                        },
                      ),
                      BlocBuilder<PsPhotoCubit, PsPhotoState>(
                        builder: (context, state) {
                          String? remarksError;
                          if (state is ValidateState) {
                            remarksError = state.remarksError;
                          }

                          return CustomTextformField(
                            labelText: "Remarks",
                            controller: remarkC,
                            minLines: 1,
                            maxLines: 1000,
                            errorText: remarksError?.isNotEmpty == true ? remarksError : null,
                            onChanged: (value) {
                              photoCubit.fieldsValidate(
                                imgType: imageCategory,
                                imgPath: imagePath,
                                remarks: remarkC.text,
                              );
                            },
                          );
                        },
                      ),
                      Text("Pick Image", style: AppTextStyle.ts16BB),
                      BlocBuilder<PsPhotoCubit, PsPhotoState>(
                        builder: (context, state) {
                          String? erMsg;
                          if (state is ValidateState) {
                            imagePath = state.imagePath;
                            erMsg = state.imageError ?? "";
                          }
                          return Row(
                            spacing: 10,
                            children: [
                              InkWell(
                                onTap: () async {
                                  try {
                                    if (!context.mounted) return;
                                    bool isLocationPermission = await Utils.checkLocationAndGpsPermission(context);
                                    if (isLocationPermission == true) {
                                      if (!context.mounted) return;
                                      final result = await Utils.pickFromCamera(context: context);
                                      if (result != null) {
                                        // innerState(() {
                                        imagePath = result.path;
                                        // });
                                        photoCubit.fieldsValidate(
                                          imgType: imageCategory,
                                          imgPath: result.path,
                                          remarks: remarkC.text,
                                        );
                                      }
                                    }
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    CustomSnackHelper.errorToast(message: e.toString());
                                  }
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      height: 100,
                                      width: 100,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: (erMsg != null && erMsg.isNotEmpty)
                                            ? Colors.red.shade100
                                            : AppColors.secondaryColor.withAlpha(200),
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.circular(4.0),
                                      ),
                                      child: Icon(Icons.camera_alt_outlined, color: AppColors.white, size: 35),
                                    ),
                                    if (erMsg != null && erMsg.isNotEmpty)
                                      Text(erMsg, style: AppTextStyle.ts12MB.copyWith(color: AppColors.red)),
                                  ],
                                ),
                              ),
                              imagePath.isEmpty
                                  ? SizedBox.shrink()
                                  : ClipRRect(
                                      borderRadius: BorderRadiusGeometry.circular(4.0),
                                      child: Image.file(File(imagePath), height: 100, width: 100, fit: BoxFit.fill),
                                    ),
                            ],
                          );
                        },
                      ),
                      Center(
                        child: CustomElevatedButton(
                          text: "Submit",
                          onPressed: () {
                            if (!photoCubit.fieldsValidate(
                              imgType: imageCategory,
                              imgPath: imagePath,
                              remarks: remarkC.text,
                            )) {
                              return;
                            }
                            context.pop();
                            photoCubit.addImage(
                              projectId: projectId,
                              imagePath: imagePath,
                              imageType: imageCategory,
                              imageName: imageCategory,
                              remarks: remarkC.text,
                              context: context,
                            );
                            imagePath = "";
                            remarkC.clear();
                            // context.pop();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).then((_) {
      remarkC.clear();
      imagePath = "";
      imageCategory = "";
      photoCubit.clearValidation();
    });
  }
}
