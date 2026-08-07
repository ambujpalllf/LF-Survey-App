import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lf_survey/app_popups/cutsom_alert_dialogues.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_dimens.dart';
import 'package:lf_survey/constants/app_images.dart';
import 'package:lf_survey/constants/app_text_style.dart';
import 'package:lf_survey/constants/snackbar_helper.dart';
import 'package:lf_survey/constants/utils.dart';
import 'package:lf_survey/cubit/residential/project/project_cubit.dart';
import 'package:lf_survey/cubit/residential/project/project_state.dart';
import 'package:lf_survey/model/db_model/residential/new_project_entity.dart';
import 'package:lf_survey/model/db_model/residential/new_sub_project_entity.dart';
import 'package:lf_survey/model/db_model/residential/project_entity.dart';
import 'package:lf_survey/model/db_model/residential/reject_reason_model.dart';
import 'package:lf_survey/model/db_model/residential/sub_prj_entity.dart';
import 'package:lf_survey/routes/app_routes_name.dart';
import 'package:lf_survey/services/notification_services.dart';
import 'package:lf_survey/widgets/custom_app_bar.dart';
import 'package:lf_survey/widgets/custom_elevated_btn.dart';
import 'package:lf_survey/widgets/custom_textform_field.dart';

class ProjectPage extends StatefulWidget {
  const ProjectPage({super.key});

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  NotificationServices notificationServices = NotificationServices();
  final FocusNode searchFocusNode = FocusNode();
  bool isFocused = false;
  bool isLoading = false;
  bool applyFilter = false;
  List<ProjectEntity> projects = [];
  List<SubProjectEntity> subProjects = [];
  List<NewProjectEntity> newProjects = [];
  List<NewSubProjectEntity> newSubProjects = [];
  List<ProjectEntity> filterProjects = [];
  List<ProjectEntity> searchProjects = [];
  Map<int, int> totalUnsoldFlats = {};
  final List<String> popupMenuItems = [
    'Download',
    'Download Assigned New Project',
    'Image Sync',
    'Report',
    'Help',
    'Local UnSync',
    'Clear DB',
    'Refresh Data',
    'Download Drop-down Data',
    'Add New Project',
    'Download New Projects',
  ];
  TextEditingController searchC = TextEditingController();
  List<RejectDatum> rejectData = [];
  late ReceivePort _receivePort;
  @override
  void initState() {
    super.initState();
    context.read<ProjectCubit>().getProject();
    context.read<ProjectCubit>().downloadProjectSpinner();
    searchFocusNode.addListener(() {
      setState(() {
        isFocused = searchFocusNode.hasFocus;
      });
    });
    initializeFirebaseMessaging();
    _receivePort = ReceivePort();
    IsolateNameServer.registerPortWithName(_receivePort.sendPort, "project_update");
    _receivePort.listen((message) {
      context.read<ProjectCubit>().getProject();
    });
  }

  void initializeFirebaseMessaging() {
    notificationServices.foregroundMessage();
    notificationServices.firebaseInit(context);
    // notificationServices.setUpInteractMessage(context);
    notificationServices.isTokenRefresh();
  }

  @override
  void dispose() {
    super.dispose();
    searchC.dispose();
    searchFocusNode.dispose();
    IsolateNameServer.removePortNameMapping('project_update');
    _receivePort.close();
  }

