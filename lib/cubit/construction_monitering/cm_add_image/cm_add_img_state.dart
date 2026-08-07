import 'package:lf_survey/model/pams_survey/ps_photo_response.dart';

abstract class CmAddImgState {}

class InitState extends CmAddImgState {}

class LoadingState extends CmAddImgState {}

class LoadedState extends CmAddImgState {
  List<PsPhotoDatum> image;
  LoadedState({required this.image});
}

class AddImgState extends CmAddImgState {
  PsPhotoDatum image;
  bool isProcessing;
  AddImgState({required this.image, required this.isProcessing});
}

class ErrorState extends CmAddImgState {
  final String message;
  ErrorState({required this.message});
}

class SuccessState extends CmAddImgState {
  final String message;
  SuccessState({required this.message});
}

class DeleteState extends CmAddImgState {
  final int index;
  DeleteState({required this.index});
}
