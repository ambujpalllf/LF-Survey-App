import 'package:lf_survey/model/construction_monitoring/cm_building_response.dart';
import 'package:lf_survey/model/construction_monitoring/cm_wing_response.dart';

abstract class CmBuildingState {}

class InitState extends CmBuildingState {}

class LoadingState extends CmBuildingState {}

class LoadedState extends CmBuildingState {
  List<BuildingData> buildings;
  List<WingData> wings;
  LoadedState({required this.buildings, required this.wings});
}

class WingState extends CmBuildingState {
  List<WingData> wings;
  WingState({required this.wings});
}

class DeleteState extends CmBuildingState {
  int index;
  DeleteState({required this.index});
}

class ErrorState extends CmBuildingState {
  String message;
  ErrorState({required this.message});
}

class SuccessState extends CmBuildingState {
  String message;
  SuccessState({required this.message});
}
