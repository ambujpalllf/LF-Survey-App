import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lf_survey/constants/storage_function.dart';
import 'package:lf_survey/constants/storage_key.dart';
import 'package:lf_survey/constants/utils.dart';
import 'package:lf_survey/cubit/residential/sub_project/new_sub_projects/new_sprj_states.dart';
import 'package:lf_survey/database/db_helper.dart';
import 'package:lf_survey/model/db_model/residential/new_flat_entity.dart';
import 'package:lf_survey/model/db_model/residential/new_sub_project_entity.dart';
import 'package:lf_survey/model/residential/project_spinner.dart';
import 'package:lf_survey/model/residential/user_response.dart';
import 'package:lf_survey/services/work_manager_task_register.dart';

class NewSprjCubit extends Cubit<NewSprjState> {
  NewSprjCubit() : super(InitState());
  void fetchUserData() async {
    try {
      final userData = await StorageFunction.readStringData(StorageKey.userData);
      if (userData != null) {
        UserData user = UserData.fromJson(jsonDecode(userData));
        final decodedList = jsonDecode(user.jsonstr ?? "");
        final List<Map<String, dynamic>> prjEntryData = decodedList.cast<Map<String, dynamic>>();
        if (prjEntryData.isNotEmpty) {
          emit(
            UserDataState(
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

  void fetchSubProjects({required int projectId, required String newPrjId}) async {
    try {
      emit(LoadingState());
      final response = await Future.wait([
        projectId != 0
            ? DBHelper.getAllNewSubProjectByPrjId(projectId: projectId)
            : DBHelper.getAllNewSubProjectByNewPrjId(newPrjId: newPrjId),
        DBHelper.getConstProgress(),
      ]);
      final sprjResp = response[0] as List<NewSubProjectEntity>;
      final constProgressResp = response[1] as List<Map<String, dynamic>>;
      if (sprjResp.isNotEmpty && constProgressResp.isNotEmpty) {
        List<NewSubProjectEntity> subProjects = sprjResp;
        final Map<String, List<NewFlatEntity>> flatsMap = {};
        await Future.wait(
          subProjects.map((subProject) async {
            final flats = await DBHelper.fetchAllNewFlatsBySubPrjId(subProject.subPrjid!);
            flatsMap[subProject.subPrjid!] = flats;
          }),
        );
        List<ConstProgressList> constProgress = constProgressResp.map((i) => ConstProgressList.fromJson(i)).toList();
        emit(LoadedState(subProjects: subProjects, constProgress: constProgress, flatsBySubProject: flatsMap));
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void fetchFlatData({required String suprj}) async {
    try {
      emit(LoadingState());
      final response = await DBHelper.fetchAllNewFlatsBySubPrjId(suprj);
      if (response.isNotEmpty) {
        // emit(FlatLoadedState(flats: response));
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void deleteSprj({required String subPrjid, required int index}) async {
    try {
      final response = await DBHelper.deleteNewSubProjectEntity(subPrjid);
      if (response > 0) {
        emit(DeleteState(index: index));
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void validateAndCopy({
    required int selectedCopyIndex,
    required String subPrjName,
    required List<NewSubProjectEntity> subProjectList,
  }) async {
    //  Don't Copy - navigate
    if (selectedCopyIndex == -1) {
      emit(SubPrjCopyState(isValid: true, shouldNavigate: true));
      return;
    }

    //  Copy - validation
    if (subPrjName.trim().isEmpty) {
      emit(SubPrjCopyState(errorMsg: "Enter sub-project name"));
      return;
    }

    final queryText = Utils.normalizeString(subPrjName);

    final bool isContain = subProjectList.any((e) => Utils.normalizeString(e.subPrjName ?? "") == queryText);

    if (isContain) {
      emit(SubPrjCopyState(errorMsg: "Sub-project with entered name already exists"));
      return;
    }
    final userId = await StorageFunction.readIntData(StorageKey.userId);
    var subPrj = subProjectList[selectedCopyIndex];
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final String subProjectId = "${userId}_${subPrj.projectId}_$timestamp";
    final String createdDateTime = DateFormat("dd-MMM-yyyy'T'HH:mm:ss").format(DateTime.now());

    debugPrint("Selected Sub Project Id: ${subPrj.subPrjid}");
    List<NewFlatEntity> newFlats = await DBHelper.fetchAllNewFlatsBySubPrjId(subPrj.subPrjid!);
    debugPrint("Flat Data Length: ${newFlats.length}");
    for (var flatData in newFlats) {
      // final flatTimeStamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final flatTimeStamp = DateTime.now().millisecondsSinceEpoch;
      String flatId = "${subProjectId}_$flatTimeStamp";
      flatData.newFlatId = flatId;
      flatData.newSubProjectId = subProjectId;
      flatData.createdDateTime = createdDateTime;
      flatData.syncGlobalStatus = 0;
      debugPrint("Flat Info: ${flatData.toNewFlatEntityMap()}");
      await DBHelper.insertNewFlatEntity(flatData);
    }

    subPrj.subPrjName = subPrjName;
    subPrj.subPrjid = subProjectId;
    subPrj.createdDateTime = createdDateTime;
    subPrj.syncGlobalStatus = 0;
    await DBHelper.insertNewSubProject(subPrj);

    //  Valid input
    emit(SubPrjCopyState(isValid: true, shouldNavigate: false));
    // submitSubProject(subPrjData: subPrj);
  }

  void submitSubProject({NewSubProjectEntity? subPrjData, List<NewSubProjectEntity>? subProjectList}) async {
    try {
      if (subProjectList != null && subProjectList.isEmpty) {
        emit(ErrorState(message: "No new sub projects available to sync. Please add sub-projects and try again."));
        return;
      }
      if (subProjectList != null) {
        bool allSynced = subProjectList.every((element) => element.syncGlobalStatus == 1);
        if (allSynced) {
          emit(ErrorState(message: "All sub-projects are already synced."));
          return;
        }
      }

      // await ApiClient.addNewSubPrj(subProject: subPrjData);
      if (subPrjData != null) {
        WorkManagerTaskRegister.syncNewSubProject(supProjectId: subPrjData.subPrjid!);
      } else {
        WorkManagerTaskRegister.syncNewSubProject(supProjectId: "0");
      }
    } catch (e) {
      String error = e.toString().split(":").last;
      emit(ErrorState(message: error));
    }
  }
}
