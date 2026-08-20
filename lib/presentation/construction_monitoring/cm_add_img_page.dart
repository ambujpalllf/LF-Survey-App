import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lf_survey/app_popups/cutsom_alert_dialogues.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_dimens.dart';
import 'package:lf_survey/constants/app_text_style.dart';
import 'package:lf_survey/constants/snackbar_helper.dart';
import 'package:lf_survey/cubit/construction_monitering/cm_add_image/cm_add_img_cubit.dart';
import 'package:lf_survey/cubit/construction_monitering/cm_add_image/cm_add_img_state.dart';
import 'package:lf_survey/model/construction_monitoring/cm_wing_response.dart';
import 'package:lf_survey/model/pams_survey/ps_photo_response.dart';
import 'package:lf_survey/presentation/residential/sub_project/img_view_page.dart';
import 'package:lf_survey/widgets/custom_app_bar.dart';

class CmAddImgPage extends StatefulWidget {
  final WingData wingData;
  const CmAddImgPage({super.key, required this.wingData});

  @override
  State<CmAddImgPage> createState() => _CmAddImgPageState();
}

class _CmAddImgPageState extends State<CmAddImgPage> {
  List<PsPhotoDatum> images = [];
  late ReceivePort _receivePort;
  @override
  void initState() {
    super.initState();
    context.read<CmAddImgCubit>().getPhotos(
      projectId: widget.wingData.projectId!,
      wingId: widget.wingData.wingId,
      localwingId: widget.wingData.createdWingId,
    );
    _receivePort = ReceivePort();
    IsolateNameServer.registerPortWithName(_receivePort.sendPort, 'sync_cm_image');
    _receivePort.listen((message) {
      context.read<CmAddImgCubit>().getPhotos(
        projectId: widget.wingData.projectId!,
        wingId: widget.wingData.wingId,
        localwingId: widget.wingData.createdWingId,
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
    IsolateNameServer.removePortNameMapping('sync_cm_image');
    _receivePort.close();
  }

  @override
  Widget build(BuildContext context) {
    final cmAddImgCubit = context.read<CmAddImgCubit>();
    return Scaffold(
      appBar: CustomAppBar(
        title: "Add Images",
        actions: [
          BlocBuilder<CmAddImgCubit, CmAddImgState>(
            builder: (context, state) {
              bool isUnsynPrjTechInfo = images.any((e) => e.sync == 0);
              return IconButton(
                onPressed: isUnsynPrjTechInfo == false
                    ? () {}
                    : () {
                        cmAddImgCubit.syncProjects();
                      },
                icon: Icon(Icons.sync, color: isUnsynPrjTechInfo ? AppColors.white : Colors.grey.shade600),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<CmAddImgCubit, CmAddImgState>(
        listener: (context, state) {
          if (state is LoadedState) {
            images.clear();
            images.addAll(state.image);
          } else if (state is AddImgState) {
            if (state.isProcessing) {
              images.add(state.image);
            } else {
              images.removeLast();
              images.add(state.image);
            }
          } else if (state is DeleteState) {
            images.removeAt(state.index);
          } else if (state is SuccessState) {
            CustomSnackHelper.customToastMsg(
              context: context,
              message: state.message,
              bgColor: AppColors.white,
              textColor: AppColors.black,
            );
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
            child: GridView.builder(
              itemCount: images.length,
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: MediaQuery.of(context).size.width * 0.45,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemBuilder: (_, index) {
                bool isLastProcessing = state is AddImgState && state.isProcessing && index == images.length - 1;
                var img = images[index];
                return Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ImageViewPage(imageData: "${images[index].photoPath}")),
                        );
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.45,
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: img.sync == 0 ? AppColors.imgUnSyncColor : AppColors.imgSyncColor,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Image.file(
                          File(img.photoPath!),
                          fit: BoxFit.fill,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.broken_image, color: Colors.grey, size: 40),
                        ),
                      ),
                    ),
                    if (widget.wingData.submitStatus != true)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: InkWell(
                          onTap: () {
                            CutsomAlertDialogues.deleteDialogue(
                              context: context,
                              title: "image",
                              onDelete: () {
                                context.pop();
                                context.read<CmAddImgCubit>().deleteImage(imgData: img, index: index);
                              },
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(4.0),
                            decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(100)),
                            child: Icon(Icons.delete_outline, size: 20, color: AppColors.red),
                          ),
                        ),
                      ),
                    if (isLastProcessing)
                      Container(
                        color: Colors.black26,
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                      ),
                  ],
                );
              },
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: widget.wingData.submitStatus == true ? AppColors.greyLite : AppColors.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(100)),
        onPressed: () {
          widget.wingData.submitStatus == true
              ? finalSubmitInfo()
              : context.read<CmAddImgCubit>().addImage(
                  projectId: widget.wingData.projectId ?? 0,
                  buildingId: widget.wingData.buildingId,
                  wingId: widget.wingData.wingId,
                  localBuildingId: widget.wingData.createdBuildingId,
                  localWingId: widget.wingData.createdWingId,
                  buildingName: widget.wingData.buildingName ?? "",
                  wingName: widget.wingData.wingName ?? "",
                  context: context,
                );
        },
        child: Icon(Icons.add_a_photo_outlined, color: AppColors.white),
      ),
    );
  }

  void finalSubmitInfo() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          title: Text("Submission Completed", style: AppTextStyle.ts16BB),
          content: Text(
            "This sub-project has already been successfully submitted. "
            "Editing details or adding new photos is no longer permitted.",
            style: AppTextStyle.ts14RB,
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: Text("OK", style: AppTextStyle.ts14BB.copyWith(color: AppColors.primaryColor)),
            ),
          ],
        );
      },
    );
  }
}
