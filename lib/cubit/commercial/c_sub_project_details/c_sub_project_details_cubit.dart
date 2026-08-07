import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lf_survey/cubit/commercial/c_sub_project_details/c_sub_project_detais_state.dart';
import 'package:lf_survey/database/db_helper.dart';

class CSubProjectDetailsCubit extends Cubit<CSubProjectDetaisState> {
  CSubProjectDetailsCubit() : super(InitState());

  void getData({required int subProjectId}) async {
    try {
      final response = await DBHelper.cGetSubPrjById(subProjectId: subProjectId);
      if (response != null) {
        emit(LocalDbState(subProjectData: response));
      }
    } catch (e) {
      emit(MessageState(message: e.toString()));
    }
  }
}
