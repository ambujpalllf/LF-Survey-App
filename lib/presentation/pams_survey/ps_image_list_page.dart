import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_dimens.dart';
import 'package:lf_survey/constants/app_text_style.dart';
import 'package:lf_survey/constants/snackbar_helper.dart';
import 'package:lf_survey/cubit/pams_survey/ps_image_list/ps_image_list_state.dart';
import 'package:lf_survey/cubit/pams_survey/ps_image_list/ps_img_list_cubit.dart';
import 'package:lf_survey/model/pams_survey/ps_photo_response.dart';
import 'package:lf_survey/widgets/custom_app_bar.dart';

class PsImageListPage extends StatefulWidget {
  const PsImageListPage({super.key});

  @override
  State<PsImageListPage> createState() => _PsImageListPageState();
}

class _PsImageListPageState extends State<PsImageListPage> {
  List<PsPhotoDatum> images = [];
  @override
  void initState() {
    super.initState();
    context.read<PsImgListCubit>().getImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      appBar: CustomAppBar(
        title: "Images",
        actions: [
          BlocBuilder<PsImgListCubit, PsImgListState>(
            builder: (context, state) {
              bool isUnsync = images.any((e) => e.sync == 0);
              return IconButton(
                onPressed: isUnsync
                    ? () {
                        context.read<PsImgListCubit>().syncImages();
                      }
                    : () {},
                icon: Icon(Icons.sync, color: isUnsync ? AppColors.white : Colors.grey.shade600),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: AppDimens.hvPadding,
          child: BlocConsumer<PsImgListCubit, PsImgListState>(
            listener: (context, state) {
              if (state is LoadedState) {
                images.clear();
                images.addAll(state.images);
              } else if (state is ErrorState) {
                CustomSnackHelper.customToastMsg(
                  context: context,
                  message: state.message,
                  bgColor: AppColors.white,
                  textColor: AppColors.black,
                );
              } else if (state is SuccessState) {
                CustomSnackHelper.customToastMsg(
                  context: context,
                  message: state.message,
                  bgColor: AppColors.white,
                  textColor: AppColors.black,
                );
              }
            },
            builder: (context, state) {
              if (state is LoadingState) {
                return Center(child: CircularProgressIndicator(color: AppColors.red));
              }
              return images.isEmpty
                  ? Center(child: Text("No data found!", style: AppTextStyle.ts14RB))
                  : ListView.builder(
                      itemCount: images.length,
                      itemBuilder: (_, index) {
                        var imgData = images[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: imgData.sync == 0 ? AppColors.unSyncColor : AppColors.syncColor,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 2,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                spacing: 4.0,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(imgData.photoPath?.split("/").last ?? "", style: AppTextStyle.ts14RB),
                                  Text(
                                    DateFormat(
                                      "yyyy-MM-dd HH:mm:ss a",
                                    ).format(DateTime.parse(imgData.createdDateTime ?? "")),
                                    style: AppTextStyle.ts12RB,
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
    );
  }
}