  @override
  Widget build(BuildContext context) {
    ProjectCubit projectCubit = context.read<ProjectCubit>();
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: CustomAppBar(
        titleWidget: BlocBuilder<ProjectCubit, ProjectState>(
          builder: (context, state) {
            return Text("Project (${searchProjects.length})", style: AppTextStyle.ts18BW);
          },
        ),
        actions: [
          InkWell(
            onTap: () {
              if (searchProjects.isNotEmpty) {
                context.push(
                  AppRoutesName.locationViewPage,
                  extra: {"resiPrjects": searchProjects, "cProjects": null, "type": "resi"},
                );
              } else {
                CustomSnackHelper.errorToast(message: "No project available to show in the map");
              }
            },
            child: Image.asset(AppImages.gMapImg, color: AppColors.red, width: 25, fit: BoxFit.contain),
          ),
          IconButton(
            onPressed: () async {
              await context.pushNamed(AppRoutesName.filterPage);
              projectCubit.applyFilter(projects: projects);
            },
            icon: BlocBuilder<ProjectCubit, ProjectState>(
              builder: (context, state) {
                return Icon(applyFilter ? Icons.filter_alt : Icons.filter_alt_outlined, size: 30, color: AppColors.red);
              },
            ),
          ),
          PopupMenuButton<String>(
            color: AppColors.white,
            icon: Icon(Icons.more_vert, color: AppColors.red, size: 28),
            onSelected: (String value) async {
              switch (value) {
                case 'Download':
                  await context.pushNamed(AppRoutesName.downloadPage, extra: {"appBarTitle": "Download"});
                  projectCubit.getProject();
                  break;
                case 'Download Assigned New Project':
                  projectCubit.downloadAssignNewProject(locationIds: "-1");
                  break;
                case 'Image Sync':
                  context.pushNamed(
                    AppRoutesName.imageListPage,
                    extra: {"projectId": 0, "subProjectId": 0, "resident": 1, "commercial": 0},
                  );
                  break;
                case 'Report':
                  context.pushNamed(AppRoutesName.reportPage);
                  break;
                case 'Help':
                  context.pushNamed(AppRoutesName.helpPage, extra: {"projectType": "resi"});
                  break;
                case 'Local UnSync':
                  localSyncCount(
                    projects: projects,
                    subProjects: subProjects,
                    newPrj: newProjects,
                    newSubPrj: newSubProjects,
                  );
                  break;
                case 'Clear DB':
                  showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        actionsPadding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(),
                        title: Text("Clear Local Data", style: AppTextStyle.ts18MB),
                        content: Text("Are you sure ? you want to clear DB.", style: AppTextStyle.ts14RB),
                        actions: [
                          TextButton(
                            onPressed: () {
                              context.pop();
                            },
                            child: Text("Cancel", style: AppTextStyle.ts14BB),
                          ),
                          TextButton(
                            onPressed: () {
                              context.pop();
                              projectCubit.clearDb();
                            },
                            child: Text("Yes", style: AppTextStyle.ts14BB.copyWith(color: AppColors.red)),
                          ),
                        ],
                      );
                    },
                  );
                  break;
                case 'Refresh Data':
                  projectCubit.refreshData(projects: projects, subProjects: subProjects);
                  break;
                case 'Download Drop-down Data':
                  projectCubit.downloadProjectSpinner(isDownload: true);
                  break;
                case 'Add New Project':
                  context.pushNamed(AppRoutesName.newProjectsPage);
                  break;
                case 'Download New Projects':
                  projectCubit.downloadNewProjects();
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return popupMenuItems.map((String item) {
                return PopupMenuItem<String>(value: item, child: Text(item));
              }).toList();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 8.0, vertical: 16.0),
          child: Column(
            spacing: AppDimens.spacingMD,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.shade300, blurRadius: 8, spreadRadius: 1, offset: const Offset(0, 3)),
                  ],
                ),
                child: CustomTextformField(
                  focusNode: searchFocusNode,
                  controller: searchC,
                  filled: true,
                  fillColor: AppColors.white,
                  hintText: isFocused ? "Project Id, Project Name, Builder Name, Road Name" : null,
                  hintTextColor: Colors.grey,
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  suffixIcon: isFocused
                      ? IconButton(
                          onPressed: () {
                            searchC.clear();
                            searchFocusNode.unfocus();
                            projectCubit.searchProject(
                              query: "",
                              projects: projects,
                              filteredProjects: filterProjects,
                              applyFilter: applyFilter,
                            );
                          },
                          icon: Icon(Icons.close, color: Colors.grey),
                        )
                      : null,
                  onChanged: (value) {
                    projectCubit.searchProject(
                      query: value,
                      projects: projects,
                      filteredProjects: filterProjects,
                      applyFilter: applyFilter,
                    );
                  },
                ),
              ),
              Expanded(
                child: BlocConsumer<ProjectCubit, ProjectState>(
                  listener: (context, state) {
                    if (state is ErrorState) {
                      CustomSnackHelper.customToastMsg(
                        context: context,
                        message: state.message,
                        bgColor: AppColors.white,
                        textColor: AppColors.black,
                      );
                      isLoading = false;
                    } else if (state is SuccessState) {
                      CustomSnackHelper.customToastMsg(
                        context: context,
                        message: state.message,
                        bgColor: AppColors.white,
                        textColor: AppColors.black,
                      );
                      isLoading = false;
                    } else if (state is LoadedState) {
                      projects.clear();
                      subProjects.clear();
                      filterProjects.clear();
                      searchProjects.clear();
                      totalUnsoldFlats.clear();
                      filterProjects.addAll(state.projectData);
                      searchProjects.addAll(state.projectData);
                      projects.addAll(state.projectData);
                      subProjects.addAll(state.subProjects);
                      totalUnsoldFlats.addAll(state.totalUnsoldflats);
                      isLoading = false;
                    } else if (state is FilterState) {
                      filterProjects.clear();
                      searchProjects.clear();
                      filterProjects.addAll(state.projectData);
                      searchProjects.addAll(state.projectData);
                      isLoading = false;
                      applyFilter = state.applyFilter;
                    } else if (state is SearchState) {
                      searchProjects.clear();
                      searchProjects.addAll(state.projectData);
                      isLoading = false;
                      applyFilter = state.applyFilter;
                    } else if (state is ClearDbState) {
                      filterProjects.clear();
                      searchProjects.clear();
                      projects.clear();
                      subProjects.clear();
                      newProjects.clear();
                      newSubProjects.clear();
                      isLoading = false;
                    } else if (state is DeleteProject) {
                      searchProjects.removeAt(state.index);
                      isLoading = false;
                    } else if (state is RejectState) {
                      rejectData.clear();
                      rejectData.addAll(state.rejectData);
                      isLoading = false;
                    } else if (state is LoadingState) {
                      isLoading = true;
                    } else {
                      isLoading = false;
                    }
                  },
                  builder: (context, state) {
                    return Stack(
                      children: [
                        searchProjects.isEmpty
                            ? Center(child: Text("No Data Found", style: AppTextStyle.ts14RB))
                            : ListView.builder(
                                itemCount: searchProjects.length,
                                itemBuilder: (_, index) {
                                  var projectData = searchProjects[index];
                                  List<SubProjectEntity> perPrjSubPrj = subProjects
                                      .where((i) => i.projectId == projectData.projectId)
                                      .toList();
                                  List<SubProjectEntity> perPrjSyncSubPrj = subProjects
                                      .where((i) => i.projectId == projectData.projectId && i.syncGlobalStatus == 1)
                                      .toList();

                                  List<SubProjectEntity> perPrjUnsyncSubPrj = subProjects
                                      .where((i) => i.projectId == projectData.projectId && i.syncGlobalStatus == 0)
                                      .toList();
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: InkWell(
                                      onTap: () async {
                                        await context.pushNamed(
                                          AppRoutesName.projectDetailsPage,
                                          extra: {"projectData": projectData},
                                        );
                                        if (!context.mounted) return;
                                        context.read<ProjectCubit>().getProject();
                                      },
                                      child: Card(
                                        margin: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(4.0)),
                                        color: (projectData.syncGlobalStatus == 1 && perPrjUnsyncSubPrj.isEmpty)
                                            ? AppColors.syncColor
                                            : projectData.syncLocalStatus == 1
                                            ? AppColors.unSyncColor
                                            : AppColors.white,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            spacing: 4.0,
                                            children: [
                                              Row(
                                                spacing: 20,
                                                children: [
                                                  Flexible(
                                                    child: Row(
                                                      spacing: 10,
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            projectData.projectName ?? "",
                                                            style: AppTextStyle.ts14MB,
                                                          ),
                                                        ),
                                                        projectData.rejectId != 0
                                                            ? GestureDetector(
                                                                onTap: () {
                                                                  projectCubit.getRejectReason(
                                                                    projectId: projectData.projectId!,
                                                                    qtrId: projectData.qtrId!,
                                                                  );
                                                                  CutsomAlertDialogues.rejectDetailsDialogue(
                                                                    context: context,
                                                                  );
                                                                },
                                                                child: Icon(
                                                                  Icons.warning_rounded,
                                                                  size: 35,
                                                                  color: Colors.amber,
                                                                ),
                                                              )
                                                            : SizedBox.shrink(),
                                                      ],
                                                    ),
                                                  ),
                                                  Text("${projectData.projectId}", style: AppTextStyle.ts14MB),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Flexible(
                                                    child: RichText(
                                                      text: TextSpan(
                                                        text: "Builder: ",
                                                        style: AppTextStyle.ts12RB.copyWith(color: Colors.grey),
                                                        children: [
                                                          TextSpan(
                                                            text: projectData.builderName ?? "",
                                                            style: AppTextStyle.ts12RB.copyWith(color: Colors.grey),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  if (projectData.assignedNewPrj == 1)
                                                    Image.asset(AppImages.newImg, height: 30),
                                                ],
                                              ),

                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                spacing: 20,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      projectData.projectAddress ?? "",
                                                      style: AppTextStyle.ts12RB.copyWith(color: Colors.grey),
                                                    ),
                                                  ),
                                                  projectData.rejectId != 0
                                                      ? CustomElevatedButton(
                                                          elevation: 0,
                                                          backgroundColor: projectData.fixedBy != 0
                                                              ? AppColors.greyLite
                                                              : AppColors.primaryColor,
                                                          borderRadius: 100,
                                                          text: projectData.fixedBy != 0 ? "Fixed" : "Fix",
                                                          onPressed: projectData.fixedBy != 0
                                                              ? () {}
                                                              : () {
                                                                  if (perPrjUnsyncSubPrj.isNotEmpty) {
                                                                    CustomSnackHelper.customToastMsg(
                                                                      context: context,
                                                                      message: "Please sync the project to fix it",
                                                                    );
                                                                  } else {
                                                                    projectCubit.fixMethod(
                                                                      projectData: projectData,
                                                                      subProjects: perPrjUnsyncSubPrj,
                                                                      context: context,
                                                                    );
                                                                  }
                                                                },
                                                        )
                                                      : SizedBox.shrink(),
                                                ],
                                              ),
                                              Text(
                                                projectData.roadName ?? "",
                                                style: AppTextStyle.ts12RB.copyWith(color: Colors.grey),
                                              ),
                                              if (projectData.syncGlobalStatus == 1 && perPrjUnsyncSubPrj.isEmpty)
                                                Align(
                                                  alignment: Alignment.topRight,
                                                  child: Text(
                                                    "Total Increments: ${projectData.projectUnsold! - (totalUnsoldFlats[projectData.projectId] ?? 0)}",
                                                    style: AppTextStyle.ts14MB.copyWith(color: AppColors.red),
                                                  ),
                                                ),
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: RichText(
                                                      text: TextSpan(
                                                        text: "Sub-Project Sync Count : ",
                                                        style: AppTextStyle.ts12RB,
                                                        children: [
                                                          TextSpan(
                                                            text: "${perPrjSyncSubPrj.length}",
                                                            style: AppTextStyle.ts12BB.copyWith(
                                                              color: perPrjSyncSubPrj.length == perPrjSubPrj.length
                                                                  ? Color(0xff0000FF)
                                                                  : AppColors.red,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text: "/",
                                                            style: AppTextStyle.ts12MB.copyWith(
                                                              color: perPrjSyncSubPrj.length == perPrjSubPrj.length
                                                                  ? Color(0xff0000FF)
                                                                  : AppColors.red,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text: "${perPrjSubPrj.length}",
                                                            style: AppTextStyle.ts12BB.copyWith(
                                                              color: Color(0xff0000FF),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 20),
                                                  RichText(
                                                    text: TextSpan(
                                                      text: "Delete ",
                                                      style: AppTextStyle.ts14BB.copyWith(color: AppColors.red),
                                                      recognizer: TapGestureRecognizer()
                                                        ..onTap = () {
                                                          showDialog(
                                                            context: context,
                                                            builder: (_) {
                                                              return AlertDialog(
                                                                shape: RoundedRectangleBorder(),
                                                                actionsPadding: EdgeInsets.zero,
                                                                alignment: Alignment.center,
                                                                content: Text(
                                                                  "Are you sure you want to Delete ?",
                                                                  style: AppTextStyle.ts16RB,
                                                                ),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed: () {
                                                                      context.pop();
                                                                    },
                                                                    child: Text(
                                                                      "No",
                                                                      style: AppTextStyle.ts14BB.copyWith(
                                                                        color: AppColors.primaryColor,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  TextButton(
                                                                    onPressed: () {
                                                                      context.pop();
                                                                      projectCubit.deleteProject(
                                                                        projectId: projectData.projectId!,
                                                                        index: index,
                                                                      );
                                                                    },
                                                                    child: Text(
                                                                      "Yes",
                                                                      style: AppTextStyle.ts14BB.copyWith(
                                                                        color: AppColors.primaryColor,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          );
                                                        },
                                                      children: [
                                                        TextSpan(
                                                          text:
                                                              "(DOS : ${DateFormat('MMM yyyy').format(Utils.tryParseDate(projectData.dos!)!)})",
                                                          style: AppTextStyle.ts12RB,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                        isLoading ? Center(child: CircularProgressIndicator(color: AppColors.red)) : SizedBox.shrink(),
                      ],
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

  void localSyncCount({
    required List<ProjectEntity> projects,
    required List<SubProjectEntity> subProjects,
    required List<NewProjectEntity> newPrj,
    required List<NewSubProjectEntity> newSubPrj,
  }) {
    List<ProjectEntity> unsyncPrj = projects.where((i) => i.syncGlobalStatus == 0).toList();
    List<SubProjectEntity> unsyncSubPrj = subProjects.where((i) => i.syncGlobalStatus == 0).toList();
    List<NewProjectEntity> unsyncNewPrj = newPrj.where((i) => i.syncGlobalStatus == 0).toList();
    List<NewSubProjectEntity> unsyncNewSubPrj = newSubPrj.where((i) => i.syncGlobalStatus == 0).toList();
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(),
          actionsPadding: EdgeInsets.zero,
          title: Text("Unsync Count", style: AppTextStyle.ts18BB),
          content: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Unsync Project Count = ${unsyncPrj.length} Unsync", style: AppTextStyle.ts14RB),
              Text("Sub-Project Count = ${unsyncSubPrj.length} Unsync", style: AppTextStyle.ts14RB),
              Text("New Project Count = ${unsyncNewPrj.length} Unsync", style: AppTextStyle.ts14RB),
              Text("New Sub-Project Count = ${unsyncNewSubPrj.length} Unsync", style: AppTextStyle.ts14RB),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: Text("OK", style: AppTextStyle.ts14BB.copyWith(color: AppColors.primaryColor)),
            ),
          ],
        );
      },
    );
  }
}
