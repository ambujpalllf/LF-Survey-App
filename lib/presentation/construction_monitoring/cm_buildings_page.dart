import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lf_survey/app_popups/cutsom_alert_dialogues.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_images.dart';
import 'package:lf_survey/constants/app_text_style.dart';
import 'package:lf_survey/constants/snackbar_helper.dart';
import 'package:lf_survey/constants/utils.dart';
import 'package:lf_survey/cubit/construction_monitering/cm_building/cm_building_cubit.dart';
import 'package:lf_survey/cubit/construction_monitering/cm_building/cm_building_state.dart';
import 'package:lf_survey/model/construction_monitoring/cm_building_response.dart';
import 'package:lf_survey/model/construction_monitoring/cm_wing_response.dart';
import 'package:lf_survey/model/pams_survey/ps_prj_response.dart';
import 'package:lf_survey/routes/app_routes_name.dart';
import 'package:lf_survey/services/work_manager_task_register.dart';
import 'package:lf_survey/widgets/custom_app_bar.dart';

class CmBuildingsPage extends StatefulWidget {
  final PsPrjDatum prjDatum;

  const CmBuildingsPage({super.key, required this.prjDatum});

  @override
  State<CmBuildingsPage> createState() => _CmBuildingsPageState();
}

class _CmBuildingsPageState extends State<CmBuildingsPage> {
  List<BuildingData> buildings = [];
  List<WingData> wings = [];
  TextEditingController buildingC = TextEditingController();

  late ReceivePort _receivePort;
  StreamSubscription? _receiveSubscription;

  @override
  void initState() {
    super.initState();
    context.read<CmBuildingCubit>().getBuildings(projectId: widget.prjDatum.projectId!);
    _receivePort = ReceivePort();
    IsolateNameServer.removePortNameMapping("sync_building");
    IsolateNameServer.registerPortWithName(_receivePort.sendPort, "sync_building");
    _receiveSubscription = _receivePort.listen((message) {
      if (!mounted) return;
      context.read<CmBuildingCubit>().getBuildings(projectId: widget.prjDatum.projectId!);
    });
  }

