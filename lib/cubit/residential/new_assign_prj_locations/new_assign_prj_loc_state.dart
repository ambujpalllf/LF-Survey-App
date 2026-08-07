abstract class NewAssignPrjLocState {}

class InitState extends NewAssignPrjLocState {}

class LocalDbState extends NewAssignPrjLocState {
  List<Map<String, dynamic>> locations;
  LocalDbState({required this.locations});
}

class SearchedState extends NewAssignPrjLocState {
  List<Map<String, dynamic>> locations;
  SearchedState({required this.locations});
}

class ErrorState extends NewAssignPrjLocState {
  final String message;
  ErrorState({required this.message});
}

class LoadingState extends NewAssignPrjLocState {}
