import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lf_survey/cubit/construction_monitering/cm_img_list/cm_img_list_state.dart';
import 'package:lf_survey/database/db_helper.dart';

class CmImgListCubit extends Cubit<CmImgListState> {
  CmImgListCubit() : super(InitState());

  void getImages() async {
    try {
      final response = await DBHelper.getAllPsImage();
      if (response.isNotEmpty) {
        emit(LoadedState(images: response));
      } else {
        emit(ErrorState(message: "Data Not Found!"));
      }
    } catch (e) {
      String erMsg = e.toString().split(":").last;
      emit(ErrorState(message: erMsg));
    }
  }
}
