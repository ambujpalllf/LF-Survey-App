import 'package:lf_survey/model/construction_monitoring/cm_wing_response.dart';
import 'package:lf_survey/model/pams_survey/land_response.dart';
import 'package:lf_survey/model/pams_survey/ps_photo_response.dart';
import 'package:lf_survey/model/pams_survey/ps_prj_response.dart';

abstract class PsProjectState {}

class InitState extends PsProjectState {}

class SuccessState extends PsProjectState {
  final String message;
  SuccessState({required this.message});
}

class ErrorState extends PsProjectState {
  final String message;
  ErrorState({required this.message});
}

class LoadingState extends PsProjectState {}

class LocalDBState extends PsProjectState {
  List<PsPrjDatum> projects;
  List<PsPhotoDatum> photos;
  List<PsLandDatum> land;
  List<WingData> wings;
  LocalDBState({required this.projects, required this.photos, this.land = const [], this.wings = const []});
}

class DownloadedState extends PsProjectState {
  List<PsPrjDatum> projects;
  DownloadedState({required this.projects});
}

class SearchState extends PsProjectState {
  List<PsPrjDatum> projects;
  SearchState({required this.projects});
}

class DbClearState extends PsProjectState {
  final String message;
  DbClearState({required this.message});
}
