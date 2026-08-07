import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lf_survey/constants/storage_function.dart';
import 'package:lf_survey/constants/storage_key.dart';
import 'package:lf_survey/cubit/user_cubit/user_state.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(InitState());

  // Future<void> checkLogin() async {
  //   try {
  //     final result = await StorageFunction.readBoolData(StorageKey.isLogin);
  //     final loginType = await StorageFunction.readStringData(StorageKey.loginType);
  //     if (result != null && loginType != null) {
  //       emit(LoginState(isLogin: result, loginType: loginType));
  //     } else {
  //       emit(LogoutState());
  //     }
  //   } catch (e) {
  //     emit(ErrorState(message: e.toString()));
  //   }
  // }

  Future<void> checkLogin() async {
    try {
      final isLogin = await StorageFunction.readBoolData(StorageKey.isLogin);
      final loginType = await StorageFunction.readStringData(StorageKey.loginType);
      final loginTimeMillis = await StorageFunction.readIntData(StorageKey.loginTime);

      if (isLogin != null && loginType != null && loginTimeMillis != null) {
        final loginDate = DateTime.fromMillisecondsSinceEpoch(loginTimeMillis);
        final now = DateTime.now();
        final isSameDate = loginDate.year == now.year && loginDate.month == now.month && loginDate.day == now.day;

        if (!isSameDate) {
          await StorageFunction.clearStorage();
          emit(LogoutState());
        } else {
          emit(LoginState(isLogin: isLogin, loginType: loginType));
        }
      } else {
        emit(LogoutState());
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void logout() async {
    try {
      await StorageFunction.clearStorage();
      emit(LogoutState());
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }
}
