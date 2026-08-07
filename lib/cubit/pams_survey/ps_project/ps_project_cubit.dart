import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lf_survey/cubit/pams_survey/ps_project/ps_project_state.dart';
import 'package:lf_survey/database/db_helper.dart';
import 'package:lf_survey/model/construction_monitoring/cm_wing_response.dart';
import 'package:lf_survey/model/pams_survey/land_response.dart';
import 'package:lf_survey/model/pams_survey/ps_photo_response.dart';
import 'package:lf_survey/model/pams_survey/ps_prj_response.dart';
import 'package:lf_survey/services/api_client.dart';
import 'package:lf_survey/services/work_manager_task_register.dart';

class PsProjectCubit extends Cubit<PsProjectState> {
  PsProjectCubit() : super(InitState());

  void getProjects() async {
    try {
      emit(LoadingState());
      final response = await Future.wait([
        DBHelper.getAllPsProjects(),
        DBHelper.getAllPsImage(),
        DBHelper.getAllPsLandInfo(),
        DBHelper.getCmAllWings(),
      ]);
      final resPrj = response[0] as List<PsPrjDatum>;
      final resPhoto = response[1] as List<PsPhotoDatum>;
      final resLand = response[2] as List<PsLandDatum>;
      final resWing = response[3] as List<WingData>;
      if (resPrj.isNotEmpty) {
        emit(LocalDBState(projects: resPrj, photos: resPhoto, land: resLand, wings: resWing));
      } else {
        emit(ErrorState(message: "No Data Found."));
      }
    } catch (e) {
      String erMsg = e.toString().split(":").last;
      emit(ErrorState(message: erMsg));
    }
  }

  Future<void> downloadProjects({required String projectsId}) async {
    try {
      emit(LoadingState());
      final responses = await ApiClient.psGetProjects(projectId: projectsId);
      if (responses == null || responses["status"] != "OK") {
        emit(ErrorState(message: responses?["message"] ?? "Failed to load projects"));
        return;
      }
      final prjResponse = PsPrjResponse.fromJson(responses);
      final List<PsPrjDatum> projects = prjResponse.data ?? [];
      if (projects.isEmpty) {
        emit(ErrorState(message: "You don't have any assigned projects at the moment."));
        return;
      }
      await Future.wait(projects.map((p) => DBHelper.insertPsProject(p)));

      // for (final project in projects) {
      //   if (project.wings?.isNotEmpty ?? false) {
      //     await Future.wait(
      //       project.wings!.map((wing) {
      //         wing.projectId = project.projectId;
      //         wing.submitStatus = false;
      //         return DBHelper.cmInsertWing(wing: wing);
      //       }),
      //     );
      //   }
      // }
      for (final project in projects) {
        if (project.buildings?.isNotEmpty ?? false) {
          await Future.wait(
            project.buildings!.map((building) {
              building.projectId = project.projectId;
              return DBHelper.cmInsertBuilding(building: building);
            }),
          );

          for (final building in project.buildings!) {
            if (building.wings?.isNotEmpty ?? false) {
              await Future.wait(
                building.wings!.map((wing) {
                  wing.projectId = project.projectId;
                  wing.submitStatus = false;
                  return DBHelper.cmInsertWing(wing: wing);
                }),
              );
            }
          }
        }
      }

      for (final project in projects) {
        // final land = project.landDetails;
        var land = project.landDetails;
        land?.lat = project.lat;
        land?.lng = project.lng;

        if (land != null) {
          await DBHelper.insertPsLandInfo(landData: land);
        }
      }
      // emit(LoadedState(projects: projects, photos: []));
      emit(DownloadedState(projects: projects));
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void searchProject({required String query, required List<PsPrjDatum> projects}) {
    try {
      final trimmedQuery = query.trim().toLowerCase();
      List<PsPrjDatum> filteredList = projects;
      if (trimmedQuery.isNotEmpty && trimmedQuery.length >= 2) {
        filteredList = projects.where((e) {
          return e.projectId.toString().contains(trimmedQuery) ||
              e.projectName!.toLowerCase().contains(trimmedQuery) ||
              e.legalAddress!.toLowerCase().contains(trimmedQuery);
        }).toList();
      }
      emit(SearchState(projects: filteredList));
    } catch (e) {
      String erMsg = e.toString().split(":").last;
      emit(ErrorState(message: erMsg));
    }
  }

  void syncProjects({required int projectId}) {
    try {
      // WorkManagerTaskRegister.syncPsPrjTechInfo(projectId: projectId);
      WorkManagerTaskRegister.syncUpdatePsPrjTechInfo(projectId: projectId);
      emit(SuccessState(message: "Syncing started..."));
    } catch (e) {
      String erMsg = e.toString().split(":").last;
      emit(ErrorState(message: erMsg));
    }
  }

  void clearDb() async {
    try {
      emit(LoadingState());
      await DBHelper.clearAllPsData();
      emit(DbClearState(message: "Data cleared successfully."));
    } catch (e) {
      String erMsg = e.toString().split(":").last;
      emit(ErrorState(message: erMsg));
    }
  }

  void finalSubmitPrj({required PsPrjDatum projectData, int apfStatus = 0, int cmStatus = 0}) async {
    try {
      List<Map<String, dynamic>> payload = [
        {
          "allocationId": projectData.allocationId,
          "projectId": projectData.projectId,
          "CmLocDate": cmStatus == 0 ? 0 : DateTime.now().second,
          if (cmStatus != 0) "cmStatus": cmStatus,
          "ApfLocDate": apfStatus == 0 ? 0 : DateTime.now().second,
          if (apfStatus != 0) "apfStatus": apfStatus,
        },
      ];

      final response = await ApiClient.psPrjFinalSubmit(payload: payload);

      final responseData = response.data;

      if (responseData["status"]?.toString().toUpperCase() == "OK") {
        final successCount = responseData["data"]?["success"] ?? 0;

        if (successCount > 0) {
          if (cmStatus != 0) projectData.cmStatus = 1;
          if (apfStatus != 0) projectData.apfStatus = 1;

          await DBHelper.updatePsProject(projectId: projectData.projectId!, updatedData: projectData);

          emit(SuccessState(message: responseData["message"] ?? "Project submitted successfully."));
          getProjects();
        } else {
          emit(ErrorState(message: "Submission failed. Please try again."));
        }
      } else {
        emit(ErrorState(message: responseData["message"] ?? "Something went wrong. Please try again."));
      }
    } catch (e) {
      final errorMessage = e.toString().contains(":") ? e.toString().split(":").last.trim() : e.toString();

      emit(ErrorState(message: errorMessage));
    }
  }
}
