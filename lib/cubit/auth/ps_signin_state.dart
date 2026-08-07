abstract class PsSignInState {}

class InitState extends PsSignInState {}

class LoadingState extends PsSignInState {}

class TogglePasswordState extends PsSignInState {
  final bool isShow;
  TogglePasswordState({required this.isShow});
}

class LoginState extends PsSignInState {}

class SuccessState extends PsSignInState {
  final String message;
  SuccessState({required this.message});
}

class ErrorState extends PsSignInState {
  final String message;
  ErrorState({required this.message});
}

class ValidationState extends PsSignInState {
  final bool isEmpCodeEmpty;
  final bool isPassEmpty;
  final bool isMobEmpty;
  final bool isEmailEmpty;
  final bool empCodeFocused;
  final bool emailFocused;
  final bool passFocused;
  final bool mobFocused;
  final String? empCodeMessage;
  final String? emailMessage;
  final String? passMessage;
  final String? mobMessage;

  ValidationState({
    this.isEmpCodeEmpty = false,
    this.isPassEmpty = false,
    this.isMobEmpty = false,
    this.isEmailEmpty = false,
    this.empCodeFocused = false,
    this.emailFocused = false,
    this.passFocused = false,
    this.mobFocused = false,
    this.empCodeMessage,
    this.emailMessage,
    this.passMessage,
    this.mobMessage,
  });

  ValidationState copyWith({
    bool? isEmpCodeEmpty,
    bool? isEmailEmpty,
    bool? isPassEmpty,
    bool? isMobEmpty,
    bool? empCodeFocused,
    bool? emailFocused,
    bool? passFocused,
    bool? mobFocused,
    String? empCodeMessage,
    String? passMessage,
    String? mobMessage,
    final String? emailMessage,
  }) {
    return ValidationState(
      isEmpCodeEmpty: isEmpCodeEmpty ?? this.isEmpCodeEmpty,
      isEmailEmpty: isEmailEmpty ?? this.isEmailEmpty,
      isPassEmpty: isPassEmpty ?? this.isPassEmpty,
      empCodeFocused: empCodeFocused ?? this.empCodeFocused,
      emailFocused: emailFocused ?? this.emailFocused,
      passFocused: passFocused ?? this.passFocused,
      mobFocused: mobFocused ?? this.mobFocused,
      empCodeMessage: empCodeMessage ?? this.empCodeMessage,
      passMessage: passMessage ?? this.passMessage,
      isMobEmpty: isMobEmpty ?? this.isMobEmpty,
      mobMessage: mobMessage ?? this.mobMessage,
      emailMessage: emailMessage ?? this.emailMessage,
    );
  }
}
