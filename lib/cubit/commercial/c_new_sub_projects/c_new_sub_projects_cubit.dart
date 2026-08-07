import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lf_survey/cubit/commercial/c_new_sub_projects/c_new_sub_projects_state.dart';
import 'package:lf_survey/database/db_helper.dart';
import 'package:lf_survey/services/work_manager_task_register.dart';

class CNewSubProjectsCubit extends Cubit<CNewSubProjectsState> {
  CNewSubProjectsCubit() : super(InitState());

  void getSubProjects({String? newProjectId, int? projectId}) async {
    try {
      final responseT = await DBHelper.cGetAllNewSubProjectsById(prjId: newProjectId, prjIdLF: projectId);
      if (responseT.isNotEmpty) {
        emit(LocalDbState(subProjects: responseT));
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void updateSubPrj({required String subProjectId}) async {
    try {
      WorkManagerTaskRegister.cSyncNewSubProject(subPrjId: subProjectId);
      emit(ErrorState(message: "Sub-Project synchronization is in progress."));
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void deleteSubProject({String? subProjectId, required int index}) async {
    try {
      final result = await DBHelper.cDeleteNewSubProject(subprojectId: subProjectId ?? "");
      if (result > 0) {
        emit(DeleteState(index: index));
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }
}
