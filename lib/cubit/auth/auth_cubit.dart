import 'dart:convert';
import 'package:lf_survey/constants/storage_function.dart';
import 'package:lf_survey/constants/storage_key.dart';
import 'package:lf_survey/cubit/auth/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lf_survey/services/api_client.dart';
import 'package:lf_survey/services/notification_services.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(ValidationState());

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
        empCodeMessage: value.isEmpty ? "Employee code cannot be empty" : null,
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

  bool validateFields({required String empCode, required String password}) {
    // if (state is! ValidationState) return;
    // final currretState = state as ValidationState;
    final isEmpCodeEmpty = empCode.isEmpty;
    final isPassword = password.isEmpty;
    emit(
      ValidationState(
        isEmpCodeEmpty: isEmpCodeEmpty,
        isPassEmpty: isPassword,
        empCodeMessage: empCode.isEmpty ? "Employee code cannot be empty" : null,
        passMessage: password.isEmpty ? "Password cannot be empty" : null,
      ),
    );
    return !(isEmpCodeEmpty || isPassword);
  }

  void loginUser({required String empCode, required String password}) async {
    try {
      emit(LoadingState());
      final response = await ApiClient.loginUser(empCode: empCode, password: password);
      if (response["status"] == "OK") {
        StorageFunction.writeBoolData(StorageKey.isLogin, true);
        StorageFunction.writeStringData(StorageKey.userData, jsonEncode(response["data"]));
        StorageFunction.writeIntData(StorageKey.userId, response["data"]["empId"]);
        StorageFunction.writeStringData(StorageKey.cityId, response["data"]["cityId"]);
        StorageFunction.writeStringData(StorageKey.loginType, "lfSurvey");
        StorageFunction.writeIntData(StorageKey.loginTime, DateTime.now().millisecondsSinceEpoch);
        firebaseTokenUpdate();
        emit(LoginState());
      } else {
        emit(ErrorState(message: response["message"] ?? "Something Error Occured"));
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void firebaseTokenUpdate() async {
    try {
      String? token = await StorageFunction.readStringData(StorageKey.firebaseToken);
      if (token == null || token == "") {
        String firebaseToken = await NotificationServices().getDeviceToken();
        final response = await ApiClient.updateFirebaseToken(firebaseToken: firebaseToken);

        if (response != null && response['status'].toString().toLowerCase() == "ok") {
          List data = response['data'] ?? [];
          if (data.isNotEmpty) {
            Map<String, dynamic> respData = data.first;
            if (respData['result'] == 1) {
              await StorageFunction.writeStringData(StorageKey.firebaseToken, firebaseToken);
            }
          }
        }
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  //********** registration section **********
  void onEmpRegisterFocusChange(bool isFocused) {
    if (state is! ValidationState) return;
    final currretState = state as ValidationState;
    emit(currretState.copyWith(empCodeFocused: isFocused));
  }

  void onEmailFocusChange(bool isFocused) {
    if (state is! ValidationState) return;
    final currretState = state as ValidationState;
    emit(currretState.copyWith(emailFocused: isFocused));
  }

  void onMobFocusChange(bool isFocused) {
    if (state is! ValidationState) return;
    final currretState = state as ValidationState;
    emit(currretState.copyWith(mobFocused: isFocused));
  }

  void onEmpCodeRegisterChanged(String value) {
    if (state is! ValidationState) return;
    final currretState = state as ValidationState;
    emit(
      currretState.copyWith(
        isEmpCodeEmpty: value.isEmpty,
        empCodeMessage: value.isEmpty ? "Employee code cannot be empty" : null,
      ),
    );
  }

  void onEmailChanged(String value) {
    if (state is! ValidationState) return;
    final currentState = state as ValidationState;
    bool isEmpty = value.isEmpty;
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    String? message;
    if (isEmpty) {
      message = "Email cannot be empty";
    } else if (!emailRegex.hasMatch(value)) {
      message = "Please enter valid email.";
      isEmpty = true;
    } else {
      message = null;
    }
    emit(currentState.copyWith(isEmailEmpty: isEmpty, emailMessage: message));
  }

  void onMobChanged(String value) {
    if (state is! ValidationState) return;
    final currentState = state as ValidationState;
    bool isEmpty = value.isEmpty;
    String? message;
    if (isEmpty) {
      message = "Mobile number cannot be empty";
    } else if (value.length < 10) {
      message = "Should be a 10 digit number";
      isEmpty = true;
    } else {
      message = null;
    }
    emit(currentState.copyWith(isMobEmpty: isEmpty, mobMessage: message));
  }

  bool validateRegistrationFields({required String empCode, required String email, required String mobile}) {
    final isEmpCodeEmpty = empCode.trim().isEmpty;
    final isEmailEmpty = email.trim().isEmpty;
    final isMobEmpty = mobile.trim().isEmpty;
    final isMobInvalid = !isMobEmpty && mobile.length != 10;

    emit(
      ValidationState(
        isEmpCodeEmpty: isEmpCodeEmpty,
        isEmailEmpty: isEmailEmpty,
        isMobEmpty: isMobEmpty || isMobInvalid,
        empCodeMessage: isEmpCodeEmpty ? "Employee code cannot be empty" : null,
        emailMessage: isEmailEmpty ? "Email cannot be empty" : null,
        mobMessage: isMobEmpty
            ? "Mobile number cannot be empty"
            : isMobInvalid
            ? "Mobile number must be 10 digits"
            : null,
      ),
    );

    return !(isEmpCodeEmpty || isEmailEmpty || isMobEmpty || isMobInvalid);
  }

  void registerUser({required String empCode, required String email, required String mobileNo}) async {
    try {
      emit(LoadingState());
      String firebaseToken = await NotificationServices().getDeviceToken();
      final response = await ApiClient.registerUser(
        empCode: empCode,
        email: email,
        mobileNo: mobileNo,
        firebaseToken: firebaseToken,
      );
      if (response["resultCode"] == 1) {
        StorageFunction.writeStringData(StorageKey.firebaseToken, firebaseToken);
        emit(SuccessState(message: response["message"] ?? "You have succesfully registered"));
      } else {
        emit(ErrorState(message: response["message"] ?? "Something Error Occured"));
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }
}
