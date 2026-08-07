import 'package:lf_survey/model/residential/project_spinner.dart';
import 'package:lf_survey/model/residential/rera_details_response.dart';
import 'package:lf_survey/model/residential/rera_response.dart';

abstract class AddNewPrjState {}

class InitState extends AddNewPrjState {}

class LocalDbState extends AddNewPrjState {
  List<CityList> cities;
  List<AmenitiesList> amenties;
  List<ApprovedBankList> approveBanks;
  List<ProjectScaleList> projectScales;
  LocalDbState({required this.cities, required this.amenties, required this.approveBanks, required this.projectScales});
}

class UserDataState extends AddNewPrjState {
  String qtrId;
  String qtr;
  UserDataState({required this.qtrId, required this.qtr});
}

class SuccessState extends AddNewPrjState {
  String message;
  SuccessState({required this.message});
}

class ErrorState extends AddNewPrjState {
  String message;
  ErrorState({required this.message});
}

class SelectPrjTypeSate extends AddNewPrjState {
  Map<String, dynamic> projectType;
  SelectPrjTypeSate({required this.projectType});
}

class LotteryState extends AddNewPrjState {
  bool isLottery;
  LotteryState({required this.isLottery});
}

class ReraLaunchState extends AddNewPrjState {
  bool isReraLaunch;
  ReraLaunchState({required this.isReraLaunch});
}

class RedevelopState extends AddNewPrjState {
  bool isRedevelop;
  RedevelopState({required this.isRedevelop});
}

class FieldsValidation extends AddNewPrjState {
  String reraMsg;
  String prjMsg;
  String prjAddMsg;
  String builderMsg;
  String archiMsg;
  String latMsg;
  String lngMsg;
  String mobMsg;
  FieldsValidation({
    required this.reraMsg,
    required this.prjMsg,
    required this.prjAddMsg,
    required this.builderMsg,
    required this.archiMsg,
    required this.latMsg,
    required this.lngMsg,
    required this.mobMsg,
  });
}

class LoadingState extends AddNewPrjState {}

class ReraSearch extends AddNewPrjState {
  List<ReraDatum> reraDatum;
  ReraSearch({required this.reraDatum});
}

class ReraDetailsState extends AddNewPrjState {
  List<ReraDetails> reraDetails;
  ReraDetailsState({required this.reraDetails});
}
