import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lf_survey/cubit/auth/ps_forget_pass.dart';
import 'package:lf_survey/services/api_client.dart';

class PsForgetCubit extends Cubit<PsForgetPassState> {
  PsForgetCubit() : super(InitState());

  bool fieldsValidation({required String email, required String password}) {
    if (email.trim().isEmpty) {
      emit(ValidationState(emailEr: "Enter email id."));
      return false;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email.trim())) {
      emit(ValidationState(emailEr: "Enter valid email id."));
      return false;
    }

    if (password.isEmpty) {
      emit(ValidationState(passEr: "Enter password."));
      return false;
    }

    if (password.length < 8) {
      emit(ValidationState(passEr: "Password must be at least 8 characters."));
      return false;
    }

    emit(ValidationState());
    return true;
  }

  void resetPassword({required String email, required String password}) async {
    try {
      if (!fieldsValidation(email: email, password: password)) return;
      emit(LoadingState());
      final response = await ApiClient.psForgetPassword(userEmail: email, password: password);
      if (response["status"].toString().toLowerCase() == "ok") {
        emit(SuccessState(message: response["message"]));
      } else {
        emit(ErrorState(message: response["message"]));
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }
}
