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
import 'package:lf_survey/cubit/commercial/c_sub_project/c_sub_project_cubit.dart';
import 'package:lf_survey/cubit/commercial/c_sub_project/c_sub_project_state.dart';
import 'package:lf_survey/model/db_model/commercial/c_project_entity.dart';
import 'package:lf_survey/model/db_model/commercial/c_sub_project_entity.dart';
import 'package:lf_survey/routes/app_routes_name.dart';
import 'package:lf_survey/widgets/custom_app_bar.dart';

class CSubProjectPage extends StatefulWidget {
  final CProjectEntity project;
  const CSubProjectPage({super.key, required this.project});

  @override
  State<CSubProjectPage> createState() => _CSubProjectPageState();
}

class _CSubProjectPageState extends State<CSubProjectPage> {
  List<CSubProjectEntity> subProjects = [];
  late ReceivePort _receivePort;
  @override
  void initState() {
    super.initState();
    context.read<CSubProjectCubit>().fetchSubProjects(projectId: widget.project.projectId ?? 0);
    _receivePort = ReceivePort();
    IsolateNameServer.registerPortWithName(_receivePort.sendPort, 'c_sync_sub_project');
    _receivePort.listen((message) {
      context.read<CSubProjectCubit>().fetchSubProjects(projectId: widget.project.projectId ?? 0);
    });
  }

  @override
  void dispose() {
    super.dispose();
    IsolateNameServer.removePortNameMapping('c_sync_sub_project');
    _receivePort.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: CustomAppBar(title: "Sub Project"),
      body: SafeArea(
        child: Padding(
          padding: AppDimens.hvPadding,
          child: Column(
            spacing: 12.0,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
                onPressed: () async {
                  if (!await Utils.checkLocationAndGpsPermission(context)) return;
                  if (!context.mounted) return;
                  context.pushNamed(
                    AppRoutesName.cNewSubProjectPage,
                    extra: {"newProjectData": null, "projectData": widget.project},
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 12.0,
                  children: [
                    Icon(Icons.add, color: AppColors.white, size: 25),
                    Text("Add New Sub-Project", style: AppTextStyle.ts14BW),
                  ],
                ),
              ),

              BlocConsumer<CSubProjectCubit, CSubProjectState>(
                listener: (context, state) {
                  if (state is LoadedState) {
                    subProjects.clear();
                    subProjects.addAll(state.subProjects);
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
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: subProjects.length,
                    itemBuilder: (context, index) {
                      var subPrjData = subProjects[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: GestureDetector(
                          onTap: () async {
                            if (!await Utils.checkLocationAndGpsPermission(context)) return;
                            if (!context.mounted) return;
                            context.pushNamed(
                              AppRoutesName.cSubProjectDetailsPage,
                              extra: {"subProjectData": subPrjData},
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: subPrjData.syncLocalStatus == 1 && subPrjData.syncGlobalStatus == 0
                                  ? AppColors.unSyncColor
                                  : subPrjData.syncGlobalStatus == 1
                                  ? AppColors.syncColor
                                  : AppColors.white,
                              borderRadius: BorderRadius.circular(4.0),
                              boxShadow: [BoxShadow(color: Colors.grey.shade300, offset: Offset(2, 2))],
                            ),
                            child: Column(
                              spacing: 12.0,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "(DOS : ${DateFormat('MMM yyyy').format(Utils.tryParseDate(subPrjData.dos!)!)}) ${subPrjData.syncGlobalStatus}",
                                  style: AppTextStyle.ts14RB,
                                ),
                                Text(subPrjData.subProjectName ?? "", style: AppTextStyle.ts16RB),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
