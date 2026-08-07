import 'package:lf_survey/model/db_model/residential/city_entiy.dart';
import 'package:lf_survey/model/db_model/residential/location_entity.dart';
import 'package:lf_survey/model/db_model/residential/suburb_entity.dart';
import 'package:lf_survey/model/residential/cities_response.dart';

abstract class DownloadState {}

class InitState extends DownloadState {}

class LoadingState extends DownloadState {}

class RefreshState extends DownloadState {}

class LocalDbState extends DownloadState {
  List<CityEntity> cities;
  LocalDbState({required this.cities});
}

class SelectedCityState extends DownloadState {
  Map<String, dynamic> cityEntity;
  List<SuburbEntity> suburb;
  SelectedCityState({required this.cityEntity, required this.suburb});
}

class SelectedSuburbState extends DownloadState {
  Map<String, dynamic> suburbEntity;
  List<LocationEntity> locations;
  SelectedSuburbState({required this.suburbEntity, required this.locations});
}

class LoadedState extends DownloadState {
  CitiesResponse citiesResponse;
  LoadedState({required this.citiesResponse});
}

class ErrorState extends DownloadState {
  String message;
  ErrorState({required this.message});
}

class SuccessState extends DownloadState {
  String message;
  SuccessState({required this.message});
}

class SelectedState extends DownloadState {
  int index;
  bool selectedValue;
  SelectedState({required this.selectedValue, required this.index});
}
