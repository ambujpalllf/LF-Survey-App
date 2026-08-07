import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_dimens.dart';
import 'package:lf_survey/constants/app_text_style.dart';
import 'package:lf_survey/constants/snackbar_helper.dart';
import 'package:lf_survey/cubit/residential/new_assign_prj_locations/new_assign_prj_loc_cubit.dart';
import 'package:lf_survey/cubit/residential/new_assign_prj_locations/new_assign_prj_loc_state.dart';
import 'package:lf_survey/widgets/custom_app_bar.dart';
import 'package:lf_survey/widgets/custom_elevated_btn.dart';
import 'package:lf_survey/widgets/custom_textform_field.dart';

class NewAssignPrjLocFilterPage extends StatefulWidget {
  const NewAssignPrjLocFilterPage({super.key});

  @override
  State<NewAssignPrjLocFilterPage> createState() => _NewAssignPrjLocFilterPageState();
}

class _NewAssignPrjLocFilterPageState extends State<NewAssignPrjLocFilterPage> {
  List<Map<String, dynamic>> locations = [];
  List<Map<String, dynamic>> filterLocations = [];
  @override
  void initState() {
    super.initState();
    context.read<NewAssignPrjLocCubit>().getProject();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "New Assign Project Locations"),
      body: SafeArea(
        child: Padding(
          padding: AppDimens.hvPadding,
          child: Container(
            padding: AppDimens.hvPadding,
            decoration: BoxDecoration(color: AppColors.white),
            child: Column(
              children: [
                CustomTextformField(
                  hintText: "Search city here...",
                  onChanged: (value) {
                    context.read<NewAssignPrjLocCubit>().searchItem(locations: locations, query: value);
                  },
                ),
                BlocBuilder<NewAssignPrjLocCubit, NewAssignPrjLocState>(
                  builder: (context, state) {
                    return filterLocations.isNotEmpty
                        ? CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            checkColor: Colors.white,
                            activeColor: AppColors.red,
                            controlAffinity: ListTileControlAffinity.leading,
                            value:
                                filterLocations.isNotEmpty &&
                                filterLocations.every((item) => item["isSelected"] == true),
                            title: Text("Select All", style: AppTextStyle.ts14RB),
                            onChanged: (bool? value) {
                              context.read<NewAssignPrjLocCubit>().toggleSelectAll(
                                locations: filterLocations,
                                isSelected: value ?? false,
                              );
                            },
                          )
                        : SizedBox.shrink();
                  },
                ),
                Expanded(
                  child: BlocConsumer<NewAssignPrjLocCubit, NewAssignPrjLocState>(
                    listener: (context, state) {
                      if (state is ErrorState) {
                        CustomSnackHelper.customToastMsg(
                          context: context,
                          message: state.message,
                          bgColor: AppColors.white,
                          textColor: AppColors.black,
                        );
                      } else if (state is LocalDbState) {
                        locations.clear();
                        filterLocations.clear();
                        locations.addAll(state.locations);
                        filterLocations.addAll(state.locations);
                      } else if (state is SearchedState) {
                        filterLocations.clear();
                        filterLocations.addAll(state.locations);
                      }
                    },
                    builder: (context, state) {
                      if (state is LoadingState) {
                        return Center(child: CircularProgressIndicator(color: AppColors.red));
                      }
                      return filterLocations.isEmpty
                          ? Center(child: Text("Data Not Found!"))
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: filterLocations.length,
                              itemBuilder: (context, index) {
                                return CheckboxListTile(
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
                                  controlAffinity: ListTileControlAffinity.leading,
                                  checkColor: Colors.white,
                                  activeColor: AppColors.red,
                                  value: filterLocations[index]["isSelected"],
                                  // title: Text(filterLocations[index]["title"] ?? "", style: AppTextStyle.ts14RB),
                                  title: Text(filterLocations[index]["cityName"] ?? "", style: AppTextStyle.ts14RB),
                                  onChanged: (bool? value) {
                                    context.read<NewAssignPrjLocCubit>().toggleItemSelection(
                                      locations: filterLocations,
                                      index: index,
                                    );
                                  },
                                );
                              },
                            );
                    },
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: CustomElevatedButton(
                    text: "Select Location",
                    onPressed: () {
                      List<int> selected = filterLocations
                          .where((i) => i['isSelected'] == true && i['cityId'] != null)
                          .map<int>((i) => i['cityId'] as int)
                          .toList();
                      if (selected.isEmpty) {
                        CustomSnackHelper.customToastMsg(
                          context: context,
                          message: "Please select a location to continue.",
                          bgColor: AppColors.white,
                          textColor: AppColors.black,
                        );
                        return;
                      }
                      Navigator.pop(context, {"loactions": selected});
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
