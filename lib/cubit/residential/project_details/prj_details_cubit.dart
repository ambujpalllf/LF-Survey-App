import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lf_survey/app_popups/cutsom_alert_dialogues.dart';
import 'package:lf_survey/constants/utils.dart';
import 'package:lf_survey/cubit/residential/project_details/prj_details_state.dart';
import 'package:lf_survey/services/api_client.dart';
import 'package:url_launcher/url_launcher.dart';

class PrjDetailsCubit extends Cubit<PrjDetailsState> {
  PrjDetailsCubit() : super(InitState());

  Future<File?> pickedPdf() async {
    try {
      final File? response = await Utils.pickedPdf();
      return response;
    } catch (e) {
      String erMsg = e.toString().split(":").last;
      emit(ErrorState(message: erMsg));
      return null;
    }
  }

  void uploadBrochure({required int projectId, required File pdfFile}) async {
    try {
      emit(LoadingState());
      final result = await ApiClient.uploadBrouchure(pdfFile: pdfFile, projectId: projectId);
      if (result != null) {
        final String str = result["0"];
        if (str.toLowerCase() == "duplicatefilename") {
          emit(ErrorState(message: "This file is already exits."));
        } else {
          emit(SuccessState(message: "Brochure uploaded successfully."));
        }
      } else {
        emit(ErrorState(message: "Something went wrong. Please try again."));
      }
    } catch (e) {
      String erMsg = e.toString().split(":").last;
      emit(ErrorState(message: erMsg));
    }
  }

  Future<void> openGoogleMapsDirection(double lat, double lng, String projectName) async {
    try {
      if (lat == 0.0 || lng == 0.0) {
        emit(
          LocationErrorState(
            message: "Location is not available for this project. Please try again later or contact support.",
          ),
        );
        return;
      }

      final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&destination_place_id=$projectName';
      final Uri uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        emit(ErrorState(message: "Unable to open Google Maps at the moment. Please check your device settings."));
      }
    } catch (e) {
      String erMsg = e.toString().split(":").last;
      emit(ErrorState(message: erMsg));
    }
  }

  Future pickImgGallery({required BuildContext context, required String category, required String projectId}) async {
    try {
      final picked = await Utils.pickFromGallery(context: context);

      if (picked == null) {
        emit(ErrorState(message: "You did not select any image."));
        return;
      }

      final filePath = picked.path.toLowerCase();

      // Block GIF
      if (filePath.endsWith(".gif")) {
        emit(ErrorState(message: "GIF images are not supported. Please select JPG or PNG."));
        return;
      }

      if (!context.mounted) return;

      CutsomAlertDialogues.showImageDialogue(
        context: context,
        imageFile: File(picked.path),
        confirm: () {
          context.pop();
          uploadImage(category: category, imgPath: picked.path, projectId: projectId);
        },
      );
    } catch (e) {
      String erMsg = e.toString().split(":").last;
      emit(ErrorState(message: erMsg));
    }
  }

  void uploadImage({required String category, required String imgPath, required String projectId}) async {
    try {
      Map<String, String> bodyData = {
        "imgPath": imgPath,
        "projectId": projectId,
        "vid": "0",
        "ftype": category == "construction" ? "2" : "0",
        "fid": "0",
        "dtid": "0",
        "fsize": "0",
        "category": category,
      };
      final response = await ApiClient.uploadPrjLogoImg(bodyData: bodyData);
      if (response != null && response['STATUS'] == "SUCCESS") {
        emit(SuccessState(message: "Image uploaded sucess fully"));
      }
    } catch (e) {
      String erMsg = e.toString().split(":").last;
      emit(ErrorState(message: erMsg));
    }
  }
}
