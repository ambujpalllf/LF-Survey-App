import 'package:lf_survey/model/pams_survey/land_response.dart';

abstract class PsLandState {}

class InitState extends PsLandState {}

class LoadingState extends PsLandState {}

class LoadedState extends PsLandState {
  List<PsLandDatum> lands;
  LoadedState({required this.lands});
}

class SuccessState extends PsLandState {
  final String message;
  SuccessState({required this.message});
}

class ErrorState extends PsLandState {
  final String message;
  ErrorState({required this.message});
}
