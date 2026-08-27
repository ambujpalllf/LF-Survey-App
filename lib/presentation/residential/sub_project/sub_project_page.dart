import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lf_survey/app_popups/cutsom_alert_dialogues.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_dimens.dart';
import 'package:lf_survey/constants/app_text_style.dart';
import 'package:lf_survey/constants/snackbar_helper.dart';
import 'package:lf_survey/constants/utils.dart';
import 'package:lf_survey/cubit/residential/sub_project/sub_project_cubit.dart';
import 'package:lf_survey/cubit/residential/sub_project/sub_project_state.dart';
import 'package:lf_survey/model/db_model/residential/flat_entity.dart';
import 'package:lf_survey/model/db_model/residential/project_entity.dart';
import 'package:lf_survey/model/db_model/residential/sub_prj_entity.dart';
import 'package:lf_survey/routes/app_routes_name.dart';
import 'package:lf_survey/widgets/custom_app_bar.dart';

class SubProjectPage extends StatefulWidget {
  final ProjectEntity projectData;
  const SubProjectPage({super.key, required this.projectData});

  @override
  State<SubProjectPage> createState() => _SubProjectPageState();
}

class _SubProjectPageState extends State<SubProjectPage> {
  bool isLoading = false;
  List<SubProjectEntity> subProjects = [];
  List<FlatEntity> flats = [];
  List<Map<String, dynamic>> constructionProgress = [];
  late ReceivePort _receivePort;
  @override
  void initState() {
    super.initState();
    context.read<SubProjectCubit>().fetchSubProjects(projectId: widget.projectData.projectId!);
    context.read<SubProjectCubit>().fetchConstuctionProgress();
    _receivePort = ReceivePort();
    IsolateNameServer.registerPortWithName(_receivePort.sendPort, "sync_sub_project");
    _receivePort.listen((message) {
      context.read<SubProjectCubit>().fetchSubProjects(projectId: widget.projectData.projectId!);
    });
  }

