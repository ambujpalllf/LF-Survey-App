import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lf_survey/app_popups/cutsom_alert_dialogues.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_dimens.dart';
import 'package:lf_survey/constants/app_text_style.dart';
import 'package:lf_survey/constants/snackbar_helper.dart';
import 'package:lf_survey/constants/utils.dart';
import 'package:lf_survey/cubit/residential/sub_project/sprj_flat_details/s_prj_flat_details_cubit.dart';
import 'package:lf_survey/cubit/residential/sub_project/sprj_flat_details/s_prj_flat_details_state.dart';
import 'package:lf_survey/model/db_model/residential/flat_entity.dart';
import 'package:lf_survey/model/db_model/residential/sub_prj_entity.dart';
import 'package:lf_survey/model/residential/project_spinner.dart';
import 'package:lf_survey/widgets/custom_app_bar.dart';

// ignore: must_be_immutable
class SubProjectFlatDetailsPage extends StatefulWidget {
  SubProjectEntity subProjectsDatum;
  SubProjectFlatDetailsPage({super.key, required this.subProjectsDatum});

  @override
  State<SubProjectFlatDetailsPage> createState() => _SubProjectFlatDetailsPageState();
}

class _SubProjectFlatDetailsPageState extends State<SubProjectFlatDetailsPage> {
  bool isLoading = false;
  int totalFlats = 0;
  List<FlatEntity> flatData = [];
  List<FlatTypeList> flatTypeData = [];
  TextEditingController scrC = TextEditingController();
  TextEditingController totalFlatsC = TextEditingController();
  TextEditingController flatSoldC = TextEditingController();
  TextEditingController flatUnSoldC = TextEditingController();
  TextEditingController saleableSizeC = TextEditingController();
  TextEditingController carpetFlatSizeC = TextEditingController();
  @override
  void initState() {
    super.initState();
    context.read<SPrjFlatDetailsCubit>().getFlats(
      subProjectId: widget.subProjectsDatum.subProjectId!,
      projectId: widget.subProjectsDatum.projectId!,
    );
  }

