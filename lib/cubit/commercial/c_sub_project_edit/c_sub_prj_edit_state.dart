abstract class CSubPrjEditState {}

class InitState extends CSubPrjEditState {}

class LocalDbState extends CSubPrjEditState {
  List<Map<String, dynamic>> constProgress;
  List<Map<String, dynamic>> buildingType;
  List<Map<String, dynamic>> operationModel;
  List<Map<String, dynamic>> projectStatus;
  LocalDbState({
    required this.constProgress,
    required this.buildingType,
    required this.operationModel,
    required this.projectStatus,
  });
}

class ErrorState extends CSubPrjEditState {
  final String message;
  ErrorState({required this.message});
}

class SuccessState extends CSubPrjEditState {
  final String message;
  SuccessState({required this.message});
}

class SelectConstProgressState extends CSubPrjEditState {}

class ValidationState extends CSubPrjEditState {
  String? projectStatusEr;
  String? floorSlabEr;
  String? marketingStartDateEr;
  String? marketingEndDateEr;
  ValidationState({this.projectStatusEr, this.floorSlabEr, this.marketingStartDateEr, this.marketingEndDateEr});
}

class SelectDateState extends CSubPrjEditState {}

class LoadingState extends CSubPrjEditState {}
