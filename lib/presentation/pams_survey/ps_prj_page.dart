import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:go_router/go_router.dart';
import 'package:lf_survey/app_popups/cutsom_alert_dialogues.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_dimens.dart';
import 'package:lf_survey/constants/app_text_style.dart';
import 'package:lf_survey/constants/snackbar_helper.dart';
import 'package:lf_survey/constants/storage_function.dart';
import 'package:lf_survey/constants/utils.dart';
import 'package:lf_survey/cubit/pams_survey/ps_project/ps_project_cubit.dart';
import 'package:lf_survey/cubit/pams_survey/ps_project/ps_project_state.dart';
import 'package:lf_survey/model/construction_monitoring/cm_wing_response.dart';
import 'package:lf_survey/model/pams_survey/land_response.dart';
import 'package:lf_survey/model/pams_survey/ps_photo_response.dart';
import 'package:lf_survey/model/pams_survey/ps_prj_response.dart';
import 'package:lf_survey/routes/app_routes_name.dart';
import 'package:lf_survey/services/foreground_task_handler.dart';
import 'package:lf_survey/widgets/custom_app_bar.dart';
import 'package:lf_survey/widgets/custom_textform_field.dart';

class PsPrjPage extends StatefulWidget {
  const PsPrjPage({super.key});

  @override
  State<PsPrjPage> createState() => _PsPrjPageState();
}

class _PsPrjPageState extends State<PsPrjPage> {
  final FocusNode searchFocusNode = FocusNode();
  bool isFocused = false;
  TextEditingController searchC = TextEditingController();
  List<PsPrjDatum> projects = [];
  List<PsPhotoDatum> photos = [];
  List<PsPrjDatum> filterProjects = [];
  List<PsLandDatum> psLand = [];
  List<WingData> wings = [];

