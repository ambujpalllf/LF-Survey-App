import 'package:lf_survey/model/pams_survey/ps_photo_response.dart';

abstract class PsImgListState {}

class InitState extends PsImgListState {}

class LoadingState extends PsImgListState {}

class LoadedState extends PsImgListState {
  List<PsPhotoDatum> images;
  LoadedState({required this.images});
}

class ErrorState extends PsImgListState {
  String message;
  ErrorState({required this.message});
}

class SuccessState extends PsImgListState {
  String message;
  SuccessState({required this.message});
}
