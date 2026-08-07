import 'package:lf_survey/model/construction_monitoring/cm_survey_model.dart';

abstract class CmSurveyState {}

class InitState extends CmSurveyState {}

class LoadingState extends CmSurveyState {}

class LoadedState extends CmSurveyState {
  List<CmSurveyModel> surveyData;
  LoadedState({required this.surveyData});
}

class SuccessState extends CmSurveyState {
  String message;
  SuccessState({required this.message});
}

class ErrorState extends CmSurveyState {
  String message;
  ErrorState({required this.message});
}
