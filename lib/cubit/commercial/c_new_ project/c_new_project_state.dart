import 'package:lf_survey/model/db_model/commercial/c_new_project_entity.dart';

abstract class CNewProjectState {}

class InitState extends CNewProjectState {}

class LoadingState extends CNewProjectState {}

class LocalDbState extends CNewProjectState {
  List<CNewProjectEntity> projects;
  LocalDbState({required this.projects});
}

class SearchState extends CNewProjectState {
  List<CNewProjectEntity> projects;
  SearchState({required this.projects});
}

class ErrorState extends CNewProjectState {
  final String message;
  ErrorState({required this.message});
}
