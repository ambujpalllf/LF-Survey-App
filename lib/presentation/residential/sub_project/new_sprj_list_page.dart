import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lf_survey/app_popups/cutsom_alert_dialogues.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_dimens.dart';
import 'package:lf_survey/constants/app_text_style.dart';
import 'package:lf_survey/constants/snackbar_helper.dart';
import 'package:lf_survey/cubit/residential/sub_project/new_sub_projects/new_sprj_cubit.dart';
import 'package:lf_survey/cubit/residential/sub_project/new_sub_projects/new_sprj_states.dart';
import 'package:lf_survey/model/db_model/residential/new_flat_entity.dart';
import 'package:lf_survey/model/db_model/residential/new_sub_project_entity.dart';
import 'package:lf_survey/model/residential/project_spinner.dart';
import 'package:lf_survey/routes/app_routes_name.dart';
import 'package:lf_survey/widgets/custom_app_bar.dart';
import 'package:lf_survey/widgets/custom_elevated_btn.dart';
import 'package:lf_survey/widgets/custom_textfield.dart';

class NewSPrjListPage extends StatefulWidget {
  final int projectId;
  final int cityId;
  final String newProjectId;
  final String reraNo;
  const NewSPrjListPage({
    super.key,
    required this.projectId,
    required this.cityId,
    required this.newProjectId,
    required this.reraNo,
  });

  @override
  State<NewSPrjListPage> createState() => _NewSPrjListPageState();
}

class _NewSPrjListPageState extends State<NewSPrjListPage> {
  bool isLoading = false;
  bool isShowCopyUi = false;
  String qtr = "";
  List<NewSubProjectEntity> subProjectList = [];
  Map<String, List<NewFlatEntity>> flatsMap = {};
  List<ConstProgressList> constProgressList = [];
  int selectedcopyIndex = -1;

