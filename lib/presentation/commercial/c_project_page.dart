import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_dimens.dart';
import 'package:lf_survey/constants/app_text_style.dart';
import 'package:lf_survey/constants/snackbar_helper.dart';
import 'package:lf_survey/constants/utils.dart';
import 'package:lf_survey/cubit/commercial/c_project/c_project_cubit.dart';
import 'package:lf_survey/cubit/commercial/c_project/c_project_state.dart';
import 'package:lf_survey/database/db_helper.dart';
import 'package:lf_survey/model/db_model/commercial/c_project_entity.dart';
import 'package:lf_survey/model/db_model/commercial/c_sub_project_entity.dart';
import 'package:lf_survey/routes/app_routes_name.dart';
import 'package:lf_survey/services/work_manager_task_register.dart';
import 'package:lf_survey/widgets/custom_app_bar.dart';
import 'package:lf_survey/widgets/custom_textform_field.dart';

class CProjectPage extends StatefulWidget {
  const CProjectPage({super.key});

  @override
  State<CProjectPage> createState() => _CProjectPageState();
}

class _CProjectPageState extends State<CProjectPage> {
  final List<String> popupMenuItems = [
    'Map',
    'Download',
    'Help',
    'Clear DB',
    'Add New Project',
    'Download New Projects',
    'Sync Projects',
  ];
  TextEditingController searchC = TextEditingController();
  FocusNode searchFN = FocusNode();
  bool isFocused = false;
  bool isActiveFilter = false;
  List<CProjectEntity> projects = [];
  List<CSubProjectEntity> subProjects = [];
  List<CProjectEntity> searchedProjects = [];
  List<CProjectEntity> filterProjects = [];
  late ReceivePort _receivePort;
  @override
  void initState() {
    super.initState();
    searchFN.addListener(() {
      setState(() {
        isFocused = searchFN.hasFocus;
      });
    });
    context.read<CProjectCubit>().fetchData();
    _receivePort = ReceivePort();
    IsolateNameServer.registerPortWithName(_receivePort.sendPort, 'c_sync_project');
    _receivePort.listen((message) {
      context.read<CProjectCubit>().fetchData();
    });
  }

  @override
  void dispose() {
    super.dispose();
    searchFN.dispose();
    IsolateNameServer.removePortNameMapping('c_sync_project');
    _receivePort.close();
  }