  @override
  void dispose() {
    super.dispose();
    IsolateNameServer.removePortNameMapping('sync_sub_project');
    _receivePort.close();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: CustomAppBar(
        title: "Sub Project (${widget.projectData.projectId})",
        actions: [
          IconButton(
            onPressed: () async {
              final locPermission = await Utils.checkLocationAndGpsPermission(context);
              if (!context.mounted) return;
              if (!locPermission) {
                CustomSnackHelper.errorToast(message: "Please enable location permission and GPS");
                return;
              }
              bool isSaveFlats = flats.every((e) => e.dataFilled == 1);
              bool isSyncedSubProjects = subProjects.every((e) => e.syncGlobalStatus == 1);

              if (isSyncedSubProjects) {
                showDialog(
                  context: context,
                  builder: (_) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(),
                      title: Text("Already Synced", style: AppTextStyle.ts16BB),
                      content: Text("All sub-projects have already been synchronized. No further action is required."),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("OK", style: AppTextStyle.ts16RB),
                        ),
                      ],
                    );
                  },
                );
              } else if (!isSaveFlats) {
                showDialog(
                  context: context,
                  builder: (_) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(),
                      title: Text("Incomplete Data", style: AppTextStyle.ts16BB),
                      content: Text("Some flat details are missing. Kindly complete all entries before syncing."),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("OK", style: AppTextStyle.ts16RB),
                        ),
                      ],
                    );
                  },
                );
              } else {
                context.read<SubProjectCubit>().syncSubProjects(
                  subProjects: subProjects,
                  flats: flats,
                  projectId: widget.projectData.projectId!,
                );
              }
            },
            icon: Icon(Icons.sync, color: AppColors.red),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: AppDimens.hvPadding,
          child: Column(
            spacing: 12.0,
            children: [
              SizedBox(
                width: width * 0.7,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  ),
                  onPressed: () async {
                    final locPermission = await Utils.checkLocationAndGpsPermission(context);
                    if (!context.mounted) return;
                    if (!locPermission) {
                      CustomSnackHelper.errorToast(message: "Please enable location permission and GPS");
                      return;
                    }
                    context.pushNamed(
                      AppRoutesName.newSubPrjListPage,
                      extra: {
                        "projectId": widget.projectData.projectId,
                        "newProjectId": "",
                        "reraNo": widget.projectData.reraNo,
                        "cityId": widget.projectData.cityId,
                      },
                    );
                  },
                  child: Row(
                    children: [
                      Transform.scale(scale: 1.3, child: Icon(Icons.add, color: AppColors.white, size: 20)),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text("Add New Sub-Project", style: AppTextStyle.ts16BW, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: BlocConsumer<SubProjectCubit, SubProjectState>(
                  listener: (context, state) {
                    if (state is ErrorState) {
                      CustomSnackHelper.customToastMsg(
                        context: context,
                        message: state.message,
                        bgColor: AppColors.white,
                        textColor: AppColors.black,
                      );
                    } else if (state is LoadingState) {
                      isLoading = true;
                    } else if (state is LoadedState) {
                      subProjects.clear();
                      flats.clear();
                      subProjects.addAll(state.subProjects);
                      flats.addAll(state.flats);
                      isLoading = false;
                    } else if (state is ConstructionProgressState) {
                      constructionProgress.clear();
                      constructionProgress.addAll(state.constructionProgress);
                      isLoading = false;
                    } else if (state is SuccessState) {
                      CustomSnackHelper.customToastMsg(
                        context: context,
                        message: state.message,
                        bgColor: AppColors.white,
                        textColor: AppColors.black,
                      );
                      isLoading = false;
                    } else if (state is DeleteSubPrjState) {
                      subProjects.removeAt(state.index);
                    }
                  },
                  builder: (context, state) {
                    return subProjects.isEmpty
                        ? Center(
                            child: isLoading
                                ? CircularProgressIndicator()
                                : Text("No Data Found!", style: AppTextStyle.ts14RB),
                          )
                        : ListView.builder(
                            itemCount: subProjects.length,
                            itemBuilder: (_, index) {
                              var subProjectData = subProjects[index];
                              var progress = constructionProgress.firstWhere(
                                (element) => element["constProgressId"] == subProjectData.constructionProgressId,
                                orElse: () => {"constProgress": ""},
                              );

                              String constructionProgressStatus = progress["constProgress"];

                              return InkWell(
                                onTap: () async {
                                  final locPermission = await Utils.checkLocationAndGpsPermission(context);
                                  if (!context.mounted) return;
                                  if (!locPermission) {
                                    CustomSnackHelper.errorToast(message: "Please enable location permission and GPS");
                                    return;
                                  }
                                  final result = await context.pushNamed(
                                    AppRoutesName.subProjectDetailsPage,
                                    extra: {"subProjectData": subProjectData, "projectData": widget.projectData},
                                  );

                                  if (result == true) {
                                    if (!context.mounted) return;
                                    context.read<SubProjectCubit>().fetchSubProjects(
                                      projectId: widget.projectData.projectId!,
                                    );
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: Column(
                                    spacing: 4.0,
                                    children: [
                                      Card(
                                        margin: EdgeInsets.zero,
                                        color:
                                            // (subProjectData.syncGlobalStatus == 1 &&
                                            //     subProjectData.syncLocalStatus == 1)
                                            subProjectData.syncGlobalStatus == 1
                                            ? AppColors.syncColor
                                            : subProjectData.syncLocalStatus == 1
                                            ? AppColors.unSyncColor
                                            : AppColors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(0.0)),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(left: 8.0),
                                                    child: Text(
                                                      subProjectData.subProjectName ?? "",
                                                      style: AppTextStyle.ts16RB,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.all(6.0),
                                                  decoration: BoxDecoration(color: AppColors.red),
                                                  child: Text(
                                                    "${subProjectData.subProjectId}",
                                                    style: AppTextStyle.ts14RW,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 4.0),
                                            Container(width: double.infinity, height: 1, color: Colors.grey.shade300),
                                            IntrinsicHeight(
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Padding(
                                                      padding: EdgeInsetsGeometry.all(8.0),
                                                      child: Text(
                                                        "Wings: ${subProjectData.wings}",
                                                        style: AppTextStyle.ts12RB.copyWith(color: Colors.black54),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(width: 1, color: Colors.grey.shade300),
                                                  Expanded(
                                                    child: Padding(
                                                      padding: EdgeInsetsGeometry.all(8.0),
                                                      child: Text(
                                                        "Storey: ${subProjectData.storey}",
                                                        style: AppTextStyle.ts12RB.copyWith(color: Colors.black54),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(width: 1, color: Colors.grey.shade300),
                                                  Expanded(
                                                    child: Padding(
                                                      padding: EdgeInsetsGeometry.all(8.0),
                                                      child: Text(
                                                        "Flats Per Floor: ${subProjectData.flatsPerFloor}",
                                                        style: AppTextStyle.ts12RB.copyWith(color: Colors.black54),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(width: double.infinity, height: 1, color: Colors.grey.shade300),
                                            SizedBox(height: 4.0),
                                            Padding(
                                              padding: EdgeInsetsGeometry.all(8.0),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      constructionProgressStatus,
                                                      style: AppTextStyle.ts14RB.copyWith(color: Colors.black54),
                                                    ),
                                                  ),
                                                  Text(
                                                    "(DOS: ${DateFormat('MMM yyyy').format(Utils.tryParseDate(subProjectData.dos!)!)})",
                                                    style: AppTextStyle.ts14RB.copyWith(color: Colors.black54),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (subProjectData.assignedNewPrj == 1)
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: double.infinity,
                                                    height: 2,
                                                    color: Colors.grey.shade300,
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      CutsomAlertDialogues.customDialog(
                                                        context: context,
                                                        message: "Are you sure you want to DELETE, it cannot be undo",
                                                        actionsWidget: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(context);
                                                            },
                                                            child: Text("CANCEL", style: AppTextStyle.ts16MB),
                                                          ),
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(context);
                                                              context.read<SubProjectCubit>().deleteSubProject(
                                                                subprojectId: subProjectData.subProjectId!,
                                                                qtrId: subProjectData.qtrId!,
                                                                index: index,
                                                              );
                                                            },
                                                            child: Text("OK", style: AppTextStyle.ts16MB),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                    child: Container(
                                                      margin: EdgeInsets.all(4.0),
                                                      padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        border: Border.all(color: AppColors.greyLite),
                                                        borderRadius: BorderRadius.circular(4.0),
                                                      ),
                                                      child: Text(
                                                        "Delete",
                                                        style: AppTextStyle.ts14MB.copyWith(color: AppColors.red),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ),
                                      // subProjectData.errMsg != null && flats[index].dataFilled == 0
                                      // (subProjectData.errMsg != null &&
                                      //         subProjectData.errMsg!.isNotEmpty &&
                                      //         flats[index].dataFilled == 0)
                                      (subProjectData.errMsg != null && subProjectData.errMsg!.isNotEmpty)
                                          ? Card(
                                              margin: EdgeInsets.zero,
                                              shape: RoundedRectangleBorder(),
                                              color:
                                                  (subProjectData.syncGlobalStatus == 1 &&
                                                      subProjectData.syncLocalStatus == 1)
                                                  ? AppColors.syncColor
                                                  : subProjectData.syncLocalStatus == 1
                                                  ? AppColors.unSyncColor
                                                  : AppColors.white,
                                              child: Padding(
                                                padding: const EdgeInsets.all(4.0),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      subProjectData.errMsg ?? "",
                                                      style: AppTextStyle.ts12MB.copyWith(color: AppColors.red),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : SizedBox(),
                                    ],
                                  ),
                                ),
                              );
                            },
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
}
