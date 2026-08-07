import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lf_survey/app_popups/custom_bottomsheet.dart';
import 'package:lf_survey/app_popups/cutsom_alert_dialogues.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_text_style.dart';
import 'package:lf_survey/constants/snackbar_helper.dart';
import 'package:lf_survey/cubit/residential/sub_project/new_flats/new_flats_cubit.dart';
import 'package:lf_survey/cubit/residential/sub_project/new_flats/new_flats_state.dart';
import 'package:lf_survey/model/db_model/residential/new_flat_entity.dart';
import 'package:lf_survey/model/residential/project_spinner.dart';
import 'package:lf_survey/widgets/custom_app_bar.dart';

class NewFlatListPage extends StatefulWidget {
  final int flatgroupId;
  final String subPrjId;
  final String rateType;
  final int syncGlobalStatus;
  const NewFlatListPage({
    super.key,
    required this.flatgroupId,
    required this.subPrjId,
    required this.rateType,
    required this.syncGlobalStatus,
  });

  @override
  State<NewFlatListPage> createState() => _NewFlatListPageState();
}

class _NewFlatListPageState extends State<NewFlatListPage> {
  List<FlatTypeList> flatsType = [];
  Map<String, dynamic>? selectedFlatType;
  List<NewFlatEntity> flats = [];
  TextEditingController saleableFlatC = TextEditingController();
  TextEditingController carpetFlatC = TextEditingController();
  TextEditingController flatSoldC = TextEditingController();
  TextEditingController totalFlatsC = TextEditingController();
  FocusNode flatSoldFN = FocusNode();
  FocusNode totalFlatFN = FocusNode();
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    context.read<NewFlatsCubit>().fetchData();
    context.read<NewFlatsCubit>().fetchFlatData(suprj: widget.subPrjId);
  }

  @override
  void dispose() {
    super.dispose();
    saleableFlatC.dispose();
    carpetFlatC.dispose();
    flatSoldC.dispose();
    totalFlatsC.dispose();
    flatSoldFN.dispose();
    totalFlatFN.dispose();
  }

  @override
  Widget build(BuildContext context) {
    NewFlatsCubit newFlatsCubit = context.read<NewFlatsCubit>();
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: CustomAppBar(title: "New Flat List"),
      body: SafeArea(
        child: BlocListener<NewFlatsCubit, NewFlatsState>(
          listener: (context, state) {
            if (state is LocalDbState) {
              flatsType.clear();
              flatsType.addAll(state.flats.where((i) => i.flatTypeId == widget.flatgroupId));
              isLoading = false;
            } else if (state is ErrorState) {
              CustomSnackHelper.customToastMsg(
                context: context,
                message: state.message,
                bgColor: AppColors.white,
                textColor: AppColors.black,
              );
              isLoading = false;
            } else if (state is LoadingState) {
              isLoading = true;
            } else if (state is FlatLoadedState) {
              flats.clear();
              flats.addAll(state.flats);
              isLoading = false;
            } else if (state is DeleteState) {
              flats.removeAt(state.index);
              isLoading = false;
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: BlocBuilder<NewFlatsCubit, NewFlatsState>(
              builder: (context, state) {
                return isLoading
                    ? Center(child: CircularProgressIndicator(color: AppColors.red))
                    : flats.isEmpty
                    ? Center(child: Text("No data found !", style: AppTextStyle.ts14RB))
                    : ListView.builder(
                        itemCount: flats.length,
                        itemBuilder: (context, index) {
                          var flatData = flats[index];
                          return InkWell(
                            onTap: flatData.syncGlobalStatus == 1
                                ? null
                                : () async {
                                    saleableFlatC.text = flatData.flatSize ?? "";
                                    carpetFlatC.text = flatData.carpetSize ?? "";
                                    flatSoldC.text = flatData.flatSold.toString();
                                    totalFlatsC.text = flatData.totalFlats.toString();
                                    final resp = await CustomBottomsheet.addNewFlatBtmSheet(
                                      context: context,
                                      selectedflatId: flatData.flatTypeId,
                                      subPrjId: widget.subPrjId,
                                      rateType: widget.rateType,
                                      flats: flats,
                                      flatsType: flatsType,
                                      selectedFlatType: selectedFlatType,
                                      saleableFaltC: saleableFlatC,
                                      carpetFlatC: carpetFlatC,
                                      flatSoldC: flatSoldC,
                                      totalFlatC: totalFlatsC,
                                      flatSoldFN: flatSoldFN,
                                      totalFlatsFN: totalFlatFN,
                                      isUpdate: true,
                                      flatId: flatData.newFlatId ?? "",
                                    );
                                    if (resp == true) {
                                      newFlatsCubit.fetchFlatData(suprj: widget.subPrjId);
                                    }
                                  },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: flatData.syncGlobalStatus == 1 ? AppColors.syncColor : AppColors.unSyncColor,
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
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          alignment: Alignment.center,
                                          height: MediaQuery.of(context).size.height * 0.05,
                                          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 14),
                                          color: AppColors.red,
                                          child: Text(flatData.flatType ?? "", style: AppTextStyle.ts14MW),
                                        ),
                                        flatData.syncGlobalStatus == 1
                                            ? Container()
                                            : InkWell(
                                                onTap: () {
                                                  CutsomAlertDialogues.deleteDialogue(
                                                    context: context,
                                                    onDelete: () {
                                                      context.pop();
                                                      newFlatsCubit.deleteFlat(
                                                        suprj: flatData.newFlatId!,
                                                        index: index,
                                                      );
                                                    },
                                                  );
                                                },
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  height: MediaQuery.of(context).size.height * 0.05,
                                                  padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 14),
                                                  color: AppColors.red,
                                                  child: Icon(Icons.delete, color: AppColors.white),
                                                ),
                                              ),
                                      ],
                                    ),
                                    Container(height: 1, color: AppColors.greyLite),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: flatDataWidget(
                                              title: "Sales",
                                              key: "Flat Sold ",
                                              value: "${flatData.flatSold}",
                                              key1: 'Total Flats ',
                                              value1: "${flatData.totalFlats}",
                                            ),
                                          ),
                                          Expanded(
                                            child: flatDataWidget(
                                              title: "Size",
                                              key: "Flat Size ",
                                              value: "${flatData.flatSize}",
                                              key1: 'Carpet Size',
                                              value1: "${flatData.carpetSize}",
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
      ),
      floatingActionButton: widget.syncGlobalStatus == 1
          ? null
          : FloatingActionButton(
              backgroundColor: AppColors.red,
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 0.5, color: AppColors.white),
                borderRadius: BorderRadiusGeometry.circular(100),
              ),
              onPressed: () async {
                final resp = await CustomBottomsheet.addNewFlatBtmSheet(
                  context: context,
                  subPrjId: widget.subPrjId,
                  rateType: widget.rateType,
                  flats: flats,
                  flatsType: flatsType,
                  selectedFlatType: selectedFlatType,
                  saleableFaltC: saleableFlatC,
                  carpetFlatC: carpetFlatC,
                  flatSoldC: flatSoldC,
                  totalFlatC: totalFlatsC,
                  flatSoldFN: flatSoldFN,
                  totalFlatsFN: totalFlatFN,
                );
                if (resp == true) {
                  newFlatsCubit.fetchFlatData(suprj: widget.subPrjId);
                }
              },
              child: Icon(Icons.add, color: AppColors.white),
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
