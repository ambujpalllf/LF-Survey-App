import 'package:lf_survey/model/commercial/c_location_response.dart';
import 'package:lf_survey/model/db_model/commercial/c_entity.dart';
import 'package:lf_survey/model/db_model/commercial/c_location_entity.dart';
import 'package:lf_survey/model/db_model/commercial/c_suburb_entity.dart';

abstract class CDownloadState {}

class InitState extends CDownloadState {}

class LoadingState extends CDownloadState {}

class LoadedSate extends CDownloadState {
  CLocationResponse locData;
  LoadedSate({required this.locData});
}

class LocalDbState extends CDownloadState {
  List<CCityEntity> cities;
  LocalDbState({required this.cities});
}

class SelectCityState extends CDownloadState {
  List<CSuburbEntity> suburb;
  SelectCityState({required this.suburb});
}

class SelectSuburbState extends CDownloadState {
  List<CLocationEntity> locations;
  SelectSuburbState({required this.locations});
}

class ErrorState extends CDownloadState {
  String message;
  ErrorState({required this.message});
}

class SuccessState extends CDownloadState {
  String message;
  SuccessState({required this.message});
}
