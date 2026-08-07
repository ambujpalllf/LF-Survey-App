import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_dimens.dart';
import 'package:lf_survey/constants/app_text_style.dart';
import 'package:lf_survey/constants/snackbar_helper.dart';
import 'package:lf_survey/cubit/residential/download/download_cubit.dart';
import 'package:lf_survey/cubit/residential/download/download_state.dart';
import 'package:lf_survey/model/db_model/residential/location_entity.dart';
import 'package:lf_survey/widgets/custom_app_bar.dart';
import 'package:lf_survey/widgets/custom_dropdown.dart';
import 'package:lf_survey/widgets/custom_elevated_btn.dart';

class DownloadPage extends StatefulWidget {
  final String appBarTitle;
  const DownloadPage({super.key, required this.appBarTitle});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  bool isSelectAll = false;
  bool isLoading = false;
  bool isRefresh = false;

  List<int> selectedLocationIds = [];

  List<Map<String, dynamic>> cityList = [];
  List<Map<String, dynamic>> suburbsList = [];
  List<LocationEntity> locationList = [];

  Map<String, dynamic>? selectedCity;
  Map<String, dynamic>? selectedSuburb;

  @override
  void initState() {
    super.initState();
    context.read<DownloadCubit>().fetchData();
  }

  void clearFields() {
    selectedCity = null;
    selectedSuburb = null;
    cityList.clear();
    suburbsList.clear();
    locationList.clear();
    isSelectAll = false;
    isRefresh = true;
    isLoading = false;
    selectedLocationIds.clear();
  }

