import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_dimens.dart';
import 'package:lf_survey/constants/app_images.dart';
import 'package:lf_survey/constants/app_text_style.dart';
import 'package:lf_survey/constants/snackbar_helper.dart';
import 'package:lf_survey/constants/utils.dart';
import 'package:lf_survey/cubit/residential/new_project/new_project_cubit.dart';
import 'package:lf_survey/cubit/residential/new_project/new_project_state.dart';
import 'package:lf_survey/model/db_model/residential/new_project_entity.dart';
import 'package:lf_survey/routes/app_routes_name.dart';
import 'package:lf_survey/widgets/custom_app_bar.dart';
import 'package:lf_survey/widgets/custom_textform_field.dart';

class NewProjectPage extends StatefulWidget {
  const NewProjectPage({super.key});

  @override
  State<NewProjectPage> createState() => _NewProjectPageState();
}

class _NewProjectPageState extends State<NewProjectPage> {
  final FocusNode searchFocusNode = FocusNode();
  bool isFocused = false;
  TextEditingController searchC = TextEditingController();
  bool isSyncProject = false;
  int qtrId = 0;
  String qtr = "";
  List<NewProjectEntity> projects = [];
  List<NewProjectEntity> filterProjects = [];
  late ReceivePort _receivePort;
  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      context.read<NewProjectCubit>().downloadProjects();
    } else {
      context.read<NewProjectCubit>().fetchData();
      _receivePort = ReceivePort();
      IsolateNameServer.registerPortWithName(_receivePort.sendPort, 'sync_new_project');
      _receivePort.listen((message) {
        final String projectId = message as String;
        debugPrint("Received update for project Id: $projectId");
        context.read<NewProjectCubit>().fetchData();
      });
    }

    context.read<NewProjectCubit>().fetchQtrData();
    searchFocusNode.addListener(() {
      setState(() {
        isFocused = searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    IsolateNameServer.removePortNameMapping('sync_new_project');
    _receivePort.close();
    searchFocusNode.dispose();
    searchC.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: CustomAppBar(
        titleWidget: BlocBuilder<NewProjectCubit, NewProjectState>(
          builder: (context, state) {
            return Text("New Projects(${projects.length})", style: AppTextStyle.ts18BW);
          },
        ),

        actions: [
          IconButton(
            onPressed: isSyncProject
                ? null
                : () {
                    // setState(() {
                    //   isSyncProject = true;
                    // });
                    context.read<NewProjectCubit>().syncProjects(projects: filterProjects);
                  },
            icon: Icon(Icons.sync, color: isSyncProject ? AppColors.greyLite : AppColors.red),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocListener<NewProjectCubit, NewProjectState>(
          listener: (context, state) {
            if (state is LocalDbState) {
              projects.clear();
              filterProjects.clear();
              projects.addAll(state.projects);
              filterProjects.addAll(state.projects);
            } else if (state is SearchState) {
              filterProjects.clear();
              filterProjects.addAll(state.projects);
            } else if (state is LocalPrefsState) {
              qtrId = int.tryParse(state.qtrId) ?? 0;
              qtr = DateFormat('MMM yyyy').format(Utils.tryParseDate(state.qtr)!);
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
                    controller: searchC,
                    focusNode: searchFocusNode,
                    filled: true,
                    fillColor: AppColors.white,
                    hintText: isFocused ? "Project Id, Project Name, Builder Name, project Address" : null,
                    hintTextColor: Colors.grey,
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    suffixIcon: isFocused
                        ? IconButton(
                            onPressed: () {
                              searchC.clear();
                              context.read<NewProjectCubit>().searchProject(query: "", projects: projects);
                            },
                            icon: Icon(Icons.close, color: Colors.grey),
                          )
                        : null,
                    onChanged: (value) {
                      context.read<NewProjectCubit>().searchProject(query: value, projects: projects);
                    },
                  ),
                ),
                BlocBuilder<NewProjectCubit, NewProjectState>(
                  buildWhen: (previous, current) => current is LocalDbState || current is SearchState,
                  builder: (context, state) {
                    return Flexible(
                      child: ListView.builder(
                        // itemCount: projects.length,
                        itemCount: filterProjects.length,
                        itemBuilder: (context, index) {
                          // var item = projects[index];
                          var item = filterProjects[index];
                          // DateTime parsedDate = DateTime.parse(item.createdDateTime!);
                          DateTime parsedDate = Utils.tryParseDate(item.createdDateTime!)!;
                          String createdDate = DateFormat('dd MMM yyyy').format(parsedDate);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: InkWell(
                              onTap: () {
                                context.pushNamed(AppRoutesName.newProjectDetailsPage, extra: {"newProjectData": item});
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: item.syncGlobalStatus == 0 ? AppColors.unSyncColor : AppColors.syncColor,
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, 3)),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    spacing: 4.0,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.prjName ?? "", style: AppTextStyle.ts14RB),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        spacing: 12.0,
                                        children: [
                                          Flexible(child: Text("id: ${item.prjId ?? ""}", style: AppTextStyle.ts14RB)),
                                          // Image.asset(AppImages.newIc, height: 40),
                                          Image.asset(AppImages.newImg, height: 30),
                                        ],
                                      ),
                                      Text(item.prjAddr ?? "", style: AppTextStyle.ts14RB),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "(DOS: ${item.qtr ?? qtr})",
                                            style: AppTextStyle.ts14RB.copyWith(color: Colors.red),
                                          ),
                                          Text(createdDate, style: AppTextStyle.ts14RB),
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
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.red,
        onPressed: () async {
          final res = await context.pushNamed(AppRoutesName.addNewPrjPage);
          if (!context.mounted) return;
          if (res == true) {
            if (kIsWeb) {
              context.read<NewProjectCubit>().downloadProjects();
            } else {
              context.read<NewProjectCubit>().fetchData();
            }
          }
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(100)),
        child: Icon(Icons.add, color: AppColors.white),
      ),
    );
  }
}
