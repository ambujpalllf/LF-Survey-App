import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_dimens.dart';
import 'package:lf_survey/constants/app_text_style.dart';
import 'package:lf_survey/constants/snackbar_helper.dart';
import 'package:lf_survey/cubit/residential/project_search/prj_search_cubit.dart';
import 'package:lf_survey/cubit/residential/project_search/prj_search_state.dart';
import 'package:lf_survey/model/residential/prj_search_details.dart';
import 'package:lf_survey/model/residential/project_search_response.dart';
import 'package:lf_survey/widgets/custom_app_bar.dart';
import 'package:lf_survey/widgets/custom_table.dart';
import 'package:lf_survey/widgets/custom_textform_field.dart';

class ProjectSearchPage extends StatefulWidget {
  const ProjectSearchPage({super.key});

  @override
  State<ProjectSearchPage> createState() => _ProjectSearchPageState();
}

class _ProjectSearchPageState extends State<ProjectSearchPage> {
  bool isLoading = false;
  TextEditingController searchC = TextEditingController();
  List<ProjectSearchDatum> projects = [];
  PrjSearchDetails? prjDetails;

  FocusNode searchFocus = FocusNode();

  @override
  void dispose() {
    super.dispose();
    searchC.dispose();
    searchFocus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width * 0.4;
    PrjSearchCubit prjSearchCubit = context.read<PrjSearchCubit>();
    return BlocListener<PrjSearchCubit, PrjSearchState>(
      listener: (context, state) {
        if (state is LoadingState) {
          isLoading = true;
        } else if (state is LoadedState) {
          projects.clear();
          projects.addAll(state.projects);
          isLoading = false;
        } else if (state is ClearState) {
          isLoading = false;
          projects.clear();
        } else if (state is PrjDetailsState) {
          isLoading = false;
          searchC.clear();
          projects.clear();
          prjDetails = state.prjDetails;
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
      child: Scaffold(
        backgroundColor: AppColors.appBg,
        appBar: CustomAppBar(title: "Project Search"),
        body: SafeArea(
          child: Padding(
            padding: AppDimens.hvPadding,
            child: Column(
              children: [
                CustomTextformField(
                  focusNode: searchFocus,
                  controller: searchC,
                  filled: true,
                  fillColor: AppColors.white,
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  onChanged: (value) {
                    prjDetails = null;
                    prjSearchCubit.searchProject(query: value);
                  },
                ),

                const SizedBox(height: 16),
                Expanded(
                  child: BlocBuilder<PrjSearchCubit, PrjSearchState>(
                    builder: (_, state) {
                      if (isLoading) {
                        return const Center(child: CircularProgressIndicator(color: Colors.red));
                      }

                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            if (projects.isNotEmpty)
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: projects.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: InkWell(
                                      onTap: () {
                                        searchFocus.unfocus();
                                        prjSearchCubit.getPrjDetails(projectId: "${projects[index].projectId}");
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(4),
                                          color: AppColors.white,
                                          boxShadow: const [
                                            BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 4)),
                                          ],
                                        ),
                                        child: Text(projects[index].projectName ?? "", style: AppTextStyle.ts14MB),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            if (prjDetails != null) ...[
                              const SizedBox(height: 20),
                              CustomTable(tableData: prjDetails!.data!, columnWidth: width),
                              const SizedBox(height: 25),
                              // CustomTable1(tableData: prjDetails!.table1!, columnWidth: width),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
                BlocBuilder<PrjSearchCubit, PrjSearchState>(
                  builder: (context, state) {
                    return prjDetails != null
                        ? InkWell(
                            onTap: () {
                              prjSearchCubit.openProjectImgUrl(projectId: "${prjDetails!.data![0].projectId}");
                            },
                            child: Text(
                              "Project Photo View Here",
                              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                            ),
                          )
                        : SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
