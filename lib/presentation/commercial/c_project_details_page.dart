import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_dimens.dart';
import 'package:lf_survey/constants/app_images.dart';
import 'package:lf_survey/constants/app_text_style.dart';
import 'package:lf_survey/constants/snackbar_helper.dart';
import 'package:lf_survey/constants/utils.dart';
import 'package:lf_survey/cubit/commercial/c_project_details/c_project_details_cubit.dart';
import 'package:lf_survey/cubit/commercial/c_project_details/c_project_details_state.dart';
import 'package:lf_survey/model/db_model/commercial/c_project_entity.dart';
import 'package:lf_survey/routes/app_routes_name.dart';
import 'package:lf_survey/widgets/custom_app_bar.dart';

class CProjectDetailsPage extends StatelessWidget {
  final CProjectEntity projectData;
  const CProjectDetailsPage({super.key, required this.projectData});

  @override
  Widget build(BuildContext context) {
    final cPrjDetailsCubit = context.read<CProjectDetailsCubit>();
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: CustomAppBar(
        title: "Project Details",
        actions: [
          InkWell(
            onTap: () async {
              if (!await Utils.checkLocationAndGpsPermission(context)) return;
              cPrjDetailsCubit.openGoogleMapsDirection(
                projectData.pxval ?? 0.0,
                projectData.pyval ?? 0.0,
                projectData.projectName ?? "",
              );
            },
            child: Image.asset(AppImages.turnImg, color: AppColors.red, width: 30),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.location_off, color: AppColors.red, size: 28),
          ),
        ],
      ),
      body: BlocListener<CProjectDetailsCubit, CProjectDetailsState>(
        listener: (context, state) {
          if (state is ErrorState) {
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
            child: Column(
              spacing: 12.0,
              children: [
                Container(
                  decoration: BoxDecoration(color: AppColors.white),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                        child: Text("PROJECT DETAILS", style: AppTextStyle.ts18RB),
                      ),
                      Divider(color: Colors.grey.shade400, height: 0),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Row(
                          children: [
                            Expanded(child: Text(projectData.projectName ?? "", style: AppTextStyle.ts14RB)),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                              decoration: BoxDecoration(color: AppColors.red),
                              child: Text("${projectData.projectId}", style: AppTextStyle.ts16RW),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          spacing: 12.0,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("Address:", style: AppTextStyle.ts14RB),
                                  Text(projectData.projectAddress ?? "", style: AppTextStyle.ts12RB),
                                  Text(projectData.roadName ?? "", style: AppTextStyle.ts12RB),
                                ],
                              ),
                            ),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("Phone No:", style: AppTextStyle.ts14RB),
                                  Text(
                                    "${projectData.projectPhoneNo}, ${projectData.projectMobileNo}",
                                    style: AppTextStyle.ts12RB,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(color: AppColors.white),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                        child: Text("BUILDER DETAILS", style: AppTextStyle.ts18RB),
                      ),
                      Divider(color: Colors.grey.shade400, height: 0),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Row(
                          children: [
                            Expanded(child: Text(projectData.builderName ?? "", style: AppTextStyle.ts14RB)),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                              decoration: BoxDecoration(color: AppColors.red),
                              child: Text("${projectData.builderId}", style: AppTextStyle.ts16RW),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          spacing: 12.0,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("Address:", style: AppTextStyle.ts14RB),
                                  Text(projectData.builderAddress ?? "", style: AppTextStyle.ts12RB),
                                  Text(projectData.builderContactPerson ?? "", style: AppTextStyle.ts12RB),
                                ],
                              ),
                            ),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("Phone No:", style: AppTextStyle.ts14RB),
                                  Text(
                                    "${projectData.builderPhoneNo}, ${projectData.builderMobileNo}",
                                    style: AppTextStyle.ts12RB,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.6,
                  child: customSuffixIcButton(
                    context: context,
                    title: "SUB PROJECTS",
                    icon: Icons.arrow_forward_ios,
                    onPressed: () {
                      context.pushNamed(AppRoutesName.cSubProjectPage, extra: {"projectData": projectData});
                    },
                  ),
                ),
                Row(
                  spacing: 10,
                  children: [
                    Expanded(
                      child: customPrefixIcButton(
                        context: context,
                        isCenter: true,
                        title: "List View",
                        icon: Icons.list,
                        onPressed: () {
                          context.pushNamed(
                            AppRoutesName.imageListPage,
                            extra: {"projectId": projectData.projectId, "subProjectId": 0},
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: customPrefixIcButton(
                        context: context,
                        isCenter: true,
                        title: "Photo View",
                        icon: Icons.camera_alt,
                        onPressed: () {
                          context.pushNamed(
                            AppRoutesName.cProjectImagePage,
                            extra: {
                              "appBarTitle": "Project Image",
                              "prjId": projectData.projectId,
                              "subPrjId": 0,
                              "dos": projectData.dos,
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.red,
        onPressed: () async {
          if (!await Utils.checkLocationAndGpsPermission(context)) return;
          if (!context.mounted) return;
          context.pushNamed(AppRoutesName.cPrjEditPage, extra: {"projectData": projectData});
        },
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 0.5, color: AppColors.white),
          borderRadius: BorderRadiusGeometry.circular(100),
        ),
        child: Icon(Icons.edit, color: AppColors.white),
      ),
    );
  }

  // Suffix icon button
  Widget customSuffixIcButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.red,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
      // onPressed: onPressed,
      onPressed: () async {
        if (!await Utils.checkLocationAndGpsPermission(context)) return;
        onPressed();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(title, style: AppTextStyle.ts16BW, overflow: TextOverflow.ellipsis),
          ),
          // Transform.scale(scale: 1.2, child: Icon(icon, color: AppColors.white, size: 20)),
          Icon(icon, color: AppColors.white, size: 20),
        ],
      ),
    );
  }

  // Prefix icon button
  Widget customPrefixIcButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
    bool isMainspacing = false,
    bool isSpaceAround = false,
    bool isCenter = false,
    bool isLoading = false,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.red,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
      // onPressed: onPressed,
      onPressed: () async {
        if (!await Utils.checkLocationAndGpsPermission(context)) return;
        onPressed();
      },
      child: isLoading
          ? SizedBox(
              width: 25,
              height: 25,
              child: Center(child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2)),
            )
          : Row(
              spacing: 8.0,
              mainAxisAlignment: isMainspacing
                  ? MainAxisAlignment.spaceBetween
                  : isSpaceAround
                  ? MainAxisAlignment.spaceAround
                  : isCenter
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                // Transform.scale(scale: 1.3, child: Icon(icon, color: AppColors.white, size: 20)),
                Icon(icon, color: AppColors.white, size: 20),
                Flexible(
                  child: Text(
                    title,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.ts16BW,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
    );
  }
}