  @override
  Widget build(BuildContext context) {
    final DownloadCubit downloadCubit = context.read<DownloadCubit>();
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: CustomAppBar(title: widget.appBarTitle),
      body: SafeArea(
        child: Padding(
          padding: AppDimens.hvPadding,
          child: Container(
            padding: EdgeInsets.all(12.0),
            color: AppColors.white,
            child: BlocListener<DownloadCubit, DownloadState>(
              listener: (context, state) {
                if (state is RefreshState) {
                  clearFields();
                } else if (state is LocalDbState) {
                  cityList = state.cities.map((e) => {"cityId": e.cityId, "cityName": e.cityName}).toList();

                  selectedCity = null;
                  selectedSuburb = null;
                  suburbsList.clear();
                  locationList.clear();
                  selectedLocationIds.clear();

                  isRefresh = false;
                  isLoading = false;
                } else if (state is LoadedState) {
                  cityList = state.citiesResponse.citiesList!
                      .map((e) => {"cityId": e.cityId, "cityName": e.cityName})
                      .toList();

                  selectedCity = null;
                  selectedSuburb = null;
                  suburbsList.clear();
                  locationList.clear();
                  selectedLocationIds.clear();
                  isRefresh = false;
                  isLoading = false;
                } else if (state is SelectedCityState) {
                  suburbsList.clear();
                  suburbsList = state.suburb
                      .map((e) => {"suburbId": e.suburbId, "suburbName": e.suburbName, "cityId": e.cityId})
                      .toList();
                  selectedCity = state.cityEntity;
                } else if (state is SelectedSuburbState) {
                  locationList.clear();
                  locationList.addAll(state.locations);
                  selectedSuburb = state.suburbEntity;
                } else if (state is LoadingState) {
                  isLoading = true;
                  isRefresh = false;
                } else if (state is ErrorState) {
                  CustomSnackHelper.customToastMsg(
                    context: context,
                    message: state.message,
                    bgColor: AppColors.white,
                    textColor: AppColors.black,
                  );
                  isLoading = false;
                  isRefresh = false;
                } else if (state is RefreshState) {
                  isRefresh = true;
                  isLoading = false;
                } else if (state is SuccessState) {
                  CustomSnackHelper.customToastMsg(
                    context: context,
                    message: state.message,
                    bgColor: AppColors.white,
                    textColor: AppColors.black,
                  );
                  isRefresh = false;
                  isLoading = false;
                } else {
                  isLoading = false;
                  isRefresh = false;
                }
              },
              child: Stack(
                children: [
                  Column(
                    children: [
                      InkWell(
                        onTap: () {
                          downloadCubit.getCities();
                        },
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Text("Refresh", style: AppTextStyle.ts16MB.copyWith(color: Colors.blue)),
                        ),
                      ),
                      SizedBox(height: 5.0),
                      BlocBuilder<DownloadCubit, DownloadState>(
                        // buildWhen: (previous, current) => current is LocalDbState || current is LoadedState,
                        builder: (context, state) {
                          return CustomDropdown(
                            initialValue: selectedCity,
                            lableText: "Select City",
                            hintText: "Select City",
                            items: cityList,
                            labelKey: "cityName",
                            onChanged: (value) {
                              if (value == null) return;
                              selectedSuburb = null;
                              isSelectAll = false;
                              locationList.clear();
                              downloadCubit.selectCity(cityId: value["cityId"], city: value);
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      BlocBuilder<DownloadCubit, DownloadState>(
                        // buildWhen: (previous, current) => current is SelectedCityState || current is LoadedState,
                        builder: (context, state) {
                          return suburbsList.isEmpty
                              ? SizedBox.shrink()
                              : CustomDropdown(
                                  initialValue: selectedSuburb,
                                  lableText: "Select Suburb",
                                  hintText: "Select Suburb",
                                  items: suburbsList,
                                  labelKey: "suburbName",
                                  onChanged: (value) {
                                    if (value == null) return;
                                    isSelectAll = false;
                                    downloadCubit.selectSuburb(suburbId: value["suburbId"], selectedSuburb: value);
                                  },
                                );
                        },
                      ),

                      const SizedBox(height: 12),
                      Expanded(
                        child: Container(
                          color: AppColors.appBg,
                          child: BlocBuilder<DownloadCubit, DownloadState>(
                            // buildWhen: (previous, current) => current is SelectedSuburbState || current is LoadedState,
                            builder: (context, state) {
                              return locationList.isEmpty
                                  ? Container(color: AppColors.appBg)
                                  : SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          CheckboxListTile(
                                            activeColor: AppColors.red,
                                            value: isSelectAll,
                                            title: Text("Select ALL", style: AppTextStyle.ts14MB),
                                            controlAffinity: ListTileControlAffinity.leading,
                                            onChanged: (value) {
                                              if (value == null) return;
                                              setState(() {
                                                isSelectAll = value;
                                                if (isSelectAll) {
                                                  locationList.map((i) => i.checked = true).toList();
                                                  selectedLocationIds = locationList.map((i) => i.locationId).toList();
                                                } else {
                                                  locationList.map((i) => i.checked = false).toList();
                                                  selectedLocationIds.clear();
                                                }
                                              });
                                            },
                                          ),
                                          Column(
                                            children: List.generate(locationList.length, (index) {
                                              final item = locationList[index];

                                              return CheckboxListTile(
                                                activeColor: AppColors.red,
                                                value: item.checked,
                                                title: Text(item.locationName, style: AppTextStyle.ts14RB),
                                                controlAffinity: ListTileControlAffinity.leading,
                                                onChanged: (value) {
                                                  if (value == null) return;
                                                  setState(() {
                                                    item.checked = value;
                                                    int id = item.locationId;
                                                    if (value) {
                                                      // Add selected ID
                                                      if (!selectedLocationIds.contains(id)) {
                                                        selectedLocationIds.add(id);
                                                      }

                                                      // If ALL items selected
                                                      if (selectedLocationIds.length == locationList.length) {
                                                        isSelectAll = true;
                                                      }
                                                    } else {
                                                      // Remove deselected ID
                                                      selectedLocationIds.remove(id);

                                                      // Uncheck Select All if one item is false
                                                      isSelectAll = false;
                                                    }
                                                  });
                                                },
                                              );
                                            }),
                                          ),
                                        ],
                                      ),
                                    );
                            },
                          ),
                        ),
                      ),

                      SizedBox(
                        width: double.infinity,
                        child: CustomElevatedButton(
                          isLoading: isLoading,
                          text: widget.appBarTitle.toLowerCase() == "filter" ? "SELECT LOCATION" : "DOWNLOAD PROJECTS",
                          onPressed: () {
                            if (selectedLocationIds.isEmpty) {
                              CustomSnackHelper.customToastMsg(
                                context: context,
                                message: "Please select a location to continue.",
                                bgColor: AppColors.white,
                                textColor: AppColors.black,
                              );
                              return;
                            }
                            widget.appBarTitle.toLowerCase() == "filter"
                                ? context.pop({"loactions": selectedLocationIds})
                                : downloadCubit.downloadProject(locationIds: selectedLocationIds.join(","));
                          },
                        ),
                      ),
                    ],
                  ),

                  BlocBuilder<DownloadCubit, DownloadState>(
                    builder: (context, state) {
                      return isRefresh || isLoading
                          ? Center(child: CircularProgressIndicator(color: AppColors.red))
                          : SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
