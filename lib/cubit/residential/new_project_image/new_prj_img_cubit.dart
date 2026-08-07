import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lf_survey/constants/utils.dart';
import 'package:lf_survey/cubit/residential/new_project_image/new_prj_img_state.dart';
import 'package:lf_survey/database/db_helper.dart';
import 'package:lf_survey/model/db_model/residential/new_prj_img_entity.dart';
import 'package:lf_survey/services/work_manager_task_register.dart';
import 'package:location/location.dart';

class NewPrjImgCubit extends Cubit<NewPrjImgState> {
  NewPrjImgCubit() : super(InitState());

  fetchData({required String projectId}) async {
    try {
      final imgFile = await DBHelper.fetchNewImgPrjEntityByPrjId(projectId);
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
    required String projectId,
    required String imageTitle,
    String? projectType,
  }) async {
    try {
      final imgFile = await Utils.pickFromCamera(context: context);
      if (imgFile != null) {
        NewPrjImageEntity imageData = NewPrjImageEntity(imageUri: imgFile.path);
        emit(ImagePickedState(imageData: imageData));
        DateTime currentTime = DateTime.now();
        LocationData? locationData = await Utils.getCurrentLocation();
        File? metaImg;
        if (imageTitle == "p") {
          metaImg = await Utils.addMetadataWithCanvas(
            imageFile: File(imgFile.path),
            timestamp: currentTime,
            imageName: "${projectId}_$imageTitle",
            locationData: locationData,
            comment: "",
            additionalPathInfo: projectType,
          );
        } else {
          metaImg = await Utils.addInfoFile(
            file: File(imgFile.path),
            projectId: projectId,
            imageTitle: imageTitle,
            additionalPathInfo: projectType,
          );
        }

        if (metaImg != null) {
          final cImg = await Utils.compressIfNeeded(metaImg);
          String formatedDate = DateFormat("dd-MMM-yyyy HH:mm:ss").format(currentTime);

          debugPrint("cImg.path ${cImg.path}");
          if (locationData != null) {
            imageData.prjId = projectId;
            imageData.imageUri = cImg.path;
            imageData.imgLat = locationData.latitude;
            imageData.imgLng = locationData.longitude;
            imageData.imgLocAccuracy = locationData.accuracy;
            imageData.createdDatetime = formatedDate;
            imageData.syncStatus = 0;
            final response = await DBHelper.insertNewPrjImageEntity(imageData);
            if (response > 0) {
              WorkManagerTaskRegister.syncSingleNewProjectImage(projectId: projectId, imgUri: imageData.imageUri ?? "");
              emit(SuccessSate(message: "Image background syncing started."));
            }
          }
        }
        fetchData(projectId: projectId);
      }
    } catch (e) {
      String erStr = e.toString().split(":").last;
      emit(ErrorState(message: erStr));
    }
  }

  void pickImgGallery({
    required BuildContext context,
    required String projectId,
    required String imageTitle,
    int limit = 1,
    String? projectType,
  }) async {
    try {
      final imgFiles = await Utils.pickFromGallery(context: context);
      if (imgFiles != null) {
        if (!context.mounted) return;
        context.pop();

        NewPrjImageEntity imageData = NewPrjImageEntity(imageUri: imgFiles.path);
        emit(ImagePickedState(imageData: imageData));
        LocationData? locationData = await Utils.getCurrentLocation();
        if (locationData != null) {
          File imgFile = File(imgFiles.path);
          File? processedFile;

          if (imageTitle == "p") {
            DateTime currentTime = DateTime.now();
            processedFile = await Utils.addMetadataWithCanvas(
              locationData: locationData,
              imageFile: imgFile,
              timestamp: currentTime,
              imageName: "${projectId}_$imageTitle",
              comment: "",
              additionalPathInfo: projectType,
            );
          } else {
            processedFile = await Utils.addInfoFile(
              file: imgFile,
              projectId: projectId,
              imageTitle: imageTitle,
              additionalPathInfo: projectType,
            );
          }
          if (processedFile == null) return;
          DateTime currentTime = DateTime.now();
          String formatedDate = DateFormat("dd-MMM-yyyy HH:mm:ss").format(currentTime);
          final cImg = await Utils.compressIfNeeded(processedFile);
          imageData.prjId = projectId;
          imageData.imageUri = cImg.path;
          imageData.imgLat = locationData.latitude;
          imageData.imgLng = locationData.longitude;
          imageData.imgLocAccuracy = locationData.accuracy;
          imageData.createdDatetime = formatedDate;
          imageData.syncStatus = 0;
          final response = await DBHelper.insertNewPrjImageEntity(imageData);
          if (response > 0) {
            WorkManagerTaskRegister.syncSingleNewProjectImage(projectId: projectId, imgUri: imageData.imageUri ?? "");
            emit(SuccessSate(message: "Image background syncing started."));
          }
        }
      }
      fetchData(projectId: projectId);
    } catch (e) {
      String erStr = e.toString().split(":").last;
      emit(ErrorState(message: erStr));
    }
  }

  void deleteImg({required NewPrjImageEntity imgData, required int index}) async {
    try {
      final response = await DBHelper.deleteNewImgPrjEntity(imgData.id!);
      if (response > 0) {
        emit(DeleteState(index: index));
      }
    } catch (e) {
      String erStr = e.toString().split(":").last;
      emit(ErrorState(message: erStr));
    }
  }

  void syncImg({required String prjId, required List<NewPrjImageEntity> prjImage}) {
    try {
      if (prjImage.isEmpty) {
        emit(ErrorState(message: "No images available to sync. Please add images and try again."));
        return;
      }
      bool allSynced = prjImage.every((element) => element.syncStatus == 1);
      if (allSynced) {
        emit(ErrorState(message: "All images are already synced."));
        return;
      }
      WorkManagerTaskRegister.syncNewProjectImage(projectId: prjId);
      emit(SuccessSate(message: "Image background syncing started."));
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }
}
