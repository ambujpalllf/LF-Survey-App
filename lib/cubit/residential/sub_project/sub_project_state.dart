import 'package:lf_survey/model/db_model/residential/flat_entity.dart';
import 'package:lf_survey/model/db_model/residential/sub_prj_entity.dart';
// import 'package:lf_survey/model/residential/project_response.dart';

abstract class SubProjectState {}

class InitState extends SubProjectState {}

class LoadingState extends SubProjectState {}

class LoadedState extends SubProjectState {
  // List<SubProjectsDatum> subProjects;
  List<SubProjectEntity> subProjects;
  List<FlatEntity> flats;
  LoadedState({required this.subProjects, required this.flats});
}

class ConstructionProgressState extends SubProjectState {
  List<Map<String, dynamic>> constructionProgress;
  ConstructionProgressState({required this.constructionProgress});
}

class ErrorState extends SubProjectState {
  String message;
  ErrorState({required this.message});
}

class SuccessState extends SubProjectState {
  String message;
  SuccessState({required this.message});
}

class DeleteSubPrjState extends SubProjectState {
  final int index;
  DeleteSubPrjState({required this.index});
}