  void finalSubmitInfo() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          title: Text("Submission Completed", style: AppTextStyle.ts16BB),
          content: Text(
            "This project has already been successfully submitted. "
            "Adding new building or adding new wing is no longer permitted.",
            style: AppTextStyle.ts14RB,
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

  @override
  void dispose() {
    _receiveSubscription?.cancel();
    _receivePort.close();
    IsolateNameServer.removePortNameMapping("sync_building");
    buildingC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: CustomAppBar(
        title: "Buildings",
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () {
                List<BuildingData> unSynced = buildings
                    .where((e) => (e.buildingId != null || e.buildingId != 0) && e.sync == 0)
                    .toList();
                if (unSynced.isNotEmpty) {
                  WorkManagerTaskRegister.syncCmAllBuilding(
                    projectId: widget.prjDatum.projectId ?? 0,
                    buildingName: "",
                  );
                  CustomSnackHelper.customToastMsg(
                    context: context,
                    message: "Building sync has started in the background.",
                    bgColor: AppColors.white,
                    textColor: AppColors.black,
                  );
                } else {
                  CutsomAlertDialogues.customDialog(
                    context: context,
                    title: "Building Sync",
                    message: "There are no buildings available to sync.",
                  );
                }
              },
              child: Icon(Icons.sync, color: Colors.white),
            ),
          ),
          GestureDetector(
            onTap: widget.prjDatum.cmStatus == 1
                ? () {
                    finalSubmitInfo();
                  }
                : () async {
                    final locPermission = await Utils.checkLocationAndGpsPermission(context);
                    if (!context.mounted) return;
                    if (!locPermission) {
                      CustomSnackHelper.errorToast(message: "Please enable location permission and GPS");
                      return;
                    }
                    CutsomAlertDialogues.addBuildingDialogue(
                      context: context,
                      buildingC: buildingC,
                      title: "Building",
                      addBuilding: () {
                        context.pop();
                        context.read<CmBuildingCubit>().addBuilding(
                          projectId: widget.prjDatum.projectId ?? 0,
                          buildingName: buildingC.text,
                        );
                        buildingC.clear();
                      },
                    );
                  },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              margin: EdgeInsets.only(right: 12.0),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(100)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 4.0,
                children: [
                  const Icon(Icons.add, size: 18),
                  Text("Add Building", style: AppTextStyle.ts12MB),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            BlocConsumer<CmBuildingCubit, CmBuildingState>(
              buildWhen: (previous, current) => current is LoadedState || current is DeleteState,
              listener: (context, state) {
                if (state is LoadedState) {
                  buildings.clear();
                  wings.clear();
                  buildings.addAll(state.buildings);
                  wings.addAll(state.wings);
                } else if (state is WingState) {
                  wings.clear();
                  wings.addAll(state.wings);
                } else if (state is DeleteState) {
                  buildings.removeAt(state.index);
                } else if (state is ErrorState) {
                  CustomSnackHelper.customToastMsg(
                    context: context,
                    message: state.message,
                    bgColor: AppColors.white,
                    textColor: AppColors.black,
                  );
                }
              },
              builder: (context, state) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: buildings.length,
                    itemBuilder: (context, index) {
                      final building = buildings[index];
                      // List<WingData> wing = wings
                      //     .where(
                      //       (e) =>
                      //           (e.buildingId != null &&
                      //               building.buildingId != null &&
                      //               e.buildingId == building.buildingId) ||
                      //           (e.createdBuildingId != null &&
                      //               building.createdBuildingId != null &&
                      //               e.createdBuildingId == building.createdBuildingId),
                      //     )
                      //     .toList();
                      return GestureDetector(
                        onTap: () async {
                          final locPermission = await Utils.checkLocationAndGpsPermission(context);
                          if (!context.mounted) return;
                          if (!locPermission) {
                            CustomSnackHelper.errorToast(message: "Please enable location permission and GPS");
                            return;
                          }
                          await context.pushNamed(
                            AppRoutesName.cmSubPrjPage,
                            extra: {"projectData": widget.prjDatum, "buildingData": building},
                          );
                          if (!context.mounted) return;
                          context.read<CmBuildingCubit>().getBuildings(projectId: widget.prjDatum.projectId!);
                        },
                        child: Card(
                          color: (building.createdBuildingId != null && building.sync == 1)
                              ? AppColors.syncColor
                              : (building.createdBuildingId != null && building.sync == 0)
                              ? AppColors.unSyncColor
                              : AppColors.white,
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            child: Column(
                              spacing: 8.0,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  spacing: 16.0,
                                  children: [
                                    Image.asset(AppImages.budingImg, width: 30),
                                    Expanded(child: Text("${building.buildingName}", style: AppTextStyle.ts16MB)),
                                    Text(
                                      "${building.buildingId ?? building.createdBuildingId}",
                                      style: AppTextStyle.ts16MB,
                                    ),
                                  ],
                                ),
                                // Row(
                                //   mainAxisSize: MainAxisSize.min,
                                //   spacing: 12.0,
                                //   children: [
                                //     Image.asset(AppImages.wingImg, width: 30),
                                //     Text("Total Wings:", style: AppTextStyle.ts14MB),
                                //     Text("${wing.length}", style: AppTextStyle.ts12RB),
                                //   ],
                                // ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: GestureDetector(
                                    onTap: () async {
                                      final locPermission = await Utils.checkLocationAndGpsPermission(context);
                                      if (!context.mounted) return;
                                      if (!locPermission) {
                                        CustomSnackHelper.errorToast(
                                          message: "Please enable location permission and GPS",
                                        );
                                        return;
                                      }
                                      if (widget.prjDatum.cmStatus == 1) {
                                        finalSubmitInfo();
                                        return;
                                      }

                                      CutsomAlertDialogues.addBuildingDialogue(
                                        context: context,
                                        buildingC: buildingC,
                                        title: "Wing",
                                        addBuilding: () {
                                          context.pop();

                                          context.read<CmBuildingCubit>().addWing(
                                            projectId: widget.prjDatum.projectId ?? 0,
                                            buildingId: building.buildingId,
                                            createdBuildingId: building.createdBuildingId ?? "",
                                            wingName: buildingC.text,
                                          );

                                          buildingC.clear();
                                        },
                                      );
                                    },

                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade400,
                                        borderRadius: BorderRadius.circular(16.0),
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        spacing: 4.0,
                                        children: [
                                          Icon(Icons.add, size: 18, color: Colors.white),
                                          Text("Add Wing", style: AppTextStyle.ts14MW),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                if (building.createdBuildingId != null &&
                                    building.errorMsg != "" &&
                                    building.errorMsg != null)
                                  Text(
                                    "Error: ${building.errorMsg}",
                                    style: AppTextStyle.ts12RB.copyWith(color: AppColors.red),
                                  ),
                                if (building.createdBuildingId != null && widget.prjDatum.cmStatus != 1)
                                  GestureDetector(
                                    onTap: () {
                                      CutsomAlertDialogues.deleteDialogue(
                                        context: context,
                                        title: "Building",
                                        onDelete: () {
                                          context.pop();
                                          context.read<CmBuildingCubit>().delete(
                                            index: index,
                                            id: building.id ?? 0,
                                            buildingId: building.buildingId,
                                          );
                                        },
                                      );
                                    },
                                    // child: Text("Delete", style: AppTextStyle.ts16MB.copyWith(color: AppColors.red)),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade400,
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        spacing: 4.0,
                                        children: [
                                          Icon(Icons.delete, color: AppColors.white, size: 20.0),
                                          Text("Delete", style: AppTextStyle.ts12MW),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 12.0),
            BlocBuilder<CmBuildingCubit, CmBuildingState>(
              builder: (context, state) {
                return Row(
                  spacing: 12.0,
                  children: [
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                        decoration: BoxDecoration(color: Colors.blueGrey.shade100),
                        child: RichText(
                          text: TextSpan(
                            text: "Total Buildings: ",
                            style: AppTextStyle.ts14MB,
                            children: [TextSpan(text: "    ${buildings.length}", style: AppTextStyle.ts14RB)],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                        decoration: BoxDecoration(color: Colors.blueGrey.shade100),
                        child: RichText(
                          text: TextSpan(
                            text: "Total Wings: ",
                            style: AppTextStyle.ts14MB,
                            children: [TextSpan(text: "    ${wings.length}", style: AppTextStyle.ts14RB)],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // void deleteInfo() {
  //   showDialog(
  //     context: context,
  //     builder: (_) {
  //       return AlertDialog(
  //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
  //         title: Text("Submission Completed", style: AppTextStyle.ts16BB),
  //         content: Text(
  //           "This building has already been successfully submitted, so it can no longer be deleted.",
  //           style: AppTextStyle.ts14RB,
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               context.pop();
  //             },
  //             child: Text("OK", style: AppTextStyle.ts14BB.copyWith(color: AppColors.primaryColor)),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
}
