import 'dart:io';
import 'dart:isolate';
import 'dart:math';
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
import 'package:lf_survey/cubit/residential/new_project_image/new_prj_img_cubit.dart';
import 'package:lf_survey/cubit/residential/new_project_image/new_prj_img_state.dart';
import 'package:lf_survey/model/db_model/residential/new_prj_img_entity.dart';
import 'package:lf_survey/presentation/residential/sub_project/img_view_page.dart';
import 'package:lf_survey/widgets/custom_app_bar.dart';

class NewPrjImagePage extends StatefulWidget {
  final String projectId;
  final String? projectType;
  const NewPrjImagePage({super.key, required this.projectId, this.projectType});

  @override
  State<NewPrjImagePage> createState() => _PrjImagePageState();
}

class _PrjImagePageState extends State<NewPrjImagePage> {
  bool isSync = false;
  int imageId = 0;
  int imgGridcount = 2;
  List<NewPrjImageEntity> prjImage = [];
  late ReceivePort _receivePort;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewPrjImgCubit>().fetchData(projectId: widget.projectId);
      gridImgCount();
    });
    _receivePort = ReceivePort();
    IsolateNameServer.registerPortWithName(_receivePort.sendPort, 'sync_image');
    _receivePort.listen((message) {
      final String projectId = message as String;
      debugPrint("Received update for siteId: $projectId");
      context.read<NewPrjImgCubit>().fetchData(projectId: projectId);
    });
  }

  @override
  void dispose() {
    super.dispose();
    IsolateNameServer.removePortNameMapping('sync_image');
    _receivePort.close();
  }

  void gridImgCount() {
    final width = MediaQuery.of(context).size.width;
    if (width <= 400) {
      imgGridcount = 2;
    } else if (width <= 700) {
      imgGridcount = 3;
    } else {
      imgGridcount = 4;
    }
  }

  String getFileSize(File file, [int decimals = 2]) {
    int bytes = file.lengthSync();
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (bytes == 0) ? 0 : (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  @override
  Widget build(BuildContext context) {
    final NewPrjImgCubit newPrjImgCubit = context.read<NewPrjImgCubit>();
    return BlocListener<NewPrjImgCubit, NewPrjImgState>(
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
        } else if (state is ErrorState) {
          CustomSnackHelper.customToastMsg(
            context: context,
            message: state.message,
            bgColor: AppColors.white,
            textColor: AppColors.black,
          );
        } else if (state is SuccessSate) {
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
        appBar: CustomAppBar(
          title: "New Project Image",
          actions: [
            IconButton(
              onPressed: isSync == true
                  ? () {}
                  : () {
                      newPrjImgCubit.syncImg(prjId: widget.projectId, prjImage: prjImage);
                      // setState(() {
                      //   isSync = true;
                      // });
                    },
              icon: Icon(Icons.sync, color: isSync ? AppColors.greyLite : AppColors.red),
            ),
          ],
        ),
        body: SafeArea(
          child: BlocBuilder<NewPrjImgCubit, NewPrjImgState>(
            builder: (context, state) {
              return prjImage.isEmpty
                  ? Center(child: Text("No Images Found !", style: AppTextStyle.ts14RB))
                  : Padding(
                      padding: AppDimens.hvPadding,
                      child: GridView.builder(
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: MediaQuery.of(context).size.width / imgGridcount,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1,
                        ),
                        physics: NeverScrollableScrollPhysics(),
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
                                    color: img.syncStatus == 1 ? AppColors.imgSyncColor : AppColors.imgUnSyncColor,
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
                                          newPrjImgCubit.deleteImg(imgData: img, index: index);
                                        },
                                      );
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(6.0),
                                      decoration: BoxDecoration(
                                        color: Colors.black45,
                                        // color: Colors.red.shade300,
                                        shape: BoxShape.circle,
                                      ),
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
            final result = await Utils.checkLocationAndGpsPermission(context);
            if (result == true) {
              if (!context.mounted) return;
              CustomBottomsheet.addNewProjectImgBottomSheet(
                context: context,
                projectId: widget.projectId,
                projectType: widget.projectType,
              );
            }
          },
        ),
      ),
    );
  }
}
