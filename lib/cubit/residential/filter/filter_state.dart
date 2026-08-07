class FilterState {}

class InitState extends FilterState {}

class ErrorState extends FilterState {
  String message;
  ErrorState({required this.message});
}

class LocalDBState extends FilterState {
  Map<String, dynamic> queryData;
  LocalDBState({required this.queryData});
}
