import 'package:lf_survey/model/pams_survey/ps_prj_response.dart';

abstract class CmPrjState {}

class InitState extends CmPrjState {}

class LoadingState extends CmPrjState {}

class LoadedState extends CmPrjState {
  List<PsPrjDatum> projects;
  LoadedState({required this.projects});
}

class ClearDbState extends CmPrjState {
  String message;
  ClearDbState({required this.message});
}

class FilterState extends CmPrjState {
  List<PsPrjDatum> projects;
  FilterState({required this.projects});
}

class SuccessState extends CmPrjState {
  String message;
  SuccessState({required this.message});
}

class ErrorState extends CmPrjState {
  String message;
  ErrorState({required this.message});
}
