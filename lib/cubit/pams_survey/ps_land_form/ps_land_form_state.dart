import 'package:lf_survey/model/pams_survey/land_response.dart';
import 'package:location/location.dart';

abstract class PsLandFormState {}

class InitState extends PsLandFormState {}

class LoadingState extends PsLandFormState {}

class LoadedState extends PsLandFormState {
  List<PsLandDatum> lands;
  LoadedState({required this.lands});
}

class SucccessState extends PsLandFormState {
  final String message;
  SucccessState({required this.message});
}

class ErrorState extends PsLandFormState {
  final String message;
  ErrorState({required this.message});
}

class LocaLoadingState extends PsLandFormState {}

class LocLoadedState extends PsLandFormState {
  LocationData location;
  LocLoadedState({required this.location});
}
