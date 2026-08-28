import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lf_survey/app_popups/cutsom_alert_dialogues.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_dimens.dart';
import 'package:lf_survey/constants/app_text_style.dart';
import 'package:lf_survey/constants/utils.dart';
import 'package:lf_survey/cubit/residential/sub_project/sprj_details/s_prj_details_cubit.dart';
import 'package:lf_survey/cubit/residential/sub_project/sprj_details/s_prj_details_state.dart';
import 'package:lf_survey/model/db_model/residential/project_entity.dart';
import 'package:lf_survey/model/db_model/residential/sub_prj_entity.dart';
import 'package:lf_survey/model/residential/project_spinner.dart';
import 'package:lf_survey/routes/app_routes_name.dart';
import 'package:lf_survey/widgets/custom_app_bar.dart';
import 'package:lf_survey/widgets/custom_elevated_btn.dart';

enum AreaType { saleable, carpet }

// ignore: must_be_immutable
class SubProjectDetailsPage extends StatefulWidget {
  // final SubProjectsDatum subProjectsDatum;
  // final ProjectsDatum projectData;
  SubProjectEntity subProjectsDatum;
  final ProjectEntity projectData;
  SubProjectDetailsPage({super.key, required this.subProjectsDatum, required this.projectData});

  @override
  State<SubProjectDetailsPage> createState() => _SubProjectDetailsPageState();
}

class _SubProjectDetailsPageState extends State<SubProjectDetailsPage> {
  //   String reraType = "";
  int freezeType = 0;
  List<CityList> city = [];
  bool _isLocked = false;
  AreaType _selectedType = AreaType.saleable;

  @override
  void initState() {
    super.initState();
    _isLocked = widget.subProjectsDatum.isCarpetOrSaleableChoosen == 1;
    // getReraType();
    context.read<SPrjDetailsCubit>().fetchCity(
      projectId: widget.subProjectsDatum.projectId!,
      subPrjId: widget.subProjectsDatum.subProjectId!,
    );
  }

  // Future<void> getReraType() async {
  //   try {
  //     final response = await DBHelper. (sPrjId: widget.subProjectsDatum.subProjectId!);
  //     debugPrint("DGDGDGDGD: $response");
  //     if (!mounted) return;
  //     if (response != null) {
  //       freezeType = response;
  //     }
  //   } catch (e) {
  //     CustomSnackHelper.errorSnackbar(context: context, message: e.toString());
  //   }
  // }

  void _handleLocalDbState(LocalDbState state) {
    city
      ..clear()
      ..addAll(state.cityData);

    widget.subProjectsDatum = state.subProjectData;

    //  Already chosen → never lock
    if (widget.subProjectsDatum.isCarpetOrSaleableChoosen == 1) {
      setState(() {
        _isLocked = false;
      });

      return;
    }

    final CityList cityData = city.firstWhere((i) => i.cityId == widget.projectData.cityId, orElse: () => CityList());

    bool isLocked;

    // Apply city freeze logic
    if (cityData.cityId == null || cityData.cityId == 0) {
      isLocked = true; // default lock if city missing
    } else {
      isLocked = cityData.areaTypeFreeze != 1;
    }

    setState(() {
      _isLocked = isLocked;
    });
  }

