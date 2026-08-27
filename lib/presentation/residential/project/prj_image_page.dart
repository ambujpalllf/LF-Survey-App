import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lf_survey/app_popups/custom_bottomsheet.dart';
import 'package:lf_survey/app_popups/cutsom_alert_dialogues.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_dimens.dart';
import 'package:lf_survey/constants/app_text_style.dart';
import 'package:lf_survey/constants/snackbar_helper.dart';
import 'package:lf_survey/constants/utils.dart';
import 'package:lf_survey/cubit/residential/project_image/prj_img_cubit.dart';
import 'package:lf_survey/cubit/residential/project_image/prj_img_state.dart';
import 'package:lf_survey/model/db_model/residential/image_entity.dart';
import 'package:lf_survey/presentation/residential/sub_project/img_view_page.dart';
import 'package:lf_survey/widgets/custom_app_bar.dart';

class PrjImagePage extends StatefulWidget {
  final String appBarTitle;
  final int projectId;
  final int subProjectId;
  final String dos;
  const PrjImagePage({
    super.key,
    required this.appBarTitle,
    required this.projectId,
    required this.subProjectId,
    required this.dos,
  });

  @override
  State<PrjImagePage> createState() => _PrjImagePageState();
}

class _PrjImagePageState extends State<PrjImagePage> {
  int imageId = 0;
  int imgViewcount = 2;
  List<ImageEntity> prjImage = [];
  late ReceivePort _receivePort;
  @override
  void initState() {
    super.initState();
    imageId = widget.appBarTitle == "Project Image" ? widget.projectId : widget.subProjectId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PrjImgCubit>().fetchData(imageId: imageId);
      gridImgCount();
    });
    _receivePort = ReceivePort();
    IsolateNameServer.registerPortWithName(_receivePort.sendPort, "sync_project_image");
    _receivePort.listen((message) {
      context.read<PrjImgCubit>().fetchData(imageId: imageId);
    });
  }

  @override
  void dispose() {
    super.dispose();
    IsolateNameServer.removePortNameMapping('sync_project_image');
    _receivePort.close();
  }

  void gridImgCount() {
    final width = MediaQuery.of(context).size.width;
    if (width <= 400) {
      imgViewcount = 2;
    } else if (width <= 700) {
      imgViewcount = 3;
    } else {
      imgViewcount = 4;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PrjImgCubit, PrjImgState>(
      listener: (context, state) {
        if (state is ImagePickedState) {
          prjImage.add(state.imageData);
        } else if (state is LoadedState) {
          prjImage.clear();
          prjImage.addAll(state.images);
        } else if (state is DeleteState) {
          prjImage.removeAt(state.index);
        } else if (state is ImagePickedGalleryState) {
          prjImage.addAll(state.imageData);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.appBg,
        appBar: CustomAppBar(title: widget.appBarTitle),
        body: SafeArea(
          child: BlocBuilder<PrjImgCubit, PrjImgState>(
            builder: (context, state) {
              return prjImage.isEmpty
                  ? Center(child: Text("No Images Found !", style: AppTextStyle.ts14RB))
                  : Padding(
                      padding: AppDimens.hvPadding,
                      child: GridView.builder(
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: MediaQuery.of(context).size.width / imgViewcount,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1,
                        ),
                        itemCount: prjImage.length,
                        itemBuilder: (context, index) {
                          var img = prjImage[index];
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => ImageViewPage(imageData: img.imageUri!)),
                              );
                            },
                            child: Stack(
                              clipBehavior: Clip.none,
                              fit: StackFit.passthrough,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4.0),
                                    color: img.sync == 1 ? AppColors.imgSyncColor : AppColors.imgUnSyncColor,
                                  ),
                                  padding: EdgeInsets.all(8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4.0),
                                    child: Image.file(File(img.imageUri!), fit: BoxFit.fill),
                                  ),
                                ),
                                Positioned(
                                  right: 5,
                                  top: 5,
                                  child: InkWell(
                                    onTap: () {
                                      CutsomAlertDialogues.deleteDialogue(
                                        context: context,
                                        onDelete: () {
                                          context.pop();
                                          context.read<PrjImgCubit>().deleteImg(imgData: img, index: index);
                                        },
                                      );
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(6.0),
                                      decoration: BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                                      child: Icon(Icons.delete, color: Colors.grey.shade200, size: 18),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.red,
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 0.5, color: AppColors.white),
            borderRadius: BorderRadiusGeometry.circular(100),
          ),
          child: Icon(Icons.add_a_photo_sharp, color: AppColors.white),
          onPressed: () async {
            final locPermission = await Utils.checkLocationAndGpsPermission(context);
            if (!context.mounted) return;
            if (!locPermission) {
              CustomSnackHelper.errorToast(message: "Please enable location permission and GPS");
              return;
            }
            CustomBottomsheet.addPrjImgBottomSheet(
              context: context,
              projectId: widget.projectId,
              subProjectId: widget.subProjectId,
              dos: widget.dos,
              appBarTitle: widget.appBarTitle,
            );
          },
        ),
      ),
    );
  }
}
