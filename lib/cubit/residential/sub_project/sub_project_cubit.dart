import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lf_survey/cubit/residential/sub_project/sub_project_state.dart';
import 'package:lf_survey/database/db_helper.dart';
import 'package:lf_survey/model/db_model/residential/flat_entity.dart';
import 'package:lf_survey/model/db_model/residential/sub_prj_entity.dart';
import 'package:lf_survey/services/api_client.dart';
import 'package:lf_survey/services/work_manager_task_register.dart';

class SubProjectCubit extends Cubit<SubProjectState> {
  SubProjectCubit() : super(InitState());

  void fetchSubProjects({required int projectId}) async {
    try {
      emit(LoadingState());

      final response = await Future.wait([
        DBHelper.fetchAllSprjEntityByPrjId(projectId: projectId),
        DBHelper.getAllFlats(),
      ]);
      final respSubprj = response[0] as List<Map<String, dynamic>>;
      final respFlats = response[1] as List<FlatEntity>;
      if (respSubprj.isNotEmpty) {
        List<SubProjectEntity> subProjects = respSubprj.map((i) => SubProjectEntity.fromJson(i)).toList();
        emit(LoadedState(subProjects: subProjects, flats: respFlats));
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void fetchConstuctionProgress() async {
    try {
      emit(LoadingState());

      final response = await DBHelper.getConstProgress();

      if (response.isNotEmpty) {
        emit(ConstructionProgressState(constructionProgress: response));
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void syncSubProjects({
    required List<SubProjectEntity> subProjects,
    required List<FlatEntity> flats,
    required int projectId,
  }) async {
    try {
      bool unsync = subProjects.any((e) => e.syncGlobalStatus == 0 && e.syncLocalStatus == 0);
      bool isFlatField = flats.any((e) => e.dataFilled != 1);
      if (isFlatField == true) {
        for (var subPrj in subProjects) {
          subPrj.errMsg = "Please fill all flats data, before syncing.";
          await DBHelper.updateSprjEntity(subPrj);
        }
        fetchSubProjects(projectId: projectId);
        return;
      }
      if (unsync == true) {
        WorkManagerTaskRegister.syncAllSubProject();
        emit(SuccessState(message: "Sub-Project sync started"));
      } else {
        emit(SuccessState(message: "Sub-project is already synced. No need to sync again."));
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void deleteSubProject({required int subprojectId, required String qtrId, required int index}) async {
    try {
      final qtrsId = int.tryParse(qtrId) ?? 0;
      final response = await ApiClient.deleteSubProject(subProjectId: subprojectId, qtrId: qtrsId);
      if (response != null && response['status'] == 'OK' && response['data'] != null && response['data'].isNotEmpty) {
        final errStatus = response['data'][0]['ERRSTATUS'];
        final returnedId = response['data'][0]['ID'];
        if (errStatus == "Deleted Successfully") {
          // Delete from local DB
          await DBHelper.deleteSubprojectEntity(subProjectId: returnedId);
          await DBHelper.deleteFlat(subProjectId: returnedId);
          emit(DeleteSubPrjState(index: index));
        } else {
          //Show API error message
          emit(ErrorState(message: errStatus));
        }
      } else {
        emit(ErrorState(message: "Invalid server response"));
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }
}
