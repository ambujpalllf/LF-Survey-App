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
import 'package:lf_survey/cubit/residential/image_list/img_list_cubit.dart';
import 'package:lf_survey/cubit/residential/image_list/img_list_state.dart';
import 'package:lf_survey/model/db_model/residential/image_entity.dart';
import 'package:lf_survey/widgets/custom_app_bar.dart';

class ImageListPage extends StatefulWidget {
  final int projectId;
  final int subProjectId;
  final int resident;
  final int commercial;
  const ImageListPage({
    super.key,
    required this.projectId,
    required this.subProjectId,
    required this.resident,
    required this.commercial,
  });

  @override
  State<ImageListPage> createState() => _ImageListPageState();
}

class _ImageListPageState extends State<ImageListPage> {
  int imageId = 0;
  bool isSync = false;
  List<ImageEntity> prjImage = [];
  late ReceivePort _receivePort;
  @override
  void initState() {
    super.initState();
    imageId = widget.subProjectId == 0 ? widget.projectId : widget.subProjectId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ImageListCubit>().fetchData(
        imageId: imageId,
        resident: widget.resident,
        commercial: widget.commercial,
      );
    });
    _receivePort = ReceivePort();
    IsolateNameServer.registerPortWithName(_receivePort.sendPort, "sync_project_image");
    _receivePort.listen((message) {
      context.read<ImageListCubit>().fetchData(
        imageId: imageId,
        resident: widget.resident,
        commercial: widget.commercial,
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
    IsolateNameServer.removePortNameMapping('sync_project_image');
    _receivePort.close();
  }

  @override
  Widget build(BuildContext context) {
    ImageListCubit prjListViewCubit = context.read<ImageListCubit>();
    return BlocListener<ImageListCubit, ImageListState>(
      listener: (_, state) {
        if (state is LoadedState) {
          prjImage.clear();
          prjImage.addAll(state.images);
        } else if (state is SyncSate) {
          CustomSnackHelper.customToastMsg(
            context: context,
            message: state.message,
            bgColor: AppColors.white,
            textColor: AppColors.black,
          );
          isSync = false;
        } else if (state is DeleteState) {
          prjImage.clear();
        } else if (state is ErrorState) {
          CustomSnackHelper.customToastMsg(
            context: context,
            message: state.message,
            bgColor: AppColors.white,
            textColor: AppColors.black,
          );
          isSync = false;
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.appBg,
        appBar: CustomAppBar(
          title: "Image Sync",
          actions: [
            BlocBuilder<ImageListCubit, ImageListState>(
              builder: (context, state) {
                return IconButton(
                  onPressed: isSync == true
                      ? () {}
                      : () {
                          isSync = true;
                          prjListViewCubit.syncImages(prjImage: prjImage);
                        },
                  icon: Icon(Icons.sync, color: isSync ? Colors.grey.shade500 : AppColors.red),
                );
              },
            ),
            IconButton(
              onPressed: () {
                CutsomAlertDialogues.deleteDialogue(
                  context: context,
                  onDelete: () {
                    context.pop();
                    prjListViewCubit.deleteImg(imgData: prjImage);
                  },
                );
              },
              icon: Icon(Icons.delete, color: AppColors.white),
            ),
          ],
        ),
        body: SafeArea(
          child: BlocBuilder<ImageListCubit, ImageListState>(
            builder: (context, state) {
              return prjImage.isEmpty
                  ? Center(child: Text("No data found !", style: AppTextStyle.ts14RB))
                  : Padding(
                      padding: AppDimens.hvPadding,
                      child: ListView.builder(
                        itemCount: prjImage.length,
                        itemBuilder: (context, index) {
                          String imgPath = (prjImage[index].imageUri ?? "").split("/").last;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                              decoration: BoxDecoration(
                                color: prjImage[index].sync == 1 ? AppColors.syncColor : AppColors.unSyncColor,
                                borderRadius: BorderRadius.circular(4.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade300,
                                    offset: const Offset(0, 4), // bottom shadow
                                    blurRadius: 6,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Text(imgPath, style: AppTextStyle.ts16RB),
                            ),
                          );
                        },
                      ),
                    );
            },
          ),
        ),
      ),
    );
  }
}