  @override
  void dispose() {
    super.dispose();
    scrC.dispose();
    totalFlatsC.dispose();
    flatSoldC.dispose();
    flatUnSoldC.dispose();
    saleableSizeC.dispose();
    carpetFlatSizeC.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: CustomAppBar(title: "Flat Details"),
      body: SafeArea(
        child: Padding(
          padding: AppDimens.hvPadding,
          child: BlocConsumer<SPrjFlatDetailsCubit, SPrjFlatDetailsState>(
            buildWhen: (previous, current) => current is LoadingState || current is LoadedState,
            listener: (context, state) {
              if (state is LoadedState) {
                flatData.clear();
                flatData.addAll(state.flatsData);
                isLoading = false;
                flatTypeData.clear();
                flatTypeData.addAll(state.flatstypeData);
                widget.subProjectsDatum = state.subProjectsDatum;
              } else if (state is LoadingState) {
                isLoading = true;
              } else if (state is SuccessState) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.read<SPrjFlatDetailsCubit>().getFlats(
                    subProjectId: widget.subProjectsDatum.subProjectId!,
                    projectId: widget.subProjectsDatum.projectId!,
                  );
                });
              } else if (state is ErrorState) {
                CustomSnackHelper.customToastMsg(
                  context: context,
                  bgColor: AppColors.white,
                  textColor: AppColors.black,
                  message: state.message,
                );
              }
            },
            builder: (context, state) {
              return flatData.isEmpty
                  ? Center(
                      child: isLoading
                          ? CircularProgressIndicator()
                          : Text("No data found!", style: AppTextStyle.ts14RB),
                    )
                  : ListView.builder(
                      itemCount: flatData.length,
                      itemBuilder: (_, index) {
                        var itemData = flatData[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: InkWell(
                            onTap: () async {
                              final locPermission = await Utils.checkLocationAndGpsPermission(context);
                              if (!context.mounted) return;
                              if (!locPermission) {
                                CustomSnackHelper.errorToast(message: "Please enable location permission and GPS");
                                return;
                              }
                              if (widget.subProjectsDatum.syncGlobalStatus == 1) {
                                CustomSnackHelper.customToastMsg(
                                  context: context,
                                  bgColor: AppColors.white,
                                  textColor: AppColors.black,
                                  message: "Can not edit the flat detail now.",
                                );
                                return;
                              } else if (widget.subProjectsDatum.bookingStop != 0) {
                                // CustomSnackHelper.customToastMsg(
                                //   context: context,
                                //   bgColor: AppColors.white,
                                //   textColor: AppColors.black,
                                //   message: "Can not edit the flat detail now. Booking Stopped.",
                                // );
                                CutsomAlertDialogues.bookingStopDialogue(
                                  context: context,
                                  accept: () {
                                    Navigator.pop(context);
                                    widget.subProjectsDatum.bookingStop = 0;
                                    context.read<SPrjFlatDetailsCubit>().updateBookingStop(
                                      subProject: widget.subProjectsDatum,
                                    );
                                  },
                                );
                                return;
                              }
                              FlatTypeList flatTypeItemData = flatTypeData.firstWhere(
                                (i) => i.flatId == itemData.flatId,
                              );
                              totalFlats = itemData.flatSold! + itemData.flatUnsold!;
                              scrC.text = "${widget.subProjectsDatum.scr}";
                              flatSoldC.text = itemData.flatSold?.toString() ?? "";
                              flatUnSoldC.text = itemData.flatUnsold?.toString() ?? "";
                              saleableSizeC.text = itemData.flatSize ?? "";
                              carpetFlatSizeC.text = itemData.flatSizeCarpet ?? "";

                              CutsomAlertDialogues.subprojectFlatDetailsDialgoue(
                                context: context,
                                subProjectsDatum: widget.subProjectsDatum,
                                flatData: itemData,
                                totalFlats: totalFlats,
                                flatTypeData: flatTypeItemData,
                                flatCount: itemData.flatType ?? "",
                                rateType: widget.subProjectsDatum.rateType!,
                                scrC: scrC,
                                totalFlatsC: totalFlatsC,
                                flatSoldC: flatSoldC,
                                flatUnSoldC: flatUnSoldC,
                                saleableSizeC: saleableSizeC,
                                carpetFlatSizeC: carpetFlatSizeC,
                              );
                            },

                            child: Container(
                              decoration: BoxDecoration(
                                color: itemData.dataFilled! == 1 ? AppColors.syncColor : AppColors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.greyLite,
                                    blurRadius: 6,
                                    spreadRadius: 2,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 14),
                                    color: AppColors.red,
                                    child: Text(itemData.flatType ?? "", style: AppTextStyle.ts14MW),
                                  ),
                                  Container(height: 1, color: AppColors.greyLite),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      spacing: 16,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: flatDataWidget(
                                            title: "Sales",
                                            key: "Flat Sold ",
                                            value: "${itemData.flatSold}",
                                            key1: 'Flat Unsold ',
                                            value1: '${itemData.flatUnsold}',
                                          ),
                                        ),
                                        Expanded(
                                          child: flatDataWidget(
                                            title: "Size",
                                            key: "Flat Size ",
                                            value: itemData.flatSize ?? "",
                                            key1: 'Carpet Size',
                                            value1: itemData.flatSizeCarpet == ""
                                                ? "N.A."
                                                : itemData.flatSizeCarpet ?? "N.A.",
                                          ),
                                        ),
                                        Expanded(
                                          child: flatDataWidget(
                                            title: "Avg Size",
                                            key: "Size Avg",
                                            value: "${itemData.flatSizeAvg}",
                                            key1: 'Carpet Avg ',
                                            value1: '${itemData.flatSizeCarpetAvg}',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
            },
          ),
        ),
      ),
    );
  }

  Widget flatDataWidget({
    required String title,
    required String key,
    required String value,
    required String key1,
    required String value1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyle.ts12MB),
        Text("$key: $value", style: AppTextStyle.ts12MB.copyWith(color: Colors.grey.shade500)),
        Text("$key1: $value1", style: AppTextStyle.ts12MB.copyWith(color: Colors.grey.shade500)),
      ],
    );
  }
}
