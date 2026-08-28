import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_dimens.dart';
import 'package:lf_survey/constants/app_text_style.dart';
import 'package:lf_survey/constants/utils.dart';
import 'package:lf_survey/model/db_model/commercial/c_new_project_entity.dart';
import 'package:lf_survey/routes/app_routes_name.dart';
import 'package:lf_survey/widgets/custom_app_bar.dart';

class CNewProjectDetailsPage extends StatelessWidget {
  final CNewProjectEntity projectData;
  const CNewProjectDetailsPage({super.key, required this.projectData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: CustomAppBar(title: "CNew Project Details"),
      body: SafeArea(
        child: Padding(
          padding: AppDimens.hvPadding,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(color: AppColors.white),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                      child: Text(projectData.prjId ?? "", style: AppTextStyle.ts14MB),
                    ),
                    Divider(color: Colors.grey.shade300),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        spacing: 4.0,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(projectData.prjName ?? "", style: AppTextStyle.ts14RB),
                          customText(title: "Address : ", value: projectData.prjAddr ?? ""),
                          customText(title: "Road Name : ", value: projectData.roadName ?? ""),
                          customText(title: "Builder Name : ", value: projectData.builderName ?? ""),
                          customText(title: "Architect Name : ", value: projectData.architectName ?? ""),
                          customText(title: "Mobile Number : ", value: projectData.mobile ?? ""),
                          customText(title: "Created Date Time : ", value: projectData.mobileCreatedDatetime ?? ""),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              SizedBox(height: MediaQuery.of(context).size.height * 0.06),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: customPrefixIcButton(
                  isCenter: true,
                  title: "Add New Sub-Project",
                  icon: Icons.add,
                  onPressed: () async {
                    if (!await Utils.checkLocationAndGpsPermission(context)) return;
                    if (!context.mounted) return;
                    context.pushNamed(
                      AppRoutesName.cNewSubProjectPage,
                      extra: {"newProjectData": projectData, "projectData": null},
                    );
                  },
                ),
              ),
              SizedBox(height: 16.0),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: customPrefixIcButton(
                  isCenter: true,
                  title: "Photo View",
                  icon: Icons.camera_alt,
                  onPressed: () async {
                    if (!await Utils.checkLocationAndGpsPermission(context)) return;
                    if (!context.mounted) return;
                    context.pushNamed(
                      AppRoutesName.addNewImagePrjPage,
                      extra: {"projectId": projectData.prjId, "prjType": "comm"},
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget customText({required String title, required String value}) {
    return RichText(
      text: TextSpan(
        text: title,
        style: AppTextStyle.ts14RB,
        children: [TextSpan(text: " $value", style: AppTextStyle.ts12RB)],
      ),
    );
  }

  Widget customPrefixIcButton({
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
      onPressed: onPressed,
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
                Icon(icon, color: AppColors.white, size: 20),
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
}
