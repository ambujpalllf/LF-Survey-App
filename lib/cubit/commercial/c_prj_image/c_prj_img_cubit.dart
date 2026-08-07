import 'dart:io';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lf_survey/app_popups/cutsom_alert_dialogues.dart';
import 'package:lf_survey/constants/utils.dart';
import 'package:lf_survey/cubit/commercial/c_prj_image/c_prj_img_state.dart';
import 'package:lf_survey/database/db_helper.dart';
import 'package:lf_survey/model/db_model/residential/image_entity.dart';
import 'package:lf_survey/services/work_manager_task_register.dart';
import 'package:location/location.dart';

class CPrjImgCubit extends Cubit<CPrjImgState> {
  CPrjImgCubit() : super(InitState());

  fetchData({required int imageId}) async {
    try {
      final imgFile = await DBHelper.fetcImgEntity(imageId: imageId);
      if (imgFile.isNotEmpty) {
        emit(LoadedState(images: imgFile));
      }
    } catch (e) {
      String erStr = e.toString().split(":").last;
      emit(ErrorState(message: erStr));
    }
  }

  void pickImgCamera({
    required BuildContext context,
    required int projectId,
    required int subProjectId,
    required String dos,
    required String imageTitle,
  }) async {
    try {
      final imgFile = await Utils.pickFromCamera(context: context);
      if (imgFile != null) {
        ImageEntity imageData = ImageEntity(imageUri: imgFile.path);
        emit(ImagePickedState(imageData: imageData));
        DateTime currentTime = DateTime.now();
        String comment = "";
        if (imageTitle == "p") {
          if (!context.mounted) return;
          comment = await CutsomAlertDialogues.addCommentDialogue(context: context) ?? "";
        }

        LocationData? locationData = await Utils.getCurrentLocation();
        final metaImg = await Utils.addMetadataWithCanvas(
          imageFile: File(imgFile.path),
          timestamp: currentTime,
          imageName: "${projectId}_${subProjectId}_$imageTitle",
          comment: comment,
          locationData: locationData,
        );
        if (metaImg != null) {
          final cImg = await Utils.compressIfNeeded(metaImg);
          if (locationData != null) {
            imageData.resident = 0;
            imageData.commercial = 1;
            imageData.imageId = subProjectId == 0 ? projectId : subProjectId;
            imageData.imageUri = cImg.path;
            imageData.dos = dos;
            imageData.sync = 0;
            imageData.type = 1;
            imageData.imgLat = locationData.latitude.toString();
            imageData.imgLon = locationData.longitude.toString();
            final response = await DBHelper.insertImgEntity(imageData);
            if (response > 0) {
              WorkManagerTaskRegister.syncImage(projectId: projectId, subProjectId: subProjectId);
            }
          }
        }
        fetchData(imageId: subProjectId == 0 ? projectId : subProjectId);
      }
    } catch (e) {
      String erStr = e.toString().split(":").last;
      emit(ErrorState(message: erStr));
    }
  }

  Future<File> addInfoFile({
    required File file,
    required int projectId,
    required int subProjectId,
    required String imageTitle,
  }) async {
    final dir = file.parent.path;
    final ext = p.extension(file.path);

    final timestamp = DateTime.now();
    final formattedTime =
        DateFormat('yyyyMMdd_').format(timestamp) +
        (timestamp.millisecondsSinceEpoch % 1000000).toString().padLeft(6, '0');

    final newFileName = '${projectId}_${subProjectId}_${imageTitle}_$formattedTime$ext';

    final newPath = p.join(dir, newFileName);

    // Rename replaces the original file
    return await file.rename(newPath);
  }

  void pickImgGallery({
    required BuildContext context,
    required int projectId,
    required int subProjectId,
    required String dos,
    required String imageTitle,
    int limit = 1,
  }) async {
    try {
      final imgFiles = await Utils.pickFromGallery(context: context);
      String? comment = "";
      if (imgFiles != null) {
        if (!context.mounted) return;
        context.pop();
        if (imageTitle == "p") {
          comment = await CutsomAlertDialogues.addCommentDialogue(context: context);
        }
        ImageEntity imageData = ImageEntity(imageUri: imgFiles.path);
        emit(ImagePickedState(imageData: imageData));
        LocationData? locationData = await Utils.getCurrentLocation();
        if (locationData != null) {
          File imgFile = File(imageData.imageUri ?? "");
          File? processedFile;

          if (imageTitle == "p") {
            DateTime currentTime = DateTime.now();
            processedFile = await Utils.addMetadataWithCanvas(
              source: "gallery",
              imageFile: imgFile,
              timestamp: currentTime,
              imageName: "${projectId}_${subProjectId}_$imageTitle",
              comment: comment ?? "",
            );
          } else {
            processedFile = await addInfoFile(
              file: imgFile,
              projectId: projectId,
              subProjectId: subProjectId,
              imageTitle: imageTitle,
            );
          }
          if (processedFile == null) return;
          final cImg = await Utils.compressIfNeeded(processedFile);
          imageData.resident = 0;
          imageData.commercial = 1;
          // when user add for prject then assign project id and also for sub project then assign subprojectId.
          imageData.imageId = subProjectId == 0 ? projectId : subProjectId;
          imageData.imageUri = cImg.path;
          imageData.dos = dos;
          imageData.sync = 0;
          imageData.type = 1;
          imageData.imgLat = locationData.latitude.toString();
          imageData.imgLon = locationData.longitude.toString();
          final response = await DBHelper.insertImgEntity(imageData);
          if (response > 0) {
            WorkManagerTaskRegister.syncImage(projectId: projectId, subProjectId: subProjectId);
          }
        }
      }
      fetchData(imageId: subProjectId == 0 ? projectId : subProjectId);
    } catch (e) {
      String erStr = e.toString().split(":").last;
      emit(ErrorState(message: erStr));
    }
  }

  void deleteImg({required ImageEntity imgData, required int index}) async {
    try {
      final response = await DBHelper.deleteImgEntity(id: imgData.id!);
      if (response > 0) {
        emit(DeleteState(index: index));
      }
    } catch (e) {
      String erStr = e.toString().split(":").last;
      emit(ErrorState(message: erStr));
    }
  }
}
