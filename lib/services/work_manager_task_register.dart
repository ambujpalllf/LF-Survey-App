import 'package:lf_survey/model/db_model/residential/sub_prj_entity.dart';
import 'package:lf_survey/services/workmanager_task_key.dart';
import 'package:workmanager/workmanager.dart';

class WorkManagerTaskRegister {
  static void syncLocation() {
    Workmanager().registerPeriodicTask(
      WorkmanagerTaskKey.syncLocation,
      WorkmanagerTaskKey.syncLocation,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  }

  static void updateProject({required int projectId}) {
    Workmanager().registerOneOffTask(
      '${WorkmanagerTaskKey.updateProject}_${DateTime.now().millisecondsSinceEpoch}',
      WorkmanagerTaskKey.updateProject,
      inputData: {'projectId': projectId},
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  static void syncImage({required int projectId, required int subProjectId}) {
    Workmanager().registerOneOffTask(
      '${WorkmanagerTaskKey.syncImage}_${DateTime.now().millisecondsSinceEpoch}',
      WorkmanagerTaskKey.syncImage,
      inputData: {'projectId': projectId, 'subProjectId': subProjectId},
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  static void syncMultiImage() {
    Workmanager().registerOneOffTask(
      '${WorkmanagerTaskKey.syncMultiImage}_${DateTime.now().millisecondsSinceEpoch}',
      WorkmanagerTaskKey.syncMultiImage,
      // inputData: {'projectId': projectId, 'subProjectId': subProjectId},
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  static void updateSubProject({required List<SubProjectEntity> subProjects}) {
    final data = subProjects.first;
    Workmanager().registerOneOffTask(
      '${WorkmanagerTaskKey.updateSubProject}_${DateTime.now().millisecondsSinceEpoch}',
      WorkmanagerTaskKey.updateSubProject,
      inputData: {'subProjectId': data.subProjectId, 'projectId': data.projectId},
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  static void syncAllSubProject() {
    Workmanager().registerOneOffTask(
      WorkmanagerTaskKey.syncAllSubProject,
      WorkmanagerTaskKey.syncAllSubProject,
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  static void syncSubProject() {
    Workmanager().registerPeriodicTask(
      WorkmanagerTaskKey.syncSubProject, // UNIQUE NAME
      WorkmanagerTaskKey.syncSubProject, // TASK NAME
      frequency: const Duration(minutes: 15), //  MIN 15
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep, //  VERY IMPORTANT
    );
  }

  static void syncNewProject({required String projectId}) {
    Workmanager().registerOneOffTask(
      '${WorkmanagerTaskKey.syncSingleNewProject}_${DateTime.now().millisecondsSinceEpoch}',
      WorkmanagerTaskKey.syncSingleNewProject,
      inputData: {'prjId': projectId},
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  static void syncAllNewProject() {
    Workmanager().registerOneOffTask(
      '${WorkmanagerTaskKey.syncAllNewProject}_${DateTime.now().millisecondsSinceEpoch}',
      WorkmanagerTaskKey.syncAllNewProject,
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  static void syncNewSubProject({required String supProjectId}) {
    Workmanager().registerOneOffTask(
      '${WorkmanagerTaskKey.syncNewSubProject}_${DateTime.now().millisecondsSinceEpoch}',
      WorkmanagerTaskKey.syncNewSubProject,
      inputData: {'subProjectId': supProjectId},
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  static void syncNewProjectImage({required String projectId}) {
    Workmanager().registerOneOffTask(
      '${WorkmanagerTaskKey.syncNewProjectImage}_${DateTime.now().millisecondsSinceEpoch}',
      WorkmanagerTaskKey.syncNewProjectImage,
      inputData: {'projectId': projectId},
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  static void syncSingleNewProjectImage({required String projectId, required String imgUri}) {
    Workmanager().registerOneOffTask(
      '${WorkmanagerTaskKey.syncSingleNewPrjImage}_${DateTime.now().millisecondsSinceEpoch}',
      WorkmanagerTaskKey.syncSingleNewPrjImage,
      inputData: {'projectId': projectId, 'imgUri': imgUri},
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  // Commercial Module
  static void cSyncUpdateProject({required int projectId}) {
    Workmanager().registerOneOffTask(
      WorkmanagerTaskKey.cSyncUpdateProject,
      WorkmanagerTaskKey.cSyncUpdateProject,
      inputData: {'projectId': projectId},
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  static void cSyncUpdateSubProject({required int subProjectId}) {
    Workmanager().registerOneOffTask(
      WorkmanagerTaskKey.cSyncUpdateSubProject,
      WorkmanagerTaskKey.cSyncUpdateSubProject,
      inputData: {'subProjectId': subProjectId},
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  static void cSyncNewProject({required String prjId}) {
    Workmanager().registerOneOffTask(
      WorkmanagerTaskKey.cSyncNewProject,
      WorkmanagerTaskKey.cSyncNewProject,
      inputData: {'prjId': prjId},
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  static void cSyncNewSubProject({required String subPrjId}) {
    Workmanager().registerOneOffTask(
      WorkmanagerTaskKey.cSyncNewSubProject,
      WorkmanagerTaskKey.cSyncNewSubProject,
      inputData: {'subPrjId': subPrjId},
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  //Pams Survey Module

  static void syncPsImage({required int projectId, required String imgPath}) {
    Workmanager().registerOneOffTask(
      '${WorkmanagerTaskKey.syncPsImage}_${DateTime.now().millisecondsSinceEpoch}',
      WorkmanagerTaskKey.syncPsImage,
      inputData: {'projectId': projectId, 'imgPath': imgPath},
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  static void syncPsPrjTechInfo({required int projectId}) {
    Workmanager().registerOneOffTask(
      '${WorkmanagerTaskKey.syncPsPrjTechInfo}_${DateTime.now().millisecondsSinceEpoch}',
      WorkmanagerTaskKey.syncPsPrjTechInfo,
      inputData: {'projectId': projectId},
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  static void syncUpdatePsPrjTechInfo({required int projectId}) {
    Workmanager().registerOneOffTask(
      '${WorkmanagerTaskKey.syncUpdatePsPrjTechInfo}_${DateTime.now().millisecondsSinceEpoch}',
      WorkmanagerTaskKey.syncUpdatePsPrjTechInfo,
      inputData: {'projectId': projectId},
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  static void syncCmSurvey() {
    Workmanager().registerOneOffTask(
      WorkmanagerTaskKey.syncCmSurvey,
      WorkmanagerTaskKey.syncCmSurvey,
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }

  static void syncCmImage({required int projectId, int? wingId, String? localWingId, required String imgPath}) {
    Workmanager().registerOneOffTask(
      '${WorkmanagerTaskKey.syncCmImages}_${DateTime.now().millisecondsSinceEpoch}',
      WorkmanagerTaskKey.syncCmImages,
      inputData: {'projectId': projectId, 'imgPath': imgPath, 'wingId': wingId, 'localWingId': localWingId},
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  // This will  call. When all wings are synced.
  static void syncCmImagesAftersWings({required int projectId}) {
    Workmanager().registerOneOffTask(
      WorkmanagerTaskKey.syncCmImagesAfetrWings,
      WorkmanagerTaskKey.syncCmImagesAfetrWings,
      inputData: {'projectId': projectId, 'imgPath': "", 'wingId': null, 'localWingId': null},
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  // cm add new building
  static void syncCmAddBuilding({required int projectId, required String buildingName}) {
    Workmanager().registerOneOffTask(
      '${WorkmanagerTaskKey.syncCmAddBuilding}_${DateTime.now().millisecondsSinceEpoch}',
      WorkmanagerTaskKey.syncCmAddBuilding,
      inputData: {'projectId': projectId, 'buildingName': buildingName},
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  static void syncCmAllBuilding({required int projectId, required String buildingName}) {
    Workmanager().registerOneOffTask(
      WorkmanagerTaskKey.syncCmAllBuilding,
      WorkmanagerTaskKey.syncCmAllBuilding,
      inputData: {'projectId': projectId, 'buildingName': buildingName},
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  static void syncCmAddWing({
    required int projectId,
    int? buildingId,
    String? createdBuildingId,
    required String wingName,
  }) {
    Workmanager().registerOneOffTask(
      // '${WorkmanagerTaskKey.syncCmAddWing}_${DateTime.now().millisecondsSinceEpoch}',
      WorkmanagerTaskKey.syncCmAddWing,
      WorkmanagerTaskKey.syncCmAddWing,
      inputData: {
        'projectId': projectId,
        'buildingId': buildingId,
        'createdBuildingId': createdBuildingId,
        'wingName': wingName,
      },
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }
}
