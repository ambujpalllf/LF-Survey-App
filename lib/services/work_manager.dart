import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lf_survey/constants/storage_function.dart';
import 'package:lf_survey/constants/storage_key.dart';
import 'package:lf_survey/database/db_helper.dart';
import 'package:lf_survey/model/construction_monitoring/cm_building_response.dart';
import 'package:lf_survey/model/construction_monitoring/cm_survey_model.dart';
import 'package:lf_survey/model/construction_monitoring/cm_wing_response.dart';
import 'package:lf_survey/model/db_model/commercial/c_new_project_entity.dart';
import 'package:lf_survey/model/db_model/commercial/c_new_sub_project_entity.dart';
import 'package:lf_survey/model/db_model/commercial/c_project_entity.dart';
import 'package:lf_survey/model/db_model/commercial/c_sub_project_entity.dart';
import 'package:lf_survey/model/db_model/residential/image_entity.dart';
import 'package:lf_survey/model/db_model/residential/new_prj_img_entity.dart';
import 'package:lf_survey/model/db_model/residential/new_project_entity.dart';
import 'package:lf_survey/model/db_model/residential/new_sub_project_entity.dart';
import 'package:lf_survey/model/db_model/residential/project_entity.dart';
import 'package:lf_survey/model/db_model/residential/sub_prj_entity.dart';
import 'package:lf_survey/model/location_model.dart';
import 'package:lf_survey/model/pams_survey/land_response.dart';
import 'package:lf_survey/model/pams_survey/ps_photo_response.dart';
import 'package:lf_survey/services/api_client.dart';
import 'package:lf_survey/services/work_manager_task_register.dart';
import 'package:lf_survey/services/workmanager_task_key.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint("Executing task: $task");
    debugPrint("Executing Input Data: $inputData");
    WidgetsFlutterBinding.ensureInitialized();
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
    const InitializationSettings initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    try {
       final String normalizedTask = task.contains('_')
    ? task.substring(0, task.lastIndexOf('_'))
    : task;
      // switch (task) {
      switch (normalizedTask) {
        case WorkmanagerTaskKey.syncLocation:
        debugPrint("Take Name ##############: $normalizedTask");
          final userId = await StorageFunction.readIntData(StorageKey.userId);
          final loginType = await StorageFunction.readStringData(StorageKey.loginType);
          if (userId != null && loginType != null && loginType != "lfSurvey") {
            List<LocationModel> locationData = await DBHelper.getAllLocations(userId: userId);
            if (locationData.isNotEmpty) {
              final response = await ApiClient.userPSLocation(locationData: locationData);
              if (response != null && response["status"].toString().toLowerCase() == "ok") {
                Map<String, dynamic> data = response["data"];
                List<dynamic> syncData = data["trackings"] ?? [];
                if (syncData.isNotEmpty) {
                  for (var i in syncData) {
                    String appId = i["appId"].toString();
                    LocationModel? localItem = locationData.where((e) => e.id.toString() == appId).firstOrNull;
                    if (localItem != null) {
                      await DBHelper.deleteLocationById(id: localItem.id!);
                    }
                  }
                }
              }
            }
          } else {
            if (userId != null) {
              List<LocationModel> locationData = await DBHelper.getAllLocations(userId: userId);
              if (locationData.isNotEmpty) {
                final response = await ApiClient.userLFLocation(locationData: locationData);
                if (response != null) {
                  debugPrint("MmMMMMMMMMMMMM*************: Sync location");
                  List<dynamic> syncData = response["gpssyncstatuslist"] ?? [];
                  if (syncData.isNotEmpty) {
                    for (var item in syncData) {
                      int gpsTrackerId = item["gps_tracker_id"];
                      LocationModel? localItem = locationData.where((e) => e.id == gpsTrackerId).firstOrNull;
                      if (localItem != null) {
                        await DBHelper.deleteLocationById(id: localItem.id!);
                      }
                    }
                  }
                }
              }
            }
          }
          break;

        // case WorkmanagerTaskKey.updateProject:
        //   final projectId = inputData!['projectId'] as int;
        //   List<ProjectEntity> projects = [];
        //   if (projectId != 0) {
        //     final Map<String, dynamic>? projectMap = await DBHelper.getSingleUnsyncProject(projectId: projectId);
        //     if (projectMap != null) {
        //       ProjectEntity project = ProjectEntity.fromJson(projectMap);
        //       projects.clear();
        //       projects.add(project);
        //     }
        //   } else {
        //     final response = await DBHelper.getUnsyncProjects();
        //     projects.clear();
        //     projects = response.map((e) => ProjectEntity.fromJson(e)).toList();
        //   }
        //   if (projectMap != null) {
        //     // final response = await ApiClient.updateProject(projectEntity: [project]);
        //     final response = await ApiClient.updateProject(projectEntity: projects);
        //     if (response != null && response["projectSyncStausList"] != null) {
        //       final List syncList = response["projectSyncStausList"];
        //       for (var item in syncList) {
        //         if (item["resultCode"] == 1) {
        //           await flutterLocalNotificationsPlugin.show(
        //             Random().nextInt(100000),
        //             "Project updated successfully",
        //             "${project.projectName}(${project.projectId}) has been successfully updated.",
        //             const NotificationDetails(
        //               android: AndroidNotificationDetails(
        //                 'upload_channel',
        //                 'Upload Notifications',
        //                 importance: Importance.max,
        //                 priority: Priority.high,
        //               ),
        //             ),
        //           );
        //         }
        //       }
        //     }
        //   }
        //   final SendPort? send = IsolateNameServer.lookupPortByName('project_update');
        //   send?.send({"projectId": projectId});
        //   break;

        case WorkmanagerTaskKey.updateProject:
          final projectId = inputData!['projectId'] as int;

          List<ProjectEntity> projects = [];

          if (projectId != 0) {
            final Map<String, dynamic>? projectMap = await DBHelper.getSingleUnsyncProject(projectId: projectId);
            if (projectMap != null) {
              projects.add(ProjectEntity.fromJson(projectMap));
            }
          } else {
            final response = await DBHelper.getUnsyncProjects();
            projects = response.map((e) => ProjectEntity.fromJson(e)).toList();
          }

          const int batchSize = 5;

          while (projects.isNotEmpty) {
            // Take first 5 projects
            final batch = projects.take(batchSize).toList();

            // Call API
            final response = await ApiClient.updateProject(projectEntity: batch);
            // Exit the loop if API failed or returned null
            if (response == null || response["projectSyncStausList"] == null) {
              break;
            }
            if (response != null && response["projectSyncStausList"] != null) {
              final List syncList = response["projectSyncStausList"];

              for (int i = 0; i < syncList.length; i++) {
                final item = syncList[i];

                if (item["resultCode"] == 1) {
                  final project = batch[i];

                  await flutterLocalNotificationsPlugin.show(
                    Random().nextInt(100000),
                    "Project updated successfully",
                    "${project.projectName} (${project.projectId}) has been successfully updated.",
                    const NotificationDetails(
                      android: AndroidNotificationDetails(
                        'upload_channel',
                        'Upload Notifications',
                        importance: Importance.max,
                        priority: Priority.high,
                      ),
                    ),
                  );
                }
              }
            }
            // Remove processed projects from the list
            projects.removeRange(0, batch.length);
          }

          final SendPort? send = IsolateNameServer.lookupPortByName('project_update');
          send?.send({"projectId": projectId});

          break;

        case WorkmanagerTaskKey.syncImage:
          final projectId = inputData!['projectId'];
          final subProjectId = inputData['subProjectId'];
          int imageId = subProjectId == 0 ? projectId : subProjectId;
          final List<ImageEntity> images = await DBHelper.fetcImgEntity(imageId: imageId);
          if (images.isNotEmpty) {
            for (var img in images) {
              if(img.sync == 0){
              final response = await ApiClient.uploadImage(img);
              if (response != null && response["resultCode"] == 1) {
                String imgPath = (img.imageUri ?? "").split("/").last;
                await flutterLocalNotificationsPlugin.show(
                  Random().nextInt(100000),
                  'Image uploaded successfully',
                  imgPath,
                  const NotificationDetails(
                    android: AndroidNotificationDetails(
                      'upload_channel',
                      'Upload Notifications',
                      importance: Importance.max,
                      priority: Priority.high,
                    ),
                  ),
                );
              }}
            }
            final SendPort? send = IsolateNameServer.lookupPortByName('sync_project_image');
            send?.send({"projectId": projectId, "subProjectId": subProjectId});
          }
          break;

        case WorkmanagerTaskKey.syncMultiImage:
          final List<ImageEntity> images = await DBHelper.fetchUnSyncImgEntity();
          if (images.isNotEmpty) {
            for (var img in images) {
              await ApiClient.uploadImage(img);
            }
            final SendPort? send = IsolateNameServer.lookupPortByName('sync_project_image');
            send?.send({});
          }
          break;
        case WorkmanagerTaskKey.updateSubProject:
          final subProjectId = inputData!['subProjectId'];
          final projectId = inputData['projectId'];
          final Map<String, dynamic>? subProjectMap = await DBHelper.getSprjEntity(
            projectId: projectId,
            subPrjId: subProjectId,
          );
          if (subProjectMap != null) {
            final subProject = SubProjectEntity.fromJson(subProjectMap);
            await ApiClient.updateSubPrj(subProjects: [subProject]);
          }
          // This is callig beacause when did sub-project synced then refresh data in project page
          final SendPort? send = IsolateNameServer.lookupPortByName('project_update');
          final SendPort? syncSubPrj = IsolateNameServer.lookupPortByName('sync_sub_project');
          send?.send({"projectId": projectId});
          syncSubPrj?.send({});
          break;

        case WorkmanagerTaskKey.syncSubProject:
          final List<Map<String, dynamic>> subProjectMap = await DBHelper.getUnSyncSprjEntities();
          if (subProjectMap.isNotEmpty) {
            List<SubProjectEntity> subProject = subProjectMap.map((e) => SubProjectEntity.fromJson(e)).toList();
            await ApiClient.updateSubPrj(subProjects: subProject);
          }
          break;

        case WorkmanagerTaskKey.syncAllSubProject:
          final List<Map<String, dynamic>> subProjectMap = await DBHelper.getUnSyncSprjEntities();
          if (subProjectMap.isNotEmpty) {
            List<SubProjectEntity> subProject = subProjectMap.map((e) => SubProjectEntity.fromJson(e)).toList();
            await ApiClient.updateSubPrj(subProjects: subProject);
            final SendPort? send = IsolateNameServer.lookupPortByName('sync_sub_project');
            send?.send({});
          }
          break;

        case WorkmanagerTaskKey.syncSingleNewProject:
          final projectId = inputData!['prjId'];
          NewProjectEntity? newProjectEntity = await DBHelper.fetchSingleNewPrjById(projectId);
          if (newProjectEntity != null) {
            await ApiClient.addNewProject(newProjectEntityData: [newProjectEntity]);
            final SendPort? send = IsolateNameServer.lookupPortByName('sync_new_project');
            send?.send(newProjectEntity.prjId);
          }
          break;

        case WorkmanagerTaskKey.syncAllNewProject:
          List<NewProjectEntity> projectEntity = await DBHelper.fetchAllUnsyncNewProjects();
          if (projectEntity.isNotEmpty) {
            await ApiClient.addNewProject(newProjectEntityData: projectEntity);
            final SendPort? send = IsolateNameServer.lookupPortByName('sync_new_project');
            send?.send("Sync");
          }
          break;

        case WorkmanagerTaskKey.syncNewSubProject:
          final subProjectId = inputData!['subProjectId'];
          List<NewSubProjectEntity> subProjects = await DBHelper.getAllUnsyncNewSubProjectById(
            subProjectId: subProjectId,
          );
          if (subProjects.isNotEmpty) {
            for (var newSub in subProjects) {
              await ApiClient.addNewSubPrj(subProject: newSub);
            }
          }
          final SendPort? send = IsolateNameServer.lookupPortByName('sync_new_sub_project');
          send?.send(subProjectId);
          break;

        case WorkmanagerTaskKey.syncNewProjectImage:
          final projectId = inputData!['projectId'];
          List<NewPrjImageEntity> projects = await DBHelper.getUnsyncedNewImgPrjEntity(projectId);
          if (projects.isNotEmpty) {
            for (var prjImg in projects) {
              final response = await ApiClient.uploadNewPrjImage(prjImg);
              if (response != null && response["resultCode"] == 1) {
                String imgPath = (prjImg.imageUri ?? "").split("/").last;
                await flutterLocalNotificationsPlugin.show(
                  Random().nextInt(100000),
                  'Image uploaded successfully',
                  imgPath,
                  const NotificationDetails(
                    android: AndroidNotificationDetails(
                      'upload_channel',
                      'Upload Notifications',
                      importance: Importance.max,
                      priority: Priority.high,
                    ),
                  ),
                );
              }
              final SendPort? send = IsolateNameServer.lookupPortByName('sync_image');
              send?.send(projectId);
            }
          }
          break;

        case WorkmanagerTaskKey.syncSingleNewPrjImage:
          final projectId = inputData!['projectId'];
          final imgUri = inputData['imgUri'];
          NewPrjImageEntity? project = await DBHelper.singleNewImgPrjEntityByPrjId(prjId: projectId, imgUri: imgUri);
          if (project != null) {
            final response = await ApiClient.uploadNewPrjImage(project);
            if (response != null && response["resultCode"] == 1) {
              String imgPath = (project.imageUri ?? "").split("/").last;
              await flutterLocalNotificationsPlugin.show(
                Random().nextInt(100000),
                'Image uploaded successfully',
                imgPath,
                const NotificationDetails(
                  android: AndroidNotificationDetails(
                    'upload_channel',
                    'Upload Notifications',
                    importance: Importance.max,
                    priority: Priority.high,
                  ),
                ),
              );
            }
          }
          final SendPort? send = IsolateNameServer.lookupPortByName('sync_image');
          send?.send(projectId);
          break;

        // Commercial Survey Module

        case WorkmanagerTaskKey.cSyncUpdateProject:
          final projectId = inputData!['projectId'] as int;
          final List<CProjectEntity> unSyncProject = projectId == 0
              ? await DBHelper.cGetUnsyncProjects()
              : await DBHelper.cGetUnsyncProjectsByPrjId(projectId: projectId);
          if (unSyncProject.isEmpty) return true;
          final response = await ApiClient.cUpdateProject(projects: unSyncProject);
          if (response != null) {
            for (final project in unSyncProject) {
              project.syncGlobalStatus = 1;
            }
            await DBHelper.cUpdateMultipleProjects(projects: unSyncProject);
          }
          final SendPort? send = IsolateNameServer.lookupPortByName('c_sync_project');
          send?.send(0);
          break;

        case WorkmanagerTaskKey.cSyncUpdateSubProject:
          final subPrjId = inputData!['subProjectId'] as int;
          List<CSubProjectEntity> unsyncSubPrj = subPrjId == 0
              ? await DBHelper.cGetUnsyncSubProjects()
              : await DBHelper.cGetUnsyncSubProjectsById(subProjectId: subPrjId);
          if (unsyncSubPrj.isEmpty) return true;
          final response = await ApiClient.cUpdateSubPrj(subProjects: unsyncSubPrj);
          if (response != null && response["status"].toString().toLowerCase() == "ok") {
            List<CSubProjectEntity> localData = [];
            List syncData = response['data'] ?? [];
            for (var data in syncData) {
              final itemData = unsyncSubPrj.firstWhere((e) => e.subProjectId == data['subProjectId']);
              if (data['resultCode'] == 1) {
                itemData.syncGlobalStatus = 1;
                localData.add(itemData);
              } else {}
            }
            await DBHelper.cUpdateMultipleSubPrj(subProjects: localData);
          }
          final SendPort? send = IsolateNameServer.lookupPortByName('c_sync_sub_project');
          send?.send(0);
          break;

        case WorkmanagerTaskKey.cSyncNewProject:
          final String projectId = inputData!['prjId'] as String;
          List<CNewProjectEntity> projects = projectId == ""
              ? await DBHelper.cGetAllUnsyncNewProjects()
              : await DBHelper.cGetNewProjectById(prjId: projectId);
          if (projects.isEmpty) return true;
          await ApiClient.cAddNewProject(projects: projects);
          final SendPort? send = IsolateNameServer.lookupPortByName('sync_new_project');
          send?.send(0);
          break;

        case WorkmanagerTaskKey.cSyncNewSubProject:
          final String subPrjId = inputData!['subPrjId'] as String;
          List<CNewSubProjectEntity> subProjects = subPrjId == ""
              ? await DBHelper.cGetAllUnsyncNewSubProjects()
              : await DBHelper.cGetNewSubProjectById(subprojectId: subPrjId);
          await ApiClient.cAddNewSubPrj(subProjects: subProjects);
          final SendPort? send = IsolateNameServer.lookupPortByName('sync_new_sub_project');
          send?.send(0);
          break;
        // Pams Survey Module
        case WorkmanagerTaskKey.syncPsImage:
          final projectId = inputData!['projectId'] as int;
          final imgPath = inputData['imgPath'] as String;
          List<PsPhotoDatum> imgData = projectId == 0
              ? await DBHelper.getAllPsUnSyncImage()
              : await DBHelper.getAllPsUnSyncImgByPrjId(projectId: projectId, imgPath: imgPath);

          final response = await ApiClient.psUploadImage(imgData: imgData);
          if (response != null && response["status"].toString().toLowerCase() == "ok") {
            final List photos = response["data"]["photos"];
            for (var photo in photos) {
              if (photo["success"] == true) {
                final int appId = photo["photo_app_id"];
                final int serverId = photo["photo_id"];

                // Find matching local image
                final PsPhotoDatum localImage = imgData.firstWhere(
                  (img) => img.id == appId,
                  orElse: () => PsPhotoDatum(),
                );
                localImage.sync = 1;
                localImage.photoId = serverId;
                await DBHelper.updatePsImage(image: localImage);
              }
            }
          }
          final SendPort? send = IsolateNameServer.lookupPortByName('sync_ps_image');
          send?.send(projectId);
          break;
        case WorkmanagerTaskKey.syncPsPrjTechInfo:
          final projectId = inputData!['projectId'];
          List<PsLandDatum> psLandData = projectId == 0
              ? await DBHelper.getUnsyncPsLandInfoById(projectId: projectId)
              : await DBHelper.getAllUnsyncPsLandInfo();
          if (psLandData.isNotEmpty) {
            List<Map<String, dynamic>> payLoad = [];
            for (var psData in psLandData) {
              payLoad.add({
                "projectId": psData.projectId,
                "east_as_per_site": psData.eastAsPerSite,
                // "east_as_per_document": eDocument,
                // "east_as_per_rera": eRera,
                // "east_deviation": eSiteBoundaries,
                "west_as_per_site": psData.westAsPerSite,
                // "west_as_per_document": wDocument,
                // "west_as_per_rera": wRera,
                // "west_deviation": wSiteBoundaries,
                "north_as_per_site": psData.northAsPerSite,
                // "north_as_per_document": nDocument,
                // "north_as_per_rera": nRera,
                // "north_deviation": nSiteBoundaries,
                "south_as_per_site": psData.southAsPerSite,
                // "south_as_per_document": sDocument,
                // "south_as_per_rera": sRera,
                // "south_deviation": sSiteBoundaries,
                "width_of_accesss_road": psData.widthOfAccesssRoad,
                "type_of_access_road": psData.typeOfAccessRoad,
                "construction_status": psData.constructionStatus,
                "construction_material_status": psData.constructionMaterialStatus,
                "labour_statuson_site": psData.labourStatusonSite,
                "projectcfby_which_bank": psData.projectCFByWhichBank,
                "project_homeloan_availble": psData.projectHomeloanAvailble,
                // "critical_parameters_seismic_zone": seismicZone,
                // "critical_parameters_flood_prone_area": proneArea,
                // "critical_parameters_coastal_regulatory_zone": coastalRegZone,
                // "critical_parameters_zoning_as_per_development_plan": zoningAPDevPlan,
                // "critical_parameters_falling_in_present": faillingPresent,
                // "critical_parameters_property_within_30m_from_railway": within30FromRailway,
                // "critical_parameters_property_near_ht_lt_lines": propertyNearHTLines,
                // "critical_parameters_presence_of_nallah_water_body_nearby": presenceNallah,
                // "critical_parameters_fsi_deviation": fsiDeviation,
                // "critical_parameters_vertical_deviation": verticalDeviation,
                // "critical_parameters_unit_deviation": unitDeviation,
                // "critical_parameters_habitation": habitation,
                // "critical_parameters_remarks": remarks,
                // "critical_parameters_falling_in_reservation": fallingReservationAPDev,
              });
            }
            final response = await ApiClient.createLandInfo(bodyData: payLoad);
            if (response != null && response["status"] == "OK") {
              List<dynamic> responseList = response["data"];
              for (var item in responseList) {
                if (item["success"] == true) {
                  int projectId = item["projectId"];
                  int landId = int.parse(item["landId"].toString());
                  PsLandDatum matchingData = psLandData.firstWhere(
                    (e) => e.projectId == projectId,
                    orElse: () => PsLandDatum(),
                  );
                  matchingData.projectLandId = landId;
                  matchingData.localSync = 0;
                  matchingData.globalSync = 1;

                  await DBHelper.updatePsLandInfo(landData: matchingData);
                }
              }
            }
          }
          final SendPort? send = IsolateNameServer.lookupPortByName('sync_ps_prj_tech_info');
          send?.send(0);
          break;
        case WorkmanagerTaskKey.syncUpdatePsPrjTechInfo:
          final projectId = inputData!['projectId'];
          List<PsLandDatum> psLandData = projectId == 0
              ? await DBHelper.getAllUnsyncPsLandInfo()
              : await DBHelper.getUnsyncPsLandInfo(projectId: projectId);

          List<Map<String, dynamic>> payLoad = [];
          for (var psData in psLandData) {
            payLoad.add({
              "projectId": psData.projectId,
              // "projectLandId": psData.projectLandId,
              "lat": psData.lat,
              "lng": psData.lng,
              "east_as_per_site": psData.eastAsPerSite,
              // "east_as_per_document": eDocument,
              // "east_as_per_rera": eRera,
              // "east_deviation": eSiteBoundaries,
              "west_as_per_site": psData.westAsPerSite,
              // "west_as_per_document": wDocument,
              // "west_as_per_rera": wRera,
              // "west_deviation": wSiteBoundaries,
              "north_as_per_site": psData.northAsPerSite,
              // "north_as_per_document": nDocument,
              // "north_as_per_rera": nRera,
              // "north_deviation": nSiteBoundaries,
              "south_as_per_site": psData.southAsPerSite,
              // "south_as_per_document": sDocument,
              // "south_as_per_rera": sRera,
              // "south_deviation": sSiteBoundaries,
              "width_of_accesss_road": psData.widthOfAccesssRoad,
              "type_of_access_road": psData.typeOfAccessRoad,
              "construction_status": psData.constructionStatus,
              "construction_material_status": psData.constructionMaterialStatus,
              "labour_statuson_site": psData.labourStatusonSite,
              "projectcfby_which_bank": psData.projectCFByWhichBank,
              "project_homeloan_availble": psData.projectHomeloanAvailble,
              // "critical_parameters_seismic_zone": seismicZone,
              // "critical_parameters_flood_prone_area": proneArea,
              // "critical_parameters_coastal_regulatory_zone": coastalRegZone,
              // "critical_parameters_zoning_as_per_development_plan": zoningAPDevPlan,
              // "critical_parameters_falling_in_present": faillingPresent,
              // "critical_parameters_property_within_30m_from_railway": within30FromRailway,
              // "critical_parameters_property_near_ht_lt_lines": propertyNearHTLines,
              // "critical_parameters_presence_of_nallah_water_body_nearby": presenceNallah,
              // "critical_parameters_fsi_deviation": fsiDeviation,
              // "critical_parameters_vertical_deviation": verticalDeviation,
              // "critical_parameters_unit_deviation": unitDeviation,
              // "critical_parameters_habitation": habitation,
              // "critical_parameters_remarks": remarks,
              // "critical_parameters_falling_in_reservation": fallingReservationAPDev,
              "allocation_id": psData.allocationId,
              "revisit_remarks": psData.revisitRemarks,
              "visit_charges": psData.visitCharges,
            });
          }
          final response = await ApiClient.updateLandInfo(bodyData: payLoad);

          if (response.data != null && response.data["status"].toString().toLowerCase() == "ok") {
            List responseList = response.data["data"] ?? [];
            for (var item in responseList) {
              if (item["success"] == true) {
                // int projectLandId = item["projectLandId"];
                // PsLandDatum? matchedData = psLandData.firstWhere(
                //   (e) => e.projectLandId == projectLandId,
                //   orElse: () => PsLandDatum(),
                // );
                int projectId = item['data']["project_id"];
                PsLandDatum? matchedData = psLandData.firstWhere(
                  (e) => e.projectId == projectId,
                  orElse: () => PsLandDatum(),
                );
                matchedData.localSync = 0;
                matchedData.globalSync = 1;
                await DBHelper.updatePsLandInfo(landData: matchedData);
              }
            }
          }
          final SendPort? send = IsolateNameServer.lookupPortByName('sync_ps_prj_tech_info');
          send?.send(0);
          break;

        case WorkmanagerTaskKey.syncCmSurvey:
          final unSyncData = await DBHelper.getUnsyncCmSurvey();
          unSyncData.removeWhere((e) => e.buildingId == null || e.buildingId == 0 || e.wingId == null || e.wingId == 0);
          if (unSyncData.isEmpty) {
            return true;
          }
          if (unSyncData.isNotEmpty) {
            // Prepare payload
            final List<Map<String, dynamic>> payload = unSyncData.map((e) {
              return {
                "projectId": e.projectId,
                "wingId": e.wingId,
                "buildingId": e.buildingId,
                "numberOfFloor": e.noOfFloors,
                "surveyDate": e.survayDate,
                "totalUnits": e.totalUnits,
                "totalSoldUnitsPercent": e.soldPercentage,
                "totalSoldUnits": e.soldUnits,
                "totalUnsoldUnits": e.unsoldUnits,
                "totalUnsoldUnitsPercent": e.unsoldPercentage,
                "saleableRate": e.saleableRate,
                "carpetRate": e.carpetRate,
                "stageDetails": [
                  {
                    "construction_plinth": e.plinth,
                    "construction_no_of_slabs_completed": e.noOfSlabsCompleted,
                    "construction_brick_work": e.brickWork,
                    "construction_plastering_internal": e.plasteringInternal,
                    "construction_plastering_external": e.plasteringExternal,
                    "construction_flooring": e.flooring,
                    "construction_electrict": e.electrict,
                    "construction_plumbing": e.plumbing,
                    "construction_wood_work": e.woodWork,
                    "construction_painting": e.painting,
                  },
                ],
                "remarks": e.remarks,
                "appId": e.id,
              };
            }).toList();
            final response = await ApiClient.addCmInfo(bodyData: payload);

            if (response != null && response['status']?.toString().toLowerCase() == "ok") {
              final List<dynamic> responseData = response['data'] ?? [];
              List<CmSurveyModel> surveyData = [];
              for (var item in responseData) {
                CmSurveyModel? localItem = unSyncData.firstWhere(
                  (e) => e.id == item["appId"],
                  orElse: () => CmSurveyModel(),
                );
                localItem.localSync = 0;
                localItem.globalSync = 1;
                surveyData.add(localItem);
              }
              await DBHelper.cmUpdateWingSurveys(surveys: surveyData);
            }

            final SendPort? send = IsolateNameServer.lookupPortByName('sync_cm_survey');
            send?.send(0);
          }
          break;

        case WorkmanagerTaskKey.syncCmImages:
        case WorkmanagerTaskKey.syncCmImagesAfetrWings:
          final projectId = inputData!['projectId'] as int;
          final wingId = inputData['wingId'];
          final imgPath = inputData['imgPath'] as String;
          final localWingId = inputData['localwingId'];
          List<PsPhotoDatum> imgData = projectId == 0
              // Get All images for All project
              ? await DBHelper.getAllCmUnSyncImage()
              : imgPath.isEmpty || imgPath == ""
              // Get All images for single project
              ? await DBHelper.getCmUnSyncImagesByPrjId(projectId: projectId)
              // Get single images for single project and single wing
              : await DBHelper.getAllCmUnSyncImgByWingId(
                  projectId: projectId,
                  imgPath: imgPath,
                  wingId: wingId,
                  localWingId: localWingId,
                );
          imgData.removeWhere((e) => e.buildingId == null || e.buildingId == 0 || e.wingId == null || e.wingId == 0);
          if (imgData.isEmpty) {
            return true;
          }
          final response = await ApiClient.cmUploadImage(imgData: imgData);
          if (response != null && response["status"].toString().toLowerCase() == "ok") {
            final List photos = response["data"]["photos"];
            for (var photo in photos) {
              if (photo["success"] == true) {
                final int appId = photo["photo_app_id"];
                final int serverId = photo["photo_id"];

                // Find matching local image
                final PsPhotoDatum localImage = imgData.firstWhere(
                  (img) => img.id == appId,
                  orElse: () => PsPhotoDatum(),
                );
                localImage.sync = 1;
                localImage.photoId = serverId;
                await DBHelper.updatePsImage(image: localImage);
              }
            }
          }
          final SendPort? send = IsolateNameServer.lookupPortByName('sync_cm_image');
          send?.send(projectId);
          break;

        case WorkmanagerTaskKey.syncCmAddBuilding:
        case WorkmanagerTaskKey.syncCmAllBuilding:
          final projectId = inputData!['projectId'] as int;
          final buildingName = inputData['buildingName'] as String;
          List<BuildingData> buildings = buildingName.isEmpty
              ? await DBHelper.getCMAllBuildingByPrjId(projectId: projectId)
              : await DBHelper.getCMBuildingByName(projectId: projectId, buildingName: buildingName);
          buildings.removeWhere((e) => e.buildingId != null);
          if (buildings.isEmpty) {
            return true;
          }
          final payload = buildings
              .map((e) => {"buildingName": e.buildingName, "projectId": e.projectId, "appId": e.createdBuildingId})
              .toList();
          final response = await ApiClient.cmAddBuilding(payload: payload);
          if (response != null && response["status"]?.toString().toUpperCase() == "OK") {
            final List<BuildingData> updateList = [];
            final List<dynamic> responseData = response["data"] as List<dynamic>;
            for (final item in responseData) {
              final String appId = item["appId"]?.toString() ?? "";
              final BuildingData? localData = buildings.cast<BuildingData?>().firstWhere(
                (e) => e?.createdBuildingId == appId,
                orElse: () => null,
              );
              if (localData == null) continue;
              if (item["success"] == true) {
                localData.sync = 1;
                localData.errorMsg = "";
                final String? buildingId = item["buildingId"]?.toString();
                if (buildingId != null && buildingId.isNotEmpty) {
                  final int parsedBuildingId = int.tryParse(buildingId) ?? 0;
                  localData.buildingId = parsedBuildingId;
                  List<WingData> wings = await DBHelper.getCMAllWingsByBuildingId(
                    projectId: projectId,
                    createdBuildingId: localData.createdBuildingId,
                  );
                  for (final wing in wings) {
                    wing.buildingId = parsedBuildingId;
                  }
                  if (wings.isNotEmpty) {
                    await DBHelper.updateCMWings(wings: wings);
                  }
                }
              } else {
                localData.sync = 0;
                localData.errorMsg = item["message"]?.toString() ?? "";
              }
              updateList.add(localData);
            }
            if (updateList.isNotEmpty) {
              await DBHelper.cmUpdateBuildings(buildings: updateList);
              // When All buildings synced then starting all wings syncing
              WorkManagerTaskRegister.syncCmAddWing(
                projectId: projectId,
                buildingId: null,
                createdBuildingId: null,
                wingName: "",
              );
            }
          }
          final SendPort? send = IsolateNameServer.lookupPortByName('sync_building');
          send?.send(projectId);
          break;

        case WorkmanagerTaskKey.syncCmAddWing:
          final projectId = inputData!['projectId'] as int;
          final buildingId = inputData['buildingId'];
          final createdBuildingId = inputData['createdBuildingId'];
          final wingName = inputData["wingName"] as String;
          List<WingData> wings = wingName.isEmpty
              ? await DBHelper.getCMAllWingsByBuildingId(
                  projectId: projectId,
                  buildingId: buildingId,
                  createdBuildingId: createdBuildingId,
                )
              : await DBHelper.getCmWingByWingName(projectId: projectId, wingName: wingName);
          // wings.removeWhere((e) => e.wingId != null);
          wings.removeWhere((e) => e.wingId != null || e.buildingId == null || e.buildingId == 0);
          if (wings.isEmpty) {
            return true;
          }
          final payload = wings
              .map(
                (e) => {
                  "wingName": e.wingName,
                  "buildingId": e.buildingId,
                  "wingAddonJson": "{}",
                  "appId": e.createdWingId,
                },
              )
              .toList();
          final response = await ApiClient.cmAddWing(payload: payload);
          if (response != null && response["status"]?.toString().toUpperCase() == "OK") {
            final List<WingData> updateList = [];
            final List<dynamic> responseData = response["data"] as List<dynamic>;
            for (final item in responseData) {
              final String appId = item["appId"]?.toString() ?? "";
              final WingData? localData = wings.cast<WingData?>().firstWhere(
                (e) => e?.createdWingId == appId,
                orElse: () => null,
              );
              if (localData == null) continue;
              if (item["success"] == true) {
                localData.errorMsg = "";
                final String? wingId = item["wingId"]?.toString();
                if (wingId != null && wingId.isNotEmpty) {
                  final int parsedWingId = int.tryParse(wingId) ?? 0;
                  localData.wingId = parsedWingId;
                  List<PsPhotoDatum> images = await DBHelper.getAllCmImageByPrjIdAndWingId(
                    projectId: projectId,
                    localWingId: localData.createdWingId,
                  );
                  for (final img in images) {
                    img.buildingId = localData.buildingId;
                    img.wingId = parsedWingId;
                  }
                  if (images.isNotEmpty) {
                    await DBHelper.updatePsMultiImages(images: images);
                  }
                  final unSyncData = await DBHelper.getUnsyncCmSurvey();
                  for (var survey in unSyncData) {
                    survey.buildingId = localData.buildingId;
                    survey.wingId = parsedWingId;
                  }
                  if (unSyncData.isNotEmpty) {
                    await DBHelper.cmUpdateWingSurveys(surveys: unSyncData);
                  }
                }
              } else {
                localData.errorMsg = item["message"]?.toString() ?? "";
              }
              updateList.add(localData);
            }
            if (updateList.isNotEmpty) {
              await DBHelper.updateCMWings(wings: updateList);
              WorkManagerTaskRegister.syncCmImagesAftersWings(projectId: 0);
              WorkManagerTaskRegister.syncCmSurvey();
            }
            final SendPort? send = IsolateNameServer.lookupPortByName('sync_cm_wing');
            send?.send(0);
          }
          break;

        default:
          return Future.value(false);
      }

      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  });
}
