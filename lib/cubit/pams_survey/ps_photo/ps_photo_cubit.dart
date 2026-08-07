import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lf_survey/constants/utils.dart';
import 'package:lf_survey/cubit/pams_survey/ps_photo/ps_photo_state.dart';
import 'package:lf_survey/database/db_helper.dart';
import 'package:lf_survey/model/pams_survey/ps_photo_response.dart';
import 'package:lf_survey/services/api_client.dart';
import 'package:lf_survey/services/work_manager_task_register.dart';
import 'package:location/location.dart';

class PsPhotoCubit extends Cubit<PsPhotoState> {
  PsPhotoCubit() : super(InitState());

  void getPhotos({required int projectId}) async {
    try {
      emit(LoadingState());
      final response = await DBHelper.getAllPsImageByPrjId(projectId: projectId);
      if (response.isNotEmpty) {
        emit(PhLoadedState(photos: response));
      } else {
        emit(ErrorState(message: "Data not found."));
      }
    } catch (e) {
      String erMsg = e.toString().split(":").last;
      emit(ErrorState(message: erMsg));
    }
  }

  void clearValidation() {
    emit(InitState()); // resets imagePath, errors, etc.
  }

  bool fieldsValidate({required String imgType, required String imgPath, String remarks = ""}) {
    String? categoryError;
    String? imageError;
    String? remarksError;

    // Validate fields
    if (imgType.isEmpty) {
      categoryError = "Please select the photo category";
    }
    if (imgPath.isEmpty) {
      imageError = "Please add photo";
    }
    if (remarks.isEmpty) {
      remarksError = "Remarks is required";
    }

    // If any error exists, emit validation state and return false
    if (categoryError != null || imageError != null || remarksError != null) {
      emit(
        ValidateState(
          categoryError: categoryError,
          imageError: imageError,
          remarksError: remarksError,
          imagePath: imgPath, // optional: keep the current imagePath
        ),
      );
      return false;
    }

    // No errors, emit state with current imagePath (and optional remarks)
    emit(ValidateState(imagePath: imgPath, categoryError: null, imageError: null, remarksError: null));
    return true;
  }

  Future<void> addImage({
    required int projectId,
    required String imagePath,
    required String imageType,
    required String imageName,
    required String remarks,
    required BuildContext context,
  }) async {
    try {
      final PsPhotoDatum imgData = PsPhotoDatum(
        projectId: projectId,
        photoType: imageType,
        photoPath: imagePath,
        sync: 0,
        createdDateTime: DateTime.now().toIso8601String(),
      );
      emit(LoadedState(imgData: imgData, isProcessing: true));
      final LocationData? currentLocation = await Utils.getCurrentLocation();
      final File? result = await Utils.addMetadataWithCanvas(
        imageFile: File(imagePath),
        timestamp: DateTime.now(),
        imageName: imageName,
        comment: "",
        locationData: currentLocation,
      );

      // If metadata addition failed
      if (result == null) {
        emit(ErrorState(message: "Failed to add metadata to image"));
        return;
      }

      // emit(LoadedState(imgData: imgData, isProcessing: false));

      final File cImg = await Utils.compressIfNeeded(result);
      debugPrint("HHHHHHHHHHHH: Image Path: ${cImg.path}");
      if (currentLocation == null) return;
      imgData.photoPath = cImg.path;
      imgData.imgLat = currentLocation.latitude ?? 0.0;
      imgData.imgLng = currentLocation.longitude ?? 0.0;
      imgData.imgLocAccuracy = currentLocation.accuracy ?? 0.0;
      imgData.remarks = remarks;
      imgData.imageCategory = "pti";
      emit(LoadedState(imgData: imgData, isProcessing: false));
      await DBHelper.insertPsImage(image: imgData);
      getPhotos(projectId: projectId);
      WorkManagerTaskRegister.syncPsImage(projectId: projectId, imgPath: cImg.path);
    } catch (e) {
      emit(ErrorState(message: e.toString().trim()));
    }
  }

  void syncImages() {
    try {
      WorkManagerTaskRegister.syncPsImage(projectId: 0, imgPath: "");
      emit(SuccessState(message: "Images Syncing started..."));
    } catch (e) {
      String erMsg = e.toString().split(":").last;
      emit(ErrorState(message: erMsg));
    }
  }

  void deleteImage({required PsPhotoDatum imgData, required int index}) async {
    try {
      if (imgData.sync == 0) {
        DBHelper.deletePsImageById(imgId: imgData.id!);
        emit(DeleteState(index: index));
      } else {
        final response = await ApiClient.psDeletePhotos(photoId: imgData.photoId!);
        if (response != null && response.data["status"] == "OK") {
          DBHelper.deletePsImageById(imgId: imgData.id!);
          emit(DeleteState(index: index));
        }
      }
    } catch (e) {
      String errorMsg = e.toString().trim();
      emit(ErrorState(message: errorMsg));
    }
  }
}
