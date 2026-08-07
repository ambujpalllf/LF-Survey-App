abstract class CAddNewPrjState {}

class InitState extends CAddNewPrjState {}

class LoadingState extends CAddNewPrjState {}

class LocalDbState extends CAddNewPrjState {
  int? empId;
  String? comQtr;
  String? comQtrId;
  List<Map<String, dynamic>> amenties;
  List<Map<String, dynamic>> approvedBanks;
  List<Map<String, dynamic>> operationModel;
  List<Map<String, dynamic>> buildingType;
  List<Map<String, dynamic>> tenantType;
  List<Map<String, dynamic>> cities;

  LocalDbState({
    this.empId,
    this.comQtr,
    this.comQtrId,
    required this.amenties,
    required this.approvedBanks,
    required this.operationModel,
    required this.buildingType,
    required this.tenantType,
    required this.cities,
  });
}

class ErrorState extends CAddNewPrjState {
  final String message;
  ErrorState({required this.message});
}

class SuccessState extends CAddNewPrjState {
  final String message;
  SuccessState({required this.message});
}

class FieldsValidation extends CAddNewPrjState {
  String? projectNameEr;
  String? projectAddressEr;
  String? roadNameEr;
  String? builderNameEr;
  String? architectNameEr;
  String? latEr;
  String? lngEr;
  String? mobileNoEr;
  String? cityEr;
  String? amentiesEr;
  String? approveBanksEr;
  String? operatingModelEr;
  String? buildingTypeEr;
  String? tenantTypeEr;
  FieldsValidation({
    this.projectNameEr,
    this.projectAddressEr,
    this.roadNameEr,
    this.builderNameEr,
    this.architectNameEr,
    this.latEr,
    this.lngEr,
    this.mobileNoEr,
    this.cityEr,
    this.amentiesEr,
    this.approveBanksEr,
    this.operatingModelEr,
    this.buildingTypeEr,
    this.tenantTypeEr,
  });
}
