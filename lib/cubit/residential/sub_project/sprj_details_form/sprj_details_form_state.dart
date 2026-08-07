import 'package:lf_survey/model/db_model/residential/sub_prj_entity.dart';
// import 'package:lf_survey/model/residential/project_response.dart';
import 'package:lf_survey/model/residential/project_spinner.dart';

abstract class SPrjDetailsFormState {}

class InitState extends SPrjDetailsFormState {}

class ErrorState extends SPrjDetailsFormState {
  String message;
  String scrMsg;
  ErrorState({required this.message, this.scrMsg = ""});
}

class LocalDbState extends SPrjDetailsFormState {
  List<ConstProgressList> constProgress;
  List<ProjectStatusList> projectStatus;
  List<RemarksList> bookingStopRemarks;
  List<RemarksList> subProjectDeleteRemarks;
  // SubProjectsDatum subProjectsDatum;
  SubProjectEntity subProjectsDatum;
  LocalDbState({
    required this.constProgress,
    required this.projectStatus,
    required this.bookingStopRemarks,
    required this.subProjectDeleteRemarks,
    required this.subProjectsDatum,
  });
}

class SuccessState extends SPrjDetailsFormState {
  final String message;
  SuccessState({required this.message});
}

class LoadingState extends SPrjDetailsFormState {}
