import 'package:lf_survey/model/db_model/residential/sub_prj_entity.dart';
import 'package:lf_survey/model/residential/project_spinner.dart';

abstract class SPrjDetailsState {}

class InitState extends SPrjDetailsState {}

class ErrorState extends SPrjDetailsState {
  String message;
  ErrorState({required this.message});
}

class SuccessState extends SPrjDetailsState {
  String message;
  SuccessState({required this.message});
}

class LocalDbState extends SPrjDetailsState {
  List<CityList> cityData;
  SubProjectEntity subProjectData;
  LocalDbState({required this.cityData, required this.subProjectData});
}
