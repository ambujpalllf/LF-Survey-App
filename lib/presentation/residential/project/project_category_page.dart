import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:go_router/go_router.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_dimens.dart';
import 'package:lf_survey/constants/app_images.dart';
import 'package:lf_survey/constants/app_text_style.dart';
import 'package:lf_survey/constants/snackbar_helper.dart';
import 'package:lf_survey/constants/storage_function.dart';
import 'package:lf_survey/constants/storage_key.dart';
import 'package:lf_survey/constants/utils.dart';
import 'package:lf_survey/database/db_helper.dart';
import 'package:lf_survey/model/location_model.dart';
import 'package:lf_survey/routes/app_routes_name.dart';
import 'package:lf_survey/services/api_client.dart';
import 'package:lf_survey/services/foreground_task_handler.dart';

class ProjectCategoryPage extends StatefulWidget {
  const ProjectCategoryPage({super.key});

  @override
  State<ProjectCategoryPage> createState() => _ProjectCategoryPageState();
}

class _ProjectCategoryPageState extends State<ProjectCategoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      foregroundTask();
      // Syncs location data collected in the background that has not
      // yet been synchronized with the server. This method is called
      // once when the user visits this page.
      syncLocation(context);
    });
  }

  void foregroundTask() async {
    bool isLocationPermission = await Utils.checkLocationAndGpsPermission(context);
    if (isLocationPermission == true) {
      if (!mounted) return;
      ForegroundTaskHandler.foregroundServiceInit(context);
    }
  }

  void syncLocation(context) async {
    try {
      final userId = await StorageFunction.readIntData(StorageKey.userId);
      if (userId != null) {
        List<LocationModel> locationData = await DBHelper.getAllLocations(userId: userId);
        if (locationData.isNotEmpty) {
          final response = await ApiClient.userLFLocation(locationData: locationData);
          if (response != null) {
            List<dynamic> syncData = response["gpssyncstatuslist"] ?? [];
            if (syncData.isNotEmpty) {
              for (var item in syncData) {
                int gpsTrackerId = item["gps_tracker_id"];
                LocationModel? localItem = locationData.where((e) => e.id == gpsTrackerId).firstOrNull;
                if (localItem != null) {
                  await DBHelper.deleteLocationById(id: localItem.id!);
                }
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error : $e");
      CustomSnackHelper.customToastMsg(context: context, message: "Location sync failed. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppDimens.hvPadding,
          child: Column(
            spacing: AppDimens.spacingMD,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    spacing: AppDimens.spacingMD,
                    children: [
                      InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(),
                                title: Text("Logout", style: AppTextStyle.ts18BB),
                                content: Text("Are you sure want to logout ?", style: AppTextStyle.ts14RB),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      context.pop();
                                    },
                                    child: Text("CANCEL", style: AppTextStyle.ts16BB.copyWith(color: AppColors.red)),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      context.pop();
                                      // context.go(AppRoutesName.loginPage, extra: {"userType": ""});
                                      context.pushReplacementNamed(AppRoutesName.loginPage, extra: {"userType": ""});
                                      await StorageFunction.clearStorage();
                                      await FlutterForegroundTask.stopService();
                                    },
                                    child: Text("OK", style: AppTextStyle.ts16BB.copyWith(color: AppColors.primaryDarkColor)),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Icon(Icons.logout_sharp, color: AppColors.red),
                      ),
                      Text("Select Project Type", style: AppTextStyle.ts18BB.copyWith(color: AppColors.red)),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      context.pushNamed(AppRoutesName.projectSearchPage);
                    },
                    icon: Icon(Icons.search_outlined, color: AppColors.red),
                  ),
                ],
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    context.pushNamed(AppRoutesName.projectPage);
                  },
                  child: Stack(
                    children: [
                      Image.asset(AppImages.residentialImg),
                      Text("Residential", style: AppTextStyle.ts20MB.copyWith(fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    context.pushNamed(AppRoutesName.cProjectPage);
                  },
                  child: Stack(
                    children: [
                      Image.asset(AppImages.commercialImg),
                      Text("Commercial", style: AppTextStyle.ts20MB.copyWith(fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