  @override
  Widget build(BuildContext context) {
    final SPrjDetailsCubit sPrjDetailsCubit = context.read<SPrjDetailsCubit>();
    final double width = MediaQuery.of(context).size.width;
    return BlocListener<SPrjDetailsCubit, SPrjDetailsState>(
      listener: (context, state) {
        if (state is LocalDbState) {
          _handleLocalDbState(state);
        } else if (state is SuccessState) {
          setState(() => _isLocked = false);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.appBg,
        appBar: CustomAppBar(title: "Sub-Project Details"),
        body: SafeArea(
          child: Stack(
            children: [
              IgnorePointer(
                ignoring: _isLocked,
                child: Padding(
                  padding: AppDimens.hvPadding,
                  child: Column(
                    spacing: 12.0,
                    children: [
                      Card(
                        color: AppColors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(4.0)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 4.0),
                              child: Text(
                                "${widget.subProjectsDatum.subProjectName}(${widget.subProjectsDatum.subProjectId})",
                                style: AppTextStyle.ts16RB,
                              ),
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
                                        "Wing: ${widget.subProjectsDatum.wings}",
                                        style: AppTextStyle.ts12RB.copyWith(color: Colors.black54),
                                      ),
                                    ),
                                  ),
                                  Container(width: 1, color: Colors.grey.shade300),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsetsGeometry.all(8.0),
                                      child: Text(
                                        "Storey: ${widget.subProjectsDatum.storey}",
                                        style: AppTextStyle.ts12RB.copyWith(color: Colors.black54),
                                      ),
                                    ),
                                  ),
                                  Container(width: 1, color: Colors.grey.shade300),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsetsGeometry.all(8.0),
                                      child: Text(
                                        "Flates Per Floor: ${widget.subProjectsDatum.flatsPerFloor}",
                                        style: AppTextStyle.ts12RB.copyWith(color: Colors.black54),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(width: double.infinity, height: 1, color: Colors.grey.shade300),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: width * 0.6,
                        child: customSuffixIcButton(
                          title: "FLAT DETAILS",
                          icon: Icons.arrow_forward_ios,
                          onPressed: () {
                            context.pushNamed(
                              AppRoutesName.subProjectFlatDetailsPage,
                              extra: {"subProjectData": widget.subProjectsDatum},
                            );
                          },
                        ),
                      ),

                      Row(
                        spacing: 8.0,
                        children: [
                          Expanded(
                            child: customPrefixIcButton(
                              title: "List View",
                              icon: Icons.list,
                              // onPressed: () {
                              //   context.push(AppRoutesName.subProjectImgListPage);
                              // },
                              onPressed: () {
                                context.pushNamed(
                                  AppRoutesName.imageListPage,
                                  extra: {
                                    "projectId": widget.subProjectsDatum.projectId,
                                    "subProjectId": widget.subProjectsDatum.subProjectId,
                                  },
                                );
                              },
                            ),
                          ),

                          Expanded(
                            child: customPrefixIcButton(
                              title: "Photo View",
                              icon: Icons.camera_alt,
                              // onPressed: () {
                              //   context.pushNamed(
                              //     AppRoutesName.subPrjPhotoViewPage,
                              //     extra: {"subProjectData": widget.subProjectsDatum},
                              //   );
                              // },
                              onPressed: () {
                                context.pushNamed(
                                  AppRoutesName.prjImgPage,
                                  extra: {
                                    "projectId": widget.subProjectsDatum.projectId,
                                    "dos": widget.subProjectsDatum.dos,
                                    "subProjectId": widget.subProjectsDatum.subProjectId,
                                    "appBarTitle": "Sub-Project Image",
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (_isLocked)
                Positioned.fill(
                  child: Container(
                    color: Colors.white.withAlpha(150),
                    child: Center(
                      child: Padding(
                        padding: AppDimens.hvPadding,
                        child: Column(
                          spacing: 12.0,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Please Select Rate & Size Type. It cannot be changed later for this sub-project",
                              style: AppTextStyle.ts14BB,
                              textAlign: TextAlign.center,
                            ),
                            RadioGroup<AreaType>(
                              groupValue: _selectedType,
                              onChanged: (AreaType? newValue) {
                                setState(() {
                                  _selectedType = newValue!;
                                });
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: RadioListTile<AreaType>(
                                      value: AreaType.saleable,
                                      title: Text("Saleable", style: AppTextStyle.ts14RB),
                                      visualDensity: VisualDensity.compact,
                                      contentPadding: EdgeInsets.zero,
                                      activeColor: AppColors.red,
                                    ),
                                  ),
                                  Flexible(
                                    flex: 1,
                                    child: RadioListTile<AreaType>(
                                      value: AreaType.carpet,
                                      title: Text("Carpet", style: AppTextStyle.ts14RB),
                                      visualDensity: VisualDensity.compact,
                                      contentPadding: EdgeInsets.zero,
                                      activeColor: AppColors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            CustomElevatedButton(
                              text: "SAVE",
                              onPressed: () {
                                CutsomAlertDialogues.subProjectDetailsComfirmDialogue(
                                  context: context,
                                  onConfirm: () {
                                    context.pop();
                                    // sPrjDetailsCubit.updateSubProject(
                                    //   subProjectData: widget.subProjectsDatum,
                                    //   reraType: _selectedType.name,
                                    // );
                                    SubProjectEntity subProjectEntity = widget.subProjectsDatum;
                                    subProjectEntity.isCarpetOrSaleableChoosen = 1;
                                    subProjectEntity.rateType = _selectedType.name;
                                    sPrjDetailsCubit.updateSubProject(subProjectsDatum: subProjectEntity);
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        floatingActionButton: IgnorePointer(
          ignoring: _isLocked,
          child: FloatingActionButton(
            backgroundColor: AppColors.red,
            onPressed: () async {
              if (!await Utils.checkLocationAndGpsPermission(context)) return;
              if (!context.mounted) return;
              await context.pushNamed(
                AppRoutesName.subProjectDetailsFormPage,
                extra: {"subProjectData": widget.subProjectsDatum},
              );
              if (!context.mounted) return;
              context.read<SPrjDetailsCubit>().fetchCity(
                projectId: widget.subProjectsDatum.projectId!,
                subPrjId: widget.subProjectsDatum.subProjectId!,
              );
            },
            shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(100)),
            child: Icon(Icons.edit, color: Colors.white),
          ),
        ),
      ),
    );
  }

  // Suffix icon button
  Widget customSuffixIcButton({required String title, required IconData icon, required VoidCallback onPressed}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.red,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
      // onPressed:onPressed,
      onPressed: () async {
        if (!await Utils.checkLocationAndGpsPermission(context)) return;
        onPressed();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(title, style: AppTextStyle.ts16BW, overflow: TextOverflow.ellipsis),
          ),
          // Transform.scale(scale: 1.2, child: Icon(icon, color: AppColors.white, size: 20)),
          Icon(icon, color: AppColors.white, size: 20),
        ],
      ),
    );
  }

  // Prefix icon button
  Widget customPrefixIcButton({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
    bool isMainspacing = false,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.red,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
      // onPressed: onPressed,
      onPressed: () async {
        if (!await Utils.checkLocationAndGpsPermission(context)) return;

        onPressed();
      },
      child: Row(
        mainAxisAlignment: isMainspacing ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
        children: [
          // Transform.scale(scale: 1.3, child: Icon(icon, color: AppColors.white, size: 20)),
          Icon(icon, color: AppColors.white, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(title, style: AppTextStyle.ts16BW, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
