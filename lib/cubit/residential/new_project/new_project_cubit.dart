import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lf_survey/constants/storage_function.dart';
import 'package:lf_survey/constants/storage_key.dart';
import 'package:lf_survey/cubit/residential/new_project/new_project_state.dart';
import 'package:lf_survey/database/db_helper.dart';
import 'package:lf_survey/model/db_model/residential/new_project_entity.dart';
import 'package:lf_survey/model/residential/user_response.dart';
import 'package:lf_survey/services/api_client.dart';
import 'package:lf_survey/services/work_manager_task_register.dart';

class NewProjectCubit extends Cubit<NewProjectState> {
  NewProjectCubit() : super(InitState());

  void fetchQtrData() async {
    try {
      final userData = await StorageFunction.readStringData(StorageKey.userData);
      if (userData != null) {
        UserData user = UserData.fromJson(jsonDecode(userData));
        final decodedList = jsonDecode(user.jsonstr ?? "");
        final List<Map<String, dynamic>> prjEntryData = decodedList.cast<Map<String, dynamic>>();
        if (prjEntryData.isNotEmpty) {
          emit(
            LocalPrefsState(
              qtrId: prjEntryData.first["NEW_PRJ_ENTRY_QTR_ID"],
              qtr: prjEntryData.first["NEW_PRJ_ENTRY_QTR"],
            ),
          );
        }
      }
    } catch (e) {
      String erStr = e.toString().split(":").last;
      emit(ErrorState(message: erStr));
    }
  }

  void fetchData() async {
    try {
      final response = await DBHelper.fetchAllNewProjects();
      if (response.isNotEmpty) {
        emit(LocalDbState(projects: response));
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void downloadProjects() async {
    try {
      final userData = await StorageFunction.readStringData(StorageKey.userData);
      if (userData != null) {
        UserData user = UserData.fromJson(jsonDecode(userData));
        final decodedList = jsonDecode(user.jsonstr ?? "");
        final List<Map<String, dynamic>> prjEntryData = decodedList.cast<Map<String, dynamic>>();
        if (prjEntryData.isNotEmpty) {
          String qtrId = prjEntryData.first["NEW_PRJ_ENTRY_QTR_ID"];
          int empId = user.empId ?? 0;
          final apiResp = await ApiClient.fetchNewPrjAndSubPrj(empId: empId, qtrId: qtrId, lookup: "NEW_PROJECT");
          if (apiResp == null || apiResp["data"] == null) {
            emit(LocalDbState(projects: []));
            return;
          }
          final List<NewProjectEntity> projects = (apiResp["data"] as List)
              .map((e) => NewProjectEntity.fromJson(NewProjectEntity().mapApiProjectToEntity(e)))
              .toList();
          emit(LocalDbState(projects: projects));
        }
      }
    } catch (e) {
      debugPrint("$e");
      emit(ErrorState(message: e.toString()));
    }
  }

  void syncProjects({required List<NewProjectEntity> projects}) {
    try {
      if (projects.isEmpty) {
        emit(ErrorState(message: "No projects available to sync. Please add proects and try again."));
        return;
      }
      bool allSynced = projects.every((element) => element.syncGlobalStatus == 1);
      if (allSynced) {
        emit(ErrorState(message: "All projects are already synced."));
        return;
      }
      WorkManagerTaskRegister.syncAllNewProject();
      emit(SuccessState(message: "Projects background syncing stared."));
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void searchProject({required String query, required List<NewProjectEntity> projects}) {
    final trimmedQuery = query.trim().toLowerCase();

    List<NewProjectEntity> filteredList = projects;

    if (trimmedQuery.isNotEmpty && trimmedQuery.length >= 3) {
      filteredList = projects.where((e) {
        return e.prjId!.contains(trimmedQuery) ||
            e.prjName!.toLowerCase().contains(trimmedQuery) ||
            e.builderName!.toLowerCase().contains(trimmedQuery) ||
            e.prjAddr!.toLowerCase().contains(trimmedQuery);
      }).toList();
    }

    emit(SearchState(projects: filteredList));
  }
}
