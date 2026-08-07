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
import 'package:lf_survey/cubit/pams_survey/ps_photo/ps_photo_cubit.dart';
import 'package:lf_survey/cubit/pams_survey/ps_photo/ps_photo_state.dart';
import 'package:lf_survey/model/pams_survey/ps_photo_response.dart';
import 'package:lf_survey/model/pams_survey/ps_prj_response.dart';
import 'package:lf_survey/presentation/residential/sub_project/img_view_page.dart';
import 'package:lf_survey/widgets/custom_app_bar.dart';

class PsPhotoPage extends StatefulWidget {
  final PsPrjDatum prjDatum;
  const PsPhotoPage({super.key, required this.prjDatum});

  @override
  State<PsPhotoPage> createState() => _PsPhotoPageState();
}

class _PsPhotoPageState extends State<PsPhotoPage> {
  // List<String> images = [];

  List<PsPhotoDatum> images = [];

  final List<Map<String, dynamic>> photoCategory = [
    {"id": 1, "title": "Floor Plan"},
    {"id": 2, "title": "Elevation"},
    {"id": 3, "title": "Master Plan"},
  ];

  // TextEditingController imageNameC = TextEditingController();
  TextEditingController remarkC = TextEditingController();

  String imagePath = "";
  String selectedImageCategory = "";
  late ReceivePort _receivePort;
  @override
  void initState() {
    super.initState();
    context.read<PsPhotoCubit>().getPhotos(projectId: widget.prjDatum.projectId ?? 0);
    _receivePort = ReceivePort();
    IsolateNameServer.registerPortWithName(_receivePort.sendPort, "sync_ps_image");
    _receivePort.listen((message) {
      context.read<PsPhotoCubit>().getPhotos(projectId: widget.prjDatum.projectId ?? 0);
    });
  }

  @override
  void dispose() {
    super.dispose();
    // imageNameC.dispose();
    remarkC.dispose();
    IsolateNameServer.removePortNameMapping('sync_ps_image');
    _receivePort.close();
  }

  @override
  Widget build(BuildContext context) {
    final PsPhotoCubit photoCubit = context.read<PsPhotoCubit>();
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: CustomAppBar(
        title: "Photos",
        actions: [
          BlocBuilder<PsPhotoCubit, PsPhotoState>(
            builder: (context, state) {
              bool isUnsync = images.any((e) => e.sync == 0);
              return IconButton(
                onPressed: isUnsync
                    ? () {
                        photoCubit.syncImages();
                      }
                    : () {},
                icon: Icon(Icons.sync, color: isUnsync ? AppColors.white : Colors.grey.shade600),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: BlocConsumer<PsPhotoCubit, PsPhotoState>(
          builder: (_, state) {
            return images.isEmpty
                ? Center(
                    child: Text("No data found !", style: AppTextStyle.ts14MB.copyWith(color: Colors.grey)),
                  )
                : Padding(
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
                        final bool isLastProcessing =
                            state is LoadedState && state.isProcessing && index == images.length - 1;
                        final isNetwork =
                            images[index].photoPath!.startsWith('http://') ||
                            images[index].photoPath!.startsWith('https://');
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ImageViewPage(imageData: "${images[index].photoPath}")),
                            );
                          },
                          child: Stack(
                            children: [
                              Container(
                                padding: EdgeInsets.all(6),
                                width: MediaQuery.of(context).size.width * 0.45,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadiusGeometry.circular(4.0),
                                  color: images[index].sync == 0 ? AppColors.imgUnSyncColor : AppColors.imgSyncColor,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadiusGeometry.circular(4.0),
                                  child: isNetwork
                                      ? Image.network(
                                          "${images[index].photoPath}",
                                          fit: BoxFit.fill,
                                          errorBuilder: (context, error, stackTrace) {
                                            return const Center(
                                              child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
                                            );
                                          },
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                                          },
                                        )
                                      : Image.file(File(images[index].photoPath ?? ""), fit: BoxFit.fill),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: InkWell(
                                  onTap: () {
                                    CutsomAlertDialogues.deleteDialogue(
                                      context: context,
                                      title: "image",
                                      onDelete: () {
                                        photoCubit.deleteImage(imgData: images[index], index: index);
                                        context.pop();
                                      },
                                    );
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(6.0),
                                    decoration: BoxDecoration(color: Colors.black12, shape: BoxShape.circle),
                                    child: Icon(Icons.close, size: 18, color: AppColors.red),
                                  ),
                                ),
                              ),
                              if (isLastProcessing)
                                Container(
                                  color: Colors.black26,
                                  child: const Center(
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
          },
          listener: (BuildContext context, state) {
            if (state is LoadedState) {
              if (state.isProcessing) {
                images.add(state.imgData);
              } else {
                if (images.isNotEmpty) {
                  images[images.length - 1] = state.imgData;
                } else {
                  images.add(state.imgData);
                }
              }
            } else if (state is ErrorState) {
              CustomSnackHelper.errorSnackbar(context: context, message: state.message);
            } else if (state is PhLoadedState) {
              images.clear();
              images.addAll(state.photos);
            } else if (state is DeleteState) {
              images.removeAt(state.index);
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: widget.prjDatum.apfStatus == 1 ? AppColors.greyLite : AppColors.primaryColor,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(100)),
        onPressed: widget.prjDatum.apfStatus == 1
            ? () {
                showDialog(
                  context: context,
                  builder: (_) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      title: Text("Submission Completed", style: AppTextStyle.ts16BB),
                      content: Text(
                        "This project has already been successfully submitted. "
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
            : () {
                CustomBottomsheet.addPhotoSheet(
                  context: context,
                  projectId: widget.prjDatum.projectId ?? 0,
                  photoCategory: photoCategory,
                  remarkC: remarkC,
                );
              },
        child: Icon(Icons.add),
      ),
    );
  }
}
