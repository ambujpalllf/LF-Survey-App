import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_dimens.dart';
import 'package:lf_survey/constants/app_text_style.dart';
import 'package:lf_survey/constants/snackbar_helper.dart';
import 'package:lf_survey/cubit/construction_monitering/cm_project/cm_prj_cubit.dart';
import 'package:lf_survey/cubit/construction_monitering/cm_project/cm_prj_state.dart';
import 'package:lf_survey/model/pams_survey/ps_prj_response.dart';
import 'package:lf_survey/routes/app_routes_name.dart';
import 'package:lf_survey/widgets/custom_app_bar.dart';
import 'package:lf_survey/widgets/custom_textform_field.dart';

class CMPrjPage extends StatefulWidget {
  const CMPrjPage({super.key});

  @override
  State<CMPrjPage> createState() => _CMPrjPageState();
}

class _CMPrjPageState extends State<CMPrjPage> {
  final FocusNode searchFocusNode = FocusNode();
  bool isFocused = false;
  TextEditingController searchC = TextEditingController();
  List<PsPrjDatum> projects = [];
  List<PsPrjDatum> filteredPrj = [];
  @override
  void initState() {
    super.initState();
    searchFocusNode.addListener(() {
      setState(() {
        isFocused = searchFocusNode.hasFocus;
      });
    });
    context.read<CmPrjCubit>().getProjects();
  }

  @override
  void dispose() {
    super.dispose();
    searchC.dispose();
    searchFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: CustomAppBar(
        title: "Project(0)",
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.download, color: AppColors.white),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.sync, color: AppColors.white),
          ),
          PopupMenuButton<String>(
            color: AppColors.white,
            iconColor: AppColors.white,
            onSelected: (value) {
              switch (value) {
                case "Image Sync":
                  context.pushNamed(AppRoutesName.cmImgListPage);
                  break;
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem<String>(
                value: "Clear DB",
                child: Text("Clear DB", style: AppTextStyle.ts14RB),
              ),
              PopupMenuItem<String>(
                value: "Image Sync",
                child: Text("Image Sync", style: AppTextStyle.ts14RB),
              ),
            ],
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
                  hintText: isFocused ? "Project Id, Name,  Address, Road Name" : null,
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
                  onChanged: (value) {},
                ),
              ),
              Expanded(
                child: BlocConsumer<CmPrjCubit, CmPrjState>(
                  listener: (context, state) {
                    if (state is LoadedState) {
                      projects.clear();
                      filteredPrj.clear();
                      projects.addAll(state.projects);
                      filteredPrj.addAll(state.projects);
                    } else if (state is FilterState) {
                      filteredPrj.clear();
                      filteredPrj.addAll(state.projects);
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
                  builder: (context, state) {
                    return state is LoadingState
                        ? Center(child: CircularProgressIndicator(color: AppColors.red))
                        : filteredPrj.isEmpty
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
                            itemCount: filteredPrj.length,
                            itemBuilder: (context, index) {
                              var prjData = filteredPrj[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: InkWell(
                                  onTap: () {
                                    context.pushNamed(AppRoutesName.cmSubPrjPage, extra: {"projectData": prjData});
                                  },
                                  child: Card(
                                    margin: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(4.0)),
                                    color: AppColors.white,
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
                                                child: Text(prjData.projectName ?? "", style: AppTextStyle.ts14MB),
                                              ),
                                              Text("${prjData.projectId}", style: AppTextStyle.ts14MB),
                                            ],
                                          ),
                                          Text(
                                            prjData.legalAddress ?? "",
                                            style: AppTextStyle.ts12RB.copyWith(color: Colors.grey),
                                          ),
                                          // Text("Builder Name", style: AppTextStyle.ts14MB),
                                          // Text("Builder Address", style: AppTextStyle.ts12RB.copyWith(color: Colors.grey)),
                                          Text("Sub Projects: 5 ", style: AppTextStyle.ts14MB),
                                          // counterwidget(title: 'Sub Projects: ', syncCount: '4', totalValue: '5'),
                                          counterwidget(
                                            title: 'Construction Monitoring: ',
                                            syncCount: '4',
                                            totalValue: '5',
                                          ),
                                          Row(
                                            spacing: 10,
                                            children: [
                                              Expanded(
                                                child: counterwidget(
                                                  title: 'Selfie: ',
                                                  syncCount: '4',
                                                  totalValue: '5',
                                                ),
                                              ),
                                              Text("Delete", style: AppTextStyle.ts14MB.copyWith(color: AppColors.red)),
                                            ],
                                          ),
                                          // SizedBox(
                                          //   width: double.infinity,
                                          //   child: CustomElevatedButton(
                                          //     borderRadius: 4.0,
                                          //     text: "Final Submit",
                                          //     onPressed: () {},
                                          //   ),
                                          // ),
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
            style: AppTextStyle.ts14MB.copyWith(color: AppColors.red),
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
