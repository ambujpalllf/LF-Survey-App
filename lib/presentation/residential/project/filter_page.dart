import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_dimens.dart';
import 'package:lf_survey/constants/snackbar_helper.dart';
import 'package:lf_survey/constants/utils.dart';
import 'package:lf_survey/cubit/residential/filter/filter_cubit.dart';
import 'package:lf_survey/cubit/residential/filter/filter_state.dart';
import 'package:lf_survey/routes/app_routes_name.dart';
import 'package:lf_survey/widgets/custom_app_bar.dart';
import 'package:lf_survey/widgets/custom_dropdown.dart';
import 'package:lf_survey/widgets/custom_elevated_btn.dart';
import 'package:lf_survey/widgets/custom_textfield.dart';
import 'package:lf_survey/widgets/custom_textform_field.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  List<Map<String, dynamic>> projectType = [
    {"id": 0, "title": "All Projects"},
    {"id": 1, "title": "Complete Projects"},
    {"id": 2, "title": "Pending Projects"},
    {"id": 3, "title": "Rejected Projects"},
  ];
  List<Map<String, dynamic>> totalSupply = [
    {"id": 1, "title": "="},
    {"id": 2, "title": ">="},
    {"id": 3, "title": "<="},
  ];
  Map<String, dynamic>? selectedProject;
  Map<String, dynamic>? selectedTotalSupply;
  Map<String, dynamic>? selectedPrjUnsold;
  TextEditingController totalSupplyC = TextEditingController();
  TextEditingController projectUnsoldC = TextEditingController();
  List<int> locationIds = [];
  List<int> newCityIds = [];

  @override
  void initState() {
    super.initState();
    context.read<FilterCubit>().getFilter();
  }

  @override
  void dispose() {
    totalSupplyC.dispose();
    projectUnsoldC.dispose();
    super.dispose();
  }

  void clearFields() {
    setState(() {
      selectedProject = null;
      selectedTotalSupply = null;
      selectedPrjUnsold = null;
      totalSupplyC.clear();
      projectUnsoldC.clear();
      locationIds.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: CustomAppBar(title: "Filter"),
      body: SafeArea(
        child: BlocConsumer<FilterCubit, FilterState>(
          listener: (context, state) {
            if (state is ErrorState) {
              CustomSnackHelper.customToastMsg(
                context: context,
                message: state.message,
                bgColor: AppColors.white,
                textColor: AppColors.black,
              );
            } else if (state is LocalDBState) {
              Map<String, dynamic> filterQuery = state.queryData;
              selectedProject = projectType.where((i) => i['id'] == filterQuery['projectType']['id']).firstOrNull;
              selectedTotalSupply = totalSupply
                  .where((i) => i['id'] == filterQuery['selectedTotalSupply']['id'])
                  .firstOrNull;
              totalSupplyC.text = filterQuery['totalSupply'];
              selectedPrjUnsold = totalSupply
                  .where((i) => i['id'] == filterQuery['selectedPrjUnsold']['id'])
                  .firstOrNull;
              projectUnsoldC.text = filterQuery['projectUnsold'];
              locationIds.clear();
              locationIds = (filterQuery["location"] as List?)?.map((e) => e as int).toList() ?? [];
              newCityIds = (filterQuery["newAssignPrjCity"] as List?)?.map((e) => e as int).toList() ?? [];
            }
          },
          builder: (context, statet) {
            return Padding(
              padding: AppDimens.hvPadding,
              child: Container(
                padding: AppDimens.hvPadding,
                decoration: BoxDecoration(color: AppColors.white),
                child: Column(
                  spacing: 20.0,
                  children: [
                    SizedBox(height: 10),
                    CustomDropdown(
                      initialValue: selectedProject,
                      lableText: "Project Type",
                      items: projectType,
                      labelKey: "title",
                      onChanged: (value) {
                        setState(() {
                          selectedProject = value;
                        });
                      },
                    ),
                    Row(
                      spacing: 10,
                      children: [
                        Flexible(
                          child: CustomDropdown(
                            initialValue: selectedTotalSupply,
                            lableText: "Total Supply",
                            items: totalSupply,
                            labelKey: "title",
                            onChanged: (value) {
                              setState(() {
                                selectedTotalSupply = value;
                              });
                            },
                          ),
                        ),
                        Flexible(
                          child: CustomTextField(
                            readOnly: selectedTotalSupply == null ? true : false,
                            style: TextStyle(color: AppColors.red),
                            borderColor: selectedTotalSupply == null ? AppColors.greyLite : AppColors.red,
                            cursorColor: selectedTotalSupply == null ? AppColors.greyLite : AppColors.red,
                            controller: totalSupplyC,
                            borderWidth: 2,
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            counterText: "",
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      spacing: 10,
                      children: [
                        Flexible(
                          child: CustomDropdown(
                            initialValue: selectedPrjUnsold,
                            lableText: "Project Unsold",
                            items: totalSupply,
                            labelKey: "title",
                            onChanged: (value) {
                              setState(() {
                                selectedPrjUnsold = value;
                              });
                            },
                          ),
                        ),
                        Flexible(
                          child: CustomTextField(
                            readOnly: selectedPrjUnsold == null ? true : false,
                            style: TextStyle(color: AppColors.red),
                            borderColor: selectedPrjUnsold == null ? AppColors.greyLite : AppColors.red,
                            cursorColor: selectedPrjUnsold == null ? AppColors.greyLite : AppColors.red,
                            borderWidth: 2.0,
                            maxLength: 4,
                            counterText: "",
                            keyboardType: TextInputType.number,
                            controller: projectUnsoldC,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () async {
                        final resp = await context.pushNamed(
                          AppRoutesName.downloadPage,
                          extra: {"appBarTitle": "Filter"},
                        );
                        if (resp != null && resp is Map<String, dynamic>) {
                          locationIds.clear();

                          setState(() {
                            locationIds.addAll(resp["loactions"]);
                          });
                        }
                      },
                      child: IgnorePointer(
                        ignoring: true,
                        child: CustomTextformField(
                          hintText: locationIds.isEmpty
                              ? "SELECT PROJECT LOCATIONS"
                              : "${locationIds.length} LOCATION SELECTED",
                          hintTextColor: AppColors.red,
                          suffixIcon: Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                            color: AppColors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        final resp = await context.pushNamed(
                          AppRoutesName.newAssignPrjLocFilterPage,
                          extra: {"appBarTitle": "Filter"},
                        );
                        if (resp != null && resp is Map<String, dynamic>) {
                          newCityIds.clear();

                          setState(() {
                            newCityIds.addAll(resp["loactions"]);
                          });
                        }
                      },
                      child: IgnorePointer(
                        ignoring: true,
                        child: CustomTextformField(
                          hintText: newCityIds.isEmpty
                              ? "SELECT NEW PROJECT LOCATIONS"
                              : "${newCityIds.length} LOCATION SELECTED",
                          hintTextColor: AppColors.red,
                          suffixIcon: Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                            color: AppColors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width,
                      child: CustomElevatedButton(
                        borderRadius: 0,
                        text: "CLEAR FILTER",
                        onPressed: () async {
                          if (!await Utils.checkLocationAndGpsPermission(context)) return;
                          if (!context.mounted) return;
                          context.read<FilterCubit>().clearFilter();
                          clearFields();
                          context.pop();
                        },
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width,
                      child: CustomElevatedButton(
                        borderRadius: 0,
                        text: "APPLY",
                        onPressed: () async {
                          if (!await Utils.checkLocationAndGpsPermission(context)) return;
                          if (!context.mounted) return;
                          Map<String, dynamic> filterData = {
                            "projectType": selectedProject ?? {},
                            "selectedTotalSupply": selectedTotalSupply ?? {},
                            "selectedPrjUnsold": selectedPrjUnsold ?? {},
                            "totalSupply": totalSupplyC.text,
                            "projectUnsold": projectUnsoldC.text,
                            "location": locationIds,
                            "newAssignPrjCity": newCityIds,
                          };
                          context.read<FilterCubit>().applyFilter(query: filterData);
                          // context.pop(filterData);
                          context.pop();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
