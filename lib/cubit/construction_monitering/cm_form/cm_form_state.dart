import 'package:lf_survey/model/construction_monitoring/cm_progress_response.dart';

abstract class CMFormState {}

class InitState extends CMFormState {}

class LoadingState extends CMFormState {}

class SuccessState extends CMFormState {
  final String message;
  SuccessState({required this.message});
}

class LoadedState extends CMFormState {
  CmProgressDatum progressDatum;
  LoadedState({required this.progressDatum});
}

class ErrorState extends CMFormState {
  final String message;
  ErrorState({required this.message});
}

class ValidationState extends CMFormState {
  String? floorsErMsg;
  String? slabErMsg;
  String? plinthErMsg;
  String? rccErMsg;
  String? uptoSlabErMsg;
  String? pInternalErMsg;
  String? pExternalErMsg;
  String? flooringErMsg;
  String? electricErMsg;
  String? plumbingErMsg;
  String? woodWorkErMsg;
  String? paintingErMsg;
  bool isPlinthComplete;
  String? totalUnitsErMsg;
  String? soldUnitsErMsg;
  String? soldPercErMsg;
  String? unsoldErMsg;
  String? unsoldPercErMsg;
  String? saleableErMsg;
  String? carpetErMsg;
  ValidationState({
    this.floorsErMsg,
    this.slabErMsg,
    this.plinthErMsg,
    this.rccErMsg,
    this.uptoSlabErMsg,
    this.pInternalErMsg,
    this.pExternalErMsg,
    this.flooringErMsg,
    this.electricErMsg,
    this.plumbingErMsg,
    this.woodWorkErMsg,
    this.paintingErMsg,
    this.isPlinthComplete = false,
    this.totalUnitsErMsg,
    this.soldUnitsErMsg,
    this.soldPercErMsg,
    this.unsoldErMsg,
    this.unsoldPercErMsg,
    this.saleableErMsg,
    this.carpetErMsg,
  });
}

class RateState extends CMFormState {
  final bool isSaleable;
  final bool isCarpet;
  RateState({required this.isSaleable, required this.isCarpet});
}
