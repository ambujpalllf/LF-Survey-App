import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lf_survey/app_popups/cutsom_alert_dialogues.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_dimens.dart';
import 'package:lf_survey/constants/app_images.dart';
import 'package:lf_survey/constants/app_text_style.dart';
import 'package:lf_survey/constants/snackbar_helper.dart';
import 'package:lf_survey/constants/utils.dart';
import 'package:lf_survey/cubit/residential/project_details/prj_details_cubit.dart';
import 'package:lf_survey/cubit/residential/project_details/prj_details_state.dart';
import 'package:lf_survey/database/db_helper.dart';
import 'package:lf_survey/model/db_model/residential/project_entity.dart';
import 'package:lf_survey/routes/app_routes_name.dart';
import 'package:lf_survey/widgets/custom_app_bar.dart';
import 'package:lf_survey/widgets/project_details_card.dart';

class ProjectDetailsPage extends StatelessWidget {
  final ProjectEntity projectData;
  const ProjectDetailsPage({super.key, required this.projectData});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final PrjDetailsCubit prjDetailsCubit = context.read<PrjDetailsCubit>();
    return BlocListener<PrjDetailsCubit, PrjDetailsState>(
      listener: (context, state) {
        if (state is ErrorState) {
          CustomSnackHelper.customToastMsg(
            context: context,
            message: state.message,
            bgColor: AppColors.white,
            textColor: AppColors.black,
          );
        } else if (state is LocationErrorState) {
          CutsomAlertDialogues.customDialog(context: context, message: state.message);
        } else if (state is SuccessState) {
          CustomSnackHelper.customToastMsg(
            context: context,
            message: state.message,
            bgColor: AppColors.white,
            textColor: AppColors.black,
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.appBg,
        appBar: CustomAppBar(
          title: "Project Details",
          actions: [
            InkWell(
              onTap: () async {
                if (!await Utils.checkLocationAndGpsPermission(context)) return;
                prjDetailsCubit.openGoogleMapsDirection(
                  projectData.pxval ?? 0.0,
                  projectData.pyval ?? 0.0,
                  projectData.projectName ?? "",
                );
              },
              child: Image.asset(AppImages.turnImg, color: AppColors.red, width: 30),
            ),
            IconButton(
              onPressed: () {
                updateIsWrongPXValPYVal(context: context, projectData: projectData);
              },
              icon: Icon(Icons.location_off, color: AppColors.red, size: 28),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: AppDimens.hvPadding,
            child: Column(
              spacing: 12.0,
              children: [
                ProjectDetailsCard(
                  title: "PROJECT DETAILS",
                  projectName: projectData.projectName ?? "",
                  projectId: projectData.projectId.toString(),
                  address: "${projectData.projectAddress}\n${projectData.roadName}",
                  phone: "${projectData.projectMobileNo}, ${projectData.projectPhoneNo}",
                ),

                ProjectDetailsCard(
                  title: "BUILDER DETAILS",
                  projectName: projectData.builderName ?? "",
                  projectId: projectData.projectId.toString(),
                  address: projectData.builderAddress ?? "",
                  phone: "${projectData.builderMobileNo}, ${projectData.builderPhoneNo}",
                ),

                SizedBox(
                  width: width * 0.6,
                  child: customSuffixIcButton(
                    title: "SUB PROJECTS",
                    context: context,
                    icon: Icons.arrow_forward_ios,
                    onPressed: () {
                      context.pushNamed(AppRoutesName.subProjectPage, extra: {"projectData": projectData});
                    },
                  ),
                ),

                Row(
                  spacing: 8.0,
                  children: [
                    Expanded(
                      child: customPrefixIcButton(
                        isCenter: true,
                        context: context,
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
                        isCenter: true,
                        title: "Photo View",
                        context: context,
                        icon: Icons.camera_alt,
                        onPressed: () {
                          context.pushNamed(
                            AppRoutesName.prjImgPage,
                            extra: {
                              "projectId": projectData.projectId,
                              "dos": projectData.dos,
                              "subProjectId": 0,
                              "appBarTitle": "Project Image",
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: width * 0.6,
                  child: BlocBuilder<PrjDetailsCubit, PrjDetailsState>(
                    builder: (context, state) {
                      return customPrefixIcButton(
                        isCenter: true,
                        context: context,
                        isLoading: state is LoadingState,
                        title: "Upload Brochure",
                        icon: Icons.upload_file,
                        onPressed: () async {
                          final data = await prjDetailsCubit.pickedPdf();
                          if (data != null) {
                            if (!context.mounted) return;
                            showDialog(
                              context: context,
                              builder: (_) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(2.0)),
                                  content: Text(
                                    "Upload File - ${data.path.split("/").last}",
                                    style: AppTextStyle.ts14RB,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        context.pop();
                                        CustomSnackHelper.customToastMsg(
                                          context: context,
                                          message: "You have cancelled the brochure upload.",
                                          bgColor: AppColors.white,
                                          textColor: AppColors.black,
                                        );
                                      },
                                      child: Text(
                                        "Cancel",
                                        style: AppTextStyle.ts14BB.copyWith(color: AppColors.primaryColor),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        context.pop();
                                        prjDetailsCubit.uploadBrochure(
                                          projectId: projectData.projectId!,
                                          pdfFile: data,
                                        );
                                      },
                                      child: Text(
                                        "OK",
                                        style: AppTextStyle.ts14BB.copyWith(color: AppColors.primaryColor),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
                // SizedBox(height: 5),
                Row(
                  spacing: 8,
                  children: [
                    Flexible(
                      child: customPrefixIcButton(
                        isCenter: true,
                        context: context,
                        title: "Developer Logo",
                        icon: Icons.image,
                        onPressed: () {
                          prjDetailsCubit.pickImgGallery(
                            context: context,
                            category: "developerlogo",
                            projectId: " ${projectData.projectId}",
                          );
                        },
                      ),
                    ),
                    Flexible(
                      child: customPrefixIcButton(
                        isCenter: true,
                        title: "Project Logo",
                        context: context,
                        icon: Icons.image,
                        onPressed: () {
                          prjDetailsCubit.pickImgGallery(
                            context: context,
                            category: "logo",
                            projectId: " ${projectData.projectId}",
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: width * 0.6,
                  child: customPrefixIcButton(
                    isCenter: true,
                    context: context,
                    title: "Master Plan Image",
                    icon: Icons.image,
                    onPressed: () {
                      prjDetailsCubit.pickImgGallery(
                        context: context,
                        category: "masterplan",
                        projectId: " ${projectData.projectId}",
                      );
                    },
                  ),
                ),
                Row(
                  spacing: 8,
                  children: [
                    Flexible(
                      child: customPrefixIcButton(
                        isCenter: true,
                        context: context,
                        title: "Elevation Image",
                        icon: Icons.image,
                        onPressed: () {
                          prjDetailsCubit.pickImgGallery(
                            context: context,
                            category: "elevation",
                            projectId: " ${projectData.projectId}",
                          );
                        },
                      ),
                    ),
                    Flexible(
                      child: customPrefixIcButton(
                        isCenter: true,
                        context: context,
                        title: "Key Plan Image",
                        icon: Icons.image,
                        onPressed: () {
                          prjDetailsCubit.pickImgGallery(
                            context: context,
                            category: "keyplan",
                            projectId: " ${projectData.projectId}",
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: width * 0.6,
                  child: customPrefixIcButton(
                    isCenter: true,
                    context: context,
                    title: "Layout Plan Image",
                    icon: Icons.image,
                    onPressed: () {
                      prjDetailsCubit.pickImgGallery(
                        context: context,
                        category: "layoutplan",
                        projectId: " ${projectData.projectId}",
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.red,
          onPressed: () async {
            if (!await Utils.checkLocationAndGpsPermission(context)) return;
            if (!context.mounted) return;
            context.pushNamed(AppRoutesName.projectEditFormPage, extra: {"projectData": projectData});
          },
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 0.5, color: AppColors.white),
            borderRadius: BorderRadiusGeometry.circular(100),
          ),
          child: Icon(Icons.edit, color: AppColors.white),
        ),
      ),
    );
  }

  // Suffix icon button
  Widget customSuffixIcButton({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
    required BuildContext context,
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
            child: Text(title, style: AppTextStyle.ts14BW, overflow: TextOverflow.ellipsis),
          ),
          // Transform.scale(scale: 1.2, child: Icon(icon, color: AppColors.white, size: 20)),
          Icon(icon, color: AppColors.white, size: 18),
        ],
      ),
    );
  }

  // Prefix icon button
  Widget customPrefixIcButton({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
    required BuildContext context,
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
                Icon(icon, color: AppColors.white, size: 16),
                Flexible(
                  child: Text(
                    title,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.ts14BW,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> updateIsWrongPXValPYVal({required BuildContext context, required ProjectEntity projectData}) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(),
          title: Row(
            spacing: 12.0,
            children: [
              Icon(Icons.warning_rounded, size: 40, color: Colors.grey.shade400),
              Text('Confirm', style: AppTextStyle.ts20MB),
            ],
          ),
          content: Text('Are you sure, you want to report wrong location.', style: AppTextStyle.ts14RB),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('CANCEL', style: AppTextStyle.ts16RB),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  projectData.isWrongPXValPYVal = 1;
                  projectData.syncLocalStatus = 1;
                  await DBHelper.updateProject(projectData);
                } catch (e) {
                  String erStr = e.toString().split(":").last;
                  if (!context.mounted) return;
                  CustomSnackHelper.errorSnackbar(context: context, message: erStr);
                }
              },
              child: Text('OK', style: AppTextStyle.ts16RB),
            ),
          ],
        );
      },
    );
  }
}
