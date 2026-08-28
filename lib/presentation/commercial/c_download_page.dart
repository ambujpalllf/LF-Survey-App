import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_dimens.dart';
import 'package:lf_survey/constants/app_text_style.dart';
import 'package:lf_survey/constants/snackbar_helper.dart';
import 'package:lf_survey/constants/utils.dart';
import 'package:lf_survey/cubit/commercial/c_download/c_download_cubit.dart';
import 'package:lf_survey/cubit/commercial/c_download/c_download_state.dart';
import 'package:lf_survey/model/db_model/commercial/c_location_entity.dart';
import 'package:lf_survey/widgets/custom_app_bar.dart';
import 'package:lf_survey/widgets/custom_dropdown.dart';
import 'package:lf_survey/widgets/custom_elevated_btn.dart';

class CDownloadPage extends StatefulWidget {
  final String appBarTitle;
  const CDownloadPage({super.key, required this.appBarTitle});

  @override
  State<CDownloadPage> createState() => _CDownloadPageState();
}

class _CDownloadPageState extends State<CDownloadPage> {
  List<Map<String, dynamic>> cities = [];
  List<Map<String, dynamic>> suburbs = [];
  List<CLocationEntity> locations = [];
  List<int> locationIds = [];
  Map<String, dynamic>? selectedCity;
  Map<String, dynamic>? selectedSuburb;

  @override
  void initState() {
    super.initState();
    context.read<CDownloadCubit>().fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final CDownloadCubit cDownloadCubit = context.read<CDownloadCubit>();
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: CustomAppBar(title: widget.appBarTitle),
      body: BlocListener<CDownloadCubit, CDownloadState>(
        listener: (context, state) {
          if (state is LoadedSate) {
            cities.clear();
            cities.addAll(state.locData.citiesList!.map((e) => {"id": e.cityId, "title": e.cityName}));
          } else if (state is LocalDbState) {
            cities.clear();
            cities.addAll(state.cities.map((e) => {"id": e.cityId, "title": e.cityName}));
          } else if (state is SelectCityState) {
            selectedSuburb = null;
            suburbs.clear();
            suburbs.addAll(state.suburb.map((e) => {"id": e.suburbId, "title": e.suburbName}));
          } else if (state is SelectSuburbState) {
            locations.clear();
            locationIds.clear();
            locations.addAll(state.locations);
            locationIds.addAll(locations.where((e) => e.checked).map((e) => e.locationId));
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
          }
        },
        child: SafeArea(
          child: Padding(
            padding: AppDimens.hvPadding,
            child: Container(
              decoration: BoxDecoration(color: AppColors.white),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(
                  children: [
                    Column(
                      spacing: 12.0,
                      children: [
                        Align(
                          alignment: AlignmentGeometry.topRight,
                          child: TextButton(
                            style: ButtonStyle(
                              padding: WidgetStateProperty.all(EdgeInsets.zero),
                              minimumSize: WidgetStateProperty.all(Size.zero),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {
                              cDownloadCubit.fetchCities();
                            },
                            child: Text("Refresh", style: AppTextStyle.ts16MB.copyWith(color: Colors.blue)),
                          ),
                        ),
                        BlocBuilder<CDownloadCubit, CDownloadState>(
                          builder: (context, state) {
                            return CustomDropdown(
                              initialValue: selectedCity,
                              items: cities,
                              lableText: "City",
                              hintText: "Select City",
                              labelKey: "title",
                              onChanged: (value) {
                                if (selectedCity?["id"] == value?["id"]) {
                                  return; //  STOP if same city selected
                                }
                                selectedCity = value;
                                selectedSuburb = null;
                                suburbs.clear();
                                locationIds.clear();
                                locations.clear();
                                if (selectedCity != null) {
                                  cDownloadCubit.selectCity(cityId: selectedCity!["id"]);
                                }
                              },
                            );
                          },
                        ),
                        BlocBuilder<CDownloadCubit, CDownloadState>(
                          buildWhen: (previous, current) => current is SelectCityState,
                          builder: (context, state) {
                            return suburbs.isEmpty
                                ? SizedBox.shrink()
                                : CustomDropdown(
                                    initialValue: selectedSuburb,
                                    items: suburbs,
                                    lableText: "Suburb",
                                    hintText: "Select Suburb",
                                    labelKey: "title",
                                    onChanged: (value) {
                                      selectedSuburb = value;
                                      if (selectedSuburb != null) {
                                        cDownloadCubit.selectSuburb(suburbId: selectedSuburb!["id"]);
                                      }
                                    },
                                  );
                          },
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(color: AppColors.appBg),
                            child: Column(
                              children: [
                                BlocBuilder<CDownloadCubit, CDownloadState>(
                                  buildWhen: (previous, current) =>
                                      current is SelectSuburbState || current is SelectCityState,
                                  builder: (context, state) {
                                    return locations.isNotEmpty
                                        ? CheckboxListTile(
                                            contentPadding: EdgeInsets.zero,
                                            dense: true,
                                            checkColor: Colors.white,
                                            activeColor: AppColors.red,
                                            controlAffinity: ListTileControlAffinity.leading,
                                            value:
                                                locations.isNotEmpty && locations.every((item) => item.checked == true),
                                            title: Text("Select All", style: AppTextStyle.ts14RB),
                                            onChanged: (bool? value) {
                                              cDownloadCubit.toggleSelectAll(
                                                locations: locations,
                                                isSelected: value ?? false,
                                              );
                                            },
                                          )
                                        : SizedBox.shrink();
                                  },
                                ),
                                BlocBuilder<CDownloadCubit, CDownloadState>(
                                  buildWhen: (previous, current) =>
                                      current is SelectSuburbState || current is SelectCityState,
                                  builder: (context, state) {
                                    return Expanded(
                                      child: ListView.builder(
                                        itemCount: locations.length,
                                        itemBuilder: (context, index) {
                                          return CheckboxListTile(
                                            contentPadding: EdgeInsets.zero,
                                            dense: true,
                                            checkColor: Colors.white,
                                            activeColor: AppColors.red,
                                            controlAffinity: ListTileControlAffinity.leading,
                                            value: locations[index].checked,
                                            onChanged: (value) {
                                              if (value != null) {
                                                cDownloadCubit.toggleLocation(
                                                  locations: locations,
                                                  selectedId: locations[index].locationId,
                                                  isSelected: value,
                                                );
                                              }
                                            },
                                            title: Text(locations[index].locationName, style: AppTextStyle.ts14RB),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: CustomElevatedButton(
                            // text: "Download Project",
                            text: widget.appBarTitle.toLowerCase() == "filter"
                                ? "SELECT LOCATION"
                                : "DOWNLOAD PROJECTS",
                            onPressed: () async {
                              if (!await Utils.checkLocationAndGpsPermission(context)) return;
                              if (!context.mounted) return;
                              if (locationIds.isEmpty) {
                                CustomSnackHelper.customToastMsg(
                                  context: context,
                                  message: "Please select a location to continue.",
                                  bgColor: AppColors.white,
                                  textColor: AppColors.black,
                                );
                                return;
                              }
                              widget.appBarTitle.toLowerCase() == "filter"
                                  ? context.pop({"loactions": locationIds})
                                  : cDownloadCubit.downloadProjects(location: locationIds);
                            },
                          ),
                        ),
                      ],
                    ),
                    BlocBuilder<CDownloadCubit, CDownloadState>(
                      builder: (context, state) {
                        if (state is LoadingState) {
                          return Center(child: CircularProgressIndicator(color: AppColors.red));
                        }
                        return SizedBox.shrink();
                      },
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
