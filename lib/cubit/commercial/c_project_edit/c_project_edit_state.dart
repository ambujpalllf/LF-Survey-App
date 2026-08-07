abstract class CProjectEditState {}

class InitState extends CProjectEditState {}

class LoadingState extends CProjectEditState {}

class LocalDbState extends CProjectEditState {
  List<Map<String, dynamic>> areaUnit;
  List<Map<String, dynamic>> tenant;
  LocalDbState({required this.areaUnit, required this.tenant});
}

class ErrorState extends CProjectEditState {
  final String message;
  ErrorState({required this.message});
}

class SuccessState extends CProjectEditState {
  final String message;
  SuccessState({required this.message});
}
