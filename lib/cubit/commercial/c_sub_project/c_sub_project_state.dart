import 'package:lf_survey/model/db_model/commercial/c_sub_project_entity.dart';

abstract class CSubProjectState {}

class InitState extends CSubProjectState {}

class LoadingState extends CSubProjectState {}

class LoadedState extends CSubProjectState {
  List<CSubProjectEntity> subProjects;
  LoadedState({required this.subProjects});
}

class ErrorState extends CSubProjectState {
  final String message;
  ErrorState({required this.message});
}
