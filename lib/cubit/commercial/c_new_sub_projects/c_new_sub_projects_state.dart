import 'package:lf_survey/model/db_model/commercial/c_new_sub_project_entity.dart';

abstract class CNewSubProjectsState {}

class InitState extends CNewSubProjectsState {}

class LoadingState extends CNewSubProjectsState {}

class LocalDbState extends CNewSubProjectsState {
  List<CNewSubProjectEntity> subProjects;
  LocalDbState({required this.subProjects});
}

class UpdateState extends CNewSubProjectsState {
  final int index;
  final CNewSubProjectEntity subProject;

  UpdateState({required this.index, required this.subProject});
}

class DeleteState extends CNewSubProjectsState {
  final int index;
  DeleteState({required this.index});
}

class ErrorState extends CNewSubProjectsState {
  final String message;
  ErrorState({required this.message});
}

class SuccessState extends CNewSubProjectsState {
  final String message;
  SuccessState({required this.message});
}
