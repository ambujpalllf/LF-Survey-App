import 'package:lf_survey/model/db_model/residential/new_project_entity.dart';
import 'package:lf_survey/model/db_model/residential/new_sub_project_entity.dart';
import 'package:lf_survey/model/db_model/residential/project_entity.dart';
import 'package:lf_survey/model/db_model/residential/reject_reason_model.dart';
import 'package:lf_survey/model/db_model/residential/sub_prj_entity.dart';

abstract class ProjectState {}

class InitState extends ProjectState {}

class LoadingState extends ProjectState {}

class LoadedState extends ProjectState {
  List<ProjectEntity> projectData;
  List<SubProjectEntity> subProjects;
  List<NewProjectEntity> newProjects;
  List<NewSubProjectEntity> newSubProjects;
  Map<int, int> totalUnsoldflats;
  LoadedState({
    required this.projectData,
    required this.subProjects,
    required this.newProjects,
    required this.newSubProjects,
    required this.totalUnsoldflats,
  });
}

class FilterState extends ProjectState {
  List<ProjectEntity> projectData;
  bool applyFilter;
  FilterState({required this.projectData, this.applyFilter = false});
}

class SearchState extends ProjectState {
  List<ProjectEntity> projectData;
  bool applyFilter;
  SearchState({required this.projectData, this.applyFilter = false});
}

class ErrorState extends ProjectState {
  String message;
  ErrorState({required this.message});
}

class SuccessState extends ProjectState {
  String message;
  SuccessState({required this.message});
}

class DeleteProject extends ProjectState {
  int index;
  DeleteProject({required this.index});
}

class ClearDbState extends ProjectState {}

class RejectLoadingState extends ProjectState {}

class RejectState extends ProjectState {
  final List<RejectDatum> rejectData;
  RejectState({required this.rejectData});
}