  TextEditingController subPrjNameC = TextEditingController();
  String subPrjError = "";
  late ReceivePort _receivePort;
  @override
  void initState() {
    super.initState();
    context.read<NewSprjCubit>().fetchUserData();
    if (!kIsWeb) {
      context.read<NewSprjCubit>().fetchSubProjects(projectId: widget.projectId, newPrjId: widget.newProjectId);
      _receivePort = ReceivePort();
      IsolateNameServer.registerPortWithName(_receivePort.sendPort, "sync_new_sub_project");
      _receivePort.listen((message) {
        context.read<NewSprjCubit>().fetchSubProjects(projectId: widget.projectId, newPrjId: widget.newProjectId);
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    subPrjNameC.dispose();
    if (!kIsWeb) {
      IsolateNameServer.removePortNameMapping('sync_new_sub_project');
      _receivePort.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    NewSprjCubit newSprjCubit = context.read<NewSprjCubit>();
    return BlocListener<NewSprjCubit, NewSprjState>(
      listener: (context, state) async {
        if (state is LoadingState) {
          isLoading = true;
        } else if (state is LoadedState) {
          isLoading = false;
          subProjectList.clear();
          constProgressList.clear();
          flatsMap.clear();
          // subProjectList = state.subProjects.where((i) => i.isNewSubProject == true).toList();
          subProjectList = state.subProjects;
          constProgressList = state.constProgress;
          flatsMap = state.flatsBySubProject;
        } else if (state is UserDataState) {
          qtr = state.qtr;
        } else if (state is DeleteState) {
          subProjectList.removeAt(state.index);
        } else if (state is SubPrjCopyState) {
          subPrjError = state.errorMsg ?? "";
          if (state.shouldNavigate) {
            final result = await context.pushNamed(
              AppRoutesName.addNewSPrjFormPage,
              extra: {
                "projectId": widget.projectId,
                "newProjectId": widget.newProjectId,
                "reraNo": widget.reraNo,
                "cityId": widget.cityId,
                "formType": "Edit",
              },
            );
            if (result == true && context.mounted) {
              setState(() {
                isShowCopyUi = false;
                selectedcopyIndex = -1;
              });
            }
            newSprjCubit.fetchSubProjects(projectId: widget.projectId, newPrjId: widget.newProjectId);
            subPrjNameC.clear();
          } else if (state.isValid == true) {
            newSprjCubit.fetchSubProjects(projectId: widget.projectId, newPrjId: widget.newProjectId);
            setState(() {
              isShowCopyUi = false;
              selectedcopyIndex = -1;
            });
            subPrjNameC.clear();
          }
        } else if (state is ErrorState) {
          CustomSnackHelper.customToastMsg(
            message: state.message,
            context: context,
            bgColor: AppColors.white,
            textColor: AppColors.black,
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.appBg,
        appBar: CustomAppBar(
          title: "New Sub-Project(${widget.projectId})",
          actions: [
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      backgroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(),
                      title: Text("Confirmation", style: AppTextStyle.ts18MB),
                      content: Text(
                        "Are you sure you want to Sync Sub-project. Once it is Sync you won't be able to add flats",
                        style: AppTextStyle.ts14RB,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            context.pop();
                          },
                          child: Text("CANCEL", style: AppTextStyle.ts16MB),
                        ),
                        TextButton(
                          onPressed: () {
                            context.pop();
                            newSprjCubit.submitSubProject(subProjectList: subProjectList);
                          },
                          child: Text("OK", style: AppTextStyle.ts16MB),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: Icon(Icons.sync, color: AppColors.red),
            ),
          ],
        ),
        body: SafeArea(
          child: BlocBuilder<NewSprjCubit, NewSprjState>(
            builder: (context, state) {
              return Stack(
                children: [
                  subProjectList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.download, color: Colors.black54, size: 100),
                              SizedBox(height: 15),
                              Text(
                                "No New Sub-Projects Added",
                                style: AppTextStyle.ts14RB.copyWith(color: Colors.black54),
                              ),
                            ],
                          ),
                        )
                      : isLoading
                      ? Center(child: CircularProgressIndicator())
                      : Padding(
                          padding: AppDimens.hvPadding,
                          child: ListView.builder(
                            itemCount: subProjectList.length,
                            itemBuilder: (_, index) {
                              final sprjData = subProjectList[index];
                              String constProgress =
                                  constProgressList
                                      .firstWhere((i) => i.constProgressId == sprjData.constructionProgressId!)
                                      .constProgress ??
                                  "";
                              final flatsList = flatsMap[sprjData.subPrjid] ?? [];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Card(
                                  color: sprjData.syncGlobalStatus == 0 ? AppColors.unSyncColor : AppColors.syncColor,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(4.0)),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 8.0),
                                              child: Text(sprjData.subPrjName ?? "", style: AppTextStyle.ts16RB),
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(6.0),
                                            decoration: BoxDecoration(color: AppColors.red),
                                            child: Text(sprjData.subPrjid ?? "", style: AppTextStyle.ts14RW),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4.0),
                                      Container(width: double.infinity, height: 1, color: Colors.grey.shade300),
                                      IntrinsicHeight(
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsetsGeometry.all(8.0),
                                                child: Text(
                                                  "SCR: ${sprjData.scr}",
                                                  style: AppTextStyle.ts12MB.copyWith(color: Colors.black54),
                                                ),
                                              ),
                                            ),
                                            Container(width: 1, color: Colors.grey.shade300),
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsetsGeometry.all(8.0),
                                                child: Text(
                                                  "Storey: ${sprjData.storey}",
                                                  style: AppTextStyle.ts12MB.copyWith(color: Colors.black54),
                                                ),
                                              ),
                                            ),
                                            Container(width: 1, color: Colors.grey.shade300),
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsetsGeometry.all(8.0),
                                                child: Text(
                                                  "Flats Per Floor: ${sprjData.flatsPerFloor}",
                                                  style: AppTextStyle.ts12MB.copyWith(color: Colors.black54),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(width: double.infinity, height: 1, color: Colors.grey.shade300),
                                      SizedBox(height: 4.0),
                                      Padding(
                                        padding: EdgeInsetsGeometry.all(8.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                constProgress,
                                                style: AppTextStyle.ts14MB.copyWith(color: Colors.black54),
                                              ),
                                            ),
                                            Text(
                                              "(DOS: ${DateFormat('MMM yyyy').format(DateTime.parse(sprjData.qtr == "" || sprjData.qtr == null ? qtr : sprjData.qtr!))})",
                                              style: AppTextStyle.ts14MB.copyWith(color: Colors.black54),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(width: double.infinity, height: 1, color: Colors.grey.shade300),
                                      SizedBox(height: 4.0),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                        child: Row(
                                          spacing: 12.0,
                                          children: [
                                            Expanded(
                                              child: InkWell(
                                                onTap: () async {
                                                  await context.pushNamed(
                                                    AppRoutesName.newFlatListPage,
                                                    extra: {
                                                      "projectId": sprjData.projectId,
                                                      "subPrjId": sprjData.subPrjid,
                                                      "flatGroupId": sprjData.flatGroup,
                                                      "cityId": widget.cityId,
                                                      "rateType": sprjData.rateType,
                                                      "syncGlobalStatus": sprjData.syncGlobalStatus ?? 0,
                                                    },
                                                  );

                                                  if (!context.mounted) return;
                                                  context.read<NewSprjCubit>().fetchSubProjects(
                                                    projectId: widget.projectId,
                                                    newPrjId: widget.newProjectId,
                                                  );
                                                },
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  padding: EdgeInsets.all(8.0),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.white,
                                                    border: Border.all(color: Colors.grey.shade300),
                                                    borderRadius: BorderRadius.circular(4.0),
                                                  ),
                                                  child: Text(
                                                    "Flat Details",
                                                    style: AppTextStyle.ts14BB.copyWith(color: AppColors.red),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: InkWell(
                                                onTap: sprjData.syncGlobalStatus == 1
                                                    ? () {
                                                        context.pushNamed(
                                                          AppRoutesName.addNewSPrjFormPage,
                                                          extra: {
                                                            "projectId": widget.projectId,
                                                            "newProjectId": widget.newProjectId,
                                                            "reraNo": widget.reraNo,
                                                            "newPrjEntity": sprjData,
                                                            "cityId": widget.cityId,
                                                            "formType": "Update",
                                                            "isFreeze": true,
                                                          },
                                                        );
                                                      }
                                                    : () async {
                                                        await context.pushNamed(
                                                          AppRoutesName.addNewSPrjFormPage,
                                                          extra: {
                                                            "projectId": widget.projectId,
                                                            "newProjectId": widget.newProjectId,
                                                            "reraNo": widget.reraNo,
                                                            "newPrjEntity": sprjData,
                                                            "cityId": widget.cityId,
                                                            "formType": "Update",
                                                          },
                                                        );

                                                        if (!context.mounted) return;
                                                        context.read<NewSprjCubit>().fetchSubProjects(
                                                          projectId: widget.projectId,
                                                          newPrjId: widget.newProjectId,
                                                        );
                                                      },
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  padding: EdgeInsets.all(8.0),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.white,
                                                    border: Border.all(color: Colors.grey.shade300),
                                                    borderRadius: BorderRadius.circular(4.0),
                                                  ),
                                                  child: sprjData.syncGlobalStatus == 1
                                                      ? Text(
                                                          "View",
                                                          style: AppTextStyle.ts14BB.copyWith(color: AppColors.red),
                                                        )
                                                      : Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          spacing: 10,
                                                          children: [
                                                            Icon(Icons.edit, color: AppColors.red, size: 22),
                                                            Text(
                                                              "Edit",
                                                              style: AppTextStyle.ts14BB.copyWith(color: AppColors.red),
                                                            ),
                                                          ],
                                                        ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 4.0),
                                      Container(width: double.infinity, height: 1, color: Colors.grey.shade300),
                                      SizedBox(height: 4.0),
                                      flatsList.isEmpty
                                          ? deleteWidget(sprjData: sprjData, index: index)
                                          : flatWidget(
                                              flatsData: flatsList,
                                              sprjData: sprjData,
                                              index: index,
                                              newSprjCubit: newSprjCubit,
                                            ),
                                      SizedBox(height: 4.0),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                  isShowCopyUi
                      ? copyWidget(
                          subPrj: subProjectList,
                          selectedIndex: selectedcopyIndex,
                          subprojectC: subPrjNameC,
                          onRadioChanged: (value) {
                            setState(() {
                              selectedcopyIndex = value;
                            });
                          },
                          onOkPressed: () {
                            if (subPrjNameC.text.isNotEmpty) {
                              setState(() {
                                isShowCopyUi = false;
                              });
                            }
                            newSprjCubit.validateAndCopy(
                              selectedCopyIndex: selectedcopyIndex,
                              subPrjName: subPrjNameC.text,
                              subProjectList: subProjectList,
                            );
                          },
                          onCancelPressed: () {
                            setState(() {
                              isShowCopyUi = false;
                            });
                          },
                          onTextChanged: (value) {
                            setState(() {
                              subPrjError = "";
                            });
                          },
                          errorMsg: subPrjError,
                        )
                      : SizedBox.shrink(),
                ],
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.red,
          onPressed: () async {
            if (subProjectList.isNotEmpty) {
              setState(() {
                isShowCopyUi = true;
              });
            } else {
              await context.pushNamed(
                AppRoutesName.addNewSPrjFormPage,
                extra: {
                  "projectId": widget.projectId,
                  "newProjectId": widget.newProjectId,
                  "reraNo": widget.reraNo,
                  "cityId": widget.cityId,
                  "formType": "Edit",
                },
              );
              newSprjCubit.fetchSubProjects(projectId: widget.projectId, newPrjId: widget.newProjectId);
            }
          },
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 0.5, color: AppColors.white),
            borderRadius: BorderRadiusGeometry.circular(100),
          ),
          child: Icon(Icons.add, color: AppColors.white),
        ),
      ),
    );
  }

  Widget deleteWidget({required NewSubProjectEntity sprjData, required int index}) {
    return InkWell(
      onTap: () {
        CutsomAlertDialogues.deleteDialogue(
          context: context,
          onDelete: () {
            context.pop();
            context.read<NewSprjCubit>().deleteSprj(subPrjid: sprjData.subPrjid!, index: index);
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Container(
          padding: EdgeInsets.all(6.0),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Text("Delete", style: AppTextStyle.ts14BB.copyWith(color: AppColors.red)),
        ),
      ),
    );
  }

  Widget flatWidget({
    required NewSprjCubit newSprjCubit,
    required List<NewFlatEntity> flatsData,
    required NewSubProjectEntity sprjData,
    required int index,
  }) {
    String flatType = flatsData.map((e) => e.flatType).join(", ");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SizedBox(height: 4.0),
        // Container(width: double.infinity, height: 1, color: Colors.grey.shade300),
        // SizedBox(height: 4.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Flexible(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10,
                  children: [
                    Text("Flats : ", style: AppTextStyle.ts14MB),
                    Flexible(child: Text(flatType, style: AppTextStyle.ts14RB)),
                  ],
                ),
              ),
              sprjData.syncGlobalStatus == 1 ? SizedBox.shrink() : deleteWidget(sprjData: sprjData, index: index),
              sprjData.syncGlobalStatus == 1
                  ? SizedBox.shrink()
                  : InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: AppColors.white,
                              shape: RoundedRectangleBorder(),
                              title: Text("Confirmation", style: AppTextStyle.ts18MB),
                              content: Text(
                                "Are you sure you want to Sync Sub-project. Once it is Sync you won't be able to add flats",
                                style: AppTextStyle.ts14RB,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    context.pop();
                                  },
                                  child: Text("CANCEL", style: AppTextStyle.ts16MB),
                                ),
                                TextButton(
                                  onPressed: () {
                                    context.pop();
                                    newSprjCubit.submitSubProject(subPrjData: sprjData);
                                  },
                                  child: Text("OK", style: AppTextStyle.ts16MB),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Container(
                          padding: EdgeInsets.all(6.0),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Text("Submit", style: AppTextStyle.ts14BB.copyWith(color: AppColors.red)),
                        ),
                      ),
                    ),
            ],
          ),
        ),
        sprjData.syncGlobalStatus == 1 ? SizedBox(height: 4.0) : SizedBox.shrink(),
        sprjData.syncGlobalStatus == 0
            ? SizedBox.shrink()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4.0,
                children: [
                  Container(width: double.infinity, height: 1, color: Colors.grey.shade300),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: AppColors.black,
                              shape: RoundedRectangleBorder(),
                              title: Text("Message from Server", style: AppTextStyle.ts18MW),
                              content: Text("Already Sync", style: AppTextStyle.ts14RW),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    context.pop();
                                  },
                                  child: Text("OK", style: AppTextStyle.ts16BW),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Text("Already Sync", style: AppTextStyle.ts12RB.copyWith(color: AppColors.red)),
                    ),
                  ),
                ],
              ),
      ],
    );
  }

  Widget copyWidget({
    required List<NewSubProjectEntity> subPrj,
    required int selectedIndex,
    required ValueChanged<int> onRadioChanged,
    required VoidCallback onOkPressed,
    required VoidCallback onCancelPressed,
    required String errorMsg,
    required TextEditingController subprojectC,
    required ValueChanged onTextChanged,
  }) {
    const int dontCopyValue = -1;
    return Stack(
      children: [
        ModalBarrier(dismissible: false, color: Colors.white54),
        Padding(
          padding: AppDimens.hvPadding,
          child: Container(
            decoration: BoxDecoration(color: AppColors.white),
            child: Padding(
              padding: AppDimens.hvPadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Choose Sub-Project to Copy", style: AppTextStyle.ts14BB.copyWith(color: Colors.black54)),
                  Flexible(
                    child: RadioGroup<int>(
                      groupValue: selectedIndex,
                      onChanged: (value) {
                        onRadioChanged(value!);
                      },
                      child: ListView(
                        shrinkWrap: true,
                        // physics: const NeverScrollableScrollPhysics(),
                        children: [
                          RadioListTile<int>(
                            dense: true,
                            activeColor: AppColors.red,
                            title: Text("Don't Copy"),
                            value: dontCopyValue,
                          ),
                          ...List.generate(subPrj.length, (index) {
                            return RadioListTile<int>(
                              dense: true,
                              activeColor: AppColors.red,
                              title: Text(subPrj[index].subPrjName ?? ""),
                              value: index,
                            );
                          }),
                          CustomTextField(
                            controller: subprojectC,
                            hintText: "Sub Project Name",
                            hintTextColor: Colors.grey.shade400,
                            cursorColor: AppColors.red,
                            borderColor: AppColors.red,
                            borderWidth: 2.0,
                            // onChanged: (value) {
                            //   setState(() {
                            //     errorMsg = "";
                            //   });
                            // },
                            onChanged: onTextChanged,
                            suffixIcon: errorMsg.isNotEmpty ? Icon(Icons.error, color: AppColors.red) : null,
                          ),
                          errorMsg.isEmpty ? Container() : CustomSnackHelper.errorWidget(messgage: errorMsg),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 15.0),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.35,
                    child: CustomElevatedButton(text: "OK", onPressed: onOkPressed),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.35,
                    child: CustomElevatedButton(text: "CANCEL", onPressed: onCancelPressed),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