  late ReceivePort _receivePort;
  @override
  void initState() {
    super.initState();
    searchFocusNode.addListener(() {
      setState(() {
        isFocused = searchFocusNode.hasFocus;
      });
    });
    if (!kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        foregroundTask();
      });
    }
    context.read<PsProjectCubit>().getProjects();
    _receivePort = ReceivePort();
    IsolateNameServer.registerPortWithName(_receivePort.sendPort, "sync_ps_prj_tech_info");
    _receivePort.listen((message) {
      if (!mounted) return;
      context.read<PsProjectCubit>().getProjects();
    });
  }

  void foregroundTask() async {
    bool isLocationPermission = await Utils.checkLocationAndGpsPermission(context);
    if (isLocationPermission == true) {
      if (!mounted) return;
      ForegroundTaskHandler.foregroundServiceInit(context);
    }
  }

  @override
  void dispose() {
    searchC.dispose();
    searchFocusNode.dispose();
    IsolateNameServer.removePortNameMapping('sync_ps_prj_tech_info');
    _receivePort.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final psPrjCubit = context.read<PsProjectCubit>();
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: CustomAppBar(
        title: "Projects",
        actions: [
          IconButton(
            onPressed: () {
              String projectId = projects.map((i) => i.projectId.toString()).join(",");
              psPrjCubit.downloadProjects(projectsId: projectId);
            },
            icon: Icon(Icons.download, color: AppColors.white),
          ),
          BlocBuilder<PsProjectCubit, PsProjectState>(
            builder: (context, state) {
              bool isUnsynPrjTechInfo = psLand.any((e) => e.globalSync == 0 && e.localSync == 1);
              return IconButton(
                onPressed: isUnsynPrjTechInfo == false
                    ? () {}
                    : () {
                        psPrjCubit.syncProjects(projectId: 0);
                      },
                icon: Icon(Icons.sync, color: isUnsynPrjTechInfo ? AppColors.white : Colors.grey.shade600),
              );
            },
          ),

          PopupMenuButton<String>(
            onSelected: (String value) async {
              switch (value) {
                case 'Clear DB':
                  CutsomAlertDialogues.clearDBDialogue(
                    context: context,
                    confirm: () {
                      context.pop();
                      psPrjCubit.clearDb();
                    },
                  );
                  break;
                case 'Image Sync':
                  context.pushNamed(AppRoutesName.psImgSyncPage);
                // case 'Log Out':
                //   context.pushReplacementNamed(AppRoutesName.loginPage, extra: {"userType": "Pams"});
                //   await StorageFunction.clearStorage();
                //   break;
                // case 'Log Out':
                //   await StorageFunction.clearStorage();
                //   if (!context.mounted) return;
                //   context.go(AppRoutesName.userTypePage);
                //   break;
              }
            },
            iconColor: AppColors.white,
            surfaceTintColor: AppColors.white,
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'Clear DB',
                child: Text("Clear DB", style: AppTextStyle.ts14RB),
              ),
              PopupMenuItem<String>(
                value: 'Image Sync',
                child: Text("Image Sync", style: AppTextStyle.ts14RB),
              ),
              // PopupMenuItem<String>(
              //   value: 'Log Out',
              //   child: Text("Log Out", style: AppTextStyle.ts14RB),
              // ),
            ],
          ),
          IconButton(
            onPressed: () async {
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
                          await FlutterForegroundTask.stopService();
                          await StorageFunction.clearStorage();
                          if (!context.mounted) return;
                          context.pushReplacementNamed(AppRoutesName.loginPage, extra: {"userType": "Pams"});
                        },
                        child: Text("OK", style: AppTextStyle.ts16BB.copyWith(color: AppColors.primaryDarkColor)),
                      ),
                    ],
                  );
                },
              );
            },
            icon: Icon(Icons.logout_outlined, color: AppColors.white),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocListener<PsProjectCubit, PsProjectState>(
          listener: (context, state) {
            if (state is LocalDBState) {
              projects.clear();
              photos.clear();
              filterProjects.clear();
              psLand.clear();
              wings.clear();
              projects.addAll(state.projects);
              filterProjects.addAll(state.projects);
              photos.addAll(state.photos);
              psLand.addAll(state.land);
              wings.addAll(state.wings);
            } else if (state is DownloadedState) {
              projects.addAll(state.projects);
              filterProjects.addAll(state.projects);
            } else if (state is SearchState) {
              filterProjects.clear();
              filterProjects.addAll(state.projects);
            } else if (state is ErrorState) {
              CustomSnackHelper.customToastMsg(
                context: context,
                message: state.message,
                bgColor: AppColors.white,
                textColor: AppColors.black,
              );
            } else if (state is SuccessState) {
              CustomSnackHelper.customToastMsg(
                context: context,
                message: state.message,
                bgColor: AppColors.white,
                textColor: AppColors.black,
              );
            } else if (state is DbClearState) {
              projects.clear();
              photos.clear();
              filterProjects.clear();
              psLand.clear();
              CustomSnackHelper.customToastMsg(
                context: context,
                message: state.message,
                bgColor: AppColors.white,
                textColor: AppColors.black,
              );
            }
          },
          child: Padding(
            padding: AppDimens.hvPadding,
            child: Column(
              spacing: 12.0,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: CustomTextformField(
                    focusNode: searchFocusNode,
                    controller: searchC,
                    filled: true,
                    fillColor: AppColors.white,
                    hintText: isFocused ? "Project Id, Name,  Address" : null,
                    hintTextColor: Colors.grey,
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    suffixIcon: isFocused
                        ? IconButton(
                            onPressed: () {
                              searchC.clear();
                              searchFocusNode.unfocus();
                            },
                            icon: Icon(Icons.close, color: Colors.grey),
                          )
                        : null,
                    onChanged: (value) {
                      context.read<PsProjectCubit>().searchProject(query: value, projects: projects);
                    },
                  ),
                ),
                Expanded(
                  child: BlocBuilder<PsProjectCubit, PsProjectState>(
                    builder: (context, state) {
                      return state is LoadingState
                          ? Center(child: CircularProgressIndicator(color: AppColors.red))
                          : filterProjects.isEmpty
                          ? Center(
                              child: Column(
                                spacing: 4.0,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("No data found !", style: AppTextStyle.ts14MB),
                                  Row(
                                    spacing: 12,
                                    children: [
                                      Icon(Icons.download),
                                      Flexible(
                                        child: Text(
                                          "Click on download button for download projects",
                                          style: AppTextStyle.ts14MB,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: filterProjects.length,
                              itemBuilder: (context, index) {
                                var prjData = filterProjects[index];
                                var prjPhoto = photos.where((i) => i.projectId == prjData.projectId);
                                var prjSyncPhoto = photos.where((i) => i.projectId == prjData.projectId && i.sync == 1);
                                var prjUnSyncPhoto = photos.where(
                                  (i) => i.projectId == prjData.projectId && i.sync == 0,
                                );
                                final prjLand = psLand.firstWhere(
                                  (i) => i.projectId == prjData.projectId,
                                  orElse: () => PsLandDatum(),
                                );

                                List<WingData> projectWings = wings
                                    .where((e) => e.projectId == prjData.projectId)
                                    .toList();
                                var unSyncWings = projectWings
                                    .where((element) => element.submitStatus != true)
                                    .toList();
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Card(
                                    margin: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(4.0)),
                                    color: prjLand.localSync == 1
                                        ? AppColors.unSyncColor
                                        : prjLand.globalSync == 1
                                        ? AppColors.syncColor
                                        : AppColors.white,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        spacing: 4.0,
                                        children: [
                                          SizedBox(height: 2.0),
                                          Row(
                                            spacing: 10,
                                            children: [
                                              Expanded(
                                                child: Text(prjData.projectName ?? "", style: AppTextStyle.ts14MB),
                                              ),
                                              Text("${prjData.projectId}", style: AppTextStyle.ts14MB),
                                            ],
                                          ),
                                          Text(
                                            prjData.confirmationAddress ?? "",
                                            style: AppTextStyle.ts12RB.copyWith(color: Colors.grey),
                                          ),
                                          Text(prjData.reraRegNo ?? "", style: AppTextStyle.ts12RB),
                                          // Text("Images Sync: ${prjPhoto.length}"),
                                          counterwidget(
                                            title: "Images Sync: ",
                                            syncCount: " ${prjSyncPhoto.length}",
                                            totalValue: "${prjPhoto.length}",
                                          ),

                                          Row(
                                            spacing: 10,
                                            children: [
                                              Expanded(
                                                child: InkWell(
                                                  onTap:
                                                      // prjData.apfStatus == 1
                                                      //     ? null
                                                      //     :
                                                      () async {
                                                        await context.pushNamed(
                                                          AppRoutesName.psPrjDetailsPage,
                                                          extra: {"projectData": prjData},
                                                        );
                                                        if (!context.mounted) return;
                                                        psPrjCubit.getProjects();
                                                      },
                                                  child: Container(
                                                    alignment: Alignment.center,
                                                    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                                                    decoration: BoxDecoration(
                                                      color: prjData.apfStatus == 1
                                                          ? Colors.grey.shade300
                                                          : AppColors.primaryColor,
                                                      borderRadius: BorderRadius.circular(4.0),
                                                    ),
                                                    child: Text(
                                                      "PTI",
                                                      style: AppTextStyle.ts14BW,
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: InkWell(
                                                  onTap: prjData.apfStatus == 1
                                                      ? null
                                                      : () {
                                                          prjUnSyncPhoto.isNotEmpty || prjLand.globalSync == 0
                                                              ? CutsomAlertDialogues.syncCountDialogue(
                                                                  context: context,
                                                                  surveyCount: prjLand.globalSync == 0 ? 1 : 0,
                                                                  imageCount: prjUnSyncPhoto.length,
                                                                )
                                                              : prjPhoto.isEmpty || prjLand.globalSync == 0
                                                              ? CutsomAlertDialogues.dataAlertDialogue(context: context)
                                                              : CutsomAlertDialogues.finalSubmitPrjDialogue(
                                                                  context: context,
                                                                  title: "project technical information",
                                                                  confirm: () {
                                                                    context.pop();
                                                                    psPrjCubit.finalSubmitPrj(
                                                                      projectData: prjData,
                                                                      apfStatus: 1,
                                                                    );
                                                                  },
                                                                );
                                                        },
                                                  child: Container(
                                                    alignment: Alignment.center,
                                                    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                                                    decoration: BoxDecoration(
                                                      color: prjData.apfStatus == 1
                                                          ? Colors.grey.shade300
                                                          : AppColors.primaryColor,
                                                      borderRadius: BorderRadius.circular(4.0),
                                                    ),
                                                    child: Text(
                                                      "Final PTI",
                                                      style: AppTextStyle.ts14BW,
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            spacing: 10,
                                            children: [
                                              Expanded(
                                                child: InkWell(
                                                  onTap: () async {
                                                    await context.pushNamed(
                                                      AppRoutesName.cmBuildingPage,
                                                      extra: {"projectData": prjData},
                                                    );
                                                    if (!context.mounted) return;
                                                    psPrjCubit.getProjects();
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                                                    decoration: BoxDecoration(
                                                      color: prjData.cmStatus == 1
                                                          ? Colors.grey.shade300
                                                          : AppColors.primaryColor,
                                                      borderRadius: BorderRadius.circular(4.0),
                                                    ),
                                                    child: Text(
                                                      "CM",
                                                      style: AppTextStyle.ts14BW,
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: InkWell(
                                                  onTap: prjData.cmStatus == 1
                                                      ? null
                                                      : () {
                                                          unSyncWings.isNotEmpty
                                                              ? CutsomAlertDialogues.syncCMCountDialogue(
                                                                  context: context,
                                                                  surveyCount: unSyncWings.length,
                                                                )
                                                              : CutsomAlertDialogues.finalSubmitPrjDialogue(
                                                                  context: context,
                                                                  title: "construction monitoring",
                                                                  confirm: () {
                                                                    context.pop();
                                                                    psPrjCubit.finalSubmitPrj(
                                                                      projectData: prjData,
                                                                      cmStatus: 1,
                                                                    );
                                                                  },
                                                                );
                                                        },
                                                  child: Container(
                                                    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                                                    decoration: BoxDecoration(
                                                      color: prjData.cmStatus == 1
                                                          ? Colors.grey.shade300
                                                          : AppColors.primaryColor,
                                                      borderRadius: BorderRadius.circular(4.0),
                                                    ),
                                                    child: Text(
                                                      "Final CM",
                                                      style: AppTextStyle.ts14BW,
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
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
      ),
    );
  }

  Widget counterwidget({required String title, required String syncCount, required String totalValue}) {
    return RichText(
      text: TextSpan(
        text: title,
        style: AppTextStyle.ts14MB,
        children: [
          TextSpan(
            text: syncCount,
            style: AppTextStyle.ts14MB.copyWith(
              color: int.parse(syncCount) == int.parse(totalValue) ? AppColors.primaryColor : AppColors.red,
            ),
          ),
          TextSpan(
            text: "/$totalValue",
            style: AppTextStyle.ts14MB.copyWith(color: AppColors.primaryColor),
          ),
        ],
      ),
    );
  }
}
