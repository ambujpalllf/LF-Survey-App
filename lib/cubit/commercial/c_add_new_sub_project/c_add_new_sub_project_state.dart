abstract class CAddNewSubProjectState {}

class InitState extends CAddNewSubProjectState {}

class LoadingState extends CAddNewSubProjectState {}

class LocalDbState extends CAddNewSubProjectState {
  List<Map<String, dynamic>> constProjgress;
  LocalDbState({required this.constProjgress});
}

class ErrorState extends CAddNewSubProjectState {
  final String message;
  ErrorState({required this.message});
}

class SuccessState extends CAddNewSubProjectState {
  final String message;
  SuccessState({required this.message});
}

class RateTypeState extends CAddNewSubProjectState {
  final String rateType;
  RateTypeState({required this.rateType});
}

class SelectConstState extends CAddNewSubProjectState {
  final dynamic constType;
  SelectConstState({required this.constType});
}

class ValidationState extends CAddNewSubProjectState {
  final Map<String, String> errors;

  ValidationState({required this.errors});

  ValidationState copyWith({Map<String, String>? errors}) {
    return ValidationState(errors: errors ?? this.errors);
  }
}
