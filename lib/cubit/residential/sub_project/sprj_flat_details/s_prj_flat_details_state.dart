import 'package:lf_survey/model/db_model/residential/flat_entity.dart';
import 'package:lf_survey/model/db_model/residential/sub_prj_entity.dart';
// import 'package:lf_survey/model/residential/project_response.dart';
import 'package:lf_survey/model/residential/project_spinner.dart';

abstract class SPrjFlatDetailsState {}

class InitState extends SPrjFlatDetailsState {}

class LoadingState extends SPrjFlatDetailsState {}

class LoadedState extends SPrjFlatDetailsState {
  // List<FlatsData> flatsData = [];
  List<FlatEntity> flatsData = [];
  List<FlatTypeList> flatstypeData = [];
  // SubProjectsDatum subProjectsDatum;
  SubProjectEntity subProjectsDatum;
  LoadedState({required this.flatsData, required this.flatstypeData, required this.subProjectsDatum});
}

class ErrorState extends SPrjFlatDetailsState {
  final String message;
  ErrorState({required this.message});
}

class SuccessState extends SPrjFlatDetailsState {
  final String message;
  SuccessState({required this.message});
}

class ValidationState extends SPrjFlatDetailsState {
  String scrMsg;
  String flatSoldMsg;
  String slaeableSizeMsg;
  String carpetFlatSizeMsg;
  ValidationState({
    required this.scrMsg,
    required this.flatSoldMsg,
    required this.carpetFlatSizeMsg,
    required this.slaeableSizeMsg,
  });
}

class FlatUnsoldCount extends SPrjFlatDetailsState {
  String unsoldFlat;
  FlatUnsoldCount({required this.unsoldFlat});
}
