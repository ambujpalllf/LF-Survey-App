import 'package:lf_survey/model/construction_monitoring/cm_survey_model.dart';
import 'package:lf_survey/model/construction_monitoring/cm_wing_response.dart';
import 'package:lf_survey/model/pams_survey/ps_photo_response.dart';

abstract class CmSubPrjState {}

class InitState extends CmSubPrjState {}

class LoadingState extends CmSubPrjState {}

class LoadedState extends CmSubPrjState {
  List<WingData> wingData;
  LoadedState({required this.wingData});
}

class ErrorState extends CmSubPrjState {
  String message;
  ErrorState({required this.message});
}

class SuccessState extends CmSubPrjState {
  String message;
  SuccessState({required this.message});
}

class SearchState extends CmSubPrjState {
  List<WingData> wings;
  SearchState({required this.wings});
}

class WingUpdateState extends CmSubPrjState {
  WingData wing;
  WingUpdateState({required this.wing});
}

class SurveyState extends CmSubPrjState {
  List<CmSurveyModel> surveyData;
  List<PsPhotoDatum> imageData;
  SurveyState({required this.surveyData, required this.imageData});
}

class DeleteState extends CmSubPrjState {
  final int index;
  DeleteState({required this.index});
}
