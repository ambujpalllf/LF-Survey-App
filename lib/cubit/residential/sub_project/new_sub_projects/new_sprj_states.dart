import 'package:lf_survey/model/db_model/residential/new_flat_entity.dart';
import 'package:lf_survey/model/db_model/residential/new_sub_project_entity.dart';
import 'package:lf_survey/model/residential/project_spinner.dart';

abstract class NewSprjState {}

class InitState extends NewSprjState {}

class LoadingState extends NewSprjState {}

class LoadedState extends NewSprjState {
  List<NewSubProjectEntity> subProjects;
  List<ConstProgressList> constProgress;
  Map<String, List<NewFlatEntity>> flatsBySubProject;
  LoadedState({required this.subProjects, required this.constProgress, required this.flatsBySubProject});
}

class SuccessState extends NewSprjState {
  final String message;
  SuccessState({required this.message});
}

class ErrorState extends NewSprjState {
  final String message;
  ErrorState({required this.message});
}

class UserDataState extends NewSprjState {
  String qtrId;
  String qtr;
  UserDataState({required this.qtrId, required this.qtr});
}

class DeleteState extends NewSprjState {
  final int index;
  DeleteState({required this.index});
}

class SubPrjCopyState extends NewSprjState {
  bool isValid;
  bool shouldNavigate;
  String? errorMsg = "";
  SubPrjCopyState({this.isValid = false, this.shouldNavigate = false, this.errorMsg});
}
