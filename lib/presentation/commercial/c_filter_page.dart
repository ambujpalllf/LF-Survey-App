import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_dimens.dart';
import 'package:lf_survey/constants/snackbar_helper.dart';
import 'package:lf_survey/constants/utils.dart';
import 'package:lf_survey/cubit/commercial/c_filter/c_filter_cubit.dart';
import 'package:lf_survey/cubit/commercial/c_filter/c_filter_state.dart';
import 'package:lf_survey/routes/app_routes_name.dart';
import 'package:lf_survey/widgets/custom_app_bar.dart';
import 'package:lf_survey/widgets/custom_dropdown.dart';
import 'package:lf_survey/widgets/custom_elevated_btn.dart';
import 'package:lf_survey/widgets/custom_textform_field.dart';

class CFilterPage extends StatefulWidget {
  const CFilterPage({super.key});

  @override
  State<CFilterPage> createState() => _CFilterPageState();
}

class _CFilterPageState extends State<CFilterPage> {
  List<Map<String, dynamic>> projectType = [
    {"id": 0, "title": "All Projects"},
    {"id": 1, "title": "Complete Projects"},
    {"id": 2, "title": "Pending Projects"},
  ];
  List<int> locationIds = [];
  Map<String, dynamic>? selectedPrjType;

  void clearFields() {
    setState(() {
      selectedPrjType = null;
      locationIds.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    context.read<CFilterCubit>().getFilter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: CustomAppBar(title: "Filter"),
      body: SafeArea(
        child: Padding(
          padding: AppDimens.hvPadding,
          child: Container(
            color: AppColors.white,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: BlocConsumer<CFilterCubit, CFilterState>(
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
                    selectedPrjType = projectType.where((i) => i['id'] == filterQuery['projectType']['id']).firstOrNull;
                    locationIds.clear();
                    locationIds = (filterQuery["location"] as List?)?.map((e) => e as int).toList() ?? [];
                  }
                },
                builder: (context, state) {
                  return Column(
                    spacing: 12.0,
                    children: [
                      CustomDropdown(
                        initialValue: selectedPrjType,
                        items: projectType,
                        labelKey: "title",
                        lableText: "Project Type",
                        onChanged: (value) {
                          selectedPrjType = value;
                        },
                      ),
                      InkWell(
                        onTap: () async {
                          final resp = await context.pushNamed(
                            AppRoutesName.cDownloadPage,
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
                      SizedBox(height: 20),
                      SizedBox(
                        width: MediaQuery.sizeOf(context).width,
                        child: CustomElevatedButton(
                          borderRadius: 0,
                          text: "CLEAR FILTER",
                          onPressed: () async {
                            if (!await Utils.checkLocationAndGpsPermission(context)) return;
                            if (!context.mounted) return;
                            context.read<CFilterCubit>().clearFilter();
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
                              "projectType": selectedPrjType ?? {},
                              "location": locationIds,
                            };
                            context.read<CFilterCubit>().applyFilter(query: filterData);
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
        ),
      ),
    );
  }
}
