import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lf_survey/app_popups/cutsom_alert_dialogues.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_dimens.dart';
import 'package:lf_survey/constants/app_text_style.dart';
import 'package:lf_survey/constants/snackbar_helper.dart';
import 'package:lf_survey/cubit/commercial/c_new_sub_projects/c_new_sub_projects_cubit.dart';
import 'package:lf_survey/cubit/commercial/c_new_sub_projects/c_new_sub_projects_state.dart';
import 'package:lf_survey/model/db_model/commercial/c_new_project_entity.dart';
import 'package:lf_survey/model/db_model/commercial/c_new_sub_project_entity.dart';
import 'package:lf_survey/model/db_model/commercial/c_project_entity.dart';
import 'package:lf_survey/routes/app_routes_name.dart';
import 'package:lf_survey/widgets/custom_app_bar.dart';

class CNewSubProjectsPage extends StatefulWidget {
  final CNewProjectEntity? cNewProjectEntity;
  final CProjectEntity? project;
  const CNewSubProjectsPage({super.key, this.cNewProjectEntity, this.project});

  @override
  State<CNewSubProjectsPage> createState() => _CNewSubProjectsPageState();
}

class _CNewSubProjectsPageState extends State<CNewSubProjectsPage> {
  List<CNewSubProjectEntity> supProjects = [];
  late ReceivePort _receivePort;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CNewSubProjectsCubit>().getSubProjects(
        newProjectId: widget.cNewProjectEntity?.prjId,
        projectId: widget.project?.projectId,
      );
      _receivePort = ReceivePort();
      IsolateNameServer.registerPortWithName(_receivePort.sendPort, 'sync_new_sub_project');
      _receivePort.listen((message) {
        if (!mounted) return;
        context.read<CNewSubProjectsCubit>().getSubProjects(
          newProjectId: widget.cNewProjectEntity?.prjId,
          projectId: widget.project?.projectId,
        );
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    IsolateNameServer.removePortNameMapping('sync_new_sub_project');
    _receivePort.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: CustomAppBar(
        title: "New Sub Project",
        actions: [
          IconButton(
            onPressed: () {
              List<CNewSubProjectEntity> unSyncSubPrj = supProjects.where((e) => e.globalSyncStatus == 0).toList();
              if (unSyncSubPrj.isEmpty) return;
              CutsomAlertDialogues.customDialog(
                context: context,
                title: "Confirmation",
                message:
                    "Please confirm that you want to sync this sub-project. Once submitted, no further changes will be permitted.",
                actionsWidget: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("CANCEL", style: AppTextStyle.ts14RB.copyWith(color: AppColors.red)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.read<CNewSubProjectsCubit>().updateSubPrj(subProjectId: "");
                    },
                    child: Text("OK", style: AppTextStyle.ts14RB.copyWith(color: AppColors.red)),
                  ),
                ],
              );
            },
            icon: const Icon(Icons.sync, color: Colors.red),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: AppDimens.hvPadding,
          child: BlocConsumer<CNewSubProjectsCubit, CNewSubProjectsState>(
            listener: (context, state) {
              if (state is LocalDbState) {
                supProjects.clear();
                supProjects.addAll(state.subProjects);
              } else if (state is ErrorState) {
                CustomSnackHelper.customToastMsg(
                  context: context,
                  message: state.message,
                  bgColor: AppColors.white,
                  textColor: AppColors.black,
                );
              } else if (state is UpdateState) {
                supProjects[state.index] = state.subProject;
              } else if (state is DeleteState) {
                supProjects.removeAt(state.index);
              }
            },
            buildWhen: (previous, current) =>
                current is LocalDbState || current is DeleteState || current is UpdateState,
            builder: (context, state) {
              return ListView.builder(
                itemCount: supProjects.length,
                itemBuilder: (context, index) {
                  var subPrj = supProjects[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: GestureDetector(
                      onTap: () async {
                        await context.pushNamed(
                          AppRoutesName.cAddNewSubProjectPage,
                          extra: {"newProjectData": widget.cNewProjectEntity, "newSubProject": subPrj},
                        );
                        if (!context.mounted) return;
                        context.read<CNewSubProjectsCubit>().getSubProjects(
                          newProjectId: widget.cNewProjectEntity?.prjId,
                          projectId: widget.project?.projectId,
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(),
                        margin: EdgeInsets.zero,
                        color: subPrj.globalSyncStatus == 1 ? AppColors.syncColor : AppColors.unSyncColor,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            spacing: 4.0,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                // "(DOS: ${DateFormat("MMM yyyy").format(Utils.tryParseDate(subPrj.dos!)!)})"
                                "(DOS: ${subPrj.dos})",
                              ),
                              Text(subPrj.subPrjName ?? "", style: AppTextStyle.ts14RB),
                              if (subPrj.globalSyncStatus == 0)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton(
                                      style: ButtonStyle(
                                        padding: WidgetStateProperty.all(EdgeInsets.zero),
                                        minimumSize: WidgetStateProperty.all(Size.zero),
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                      onPressed: () {
                                        CutsomAlertDialogues.customDialog(
                                          context: context,
                                          title: "Confirmation",
                                          message:
                                              "Please confirm that you want to sync this sub-project. Once submitted, no further changes will be permitted.",
                                          actionsWidget: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                "CANCEL",
                                                style: AppTextStyle.ts14RB.copyWith(color: AppColors.red),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                context.read<CNewSubProjectsCubit>().updateSubPrj(
                                                  subProjectId: subPrj.subPrjId ?? "",
                                                );
                                              },
                                              child: Text(
                                                "OK",
                                                style: AppTextStyle.ts14RB.copyWith(color: AppColors.red),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                      child: Text("Submit", style: AppTextStyle.ts14RB.copyWith(color: AppColors.red)),
                                    ),
                                    GestureDetector(
                                      onTap: () => CutsomAlertDialogues.deleteDialogue(
                                        context: context,
                                        onDelete: () {
                                          Navigator.pop(context);
                                          context.read<CNewSubProjectsCubit>().deleteSubProject(
                                            subProjectId: subPrj.subPrjId,
                                            index: index,
                                          );
                                        },
                                      ),
                                      child: Container(
                                        margin: EdgeInsets.zero,
                                        padding: EdgeInsetsDirectional.symmetric(vertical: 2.0, horizontal: 4.0),
                                        decoration: BoxDecoration(
                                          color: AppColors.white,
                                          boxShadow: [BoxShadow(color: AppColors.greyLite, offset: Offset(2, 2))],
                                        ),
                                        child: Text(
                                          "Delete",
                                          style: AppTextStyle.ts12RB.copyWith(color: AppColors.red),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              if (subPrj.errorMessage != null && subPrj.errorMessage != "")
                                Text(
                                  "Error: ${subPrj.errorMessage}",
                                  style: AppTextStyle.ts14RB.copyWith(color: AppColors.red),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(100)),
        onPressed: () async {
          await context.pushNamed(
            AppRoutesName.cAddNewSubProjectPage,
            extra: {"newProjectData": widget.cNewProjectEntity, "projectData": widget.project},
          );
          if (!context.mounted) return;
          context.read<CNewSubProjectsCubit>().getSubProjects(
            newProjectId: widget.cNewProjectEntity?.prjId,
            projectId: widget.project?.projectId,
          );
        },
        child: const Icon(Icons.add, size: 25, color: Colors.white),
      ),
    );
  }
}
