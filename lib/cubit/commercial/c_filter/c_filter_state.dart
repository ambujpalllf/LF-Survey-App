class CFilterState {}

class InitState extends CFilterState {}

class ErrorState extends CFilterState {
  String message;
  ErrorState({required this.message});
}

class LocalDBState extends CFilterState {
  Map<String, dynamic> queryData;
  LocalDBState({required this.queryData});
}
