import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_dimens.dart';
import 'package:lf_survey/constants/app_text_style.dart';
import 'package:lf_survey/constants/snackbar_helper.dart';
import 'package:lf_survey/cubit/pams_survey/ps_land/ps_land_cubit.dart';
import 'package:lf_survey/cubit/pams_survey/ps_land/ps_land_state.dart';
import 'package:lf_survey/model/pams_survey/land_response.dart';
import 'package:lf_survey/model/pams_survey/ps_prj_response.dart';
import 'package:lf_survey/routes/app_routes_name.dart';
import 'package:lf_survey/widgets/custom_app_bar.dart';

class PsLandsPage extends StatefulWidget {
  final PsPrjDatum prjDatum;
  const PsLandsPage({super.key, required this.prjDatum});

  @override
  State<PsLandsPage> createState() => _PsLandsPageState();
}

class _PsLandsPageState extends State<PsLandsPage> {
  bool isLoading = false;
  List<PsLandDatum> lands = [];

  @override
  void initState() {
    super.initState();
    context.read<PsLandCubit>().getLands(projectId: widget.prjDatum.projectId!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: CustomAppBar(title: "Lands Info"),
      body: BlocConsumer<PsLandCubit, PsLandState>(
        listener: (context, state) {
          if (state is LoadingState) {
            isLoading = true;
          } else if (state is LoadedState) {
            isLoading = false;
            lands.clear();
            lands.addAll(state.lands);
          } else if (state is ErrorState) {
            isLoading = false;
            CustomSnackHelper.customToastMsg(
              context: context,
              message: state.message,
              bgColor: AppColors.white,
              textColor: AppColors.black,
            );
          }
        },
        builder: (context, state) {
          return isLoading
              ? Center(child: CircularProgressIndicator(color: AppColors.red))
              : lands.isEmpty
              ? Center(child: Text("No data found!", style: AppTextStyle.ts14MB))
              : Padding(
                  padding: AppDimens.hvPadding,
                  child: ListView.builder(
                    itemCount: lands.length,
                    itemBuilder: (_, index) {
                      var item = lands[index];
                      return InkWell(
                        onTap: () {
                          context.pushNamed(
                            AppRoutesName.psLandFormPage,
                            extra: {"projectData": widget.prjDatum, "landData": item, "isUpdate": true},
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Card(
                            margin: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(4.0)),
                            color: AppColors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                spacing: 4.0,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("Project Id: ${item.projectId}", style: AppTextStyle.ts14MB),
                                  Text("Access Road Type: ${item.typeOfAccessRoad}", style: AppTextStyle.ts14RB),
                                  Text(
                                    "Sesmic Zone: ${item.criticalParametersSeismicZone}",
                                    style: AppTextStyle.ts14RB,
                                  ),
                                  Text(
                                    "Coastal Regularty Zone: ${item.criticalParametersSeismicZone}",
                                    style: AppTextStyle.ts14RB,
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
      floatingActionButton: BlocBuilder<PsLandCubit, PsLandState>(
        builder: (context, state) {
          return lands.isNotEmpty
              ? SizedBox.shrink()
              : FloatingActionButton(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(100)),
                  onPressed: () {
                    context.pushNamed(AppRoutesName.psLandFormPage, extra: {"projectData": widget.prjDatum});
                  },
                  child: Icon(Icons.add),
                );
        },
      ),
    );
  }
}
