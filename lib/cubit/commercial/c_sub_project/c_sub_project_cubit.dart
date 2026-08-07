import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lf_survey/cubit/commercial/c_sub_project/c_sub_project_state.dart';
import 'package:lf_survey/database/db_helper.dart';

class CSubProjectCubit extends Cubit<CSubProjectState> {
  CSubProjectCubit() : super(InitState());

  void fetchSubProjects({required int projectId}) async {
    try {
      emit(LoadingState());
      // final response = await DBHelper.cGetSubProjects();
      final response = await DBHelper.cGetSubProjectsByPrjId(projectId: projectId);
      if (response.isNotEmpty) {
        emit(LoadedState(subProjects: response));
      } else {
        emit(LoadedState(subProjects: []));
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }
}
