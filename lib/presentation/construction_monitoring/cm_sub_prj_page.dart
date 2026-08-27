import 'dart:isolate';
import 'dart:ui';

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
import 'package:lf_survey/cubit/construction_monitering/cm_sub_prj/cm_sub_prj_cubit.dart';
import 'package:lf_survey/cubit/construction_monitering/cm_sub_prj/cm_sub_prj_state.dart';
import 'package:lf_survey/model/construction_monitoring/cm_building_response.dart';
import 'package:lf_survey/model/construction_monitoring/cm_survey_model.dart';
import 'package:lf_survey/model/construction_monitoring/cm_wing_response.dart';
import 'package:lf_survey/model/pams_survey/ps_photo_response.dart';
import 'package:lf_survey/model/pams_survey/ps_prj_response.dart';
import 'package:lf_survey/routes/app_routes_name.dart';
import 'package:lf_survey/services/work_manager_task_register.dart';
import 'package:lf_survey/widgets/custom_app_bar.dart';
import 'package:lf_survey/widgets/custom_textfield.dart';
import 'package:lf_survey/widgets/custom_textform_field.dart';

class CMSubPrjPage extends StatefulWidget {
  final PsPrjDatum prjDatum;
  final BuildingData buildingData;
  const CMSubPrjPage({super.key, required this.prjDatum, required this.buildingData});

  @override
  State<CMSubPrjPage> createState() => _CMSubPrjPageState();
}

class _CMSubPrjPageState extends State<CMSubPrjPage> {
  final FocusNode searchFocusNode = FocusNode();
  bool isFocused = false;
  TextEditingController searchC = TextEditingController();
  List<WingData> wings = [];
  List<WingData> filteredWings = [];
  List<CmSurveyModel> surveyData = [];
  List<PsPhotoDatum> imageData = [];
  TextEditingController deleteWingRequestC = TextEditingController();
  late ReceivePort _receivePort;
  @override
  void initState() {
    super.initState();
    searchFocusNode.addListener(() {
      setState(() {
        isFocused = searchFocusNode.hasFocus;
      });
    });

    context.read<CmSubPrjCubit>().getWings(
      projectId: widget.prjDatum.projectId!,
      buildingId: widget.buildingData.buildingId,
      createdBuildingId: widget.buildingData.createdBuildingId,
    );
    context.read<CmSubPrjCubit>().getSurvey(projectId: widget.prjDatum.projectId!);
    _receivePort = ReceivePort();
    IsolateNameServer.registerPortWithName(_receivePort.sendPort, "sync_cm_wing");
    _receivePort.listen((message) {
      context.read<CmSubPrjCubit>().getWings(
        projectId: widget.prjDatum.projectId!,
        buildingId: widget.buildingData.buildingId,
        createdBuildingId: widget.buildingData.createdBuildingId,
      );
      context.read<CmSubPrjCubit>().getSurvey(projectId: widget.prjDatum.projectId!);
    });
  }

