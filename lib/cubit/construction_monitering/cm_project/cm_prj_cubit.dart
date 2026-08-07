import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lf_survey/cubit/construction_monitering/cm_project/cm_prj_state.dart';
import 'package:lf_survey/database/db_helper.dart';
import 'package:lf_survey/model/pams_survey/ps_prj_response.dart';
import 'package:lf_survey/services/api_client.dart';

class CmPrjCubit extends Cubit<CmPrjState> {
  CmPrjCubit() : super(InitState());

  void getProjects() async {
    try {
      emit(LoadingState());
      final response = await DBHelper.getAllPsProjects();
      if (response.isNotEmpty) {
        emit(LoadedState(projects: response));
      } else {
        emit(ErrorState(message: "No Data Found!"));
      }
    } catch (e) {
      String erMsg = e.toString().split(":").first;
      emit(ErrorState(message: erMsg));
    }
  }

  void searchPrj({required String query, required List<PsPrjDatum> projects}) {
    try {
      String trimmedQuery = query.trim().toLowerCase();
      List<PsPrjDatum> filterList = projects;
      if (trimmedQuery.isNotEmpty && trimmedQuery.length >= 2) {
        filterList = projects.where((e) {
          return e.projectId!.toString().toLowerCase().contains(trimmedQuery) ||
              e.projectName!.toLowerCase().contains(trimmedQuery) ||
              e.legalAddress!.toLowerCase().contains(trimmedQuery);
        }).toList();
        emit(FilterState(projects: filterList));
      }
    } catch (e) {
      String erMsg = e.toString().split(":").first;
      emit(ErrorState(message: erMsg));
    }
  }

  void downloadProjects() async {
    try {
      emit(LoadingState());
      final response = await ApiClient.psGetProjects(projectId: "");
      if (response == null || response["status"] != "OK") {
        emit(ErrorState(message: response?["message"] ?? "Failed to load projects"));
        return;
      }
      final prjResponse = PsPrjResponse.fromJson(response);
      final List<PsPrjDatum> projects = prjResponse.data ?? [];
      await Future.wait(projects.map((p) => DBHelper.insertPsProject(p)));
      emit(LoadedState(projects: projects));
    } catch (e) {
      String erMsg = e.toString().split(":").first;
      emit(ErrorState(message: erMsg));
    }
  }

  void clarDb() async {
    try {
      emit(LoadingState());
      await DBHelper.clearAllPsData();
      emit(ClearDbState(message: "Data cleared successfully."));
    } catch (e) {
      String erMsg = e.toString().split(":").first;
      emit(ErrorState(message: erMsg));
    }
  }
}
