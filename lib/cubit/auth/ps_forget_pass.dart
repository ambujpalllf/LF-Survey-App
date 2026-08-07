abstract class PsForgetPassState {}

class InitState extends PsForgetPassState {}

class LoadingState extends PsForgetPassState {}

class SuccessState extends PsForgetPassState {
  final String message;
  SuccessState({required this.message});
}

class ErrorState extends PsForgetPassState {
  final String message;
  ErrorState({required this.message});
}

class ValidationState extends PsForgetPassState {
  String? emailEr;
  String? passEr;
  ValidationState({this.emailEr, this.passEr});
}
