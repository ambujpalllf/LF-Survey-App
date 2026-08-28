import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_dimens.dart';
import 'package:lf_survey/constants/app_text_style.dart';
import 'package:lf_survey/constants/snackbar_helper.dart';
import 'package:lf_survey/constants/utils.dart';
import 'package:lf_survey/cubit/residential/new_prj_details/new_prj_details_cubit.dart';
import 'package:lf_survey/cubit/residential/new_prj_details/new_prj_details_state.dart';
import 'package:lf_survey/model/db_model/residential/new_project_entity.dart';
import 'package:lf_survey/model/residential/project_spinner.dart';
import 'package:lf_survey/routes/app_routes_name.dart';
import 'package:lf_survey/widgets/custom_app_bar.dart';

class NewProjectDetailsPage extends StatefulWidget {
  final NewProjectEntity newProjectEntity;
  const NewProjectDetailsPage({super.key, required this.newProjectEntity});

  @override
  State<NewProjectDetailsPage> createState() => _NewProjectDetailsPageState();
}

class _NewProjectDetailsPageState extends State<NewProjectDetailsPage> {
  List<CityList> cities = [];
  String cityName = "";
  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      context.read<NewPrjDetailsCubit>().fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: CustomAppBar(title: "New Project Detals"),
      body: SafeArea(
        child: BlocConsumer<NewPrjDetailsCubit, NewPrjDetailsState>(
          listener: (context, state) {
            if (state is LocalDbState) {
              cities.clear();
              cities.addAll(state.city);
              cityName = cities.firstWhere((e) => e.cityId == widget.newProjectEntity.cityId).city ?? "";
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
            return Padding(
              padding: AppDimens.hvPadding,
              child: SingleChildScrollView(
                child: Column(
                  spacing: 10.0,
                  children: [
                    Container(
                      decoration: BoxDecoration(color: AppColors.white),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          spacing: 12.0,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${widget.newProjectEntity.prjId}", style: AppTextStyle.ts14RB),
                            Divider(color: AppColors.greyLite),
                            Text("${widget.newProjectEntity.prjName}", style: AppTextStyle.ts14MB),
                            customTextWidget(title: "Project Type:", value: widget.newProjectEntity.reraPrjType ?? ""),
                            customTextWidget(title: "Rera No:", value: widget.newProjectEntity.reraNo ?? ""),
                            customTextWidget(
                              title: "Rera Not Launch:",
                              value: "${widget.newProjectEntity.reraNotLaunch}",
                            ),
                            customTextWidget(title: "Address:", value: widget.newProjectEntity.prjAddr ?? ""),
                            customTextWidget(title: "City:", value: cityName),
                            customTextWidget(title: "Builder Name:", value: widget.newProjectEntity.builderName ?? ""),
                            customTextWidget(
                              title: "Architect Name:",
                              value: widget.newProjectEntity.architectName ?? "",
                            ),
                            customTextWidget(title: "Mobile Number:", value: widget.newProjectEntity.mobileNo ?? ""),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 30.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        ),
                        onPressed: () async {
                          if (!await Utils.checkLocationAndGpsPermission(context)) return;
                          if (!context.mounted) return;
                          context.pushNamed(
                            AppRoutesName.newSubPrjListPage,
                            extra: {
                              "projectId": 0,
                              "newProjectId": widget.newProjectEntity.prjId,
                              "reraNo": widget.newProjectEntity.reraNo,
                              "cityId": widget.newProjectEntity.cityId,
                            },
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Transform.scale(scale: 1.3, child: Icon(Icons.add, color: AppColors.white, size: 20)),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                "Add New Sub-Project",
                                style: AppTextStyle.ts16BW,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 30.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        ),
                        onPressed: () async {
                          if (!await Utils.checkLocationAndGpsPermission(context)) return;
                          if (!context.mounted) return;
                          context.pushNamed(
                            AppRoutesName.addNewImagePrjPage,
                            extra: {"projectId": widget.newProjectEntity.prjId, "prjType": null},
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Transform.scale(
                              scale: 1.3,
                              child: Icon(Icons.camera_alt, color: AppColors.white, size: 20),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text("Photo View", style: AppTextStyle.ts16BW, overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Row customTextWidget({required String title, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12.0,
      children: [
        Text(title, style: AppTextStyle.ts14RB),
        Expanded(child: Text(value, style: AppTextStyle.ts14RB)),
      ],
    );
  }
}
