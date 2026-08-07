import 'package:lf_survey/model/residential/project_spinner.dart';

abstract class NewPrjDetailsState {}

class InitState extends NewPrjDetailsState {}

class LocalDbState extends NewPrjDetailsState {
  List<CityList> city;
  LocalDbState({required this.city});
}

class SuccessState extends NewPrjDetailsState {
  String message;
  SuccessState({required this.message});
}

class ErrorState extends NewPrjDetailsState {
  String message;
  ErrorState({required this.message});
}
