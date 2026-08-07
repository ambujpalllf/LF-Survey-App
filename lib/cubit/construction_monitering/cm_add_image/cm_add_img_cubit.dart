import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lf_survey/constants/utils.dart';
import 'package:lf_survey/cubit/construction_monitering/cm_add_image/cm_add_img_state.dart';
import 'package:lf_survey/database/db_helper.dart';
import 'package:lf_survey/model/pams_survey/ps_photo_response.dart';
import 'package:lf_survey/services/api_client.dart';
import 'package:lf_survey/services/work_manager_task_register.dart';
import 'package:location/location.dart';

class CmAddImgCubit extends Cubit<CmAddImgState> {
  CmAddImgCubit() : super(InitState());
  void getPhotos({required int projectId, int? wingId, String? localwingId}) async {
    try {
      emit(LoadingState());

      final response = await DBHelper.getAllCmImageByPrjIdAndWingId(
        projectId: projectId,
        wingId: wingId,
        localWingId: localwingId,
      );
      if (response.isNotEmpty) {
        emit(LoadedState(image: response));
      } else {
        emit(ErrorState(message: "Data not found."));
      }
    } catch (e) {
      String erMsg = e.toString().split(":").last;
      emit(ErrorState(message: erMsg));
    }
  }

  Future<void> addImage({
    required int projectId,
    int? buildingId,
    int? wingId,
    String? localBuildingId,
    String? localWingId,
    required String wingName,
    required BuildContext context,
  }) async {
    try {
      bool isLocationPermission = await Utils.checkLocationAndGpsPermission(context);
      if (isLocationPermission == true) {
        if (!context.mounted) return;
        final result = await Utils.pickFromCamera(context: context);
        if (result == null) return;
        final PsPhotoDatum imgData = PsPhotoDatum(
          projectId: projectId,
          buildingId: buildingId,
          wingId: wingId,
          localBuildingId: localBuildingId,
          localWingId: localWingId,
          photoPath: result.path,
          sync: 0,
          createdDateTime: DateTime.now().toIso8601String(),
        );
        emit(AddImgState(image: imgData, isProcessing: true));
        final LocationData? currentLocation = await Utils.getCurrentLocation();
        final File? metaImg = await Utils.addMetadataWithCanvas(
          imageFile: File(result.path),
          timestamp: DateTime.now(),
          imageName: "construction_monitoring",
          comment: "",
          locationData: currentLocation,
        );

        // If metadata addition failed
        if (metaImg == null) {
          emit(ErrorState(message: "Failed to add metadata to image"));
          return;
        }

        // emit(LoadedState(imgData: imgData, isProcessing: false));

        final timestampSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;

        final dir = metaImg.parent.path;
        final newPath = "$dir/${wingName}_$timestampSeconds.jpg";

        final renamedFile = await metaImg.rename(newPath);

        debugPrint("Renamed file path: ${renamedFile.path}");

        // final File cImg = await Utils.compressIfNeeded(metaImg);
        final File cImg = await Utils.compressIfNeeded(renamedFile);
        if (currentLocation == null) return;
        imgData.photoPath = cImg.path;
        imgData.imgLat = currentLocation.latitude ?? 0.0;
        imgData.imgLng = currentLocation.longitude ?? 0.0;
        imgData.imgLocAccuracy = currentLocation.accuracy ?? 0.0;
        imgData.sync = 0;
        imgData.imageCategory = "cm";
        emit(AddImgState(image: imgData, isProcessing: false));
        await DBHelper.insertPsImage(image: imgData);
        WorkManagerTaskRegister.syncCmImage(imgPath: cImg.path, projectId: projectId, wingId: wingId);
        getPhotos(projectId: projectId, wingId: wingId, localwingId: localWingId);
      }
    } catch (e) {
      emit(ErrorState(message: e.toString().trim()));
    }
  }

  void deleteImage({required PsPhotoDatum imgData, required int index}) async {
    try {
      if (imgData.sync == 0) {
        DBHelper.deletePsImageById(imgId: imgData.id!);
        emit(DeleteState(index: index));
      } else {
        final response = await ApiClient.cmDeletePhotos(photoId: imgData.photoId!);
        if (response != null && response.data["status"].toString().toLowerCase() == "ok") {
          DBHelper.deletePsImageById(imgId: imgData.id!);
          emit(DeleteState(index: index));
        } else {
          emit(ErrorState(message: response.data["message"]));
        }
      }
    } catch (e) {
      String errorMsg = e.toString().trim();
      emit(ErrorState(message: errorMsg));
    }
  }

  void syncProjects() {
    try {
      WorkManagerTaskRegister.syncCmImage(imgPath: "", projectId: 0, wingId: 0);
      emit(SuccessState(message: "Syncing started..."));
    } catch (e) {
      String erMsg = e.toString().split(":").last;
      emit(ErrorState(message: erMsg));
    }
  }
}
