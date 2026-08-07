import 'package:lf_survey/model/residential/prj_search_details.dart';
import 'package:lf_survey/model/residential/project_search_response.dart';

abstract class PrjSearchState {}

class InitState extends PrjSearchState {}

class LoadingState extends PrjSearchState {}

class LoadedState extends PrjSearchState {
  List<ProjectSearchDatum> projects;
  LoadedState({required this.projects});
}

class PrjDetailsState extends PrjSearchState {
  PrjSearchDetails prjDetails;
  PrjDetailsState({required this.prjDetails});
}

class ClearState extends PrjSearchState {}

class ErrorState extends PrjSearchState {
  String message;
  ErrorState({required this.message});
}