  @override
  void dispose() {
    super.dispose();
    searchC.dispose();
    searchFocusNode.dispose();
    IsolateNameServer.removePortNameMapping('sync_cm_wing');
    _receivePort.close();
    deleteWingRequestC.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cmSubPrjCubit = context.read<CmSubPrjCubit>();
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: CustomAppBar(
        // title: "Sub Projects",
        title: "Wings",
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () {
                List<WingData> unSynced = wings
                    .where((e) => (e.buildingId == null || e.buildingId == 0) && (e.wingId == null || e.wingId == 0))
                    .toList();
                if (unSynced.isNotEmpty) {
                  WorkManagerTaskRegister.syncCmAddWing(
                    projectId: widget.prjDatum.projectId ?? 0,
                    buildingId: null,
                    createdBuildingId: null,
                    wingName: "",
                  );
                  CustomSnackHelper.customToastMsg(
                    context: context,
                    message: "Wing sync has started in the background.",
                    bgColor: AppColors.white,
                    textColor: AppColors.black,
                  );
                } else {
                  CutsomAlertDialogues.customDialog(
                    context: context,
                    title: "Wing Sync",
                    message: "There are no wings available to sync.",
                  );
                }
              },
              child: Icon(Icons.sync, color: Colors.white),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: AppDimens.hvPadding,
          child: Column(
            spacing: 12.0,
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
                  hintText: isFocused ? "Sub-Project Name" : null,
                  hintTextColor: Colors.grey,
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  suffixIcon: isFocused
                      ? IconButton(
                          onPressed: () {
                            searchC.clear();
                            searchFocusNode.unfocus();
                            // context.read<CmSubPrjCubit>().searchWings(query: "", wings: widget.prjDatum.wings!);
                            context.read<CmSubPrjCubit>().searchWings(query: "", wings: wings);
                          },
                          icon: Icon(Icons.close, color: Colors.grey),
                        )
                      : null,
                  onChanged: (value) {
                    // context.read<CmSubPrjCubit>().searchWings(query: value, wings: widget.prjDatum.wings!);
                    context.read<CmSubPrjCubit>().searchWings(query: value, wings: wings);
                  },
                ),
              ),
              Expanded(
                child: BlocConsumer<CmSubPrjCubit, CmSubPrjState>(
                  listener: (context, state) {
                    if (state is LoadedState) {
                      wings.clear();
                      filteredWings.clear();
                      wings.addAll(state.wingData);
                      filteredWings.addAll(state.wingData);
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
                    } else if (state is SearchState) {
                      // wings.clear();
                      // wings.addAll(state.wings);
                      filteredWings.clear();
                      filteredWings.addAll(state.wings);
                    } else if (state is WingUpdateState) {
                      // final wingIndex = wings.indexWhere((w) => w.wingId == state.wing.wingId);
                      // if (wingIndex != -1) {
                      //   wings[wingIndex] = state.wing;
                      //   widget.prjDatum.wings?.clear();
                      //   widget.prjDatum.wings = wings;
                      //   context.read<CmSubPrjCubit>().updateProject(prjData: widget.prjDatum);
                      // }
                    } else if (state is SurveyState) {
                      surveyData.clear();
                      imageData.clear();
                      surveyData.addAll(state.surveyData);
                      imageData.addAll(state.imageData);
                    } else if (state is DeleteState) {
                      // wings.removeAt(state.index);
                      filteredWings.removeAt(state.index);
                    }
                  },
                  builder: (context, state) {
                    return filteredWings.isEmpty
                        ? Center(child: Text("No data found !", style: AppTextStyle.ts14MB))
                        : ListView.builder(
                            itemCount: filteredWings.length,
                            itemBuilder: (context, index) {
                              // var wingData = wings[index];
                              var wingData = filteredWings[index];
                              var wingImage = imageData.where((e) => e.wingId == wingData.wingId);
                              var wingSyncImage = wingImage.where((e) => e.sync == 1);
                              var wingUnsyncImage = wingImage.where((e) => e.sync == 0);
                              var wingSurvey = surveyData.where((e) => e.wingId == wingData.wingId);
                              var wingSyncSurvey = wingSurvey.where((e) => e.globalSync == 1);
                              var wingUnsyncSurvey = wingSurvey.where((e) => e.globalSync == 0);
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: InkWell(
                                  onTap: () async {
                                    final locPermission = await Utils.checkLocationAndGpsPermission(context);
                                    if (!context.mounted) return;
                                    if (!locPermission) {
                                      CustomSnackHelper.errorToast(
                                        message: "Please enable location permission and GPS",
                                      );
                                      return;
                                    }
                                    wingData.projectId = widget.prjDatum.projectId;
                                    await context.pushNamed(AppRoutesName.cmSurveyPage, extra: {"wingData": wingData});
                                    cmSubPrjCubit.getSurvey(projectId: widget.prjDatum.projectId!);
                                  },
                                  child: Card(
                                    margin: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(4.0)),
                                    color: wingData.submitStatus == true ? AppColors.syncColor : AppColors.white,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        spacing: 4.0,
                                        children: [
                                          Row(
                                            spacing: 10,
                                            children: [
                                              Image.asset(AppImages.wingImg, width: 30),
                                              Expanded(
                                                child: Text(wingData.wingName ?? "", style: AppTextStyle.ts16MB),
                                              ),
                                              Text(
                                                "${wingData.wingId ?? wingData.createdWingId}",
                                                style: AppTextStyle.ts16MB,
                                              ),
                                            ],
                                          ),
                                          // Text(
                                          //   "Average Floor Rise: ${wingData.averageFloorRise ?? ""}",
                                          //   style: AppTextStyle.ts12RB.copyWith(color: Colors.grey),
                                          // ),
                                          counterwidget(
                                            title: "Image Sync Count :",
                                            syncCount: "${wingSyncImage.length}",
                                            totalValue: "${wingImage.length}",
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              counterwidget(
                                                title: "Survey Sync Count :",
                                                syncCount: "${wingSyncSurvey.length}",
                                                totalValue: "${wingSurvey.length}",
                                              ),
                                              // if (wingData.createdWingId != null && wingData.submitStatus != true)
                                              if (wingData.submitStatus != true)
                                                GestureDetector(
                                                  onTap: () async {
                                                    final locPermission = await Utils.checkLocationAndGpsPermission(
                                                      context,
                                                    );
                                                    if (!context.mounted) return;
                                                    if (!locPermission) {
                                                      CustomSnackHelper.errorToast(
                                                        message: "Please enable location permission and GPS",
                                                      );
                                                      return;
                                                    }
                                                    // Delete wing which is created by user
                                                    if (wingData.createdWingId != null) {
                                                      CutsomAlertDialogues.deleteDialogue(
                                                        context: context,
                                                        title: "Wing",
                                                        onDelete: () {
                                                          context.pop();
                                                          context.read<CmSubPrjCubit>().deletewing(
                                                            id: wingData.id ?? 0,
                                                            index: index,
                                                            wingId: wingData.wingId,
                                                          );
                                                        },
                                                      );
                                                    } else {
                                                      showDialog(
                                                        context: context,
                                                        builder: (_) {
                                                          return AlertDialog(
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadiusGeometry.circular(8.0),
                                                            ),

                                                            title: Row(
                                                              children: [
                                                                Icon(
                                                                  Icons.info,
                                                                  color: AppColors.primaryColor,
                                                                  size: 24,
                                                                ),
                                                                const SizedBox(width: 8),
                                                                Flexible(
                                                                  child: Text(
                                                                    "Delete Wing Request",
                                                                    style: AppTextStyle.ts16BB,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            content: CustomTextField(
                                                              controller: deleteWingRequestC,
                                                              minLines: 1,
                                                              maxLines: null,
                                                              labelText: "Remarks",
                                                              hintText: "Enter remarks",
                                                              borderColor: AppColors.black,
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () {
                                                                  Navigator.pop(context);
                                                                  deleteWingRequestC.clear();
                                                                },
                                                                child: Text("Cancel", style: AppTextStyle.ts14BB),
                                                              ),
                                                              TextButton(
                                                                onPressed: () {
                                                                  context.read<CmSubPrjCubit>().deleteWingRequest(
                                                                    id: wingData.id ?? 0,
                                                                    index: index,
                                                                    wingId: wingData.wingId,
                                                                    allocationId: widget.prjDatum.allocationId ?? 0,
                                                                    remarks: deleteWingRequestC.text,
                                                                  );
                                                                  deleteWingRequestC.clear();
                                                                  context.pop();
                                                                },
                                                                child: Text(
                                                                  "Delete",
                                                                  style: AppTextStyle.ts14BB.copyWith(
                                                                    color: AppColors.red,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    }
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsetsDirectional.all(5.0),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red.shade400,
                                                      borderRadius: BorderRadius.circular(50),
                                                    ),
                                                    child: Icon(Icons.delete, color: AppColors.white, size: 20),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          SizedBox(
                                            width: double.infinity,
                                            child: InkWell(
                                              onTap: wingData.submitStatus == true
                                                  ? null
                                                  : () async {
                                                      final locPermission = await Utils.checkLocationAndGpsPermission(
                                                        context,
                                                      );
                                                      if (!context.mounted) return;
                                                      if (!locPermission) {
                                                        CustomSnackHelper.errorToast(
                                                          message: "Please enable location permission and GPS",
                                                        );
                                                        return;
                                                      }
                                                      wingSurvey.isEmpty || wingImage.isEmpty
                                                          ? CutsomAlertDialogues.dataAlertDialogue(context: context)
                                                          : wingUnsyncSurvey.isNotEmpty || wingUnsyncImage.isNotEmpty
                                                          ? CutsomAlertDialogues.syncCountDialogue(
                                                              context: context,
                                                              surveyCount: wingUnsyncSurvey.length,
                                                              imageCount: wingUnsyncImage.length,
                                                            )
                                                          : CutsomAlertDialogues.finalSubmitWingDialogue(
                                                              context: context,
                                                              title: "sub-prject",
                                                              confirm: () {
                                                                context.pop();
                                                                context.read<CmSubPrjCubit>().finalSubmitWing(
                                                                  allocationId: widget.prjDatum.allocationId!,
                                                                  wingData: wingData,
                                                                );
                                                              },
                                                            );
                                                    },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                                                decoration: BoxDecoration(
                                                  color: wingData.submitStatus == true
                                                      ? Colors.grey.shade300
                                                      : AppColors.primaryColor,
                                                  borderRadius: BorderRadius.circular(4.0),
                                                ),
                                                child: Text(
                                                  "Final Submit",
                                                  style: AppTextStyle.ts14BW,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (wingData.createdBuildingId != null &&
                                              wingData.errorMsg != "" &&
                                              wingData.errorMsg != null)
                                            Text(
                                              "Error: ${wingData.errorMsg}",
                                              style: AppTextStyle.ts12RB.copyWith(color: AppColors.red),
                                            ),
                                          // if (wingData.createdWingId != null)
                                          //   GestureDetector(
                                          //     onTap: () {
                                          //       CutsomAlertDialogues.deleteDialogue(
                                          //         context: context,
                                          //         title: "Wing",
                                          //         onDelete: () {
                                          //           context.pop();
                                          //           context.read<CmSubPrjCubit>().deletewing(
                                          //             id: wingData.id ?? 0,
                                          //             index: index,
                                          //             wingId: wingData.wingId,
                                          //           );
                                          //         },
                                          //       );
                                          //     },
                                          //     child: Container(
                                          //       padding: EdgeInsetsDirectional.symmetric(
                                          //         vertical: 3.0,
                                          //         horizontal: 20.0,
                                          //       ),
                                          //       decoration: BoxDecoration(
                                          //         color: AppColors.red,
                                          //         borderRadius: BorderRadius.circular(28),
                                          //       ),
                                          //       child: Row(
                                          //         spacing: 4.0,
                                          //         mainAxisAlignment: MainAxisAlignment.center,
                                          //         mainAxisSize: MainAxisSize.min,
                                          //         children: [
                                          //           Text("Delete", style: AppTextStyle.ts14MW),
                                          //           Icon(Icons.delete, color: AppColors.white, size: 16),
                                          //         ],
                                          //       ),
                                          //     ),
                                          //   ),
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
