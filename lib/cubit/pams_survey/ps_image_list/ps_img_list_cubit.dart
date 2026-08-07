import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lf_survey/cubit/pams_survey/ps_image_list/ps_image_list_state.dart';
import 'package:lf_survey/database/db_helper.dart';
import 'package:lf_survey/services/work_manager_task_register.dart';

class PsImgListCubit extends Cubit<PsImgListState> {
  PsImgListCubit() : super(InitState());

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

  void syncImages() {
    try {
      WorkManagerTaskRegister.syncPsImage(projectId: 0, imgPath: "");
      emit(SuccessState(message: "Images Syncing started..."));
    } catch (e) {
      String erMsg = e.toString().split(":").last;
      emit(ErrorState(message: erMsg));
    }
  }
}
