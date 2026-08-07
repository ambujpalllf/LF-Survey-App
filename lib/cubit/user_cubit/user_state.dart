abstract class UserState {}

class InitState extends UserState {}

class LogoutState extends UserState {}

class LoginState extends UserState {
  bool isLogin;
  String loginType;
  LoginState({required this.isLogin, required this.loginType});
}

class ErrorState extends UserState {
  String message;
  ErrorState({required this.message});
}

class SuccessState extends UserState {
  String message;
  SuccessState({required this.message});
}