  @override
  Widget build(BuildContext context) {
    CProjectCubit projectCubit = context.read<CProjectCubit>();
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: CustomAppBar(
        titleWidget: BlocBuilder<CProjectCubit, CProjectState>(
          builder: (context, state) {
            return Text("Project (${searchedProjects.length})", style: AppTextStyle.ts18BW);
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.pushNamed(
                AppRoutesName.imageListPage,
                extra: {"projectId": 0, "subProjectId": 0, "resident": 0, "commercial": 1},
              );
            },
            icon: Icon(Icons.sync, color: AppColors.red),
          ),
          BlocBuilder<CProjectCubit, CProjectState>(
            builder: (context, state) {
              return IconButton(
                onPressed: () async {
                  await context.pushNamed(AppRoutesName.cFilterPage);
                  projectCubit.applyFilter(projects: projects);
                },
                icon: Icon(isActiveFilter ? Icons.filter_alt : Icons.filter_alt_outlined, color: AppColors.red),
              );
            },
          ),
          PopupMenuButton<String>(
            iconColor: AppColors.red,
            color: AppColors.white,
            onSelected: (value) async {
              switch (value) {
                case 'Map':
                  if (searchedProjects.isNotEmpty) {
                    context.push(
                      AppRoutesName.locationViewPage,
                      extra: {"resiPrjects": null, "cProjects": searchedProjects, "type": "commercial"},
                    );
                  } else {
                    CustomSnackHelper.errorToast(message: "No project available to show in the map");
                  }
                case 'Download':
                  await context.pushNamed(AppRoutesName.cDownloadPage, extra: {"appBarTitle": "Download"});
                  if (!context.mounted) return;
                  projectCubit.fetchData();
                  break;
                case 'Add New Project':
                  context.pushNamed(AppRoutesName.cNewProjectPage);
                  break;
                case 'Download New Projects':
                  projectCubit.downloadNewPrj();
                  break;
                case 'Help':
                  context.pushNamed(AppRoutesName.helpPage, extra: {"projectType": "comm"});
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
                case 'Sync Projects':
                  final List<CProjectEntity> unSyncProjects = await DBHelper.cGetUnsyncProjects();
                  if (unSyncProjects.isEmpty) {
                    if (!context.mounted) return;
                    CustomSnackHelper.customToastMsg(
                      context: context,
                      message: "All projects are already synced. There are no pending projects to upload.",
                      bgColor: AppColors.white,
                      textColor: AppColors.black,
                    );
                    break;
                  }
                  WorkManagerTaskRegister.cSyncUpdateProject(projectId: 0);
                  break;
                default:
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
          padding: AppDimens.hvPadding,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.shade300, blurRadius: 8, spreadRadius: 1, offset: const Offset(0, 3)),
                  ],
                ),
                child: CustomTextformField(
                  focusNode: searchFN,
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
                            searchFN.unfocus();
                            projectCubit.searchProject(
                              projects: projects,
                              query: searchC.text,
                              filterProjects: filterProjects,
                              isActiveFilter: isActiveFilter,
                            );
                          },
                          icon: Icon(Icons.close, color: Colors.grey),
                        )
                      : null,
                  onChanged: (value) {
                    projectCubit.searchProject(
                      projects: projects,
                      query: value,
                      filterProjects: filterProjects,
                      isActiveFilter: isActiveFilter,
                    );
                  },
                ),
              ),
              const SizedBox(height: 8.0),
              Expanded(
                child: BlocConsumer<CProjectCubit, CProjectState>(
                  listener: (context, state) {
                    if (state is LoadedState) {
                      projects.clear();
                      subProjects.clear();
                      searchedProjects.clear();
                      projects.addAll(state.projects);
                      subProjects.addAll(state.subProjects);
                      searchedProjects.addAll(state.projects);
                      isActiveFilter = false;
                    } else if (state is SearchState) {
                      searchedProjects.clear();
                      searchedProjects.addAll(state.projects);
                      isActiveFilter = state.isActiveFilter;
                    } else if (state is ClearDbState) {
                      isActiveFilter = false;
                      projects.clear();
                      searchedProjects.clear();
                    } else if (state is ErrorState) {
                      isActiveFilter = false;
                      CustomSnackHelper.customToastMsg(
                        context: context,
                        message: state.message,
                        bgColor: AppColors.white,
                        textColor: AppColors.black,
                      );
                    } else if (state is SuccessState) {
                      isActiveFilter = false;
                      CustomSnackHelper.customToastMsg(
                        context: context,
                        message: state.message,
                        bgColor: AppColors.white,
                        textColor: AppColors.black,
                      );
                    } else if (state is FilterState) {
                      searchedProjects.clear();
                      filterProjects.clear();
                      filterProjects.addAll(state.projects);
                      searchedProjects.addAll(state.projects);
                      isActiveFilter = state.applyFilter;
                    }
                  },
                  builder: (context, state) {
                    if (state is LoadingState) {
                      return Center(child: CircularProgressIndicator(color: AppColors.red));
                    }
                    return searchedProjects.isEmpty
                        ? Center(child: Text("No projects found !", style: AppTextStyle.ts14MB))
                        : ListView.builder(
                            itemCount: searchedProjects.length,
                            itemBuilder: (context, index) {
                              var prjData = searchedProjects[index];
                              final subPrjs = subProjects.where((e) => e.projectId == prjData.projectId).toList();
                              final syncSubPrjs = subProjects
                                  .where((e) => e.projectId == prjData.projectId && e.syncGlobalStatus == 1)
                                  .toList();
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: GestureDetector(
                                  onTap: () {
                                    context.pushNamed(
                                      AppRoutesName.cProjectDetailsPage,
                                      extra: {"projectData": prjData},
                                    );
                                  },
                                  child: Card(
                                    margin: EdgeInsets.zero,
                                    color: prjData.syncLocalStatus == 1 && prjData.syncGlobalStatus == 0
                                        ? AppColors.unSyncColor
                                        : prjData.syncGlobalStatus == 1
                                        ? AppColors.syncColor
                                        : AppColors.white,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        spacing: 4.0,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            spacing: 8.0,
                                            children: [
                                              Expanded(
                                                child: Text(prjData.projectName ?? "", style: AppTextStyle.ts14MB),
                                              ),
                                              Text("${prjData.projectId}", style: AppTextStyle.ts14MB),
                                            ],
                                          ),
                                          Text("Builder: ${prjData.builderName}", style: AppTextStyle.ts12RB),
                                          Text(prjData.projectAddress ?? "", style: AppTextStyle.ts12RB),
                                          Text(prjData.roadName ?? "", style: AppTextStyle.ts12RB),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              RichText(
                                                text: TextSpan(
                                                  text: "SubProject Sync Count: ",
                                                  style: AppTextStyle.ts12RB,
                                                  children: [
                                                    TextSpan(
                                                      text: " ${syncSubPrjs.length}",
                                                      style: AppTextStyle.ts12BB.copyWith(
                                                        color: syncSubPrjs.length == subPrjs.length
                                                            ? Colors.blueAccent
                                                            : AppColors.red,
                                                      ),
                                                    ),
                                                    TextSpan(text: "/", style: AppTextStyle.ts12MB),
                                                    TextSpan(
                                                      text: "${subPrjs.length}",
                                                      style: AppTextStyle.ts12BB.copyWith(color: Colors.blueAccent),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                "(DOS : ${DateFormat('MMM yyyy').format(Utils.tryParseDate(prjData.dos!)!)})",
                                                style: AppTextStyle.ts12RB,
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
