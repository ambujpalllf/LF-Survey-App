import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lf_survey/constants/storage_function.dart';
import 'package:lf_survey/constants/storage_key.dart';
import 'package:lf_survey/cubit/auth/ps_signin_state.dart';
import 'package:lf_survey/services/api_client.dart';

class PsSigninCubit extends Cubit<PsSignInState> {
  PsSigninCubit() : super(InitState());

  void togglePassword({required bool showPass}) {
    emit(TogglePasswordState(isShow: !showPass));
  }

  void onEmpFocusChange(bool isFocused) {
    if (state is! ValidationState) return;
    final currretState = state as ValidationState;
    emit(currretState.copyWith(empCodeFocused: isFocused));
  }

  void onPassFocusChange(bool isFocused) {
    if (state is! ValidationState) return;
    final currretState = state as ValidationState;
    emit(currretState.copyWith(passFocused: isFocused));
  }

  void onEmpCodeChanged(String value) {
    if (state is! ValidationState) return;
    final currretState = state as ValidationState;
    emit(
      currretState.copyWith(
        isEmpCodeEmpty: value.isEmpty,
        empCodeMessage: value.isEmpty ? "Email cannot be empty" : null,
      ),
    );
  }

  void onPasswordChanged(String value) {
    if (state is! ValidationState) return;
    final currentState = state as ValidationState;
    bool isEmpty = value.isEmpty;
    String? message;
    if (isEmpty) {
      message = "Password cannot be empty";
    } else if (value.length < 4) {
      message = "Please enter min 4 chars";
      isEmpty = true;
    } else {
      message = null;
    }
    emit(currentState.copyWith(isPassEmpty: isEmpty, passMessage: message));
  }

  bool validateFields({required String empEmail, required String password}) {
    final isEmpCodeEmpty = empEmail.isEmpty;
    final isPassword = password.isEmpty;
    emit(
      ValidationState(
        isEmpCodeEmpty: isEmpCodeEmpty,
        isPassEmpty: isPassword,
        empCodeMessage: empEmail.isEmpty ? "Email cannot be empty" : null,
        passMessage: password.isEmpty ? "Password cannot be empty" : null,
      ),
    );
    return !(isEmpCodeEmpty || isPassword);
  }

  void loginUser({required String userEmail, required String password}) async {
    try {
      emit(LoadingState());
      final response = await ApiClient.psLoginUser(userEmail: userEmail, password: password);
      if (response["status"] == "OK") {
        StorageFunction.writeStringData(StorageKey.loginType, "pams");
        StorageFunction.writeBoolData(StorageKey.isLogin, true);
        StorageFunction.writeStringData(StorageKey.token, response["data"]["access_token"]);
        StorageFunction.writeIntData(StorageKey.userId, response["data"]["user_id"]);
        StorageFunction.writeIntData(StorageKey.tokenExpire, response["data"]["expires_in"]);
        StorageFunction.writeIntData(StorageKey.loginTime, DateTime.now().millisecondsSinceEpoch);
        emit(LoginState());
      } else {
        String? message = response["message"];

        String errorMessage;

        if (message != null && message.contains(":")) {
          errorMessage = message.split(":").last.trim();
        } else if (message != null && message.isNotEmpty) {
          errorMessage = message;
        } else {
          errorMessage = "Something Error Occured";
        }

        emit(ErrorState(message: errorMessage));
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }
}
