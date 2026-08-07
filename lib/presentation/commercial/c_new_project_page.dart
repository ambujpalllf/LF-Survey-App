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
import 'package:lf_survey/cubit/commercial/c_new_%20project/c_new_project_cubit.dart';
import 'package:lf_survey/cubit/commercial/c_new_%20project/c_new_project_state.dart';
import 'package:lf_survey/model/db_model/commercial/c_new_project_entity.dart';
import 'package:lf_survey/routes/app_routes_name.dart';
import 'package:lf_survey/widgets/custom_app_bar.dart';
import 'package:lf_survey/widgets/custom_textform_field.dart';

class CNewProjectPage extends StatefulWidget {
  const CNewProjectPage({super.key});

  @override
  State<CNewProjectPage> createState() => _CNewProjectPageState();
}

class _CNewProjectPageState extends State<CNewProjectPage> {
  List<CNewProjectEntity> projects = [];
  List<CNewProjectEntity> filteredProjects = [];
  TextEditingController searchC = TextEditingController();
  FocusNode searchFN = FocusNode();
  bool isFocused = false;
  late ReceivePort _receivePort;
  @override
  void initState() {
    super.initState();
    searchFN.addListener(() {
      setState(() {
        isFocused = searchFN.hasFocus;
      });
    });
    context.read<CNewProjectCubit>().fetchData();
    _receivePort = ReceivePort();
    IsolateNameServer.registerPortWithName(_receivePort.sendPort, 'sync_new_project');
    _receivePort.listen((message) {
      if (!mounted) return;
      context.read<CNewProjectCubit>().fetchData();
    });
  }

  @override
  void dispose() {
    super.dispose();
    searchC.dispose();
    IsolateNameServer.removePortNameMapping('sync_new_project');
    _receivePort.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: CustomAppBar(
        titleWidget: BlocBuilder<CNewProjectCubit, CNewProjectState>(
          builder: (context, state) {
            return Text("New CProjects (${filteredProjects.length})", style: AppTextStyle.ts18BW);
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              List<CNewProjectEntity> unsyncPrj = filteredProjects.where((e) => e.globalSyncStatus == 0).toList();
              if (unsyncPrj.isEmpty) return;
              CutsomAlertDialogues.customDialog(
                context: context,
                title: "Confirmation",
                message:
                    "Please confirm that you want to sync this project. Once submitted, no further changes will be permitted.",
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
                      context.read<CNewProjectCubit>().submitProject(prjId: "");
                    },
                    child: Text("OK", style: AppTextStyle.ts14RB.copyWith(color: AppColors.red)),
                  ),
                ],
              );
            },
            icon: Icon(Icons.sync, color: AppColors.red),
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
                          },
                          icon: Icon(Icons.close, color: Colors.grey),
                        )
                      : null,
                  onChanged: (value) {
                    context.read<CNewProjectCubit>().searchData(projects: projects, query: value);
                  },
                ),
              ),
              const SizedBox(height: 8.0),
              Expanded(
                child: BlocConsumer<CNewProjectCubit, CNewProjectState>(
                  listener: (context, state) {
                    if (state is ErrorState) {
                      CustomSnackHelper.customToastMsg(
                        context: context,
                        message: state.message,
                        bgColor: AppColors.white,
                        textColor: AppColors.black,
                      );
                    } else if (state is LocalDbState) {
                      projects.clear();
                      filteredProjects.clear();
                      projects.addAll(state.projects);
                      filteredProjects.addAll(state.projects);
                    } else if (state is SearchState) {
                      filteredProjects.clear();
                      filteredProjects.addAll(state.projects);
                    }
                  },
                  builder: (context, state) {
                    return ListView.builder(
                      itemCount: filteredProjects.length,
                      itemBuilder: (context, index) {
                        var prjData = filteredProjects[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: GestureDetector(
                            onTap: () async {
                              if (prjData.globalSyncStatus == 0) {
                                await context.pushNamed(
                                  AppRoutesName.cAddNewProjectPage,
                                  extra: {"projectData": prjData},
                                );
                                if (!context.mounted) return;
                                context.read<CNewProjectCubit>().fetchData();
                              } else {
                                context.pushNamed(
                                  AppRoutesName.cNewProjectDetatilsPage,
                                  extra: {"projectData": prjData},
                                );
                              }
                            },
                            child: Card(
                              margin: EdgeInsets.zero,
                              color: prjData.globalSyncStatus == 0 ? AppColors.unSyncColor : AppColors.syncColor,
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
                                        Expanded(child: Text(prjData.prjName ?? "", style: AppTextStyle.ts14MB)),
                                        Text(prjData.prjId ?? "", style: AppTextStyle.ts14MB),
                                      ],
                                    ),
                                    Text("Builder: ${prjData.builderName}", style: AppTextStyle.ts12RB),
                                    Text(prjData.prjAddr ?? "", style: AppTextStyle.ts12RB),
                                    Text(prjData.roadName ?? "", style: AppTextStyle.ts12RB),
                                    Align(
                                      alignment: AlignmentDirectional.topEnd,
                                      child: Text(
                                        // "(DOS : ${DateFormat('MMM yyyy').format(Utils.tryParseDate(prjData.dos!)!)})",
                                        "(DOS : ${prjData.dos})",
                                        style: AppTextStyle.ts12RB,
                                      ),
                                    ),
                                    if (prjData.globalSyncStatus == 0)
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
                                                "Please confirm that you want to sync this project. Once submitted, no further changes will be permitted.",
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
                                                  context.read<CNewProjectCubit>().submitProject(
                                                    prjId: prjData.prjId ?? "",
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
                                        child: Text(
                                          "Submit",
                                          style: AppTextStyle.ts14RB.copyWith(color: AppColors.red),
                                        ),
                                      ),
                                    if (prjData.errorMessage != null && prjData.errorMessage != "")
                                      Text(
                                        "Error: ${prjData.errorMessage}",
                                        style: AppTextStyle.ts12RB.copyWith(color: Colors.red),
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
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        backgroundColor: AppColors.red,
        onPressed: () async {
          await context.pushNamed(AppRoutesName.cAddNewProjectPage);
          if (!context.mounted) return;
          context.read<CNewProjectCubit>().fetchData();
        },
        child: Icon(Icons.add, size: 30, color: AppColors.white),
      ),
    );
  }
}
