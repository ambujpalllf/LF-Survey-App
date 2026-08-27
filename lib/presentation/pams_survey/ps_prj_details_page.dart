import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_dimens.dart';
import 'package:lf_survey/constants/app_text_style.dart';
import 'package:lf_survey/constants/snackbar_helper.dart';
import 'package:lf_survey/constants/utils.dart';
import 'package:lf_survey/model/pams_survey/ps_prj_response.dart';
import 'package:lf_survey/routes/app_routes_name.dart';
import 'package:lf_survey/widgets/custom_app_bar.dart';

class PsPrjDetailsPage extends StatefulWidget {
  final PsPrjDatum prjDatum;
  const PsPrjDetailsPage({super.key, required this.prjDatum});

  @override
  State<PsPrjDetailsPage> createState() => _PsPrjDetailsPageState();
}

class _PsPrjDetailsPageState extends State<PsPrjDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: CustomAppBar(title: "Projects Details"),
      body: SafeArea(
        child: Padding(
          padding: AppDimens.hvPadding,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(4.0),
                      boxShadow: [
                        BoxShadow(color: AppColors.greyLite, blurRadius: 2.0, spreadRadius: 2.0, offset: Offset(0, 1)),
                      ],
                    ),
                    child: Column(
                      spacing: 2.0,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Project Details", style: AppTextStyle.ts16MB),
                        Divider(color: AppColors.greyLite),
                        Text(widget.prjDatum.projectName ?? "", style: AppTextStyle.ts14RB),
                        Divider(color: AppColors.greyLite),
                        // Text("Builder Group : ${widget.prjDatum.builderGroup}", style: AppTextStyle.ts14RB),
                        textWidget(title: "Builder Group: ", value: widget.prjDatum.builderGroup ?? ""),
                        Divider(color: AppColors.greyLite),
                        // Text("Building Name: ${widget.prjDatum.projectBuildingName}", style: AppTextStyle.ts14RB),
                        textWidget(title: "Building Name: ", value: widget.prjDatum.projectBuildingName ?? ""),
                        Divider(color: AppColors.greyLite),
                        // Text("Road Name: ${widget.prjDatum.projectAddressRoadName}", style: AppTextStyle.ts14RB),
                        textWidget(title: "Road Name: ", value: widget.prjDatum.projectAddressRoadName ?? ""),
                        Divider(color: AppColors.greyLite),
                        // Text("Sub-Locality: ${widget.prjDatum.projectAddressSubLocality}", style: AppTextStyle.ts14RB),
                        textWidget(title: "Sub-Locality: ", value: widget.prjDatum.projectAddressSubLocality ?? ""),
                        Divider(color: AppColors.greyLite),
                        // Text("City: ${widget.prjDatum.projectAddressCity}", style: AppTextStyle.ts14RB),
                        textWidget(title: "City: ", value: widget.prjDatum.projectAddressCity ?? ""),
                        Divider(color: AppColors.greyLite),
                        // Text("State : ${widget.prjDatum.projectAddressState}", style: AppTextStyle.ts14RB),
                        textWidget(title: "State: ", value: widget.prjDatum.projectAddressState ?? ""),
                        Divider(color: AppColors.greyLite),
                        // Text("Zone : ${widget.prjDatum.zoneName}", style: AppTextStyle.ts14RB),
                        textWidget(title: "Zone: ", value: widget.prjDatum.zoneName ?? ""),
                        Divider(color: AppColors.greyLite),
                        // Text("Rera No : ${widget.prjDatum.reraRegNo}", style: AppTextStyle.ts14RB),
                        textWidget(title: "Rera No: ", value: widget.prjDatum.reraRegNo ?? ""),
                        Divider(color: AppColors.greyLite),
                        // Text("Rera Name : ${widget.prjDatum.reraName}", style: AppTextStyle.ts14RB),
                        textWidget(title: "Rera Name: ", value: widget.prjDatum.reraName ?? ""),
                        Divider(color: AppColors.greyLite),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
                  onPressed: () async {
                    final locPermission = await Utils.checkLocationAndGpsPermission(context);
                    if (!context.mounted) return;
                    if (!locPermission) {
                      CustomSnackHelper.errorToast(message: "Please enable location permission and GPS");
                      return;
                    }
                    context.pushNamed(AppRoutesName.psPhotoPage, extra: {"projectData": widget.prjDatum});
                  },
                  child: Row(
                    spacing: 25,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Add Project Images", style: AppTextStyle.ts16BW),
                      Icon(Icons.camera_alt_outlined, color: AppColors.white, fontWeight: FontWeight.bold),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
                  onPressed: () async {
                    final locPermission = await Utils.checkLocationAndGpsPermission(context);
                    if (!context.mounted) return;
                    if (!locPermission) {
                      CustomSnackHelper.errorToast(message: "Please enable location permission and GPS");
                      return;
                    }
                    context.pushNamed(AppRoutesName.psLandFormPage, extra: {"projectData": widget.prjDatum});
                  },
                  child: Row(
                    spacing: 25,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Add Project Technical Info", style: AppTextStyle.ts16BW),
                      Icon(Icons.description, color: AppColors.white, fontWeight: FontWeight.bold),
                    ],
                  ),
                ),
              ),

              // Row(
              //   spacing: 10,
              //   children: [
              //     Expanded(
              //       child: InkWell(
              //         onTap: () async {},
              //         child: Container(
              //           alignment: Alignment.center,
              //           padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              //           decoration: BoxDecoration(
              //             color: AppColors.primaryColor,
              //             borderRadius: BorderRadius.circular(4.0),
              //           ),
              //           child: Row(
              //             spacing: 25,
              //             mainAxisSize: MainAxisSize.min,
              //             children: [
              //               Flexible(child: Text("Add Project Technical Info", style: AppTextStyle.ts16BW)),
              //               Icon(Icons.description, color: AppColors.white, fontWeight: FontWeight.bold),
              //             ],
              //           ),
              //         ),
              //       ),
              //     ),
              //     Expanded(
              //       child: InkWell(
              //         onTap: () async {},
              //         child: Container(
              //           padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              //           decoration: BoxDecoration(
              //             color: AppColors.primaryColor,
              //             borderRadius: BorderRadius.circular(4.0),
              //           ),
              //           child: Row(
              //             spacing: 25,
              //             mainAxisSize: MainAxisSize.min,
              //             children: [
              //               Flexible(
              //                 child: Text(
              //                   "Add Project Images",
              //                   style: AppTextStyle.ts16BW,
              //                   textAlign: TextAlign.center,
              //                 ),
              //               ),
              //               Icon(Icons.camera_alt_outlined, color: AppColors.white, fontWeight: FontWeight.bold),
              //             ],
              //           ),
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              SizedBox(height: 25),
            ],
          ),
        ),
      ),

      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: AppColors.primaryColor,
      //   shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(200)),
      //   onPressed: () {
      //     CustomBottomsheet.addInfoSheet(context: context, prjData: widget.prjDatum);
      //   },
      //   child: Icon(Icons.add, color: AppColors.white),
      // ),
    );
  }

  Widget textWidget({required String title, required String value}) {
    return RichText(
      text: TextSpan(
        text: title,
        style: AppTextStyle.ts14MB,
        children: [
          TextSpan(
            text: value,
            style: AppTextStyle.ts14RB.copyWith(color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}
