import 'package:lf_survey/model/db_model/commercial/c_project_entity.dart';
import 'package:lf_survey/model/db_model/commercial/c_sub_project_entity.dart';

abstract class CProjectState {}

class InitState extends CProjectState {}

class LoadingState extends CProjectState {}

class LoadedState extends CProjectState {
  List<CProjectEntity> projects;
  List<CSubProjectEntity> subProjects;
  LoadedState({required this.projects, required this.subProjects});
}

class SearchState extends CProjectState {
  List<CProjectEntity> projects;
  bool isActiveFilter;
  SearchState({required this.projects, required this.isActiveFilter});
}

class ErrorState extends CProjectState {
  String message;
  ErrorState({required this.message});
}

class SuccessState extends CProjectState {
  String message;
  SuccessState({required this.message});
}

class ClearDbState extends CProjectState {}

class FilterState extends CProjectState {
  List<CProjectEntity> projects;
  bool applyFilter;
  FilterState({required this.projects, required this.applyFilter});
}
