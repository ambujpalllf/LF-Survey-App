import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lf_survey/cubit/commercial/c_new_%20project/c_new_project_state.dart';
import 'package:lf_survey/database/db_helper.dart';
import 'package:lf_survey/model/db_model/commercial/c_new_project_entity.dart';
import 'package:lf_survey/services/work_manager_task_register.dart';

class CNewProjectCubit extends Cubit<CNewProjectState> {
  CNewProjectCubit() : super(InitState());

  void fetchData() async {
    try {
      final response = await DBHelper.cGetAllNewProjects();
      if (response.isNotEmpty) {
        emit(LocalDbState(projects: response));
      } else {
        emit(
          ErrorState(
            message: "No project data available. Kindly create a new project or download existing new projects.",
          ),
        );
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void searchData({required List<CNewProjectEntity> projects, required String query}) {
    try {
      final sq = query.trim().toLowerCase();
      if (sq.isEmpty) {
        emit(SearchState(projects: projects));
        return;
      }
      final filterProjects = projects.where((e) {
        final prjId = e.prjId?.toLowerCase() ?? "";
        final prjName = e.prjName?.toLowerCase() ?? "";
        final builderName = e.builderName?.toLowerCase() ?? "";
        final prjAddress = e.prjAddr?.toLowerCase() ?? "";
        final roadName = e.roadName?.toLowerCase() ?? "";
        return prjId.contains(sq) ||
            prjName.contains(sq) ||
            builderName.contains(sq) ||
            prjAddress.contains(roadName) ||
            roadName.contains(sq);
      }).toList();
      emit(SearchState(projects: filterProjects));
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void submitProject({required String prjId}) async {
    try {
      WorkManagerTaskRegister.cSyncNewProject(prjId: prjId);
      emit(ErrorState(message: "Project synchronization is in progress."));
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }
}
