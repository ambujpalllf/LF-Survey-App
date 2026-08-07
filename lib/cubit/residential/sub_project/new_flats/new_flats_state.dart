import 'package:lf_survey/model/db_model/residential/new_flat_entity.dart';
import 'package:lf_survey/model/residential/project_spinner.dart';

abstract class NewFlatsState {}

class InitState extends NewFlatsState {}

class LocalDbState extends NewFlatsState {
  List<FlatTypeList> flats;
  LocalDbState({required this.flats});
}

class LoadingState extends NewFlatsState {}

class FlatLoadedState extends NewFlatsState {
  List<NewFlatEntity> flats;
  FlatLoadedState({required this.flats});
}

class SuccessState extends NewFlatsState {
  String message;
  SuccessState({required this.message});
}

class ErrorState extends NewFlatsState {
  String message;
  ErrorState({required this.message});
}

class DeleteState extends NewFlatsState {
  int index;
  DeleteState({required this.index});
}
