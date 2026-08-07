import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_dimens.dart';
import 'package:lf_survey/constants/app_text_style.dart';
import 'package:lf_survey/constants/snackbar_helper.dart';
import 'package:lf_survey/cubit/commercial/c_sub_project_details/c_sub_project_details_cubit.dart';
import 'package:lf_survey/cubit/commercial/c_sub_project_details/c_sub_project_detais_state.dart';
import 'package:lf_survey/model/db_model/commercial/c_sub_project_entity.dart';
import 'package:lf_survey/routes/app_routes_name.dart';
import 'package:lf_survey/widgets/custom_app_bar.dart';

class CSubProjectDetailsPage extends StatefulWidget {
  final CSubProjectEntity subProjectData;
  const CSubProjectDetailsPage({super.key, required this.subProjectData});

  @override
  State<CSubProjectDetailsPage> createState() => _CSubProjectDetailsPageState();
}

class _CSubProjectDetailsPageState extends State<CSubProjectDetailsPage> {
  CSubProjectEntity? subProjectData;
  @override
  void initState() {
    super.initState();
    subProjectData = widget.subProjectData;
    context.read<CSubProjectDetailsCubit>().getData(subProjectId: subProjectData!.subProjectId!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: CustomAppBar(title: "Sub-Project Details"),
      body: SafeArea(
        child: BlocListener<CSubProjectDetailsCubit, CSubProjectDetaisState>(
          listener: (context, state) {
            if (state is LocalDbState) {
              subProjectData = state.subProjectData;
            } else if (state is MessageState) {
              CustomSnackHelper.customToastMsg(
                context: context,
                message: state.message,
                textColor: AppColors.black,
                bgColor: AppColors.white,
              );
            }
          },
          child: Padding(
            padding: AppDimens.hvPadding,
            child: Column(
              spacing: 12.0,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(4.0),
                    boxShadow: [BoxShadow(color: Colors.grey.shade300, offset: Offset(2, 2))],
                  ),
                  child: Column(
                    spacing: 12.0,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${widget.subProjectData.subProjectName}(${widget.subProjectData.subProjectId})",
                        style: AppTextStyle.ts16RB,
                      ),
                    ],
                  ),
                ),
                Row(
                  spacing: 12.0,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
                        onPressed: () {
                          context.pushNamed(
                            AppRoutesName.imageListPage,
                            extra: {
                              "projectId": widget.subProjectData.projectId,
                              "subProjectId": widget.subProjectData.subProjectId,
                            },
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 12.0,
                          children: [
                            Icon(Icons.list, color: AppColors.white, size: 25),
                            Flexible(child: Text("List View", style: AppTextStyle.ts14BW)),
                          ],
                        ),
                      ),
                    ),
                    Flexible(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
                        onPressed: () {
                          context.pushNamed(
                            AppRoutesName.cProjectImagePage,
                            extra: {
                              "appBarTitle": "Sub-Project Image",
                              "prjId": widget.subProjectData.projectId,
                              "subPrjId": widget.subProjectData.subProjectId,
                              "dos": widget.subProjectData.dos,
                            },
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 12.0,
                          children: [
                            Icon(Icons.camera_alt, color: AppColors.white, size: 25),
                            Flexible(child: Text("Photo View", style: AppTextStyle.ts14BW)),
                          ],
                        ),
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
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 0.5, color: AppColors.white),
          borderRadius: BorderRadiusGeometry.circular(100),
        ),
        backgroundColor: AppColors.red,
        onPressed: () async {
          await context.pushNamed(AppRoutesName.cSubProjectEditPage, extra: {"subProjectData": widget.subProjectData});
          if (!context.mounted) return;
          context.read<CSubProjectDetailsCubit>().getData(subProjectId: subProjectData!.subProjectId!);
        },
        child: Icon(Icons.edit, color: AppColors.white),
      ),
    );
  }
}
