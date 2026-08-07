import 'package:lf_survey/model/residential/project_spinner.dart';

abstract class AddNewSprjFormState {}

class InitState extends AddNewSprjFormState {}

class UserDataState extends AddNewSprjFormState {
  String qtrId;
  String qtr;
  UserDataState({required this.qtrId, required this.qtr});
}

class LoadingState extends AddNewSprjFormState {}

class SuccessState extends AddNewSprjFormState {
  final String message;
  SuccessState({required this.message});
}

class ErrorState extends AddNewSprjFormState {
  final String message;
  ErrorState({required this.message});
}

class SelectDateState extends AddNewSprjFormState {
  final DateTime selectedDate;
  SelectDateState({required this.selectedDate});
}

class LocalState extends AddNewSprjFormState {
  List<ConstProgressList> constProgress;
  List<ProjectStatusList> prjStatus;
  List<CityList> cities;
  LocalState({required this.constProgress, required this.prjStatus, required this.cities});
}

class ValidateState extends AddNewSprjFormState {
  final Map<String, String> errors;
  ValidateState({required this.errors});
}
