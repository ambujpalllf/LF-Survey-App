import 'package:lf_survey/model/db_model/residential/new_project_entity.dart';

abstract class NewProjectState {}

class InitState extends NewProjectState {}

class SuccessState extends NewProjectState {
  String message;
  SuccessState({required this.message});
}

class ErrorState extends NewProjectState {
  String message;
  ErrorState({required this.message});
}

class LocalDbState extends NewProjectState {
  List<NewProjectEntity> projects;
  LocalDbState({required this.projects});
}

class SearchState extends NewProjectState {
  List<NewProjectEntity> projects;
  SearchState({required this.projects});
}

class LocalPrefsState extends NewProjectState {
  String qtrId;
  String qtr;
  LocalPrefsState({required this.qtrId, required this.qtr});
}
