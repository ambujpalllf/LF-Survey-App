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
import 'package:lf_survey/cubit/construction_monitering/cm_survey/cm_survey_cubit.dart';
import 'package:lf_survey/cubit/construction_monitering/cm_survey/cm_survey_state.dart';
import 'package:lf_survey/model/construction_monitoring/cm_survey_model.dart';
import 'package:lf_survey/model/construction_monitoring/cm_wing_response.dart';
import 'package:lf_survey/routes/app_routes_name.dart';
import 'package:lf_survey/widgets/custom_app_bar.dart';

class CmSurveyPage extends StatefulWidget {
  final WingData wingData;
  const CmSurveyPage({super.key, required this.wingData});

  @override
  State<CmSurveyPage> createState() => _CmSurveyPageState();
}

class _CmSurveyPageState extends State<CmSurveyPage> {
  List<CmSurveyModel> surveyData = [];
  List<CmSurveyModel> filterData = [];
  late ReceivePort _receivePort;
  @override
  void initState() {
    super.initState();
    context.read<CmSurveyCubit>().getSurvey(wingId: widget.wingData.wingId, localWingId: widget.wingData.createdWingId);
    _receivePort = ReceivePort();
    IsolateNameServer.registerPortWithName(_receivePort.sendPort, "sync_cm_survey");
    _receivePort.listen((message) {
      context.read<CmSurveyCubit>().getSurvey(
        wingId: widget.wingData.wingId,
        localWingId: widget.wingData.createdWingId,
      );
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
            "You can no longer add new surveys",
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
    super.dispose();
    IsolateNameServer.removePortNameMapping('sync_cm_survey');
    _receivePort.close();
  }

  @override
  Widget build(BuildContext context) {
    CmSurveyCubit cmSurveyCubit = context.read<CmSurveyCubit>();
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: CustomAppBar(
        title: "Survey Data (History)",
        actions: [
          BlocBuilder<CmSurveyCubit, CmSurveyState>(
            builder: (context, state) {
              bool isUnsynPrjTechInfo = filterData.any((e) => e.globalSync == 0 && e.localSync == 1);
              return IconButton(
                onPressed: isUnsynPrjTechInfo == false
                    ? () {}
                    : () {
                        cmSurveyCubit.syncProjects();
                      },
                icon: Icon(Icons.sync, color: isUnsynPrjTechInfo ? AppColors.white : Colors.grey.shade600),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: AppDimens.hvPadding,
          child: Column(
            children: [
              Expanded(
                child: BlocConsumer<CmSurveyCubit, CmSurveyState>(
                  // buildWhen: (previous, current) => current is LoadingState || current is LoadedState,
                  listener: (context, state) {
                    if (state is LoadedState) {
                      surveyData.clear();
                      filterData.clear();
                      surveyData.addAll(state.surveyData);
                      filterData.addAll(state.surveyData);
                    } else if (state is SuccessState) {
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
                    }
                  },
                  builder: (context, state) {
                    return state is LoadingState
                        ? Center(child: CircularProgressIndicator(color: AppColors.red))
                        : filterData.isEmpty
                        ? Center(child: Text("Data not found!", style: AppTextStyle.ts14MB))
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: filterData.length,
                            itemBuilder: (_, index) {
                              var item = filterData[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: InkWell(
                                  onTap: () => context.pushNamed(
                                    AppRoutesName.cmFormPage,
                                    extra: {"wingData": widget.wingData, "isViewOnly": true, "surveyData": item},
                                  ),
                                  child: Card(
                                    margin: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(4.0)),
                                    color: item.localSync == 1 && item.globalSync == 0
                                        ? AppColors.unSyncColor
                                        : item.globalSync == 1
                                        ? AppColors.syncColor
                                        : AppColors.white,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        spacing: 4.0,
                                        children: [
                                          Row(
                                            spacing: 10,
                                            children: [
                                              Expanded(
                                                child: Text(widget.wingData.wingName ?? "", style: AppTextStyle.ts14MB),
                                              ),
                                              Text(
                                                "${widget.wingData.wingId ?? widget.wingData.createdWingId}",
                                                style: AppTextStyle.ts14MB,
                                              ),
                                            ],
                                          ),
                                          RichText(
                                            text: TextSpan(
                                              text: "Number of Floors : ",
                                              style: AppTextStyle.ts14MB,
                                              children: [TextSpan(text: item.noOfFloors, style: AppTextStyle.ts14RB)],
                                            ),
                                          ),
                                          RichText(
                                            text: TextSpan(
                                              text: "Plinth : ",
                                              style: AppTextStyle.ts14MB,
                                              children: [TextSpan(text: item.plinth, style: AppTextStyle.ts14RB)],
                                            ),
                                          ),
                                          RichText(
                                            text: TextSpan(
                                              text: "Total Units : ",
                                              style: AppTextStyle.ts14MB,
                                              children: [
                                                TextSpan(text: "${item.totalUnits}", style: AppTextStyle.ts14RB),
                                              ],
                                            ),
                                          ),
                                          RichText(
                                            text: TextSpan(
                                              text: "Total Sold Units : ",
                                              style: AppTextStyle.ts14MB,
                                              children: [
                                                TextSpan(text: "${item.soldUnits}", style: AppTextStyle.ts14RB),
                                              ],
                                            ),
                                          ),
                                          RichText(
                                            text: TextSpan(
                                              text: "Total Unsold Units : ",
                                              style: AppTextStyle.ts14MB,
                                              children: [
                                                TextSpan(text: "${item.unsoldUnits}", style: AppTextStyle.ts14RB),
                                              ],
                                            ),
                                          ),
                                          RichText(
                                            text: TextSpan(
                                              text: "Date Of Survey : ",
                                              style: AppTextStyle.ts14MB,
                                              children: [
                                                TextSpan(
                                                  text: DateFormat(
                                                    "dd MMM yyyy hh:mm a",
                                                  ).format(DateTime.parse(item.survayDate!)),
                                                  style: AppTextStyle.ts14RB,
                                                ),
                                              ],
                                            ),
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
              Row(
                spacing: 5,
                children: [
                  Flexible(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: AppColors.primaryColor,
                        alignment: Alignment.center,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(4.0)),
                      ),
                      onPressed: () async {
                        if (!await Utils.checkLocationAndGpsPermission(context)) return;
                        if (!context.mounted) return;
                        await context.pushNamed(AppRoutesName.cmImgPage, extra: {"wingData": widget.wingData});
                        if (!context.mounted) return;
                        // commented date 05-06-2006 it is neccessary to un comment based locl Wing Id and wing Id
                        context.read<CmSurveyCubit>().getSurvey(
                          wingId: widget.wingData.wingId,
                          localWingId: widget.wingData.createdWingId,
                        );
                      },
                      child: Row(
                        spacing: 10,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Add Images", style: AppTextStyle.ts16MW),
                          Icon(Icons.camera_alt, size: 25, color: AppColors.white),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        alignment: Alignment.center,
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(4.0)),
                      ),
                      onPressed: widget.wingData.submitStatus == true
                          ? () async {
                              showDialog(
                                context: context,
                                builder: (_) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                    title: Text("Submission Completed", style: AppTextStyle.ts16BB),
                                    content: Text(
                                      "This sub-project has already been successfully submitted. "
                                      "Editing details or adding new photos is no longer permitted.",
                                      style: AppTextStyle.ts14RB,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          context.pop();
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
                          : () async {
                              if (!await Utils.checkLocationAndGpsPermission(context)) return;
                              if (!context.mounted) return;
                              await context.pushNamed(
                                AppRoutesName.cmFormPage,
                                extra: {
                                  "wingData": widget.wingData,
                                  "surveyData": surveyData.isNotEmpty ? surveyData.last : null,
                                },
                              );
                              if (!context.mounted) return;
                              context.read<CmSurveyCubit>().getSurvey(
                                wingId: widget.wingData.wingId,
                                localWingId: widget.wingData.createdWingId,
                              );
                            },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 10,
                        children: [
                          Text("New Survey", style: AppTextStyle.ts16MW),
                          Icon(Icons.description, size: 25, color: AppColors.white),
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
    );
  }
}
