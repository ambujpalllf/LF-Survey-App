import 'package:lf_survey/model/pams_survey/ps_photo_response.dart';

abstract class PsPhotoState {}

class InitState extends PsPhotoState {}

class LoadingState extends PsPhotoState {}

class SuccessState extends PsPhotoState {
  final String message;
  SuccessState({required this.message});
}

class ErrorState extends PsPhotoState {
  final String message;
  ErrorState({required this.message});
}

class LoadedState extends PsPhotoState {
  bool isProcessing;
  PsPhotoDatum imgData;
  LoadedState({required this.imgData, required this.isProcessing});
}

class ImageDeleteState extends PsPhotoState {
  List<String> images;
  ImageDeleteState({required this.images});
}

class DeleteState extends PsPhotoState {
  int index;
  DeleteState({required this.index});
}

class PhLoadedState extends PsPhotoState {
  List<PsPhotoDatum> photos;
  PhLoadedState({required this.photos});
}

class ValidateState extends PsPhotoState {
  final String imagePath;
  final String? categoryError;
  final String? imageError;
  final String? remarksError;

  ValidateState({this.imagePath = "", this.categoryError, this.imageError, this.remarksError});
}
