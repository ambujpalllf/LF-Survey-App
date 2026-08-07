import 'package:lf_survey/model/pams_survey/ps_photo_response.dart';

abstract class CmImgListState {}

class InitState extends CmImgListState {}

class LoadingState extends CmImgListState {}

class LoadedState extends CmImgListState {
  List<PsPhotoDatum> images;
  LoadedState({required this.images});
}

class SuccessState extends CmImgListState {
  String message;
  SuccessState({required this.message});
}

class ErrorState extends CmImgListState {
  String message;
  ErrorState({required this.message});
}
