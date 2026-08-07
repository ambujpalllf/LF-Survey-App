import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:lf_survey/constants/storage_function.dart';
import 'package:lf_survey/constants/storage_key.dart';
import 'package:lf_survey/constants/utils.dart';
import 'package:lf_survey/database/db_helper.dart';
import 'package:lf_survey/model/db_model/commercial/c_new_project_entity.dart';
import 'package:lf_survey/model/db_model/commercial/c_new_sub_project_entity.dart';
import 'package:lf_survey/model/db_model/commercial/c_project_entity.dart';
import 'package:lf_survey/model/db_model/commercial/c_sub_project_entity.dart';
import 'package:lf_survey/model/db_model/residential/flat_entity.dart';
import 'package:lf_survey/model/db_model/residential/image_entity.dart';
import 'package:lf_survey/model/db_model/residential/new_prj_img_entity.dart';
import 'package:lf_survey/model/db_model/residential/new_project_entity.dart';
import 'package:lf_survey/model/db_model/residential/new_sub_project_entity.dart';
import 'package:lf_survey/model/db_model/residential/project_entity.dart';
import 'package:lf_survey/model/db_model/residential/sub_prj_entity.dart';
import 'package:lf_survey/model/location_model.dart';
import 'package:lf_survey/model/pams_survey/ps_photo_response.dart';
import 'package:lf_survey/model/residential/user_response.dart';
import 'package:lf_survey/services/api_exception.dart';
import 'package:lf_survey/services/app_api_urls.dart';
import 'package:lf_survey/services/dio_client.dart';
import 'package:path/path.dart' as path;

class ApiClient {
  static Future<dynamic> userPSLocation({required List<LocationModel> locationData}) async {
    try {
      final List<Map<String, dynamic>> bodyData = locationData.map((e) {
        return {
          "appId": e.id.toString(),
          "lat": e.lat.toString(),
          "lng": e.long.toString(),
          "accuracy": e.accuracy.toString(),
          "locCreatedDate": e.timeStamp,
          "batteryPercentage": e.batteryPercentage.toString(),
        };
      }).toList();
      return DioClient(baseUrl: AppApiUrls.psBaseUrl).post(AppApiUrls.psUserLocationUrl, data: bodyData);
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<dynamic> userLFLocation({required List<LocationModel> locationData}) async {
    try {
      final List<Map<String, dynamic>> locations = locationData.map((e) {
        final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch((e.timeStamp) * 1000);

        return {
          "GPS_TRACKER_DATE_TIME": DateFormat("yyyy-MM-dd HH:mm:ss.000").format(dateTime),
          "GPS_TRACKER_ID": e.id,
          "LATITUDE": e.lat,
          "LONGITUDE": e.long,
          "MOBILE_APP_ID": 1,
          "USERS_ID": e.userId,
          "BATTERY_PERC": e.batteryPercentage,
          "ACCURACY": e.accuracy,
          "IS_MOCK": e.isMock,
          "PROVIDER": e.provider,
        };
      }).toList();
      Map<String, dynamic> bodyData = {"GPSTRACKLIST": locations};
      return DioClient().post(AppApiUrls.userGpsUrl, data: bodyData);
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e);
    }
  }

  //***************** Authentication Section ********************************
  static Future<dynamic> registerUser({
    required String empCode,
    required String email,
    required String mobileNo,
    required String firebaseToken,
  }) async {
    try {
      Map<String, dynamic> deviceInfo = await Utils.collectDeviceData();
      // String firebaseToken = await NotificationServices().getDeviceToken();
      Map<String, dynamic> bodyData = {
        "username": empCode,
        "email": email,
        "mobno": mobileNo,
        "firebaseToken": firebaseToken,
      };
      if (deviceInfo.isNotEmpty) {
        bodyData.addAll(deviceInfo);
      }
      return DioClient().post(AppApiUrls.registerUrl, data: bodyData);
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<dynamic> loginUser({required String empCode, required String password}) async {
    try {
      // PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String maid = "";
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (kIsWeb) {
        maid = "";
      } else if (Platform.isAndroid) {
        AndroidDeviceInfo android = await deviceInfo.androidInfo;
        maid = android.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo ios = await deviceInfo.iosInfo;
        maid = ios.identifierForVendor ?? "";
      }
      Map<String, dynamic> bodyData = {
        "username": empCode,
        "password": password,
        "maid": maid,
        // "version": packageInfo.version,
        "version": "4.8",
      };

      return DioClient().post(AppApiUrls.loginUrl, data: bodyData);
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<dynamic> updateFirebaseToken({required String firebaseToken}) async {
    try {
      int? userId = await StorageFunction.readIntData(StorageKey.userId);
      Map<String, dynamic> bodyData = {"empId": userId, "firebaseToken": firebaseToken};
      return DioClient().post(AppApiUrls.updateFBToken, data: bodyData);
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e);
    }
  }

  // ************************* Project Residential **********************
  static Future<dynamic> fetchCities() async {
    try {
      final userId = await StorageFunction.readIntData(StorageKey.userId);
      if (userId == null) return;
      String cityUrl = AppApiUrls.cityUrl(userId: userId);
      return DioClient().get(cityUrl);
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<dynamic> fetchProjectSpinner() async {
    try {
      final userId = await StorageFunction.readIntData(StorageKey.userId);
      if (userId == null) return;
      String spinnerUrl = AppApiUrls.spinnerUrl;
      return DioClient().get(spinnerUrl);
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<dynamic> fetchArchitect() async {
    try {
      final userId = await StorageFunction.readIntData(StorageKey.userId);
      if (userId == null) return;
      String archiUrl = AppApiUrls.architectUrl;
      return DioClient().get(archiUrl);
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<dynamic> fetchProject({required String locationIds, bool isAssignedNewPrj = false}) async {
    try {
      final userId = await StorageFunction.readIntData(StorageKey.userId);
      if (userId == null) return;
      String projectIds = "";
      final response = await DBHelper.getProjects();
      if (response.isNotEmpty) {
        List<ProjectEntity> projects = response.map((i) => ProjectEntity.fromJson(i)).toList();
        projectIds = projects.map((p) => p.projectId.toString()).join(',');
        projectIds = projects
            .where((p) => isAssignedNewPrj ? p.assignedNewPrj == 1 : p.assignedNewPrj == 0)
            .map((p) => p.projectId.toString())
            .join(',');
      }
      // String projectUrl = AppApiUrls.getProjectUrl(userId: userId, locationIds: locationIds, projectIds: projectIds);
      String projectUrl = AppApiUrls.getProjectUrl;
      Map<String, dynamic> payload = {"userId": userId, "locationsIds": locationIds, "projectId": projectIds};
      // return DioClient().get(projectUrl);
      return DioClient().post(projectUrl, data: payload);
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<dynamic> projectSearch({required String query}) async {
    try {
      String prjSearchUrl = AppApiUrls.projectSearchUrl(query: query);
      return DioClient().get(prjSearchUrl);
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<dynamic> projectDetails({required String projectId}) async {
    try {
      String prjSearchUrl = AppApiUrls.projectDetailsUrl(projectId: projectId);
      return DioClient().get(prjSearchUrl);
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e);
    }
  }

  // update Project
  static Future<dynamic> updateProject({required List<ProjectEntity> projectEntity}) async {
    try {
      final userId = await StorageFunction.readIntData(StorageKey.userId);
      if (userId == null) return;

      final List<Map<String, dynamic>> bodyData = [];

      for (final project in projectEntity) {
        /// Fetch sub-projects
        final sPrj = await DBHelper.fetchAllSprjEntityByPrjId(projectId: project.projectId!);

        final List<Map<String, dynamic>> subProjectList = [];

        if (sPrj.isNotEmpty) {
          final subProjects = sPrj.map((e) => SubProjectEntity.fromJson(e)).toList();

          for (final subProject in subProjects) {
            /// Fetch flats per sub-project
            final flatResponse = await DBHelper.getFlats(
              projectId: subProject.projectId!,
              subProjectId: subProject.subProjectId!,
            );

            final List<Map<String, dynamic>> flatList = [];

            if (flatResponse.isNotEmpty) {
              final flatData = flatResponse.map((e) => FlatEntity.fromJson(e)).toList();

              for (final flat in flatData) {
                // if (flat.dataFilled == 0) {
                //   throw Exception("Please fill all flats data before sync.");
                // }

                flatList.add({
                  "flat_id": flat.flatId,
                  "flat_sold": flat.flatSold,
                  "flat_unsold": flat.flatUnsold,
                  "flat_size": flat.flatSize,
                  "flat_size_avg": flat.flatSizeAvg,
                  "flat_size_carpet": flat.flatSizeCarpet,
                  "flat_size_carpet_avg": flat.flatSizeCarpetAvg,
                  "size_type": flat.sizeType,
                });
              }
            }

            /// SUB PROJECT JSON
            subProjectList.add({
              "sub_project_id": subProject.subProjectId,
              "project_status_id": subProject.projectStatusId,
              "scr": subProject.scr,
              "dos": subProject.dos,
              "start_date": subProject.startDate,
              "end_date": subProject.endDate,
              "saleable_rate_psf": subProject.saleableRatepsf,
              "carpet_rate_psf": subProject.carpetRatepsf,
              "rate_type": subProject.rateType,
              "remarks": subProject.remarks,
              "surveyar_id": userId,
              "construction_progress_id": subProject.constructionProgressId,
              "floor_slab": subProject.floorSlab,
              "user_id": userId,
              "survey_date": subProject.surveyDate,
              "booking_stop": subProject.bookingStop,
              "floor_rise": subProject.floorRise,
              "delete_flag": subProject.deleteFlag,
              "storey": subProject.storey,
              "flats_per_floor": subProject.flatsPerFloor,
              "maintenance_per_sqft": subProject.maintenancePersqft,
              "stilt_park": subProject.stiltPark,
              "open_park": subProject.openPark,
              "podium": subProject.podium,
              "double_podium": subProject.doublePodium,
              "basement_park": subProject.basementPark,
              "flat_list": flatList,
            });
          }
        }
        final prjSchems = await DBHelper.getAllProjectsSchemes(projectId: project.projectId!);

        /// PROJECT JSON
        final Map<String, dynamic> projectData = project.toPrjDb();
        projectData.remove("modularKitchenBrand");
        projectData.remove("architectName");
        projectData.remove("architectId");
        projectData["MODULAR_KITCHEN_BRAND"] = project.modularKitchenBrand;
        projectData["MOB_ARCHITECT_NAME"] = project.architectName;
        projectData["ARCHITECT_ID"] = project.architectId;
        projectData["reDevelopment"] = project.reDevelopment == 1;
        projectData["telFlag"] = project.telFlag == 1;
        projectData["newProjectUpdate"] = project.newProjectUpdate == 1;
        projectData["schemeList"] = prjSchems;
        projectData["subProjectsList"] = subProjectList;

        bodyData.add(projectData);
      }
      final projectUpadateUrl = AppApiUrls.updateProjectUrl(userId: userId);
      final response = await DioClient().post(projectUpadateUrl, data: {"projectsList": bodyData});

      if (response != null && response["projectSyncStausList"] != null) {
        final List syncList = response["projectSyncStausList"];
        for (var item in syncList) {
          if (item["resultCode"] == 1) {
            ProjectEntity prj = projectEntity.firstWhere((e) => e.projectId == item["projectId"]);
            prj.syncGlobalStatus = 1;
            await DBHelper.updateProject(prj);
          }
        }
      }
      return response;
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<dynamic> syncProjects({required List<ProjectEntity> projectEntity}) async {
    try {
      final userId = await StorageFunction.readIntData(StorageKey.userId);
      if (userId == null) return;
      String projectIds = projectEntity.map((e) => e.projectId).join(",").toString();
      final projectSyncUrl = AppApiUrls.projectSyncUrl;
      Map<String, dynamic> payload = {"user_id": "$userId", "project_id": projectIds, "sync_status": 1};
      final response = await DioClient().post(projectSyncUrl, data: payload);

      return response;
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<dynamic> uploadBrouchure({required File pdfFile, required int projectId}) async {
    try {
      final int? userId = await StorageFunction.readIntData(StorageKey.userId);

      if (userId == null) {
        throw Exception("User not logged in");
      }

      // Calculate file size
      final int sizeInKb = pdfFile.lengthSync() ~/ 1024;
      final String fileSize = sizeInKb > 1024 ? "${sizeInKb ~/ 1024} MB" : "$sizeInKb KB";

      debugPrint("Brochure Size: $fileSize");
      debugPrint("PDF Path: ${pdfFile.path}");

      final String url = AppApiUrls.broucherUrl;

      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          pdfFile.path,
          filename: pdfFile.path.split('/').last,
          // contentType: MediaType('application', 'pdf'),
        ),
        "projid": projectId.toString(),
        "usrid": userId.toString(),
        "tags": pdfFile.path.split('/').last,
      });

      final response = await DioClient(baseUrl: AppApiUrls.docBaseUrl).uploadFormdata(url, formData: formData);

      return response;
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<dynamic> uploadImage(ImageEntity imageEntity) async {
    final int? userId = await StorageFunction.readIntData(StorageKey.userId);

    if (userId == null) {
      throw Exception("User not logged in");
    }

    try {
      final imageFile = File(imageEntity.imageUri!);

      if (!imageFile.existsSync()) {
        return;
      }

      final fileName = imageFile.path.split('/').last;

      final multipartFile = await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
        contentType: DioMediaType.parse('image/png'),
      );

      /// CORRECT FORM DATA
      final formData = FormData.fromMap({
        "files": [multipartFile],
        "dos": imageEntity.dos ?? "01 Mar 2026",
        "userId": userId.toString(),
        "photoLat": imageEntity.imgLat.toString(),
        "photoLon": imageEntity.imgLon.toString(),
        // "propertyType": imageEntity.type == imageEntity.commercial ? "com" : "res",
        if (imageEntity.type == imageEntity.commercial) 'propertyType': 'com',
      });

      final response = await DioClient().uploadFormdata(AppApiUrls.postUserImage, formData: formData);
      if (response != null && response["resultCode"] == 1) {
        imageEntity.sync = 1;
        await DBHelper.updateByImgPath(imageEntity);
      }
      return response;
    } on DioException catch (e) {
      throw Exception(e.toString());
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<dynamic> uploadPrjLogoImg({required Map<String, String> bodyData}) async {
    final int? userId = await StorageFunction.readIntData(StorageKey.userId);

    if (userId == null) {
      throw Exception("User not logged in");
    }

    try {
      String? impPath = bodyData["imgPath"];
      final imageFile = File(impPath ?? "");
      if (!imageFile.existsSync()) {
        return;
      }

      final fileName = imageFile.path.split('/').last;

      final multipartFile = await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
        contentType: DioMediaType.parse('image/png'),
      );

      /// CORRECT FORM DATA
      final formData = FormData.fromMap({
        "files": [multipartFile],
        "projectid": bodyData["projectId"],
        "userid": userId.toString(),
        "vid": bodyData["vid"],
        "ftype": bodyData["ftype"],
        "fid": bodyData["fid"],
        "dtid": bodyData["dtid"],
        "fsize": bodyData['fsize'],
        "category": bodyData["category"],
      });

      /// DEBUG FORM DATA
      debugPrint("----- FORM DATA FIELDS -----");
      for (var field in formData.fields) {
        debugPrint("${field.key} : ${field.value}");
      }
      debugPrint("----- FORM DATA FILES -----");
      for (var file in formData.files) {
        debugPrint("Key: ${file.key}");
        debugPrint("FileName: ${file.value.filename}");
        debugPrint("ContentType: ${file.value.contentType}");
      }
      final response = await DioClient(
        baseUrl: AppApiUrls.docBaseUrl,
      ).uploadFormdata(AppApiUrls.prjLogoImgUrl, formData: formData);
      return response;
    } on DioException catch (e) {
      throw Exception(e.toString());
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Delete New Assigned Projects of sub-project
  static Future<dynamic> deleteSubProject({required int subProjectId, required int qtrId}) async {
    try {
      Map<String, dynamic> bodyData = {"subprojectid": subProjectId, "qtrid": qtrId};
      return DioClient().post(AppApiUrls.deleteSubProject, data: bodyData);
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e);
    }
  }

  // rera search
  static Future<dynamic> fetchRera({required String query}) async {
    try {
      final userId = await StorageFunction.readIntData(StorageKey.userId);
      if (userId == null) return;

      String reraUrl = AppApiUrls.reraSearchUrl(userId: userId, query: query);
      return DioClient().get(reraUrl);
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<dynamic> getRejectReason({required int projectId, required int qtrId}) async {
    try {
      Map<String, dynamic> payload = {"projectId": projectId, "qtrId": qtrId};
      String reraUrl = AppApiUrls.rejectReasonUrl;
      return DioClient().post(reraUrl, data: payload);
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<dynamic> fetchReraDetails({required int reraId}) async {
    try {
      String url = AppApiUrls.reraDetailsUrl;
      Map<String, dynamic> reraInfo = {"rera_id": reraId};
      Map<String, dynamic> bodyData = {
        "lookup": "GET_RERA_ADDRESS_SURVEYAPP",
        "input_json": jsonEncode(reraInfo),
        // "{\"rera_id\":\"38488\"}"
      };
      return DioClient().post(url, data: bodyData);
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<dynamic> addNewProject({required List<NewProjectEntity> newProjectEntityData}) async {
    try {
      final userId = await StorageFunction.readIntData(StorageKey.userId);
      if (userId == null) return;
      final List<Map<String, dynamic>> projectData = [];
      for (final project in newProjectEntityData) {
        Map<String, dynamic> prjData = {
          "new_project_id": project.prjId,
          "qtr_id": project.qtrId,
          "project_name": project.prjName,
          "rera_not_launched": project.reraNotLaunch,
          "project_address": project.prjAddr,
          "city_id": project.cityId,
          "builder_name": project.builderName,
          "architect_name": project.architectName,
          "lat": project.lat,
          "lng": project.lng,
          "mobile_no": project.mobileNo,
          "amenities_ids": project.prjAmenitiesIds,
          "approved_bank_ids": project.prjApprovedBanksIds,
          "project_scale_id": project.prjScaleId,
          "project_is_lottery": project.isLottery == true ? 1 : 0,
          "project_is_redevelopment": project.isRedevelopment == true ? 1 : 0,
          "created_by": project.userId,
          "rera_status": project.reraPrjType,
          "rera_no": project.reraNo,
          "created_datetime_mob": project.createdDateTime,
        };

        projectData.add(prjData);
      }

      final projectUpadateUrl = AppApiUrls.addNewProjectUrl(userId: userId);
      final Map<String, dynamic> bodyData = {"lookup": "INSERT", "JSON_STR": jsonEncode(projectData)};
      final response = await DioClient().post(projectUpadateUrl, data: bodyData);
      if (response != null && response["status"] == "OK" && response["data"] != null) {
        final List<dynamic> responseData = response['data'];

        for (int i = 0; i < responseData.length; i++) {
          if (responseData[i]['err_status'] == 'OK') {
            final String prjId = responseData[i]['new_project_id'];

            // Find the matching project entity
            NewProjectEntity newProjectEntity = newProjectEntityData.firstWhere(
              (e) => e.prjId == prjId,
              orElse: () => NewProjectEntity(), // avoid exception if not found
            );

            newProjectEntity.syncGlobalStatus = 1;
            await DBHelper.updateNewProject(newProjectEntity);
          }
        }
      }
      return response;
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Fetch New Projects and Sub-Projects Added by user
  static Future<dynamic> fetchNewPrjAndSubPrj({
    required int empId,
    required String qtrId,
    required String lookup,
  }) async {
    try {
      String url = AppApiUrls.newPrjAndSubPrjUrl;
      Map<String, dynamic> jsonInfo = {"emp_id": empId, "qtr_id": qtrId};
      // Map<String, dynamic> bodyData = {"lookup": "NEW_PROJECT", "json_str": jsonEncode(jsonInfo)};
      Map<String, dynamic> bodyData = {"lookup": lookup, "json_str": jsonEncode(jsonInfo)};
      // return DioClient(baseUrl: "http://192.168.0.18/LFAPI/").post(url, data: bodyData);
      return DioClient().post(url, data: bodyData);
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<dynamic> uploadNewPrjImage(NewPrjImageEntity imageEntity) async {
    final int? userId = await StorageFunction.readIntData(StorageKey.userId);
    final userData = await StorageFunction.readStringData(StorageKey.userData);
    String dos = "";
    String qtrId = "";
    if (userData != null) {
      UserData user = UserData.fromJson(jsonDecode(userData));
      final decodedList = jsonDecode(user.jsonstr ?? "");
      final List<Map<String, dynamic>> prjEntryData = decodedList.cast<Map<String, dynamic>>();
      if (prjEntryData.isNotEmpty) {
        qtrId = prjEntryData.first["NEW_PRJ_ENTRY_QTR_ID"];
        dos = prjEntryData.first["NEW_PRJ_ENTRY_QTR"];
      }
    }
    if (userId == null) {
      throw Exception("User not logged in");
    }
    try {
      final imageFile = File(imageEntity.imageUri!);

      if (!imageFile.existsSync()) {
        return;
      }

      // Prepare multipart file
      final multipartFile = await MultipartFile.fromFile(
        imageFile.path,
        // filename: imageFile.path,
        filename: path.basename(imageFile.path),
        contentType: DioMediaType.parse('image/*'),
      );

      // Prepare form data fields
      final formData = FormData.fromMap({
        'file': multipartFile,
        'dos': dos,
        'userId': userId.toString(),
        'qtrId': qtrId,
        'prjId': imageEntity.prjId,
        'created_date': imageEntity.createdDatetime,
        'imgpx': imageEntity.imgLat.toString(),
        'imgpy': imageEntity.imgLng.toString(),
        'imgacc': imageEntity.imgLocAccuracy.toString(),
      });
      final response = await DioClient().uploadFormdata(AppApiUrls.insertNewPrjImageUrl, formData: formData);
      if (response != null && response["resultCode"] == 1) {
        NewPrjImageEntity? newPrjImageEntity = await DBHelper.singleNewImgPrjEntityByPrjId(
          prjId: imageEntity.prjId!,
          imgUri: imageEntity.imageUri!,
        );
        if (newPrjImageEntity != null) {
          newPrjImageEntity.syncStatus = 1;
          await DBHelper.updateNewImgPrjEntity(newPrjImageEntity);
        }
      }

      return response;
    } on DioException catch (e) {
      throw Exception(e.toString());
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<dynamic> fixedProject({required ProjectEntity projectData, required String remarks}) async {
    final int? userId = await StorageFunction.readIntData(StorageKey.userId);
    final userData = await StorageFunction.readStringData(StorageKey.userData);
    // String dos = "";
    // String qtrId = "";
    if (userData != null) {
      UserData user = UserData.fromJson(jsonDecode(userData));
      final decodedList = jsonDecode(user.jsonstr ?? "");
      final List<Map<String, dynamic>> prjEntryData = decodedList.cast<Map<String, dynamic>>();
      if (prjEntryData.isNotEmpty) {
        // qtrId = prjEntryData.first["NEW_PRJ_ENTRY_QTR_ID"];
        // dos = prjEntryData.first["NEW_PRJ_ENTRY_QTR"];
      }
    }
    if (userId == null) {
      throw Exception("User not logged in");
    }
    try {
      // Prepare form data fields
      final payload = {
        'fixedBy': userId,
        'fixedRemarks': remarks,
        'projectId': projectData.projectId,
        'qtrId': projectData.qtrId,
        'rejectId': projectData.rejectId,
      };

      final response = await DioClient().post(AppApiUrls.fixProjectUrl, data: payload);
      if (response != null && response["resultCode"] == 1) {
        projectData.fixedBy = userId;
        await DBHelper.updateProject(projectData);
      }

      return response;
    } on DioException catch (e) {
      throw Exception(e.toString());
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  //************ Sub Project Residential ***************

  static Future<dynamic> updateSubPrj({required List<SubProjectEntity> subProjects}) async {
    try {
      final userId = await StorageFunction.readIntData(StorageKey.userId);
      if (userId == null) {
        throw Exception("User not found");
      }

      /// FINAL REQUEST ARRAY
      final List<Map<String, dynamic>> bodyData = [];

      for (final subProject in subProjects) {
        /// Fetch flats per sub-project
        final flatResponse = await DBHelper.getFlats(
          projectId: subProject.projectId!,
          subProjectId: subProject.subProjectId!,
        );

        List<Map<String, dynamic>> flatList = [];

        if (flatResponse.isNotEmpty) {
          final flatData = flatResponse.map((e) => FlatEntity.fromJson(e)).toList();

          for (final item in flatData) {
            if (item.dataFilled == 0) {
              throw Exception("Please fill all flats data before sync.)");
            }

            flatList.add({
              "flat_id": item.flatId,
              "flat_sold": item.flatSold,
              "flat_unsold": item.flatUnsold,
              "flat_size": item.flatSize,
              "flat_size_avg": item.flatSizeAvg,
              "flat_size_carpet": item.flatSizeCarpet,
              "flat_size_carpet_avg": item.flatSizeCarpetAvg,
              "size_type": item.sizeType,
            });
          }
        }

        /// INNER JSON (stringified)
        final jsonData = {
          "sub_project_id": subProject.subProjectId,
          "project_status_id": subProject.projectStatusId,
          "scr": subProject.scr,
          "dos": subProject.dos,
          "start_date": subProject.startDate,
          "end_date": subProject.endDate,
          "saleable_rate_psf": subProject.saleableRatepsf,
          "carpet_rate_psf": subProject.carpetRatepsf,
          "rate_type": subProject.rateType,
          "remarks": subProject.remarks,
          "surveyar_id": userId,
          "construction_progress_id": subProject.constructionProgressId,
          "floor_slab": subProject.floorSlab,
          "user_id": userId,
          "survey_date": subProject.surveyDate,
          "booking_stop": subProject.bookingStop,
          "floor_rise": subProject.floorRise,
          "delete_flag": subProject.deleteFlag,
          "storey": subProject.storey,
          "flats_per_floor": subProject.flatsPerFloor,
          "maintenance_per_sqft": subProject.maintenancePersqft,
          "stilt_park": subProject.stiltPark,
          "open_park": subProject.openPark,
          "podium": subProject.podium,
          "double_podium": subProject.doublePodium,
          "basement_park": subProject.basementPark,
          "flat_list": flatList,
        };

        /// ADD TO ARRAY
        bodyData.add({"lookup": subProject.subProjectId.toString(), "json_str": jsonEncode(jsonData)});
      }

      debugPrint("Request Body: ${jsonEncode(bodyData)}");

      /// SEND ARRAY TO API
      final response = await DioClient().post(AppApiUrls.saveSubPrj, data: bodyData);
      if (response is Map<String, dynamic>) {
        final List<dynamic>? syncList = response["subProjectSyncStatusList"];
        if (syncList != null && syncList.isNotEmpty) {
          for (final syncStatus in syncList) {
            final int subProjectId = syncStatus["subProjectId"];
            final int resultCode = syncStatus["resultCode"];
            final String message = syncStatus["message"];
            if (resultCode == 1) {
              SubProjectEntity spEntity = subProjects.firstWhere((i) => i.subProjectId == subProjectId);
              spEntity.syncGlobalStatus = resultCode;
              // spEntity.errMsg = message;
              spEntity.errMsg = "Already synced";
              await DBHelper.updateSprjEntity(spEntity);
            } else {
              SubProjectEntity spEntity = subProjects.firstWhere((i) => i.subProjectId == subProjectId);
              spEntity.syncGlobalStatus = resultCode;
              spEntity.errMsg = message;
              await DBHelper.updateSprjEntity(spEntity);
            }
          }
        }
      }
      return response;
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<dynamic> addNewSubPrj({required NewSubProjectEntity subProject}) async {
    try {
      final userId = await StorageFunction.readIntData(StorageKey.userId);
      if (userId == null) {
        throw Exception("User not found");
      }

      /// FETCH FLATS FOR THIS SUB PROJECT
      final flatResponse = await DBHelper.fetchAllNewFlatsBySubPrjId(subProject.subPrjid!);

      final List<Map<String, dynamic>> flatList = [];

      if (flatResponse.isNotEmpty) {
        for (final item in flatResponse) {
          flatList.add({
            "new_flat_id": item.newFlatId,
            "new_sub_project_id": item.newSubProjectId,
            "flat_type_id": item.flatTypeId,
            "saleable_flat_size": item.flatSize,
            "carpet_flat_size": item.carpetSize,
            "area_type": item.areaType,
            "sold": item.flatSold,
            "total": item.totalFlats,
            "created_by": userId,
            "created_datetime_mob": item.createdDateTime?.replaceAll("T", " "),
          });
        }
      }

      /// INNER JSON
      final Map<String, dynamic> jsonData = {
        "new_sub_project_id": subProject.subPrjid,
        "project_id": subProject.projectId,
        "new_project_id": subProject.newProjectId,
        "qtr_id": subProject.qtrid,
        "prj_building_name": subProject.subPrjName,
        "storey": subProject.storey,
        "scr": subProject.scr,
        "maintenance": subProject.maintenance,
        "flats_per_floor": subProject.flatsPerFloor,
        "flat_group": subProject.flatGroup,
        "saleable_launch_price": subProject.saleableLaunchPrice,
        "carpet_launch_price": subProject.carpetLaunchPrice,
        "rate_type": subProject.rateType,
        "launch_date": subProject.launchDate,
        "end_date": subProject.endDate,
        "construction_progress_id": subProject.constructionProgressId,
        "floor_slab": subProject.floorSlab,
        "rera_no": subProject.reraNo,
        "remarks": subProject.remarks,
        "created_by": userId,
        "created_datetime_mob": subProject.createdDateTime?.replaceAll("T", " "),
        "flat_list": flatList,
        "floorrise": subProject.floorRise,
        "stilt_parking": subProject.stiltParking,
        "open_parking": subProject.openParking,
        "podium_parking": subProject.podiumParking,
        "double_podium_parking": subProject.doublePodiumParking,
        "basement_parking": subProject.basementParking,
      };

      /// API BODY (ARRAY WITH SINGLE ITEM)
      // final List<Map<String, dynamic>> bodyData = [
      //   {"lookup": "INSERT", "json_str": jsonEncode(jsonData)},
      // ];
      final Map<String, dynamic> bodyData = {"lookup": "INSERT", "json_str": jsonEncode(jsonData)};

      debugPrint("Request Body: ${jsonEncode(bodyData)}");

      final response = await DioClient().post(AppApiUrls.newSubPrjUrl, data: bodyData);

      debugPrint("New Sub Project Response: $response");
      if (response is Map<String, dynamic>) {
        final List<dynamic>? syncList = response["data"];
        if (syncList != null && syncList.isNotEmpty) {
          for (final syncStatus in syncList) {
            final String subProjectId = syncStatus["new_sub_project_id"].toString();
            if (subProjectId == subProject.subPrjid) {
              subProject.syncGlobalStatus = 1;
              subProject.syncLocalStatus = 0;
              await DBHelper.updateNewSubProjectEntity(subProject);
              for (var flat in flatResponse) {
                flat.syncGlobalStatus = 1;
                await DBHelper.updateNewFlatEntity(flat);
              }
            }
          }
        }
      }
      return response;
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ****************************************************************//
  // Commercial Module ##########################
  static Future<dynamic> cFetchCities() async {
    try {
      final userId = await StorageFunction.readIntData(StorageKey.userId);
      if (userId == null) return;
      String cityUrl = AppApiUrls.cCityUrl(userId: userId);
      // String cityUrl = AppApiUrls.cCityUrl;
      Map<String, dynamic> payload = {"userid": userId};
      return DioClient().post(cityUrl, data: payload);
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e);
    }
  }

  // Fetch Projects
  static Future<dynamic> cFetchProjects({required String locationsId, required int userId}) async {
    try {
      String url = AppApiUrls.cFetchProjectsUrl(locationIds: locationsId, userId: userId);
      return DioClient().get(url);
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<dynamic> cFetchNewProjects({required String dos, required int userId}) async {
    try {
      String url = AppApiUrls.cDownloadNewProjectUrl;
      final Map<String, dynamic> jsData = {"emp_id": userId, "dos": dos};
      Map<String, dynamic> payload = {"lookup": "SELECT_NEW_PROJECT_MOB", "json_str": jsonEncode(jsData)};
      return DioClient().post(url, data: payload);
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<dynamic> cFetchNewSubPrj({required String dos, required int userId}) async {
    try {
      String url = AppApiUrls.cDownloadNewSubPrjUrl;
      final Map<String, dynamic> jsData = {"emp_id": userId, "dos": dos};
      Map<String, dynamic> payload = {"lookup": "SELECT_NEW_SUB_PROJECT_MOB", "json_str": jsonEncode(jsData)};
      return DioClient().post(url, data: payload);
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<dynamic> cUpdateProject({required List<CProjectEntity> projects}) async {
    try {
      final userId = await StorageFunction.readIntData(StorageKey.userId);
      if (userId == null) {
        throw Exception("User not found");
      }

      /// FINAL REQUEST ARRAY
      final List<Map<String, dynamic>> bodyData = [];

      for (final prjData in projects) {
        /// INNER JSON (stringified)
        final jsonData = {
          "locationId": prjData.locationId,
          "suburbId": prjData.suburbId,
          "cityId": prjData.cityId,
          "pxval": prjData.pxval,
          "pyval": prjData.pyval,
          "projectId": prjData.projectId,
          "dos": prjData.dos,
          "projectName": prjData.projectName,
          "projectAddress": prjData.projectAddress,
          "projectPhoneNo": prjData.projectPhoneNo,
          "projectContactPerson": prjData.projectContactPerson,
          "projectMobileNo": prjData.projectMobileNo,
          "builderId": prjData.builderId,
          "builderName": prjData.builderName,
          "builderAddress": prjData.builderAddress,
          "builderContactPerson": prjData.builderContactPerson,
          "builderPhoneNo": prjData.builderPhoneNo,
          "builderMobileNo": prjData.builderMobileNo,
          "roadName": prjData.roadName,
          "parkingOpen": prjData.parkingOpen,
          "parkingStacked": prjData.parkingStacked,
          "parkingStilt": prjData.parkingStilt,
          "parkingBasement": prjData.parkingBasement,
          "parkingPodium": prjData.parkingPodium,
          "parkingRatio": prjData.parkingRatio,
          "scr": prjData.scr,
          "maintenancePerSqft": prjData.maintenancePerSqft,
          "propertyTax": prjData.propertyTax,
          "landParcelSizeUnit": prjData.landParcelSizeUnit,
          "landParcelSize": prjData.landParcelSize,
          "tenantMixId": prjData.tenantMixId,
          "rerano": prjData.rerano,
          "telFlag": prjData.telFlag == 1,
        };

        /// ADD TO ARRAY
        bodyData.add(jsonData);
      }
      final String url = AppApiUrls.cUpdateProjectUrl(userId: userId);

      /// SEND ARRAY TO API
      final response = await DioClient().post(url, data: {"projectsList": bodyData});
      // if (response is Map<String, dynamic>) {
      //   List<dynamic> dataList = response["data"] ?? [];
      //   // Filter successful ones
      //   List<dynamic> successList = dataList.where((item) => item["resultCode"] == 1).toList();
      //   // Extract IDs of successful subprojects
      //   List<int> successIds = successList.map<int>((item) => item["projectId"] as int).toList();
      //   // Filter your local list
      //   List<CProjectEntity> p = projects.where((e) => successIds.contains(e.projectId)).toList();
      //   // Now update only successful ones
      //   await DBHelper.cUpdateMultipleProjects(projects: p);
      // }
      return response;
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<dynamic> cUpdateSubPrj({required List<CSubProjectEntity> subProjects}) async {
    try {
      final userId = await StorageFunction.readIntData(StorageKey.userId);
      if (userId == null) {
        throw Exception("User not found");
      }

      /// FINAL REQUEST ARRAY
      final List<Map<String, dynamic>> bodyData = [];

      for (final subProject in subProjects) {
        /// INNER JSON (stringified)
        final jsonData = {
          "subProjectId": subProject.subProjectId,
          "subProjectName": subProject.subProjectName,
          "dos": subProject.dos,
          "storeyBasement": subProject.storeyBasement,
          "storeyPodium": subProject.storeyPodium,
          "storeyService": subProject.storeyService,
          "storeyHabitable": subProject.storeyHabitable,
          "constStartDate": subProject.constStartDate,
          "constEndDate": subProject.constEndDate,
          "marketingStartDate": subProject.marketingStartDate,
          "marketingEndDate": subProject.marketingEndDate,
          "constructionProgressId": subProject.constructionProgressId,
          "floorSlab": subProject.floorSlab,
          "buildingTypeId": subProject.buildingTypeId,
          "operationModelId": subProject.operationModelId,
          "totalSupplySqft": subProject.totalSupplySqft,
          "soldAreaSqft": subProject.soldAreaSqft,
          "unsoldAreaSqft": subProject.unsoldAreaSqft,
          "leasedOccupiedArea": subProject.leasedOccupiedArea,
          "vacancyArea": subProject.vacancyArea,
          "minFloorplate": subProject.minFloorplate,
          "maxFloorplate": subProject.maxFloorplate,
          "orBareshell": subProject.orBareshell,
          "orWarmshell": subProject.orWarmshell,
          "orFullyFurnished": subProject.orFullyFurnished,
          "lrBareshell": subProject.lrBareshell,
          "lrWarmshell": subProject.lrWarmshell,
          "lrFullyFurnished": subProject.lrFullyFurnished,
          "projectStatusId": subProject.projectStatusId,
          "remarks": subProject.remarks,
          "syncStatus": subProject.syncGlobalStatus,
        };

        /// ADD TO ARRAY
        // bodyData.add({"lookup": subProject.subProjectId.toString(), "comSubProjectsList": jsonEncode(jsonData)});
        bodyData.add(jsonData);
      }
      final String url = AppApiUrls.cUpdateSubPrjUrl(userId: userId);

      /// SEND ARRAY TO API
      final response = await DioClient().post(url, data: {"comSubProjectsList": bodyData});
      // if (response is Map<String, dynamic>) {
      //   List<dynamic> dataList = response["data"] ?? [];
      //   // Filter successful ones
      //   List<dynamic> successList = dataList.where((item) => item["resultCode"] == 1).toList();
      //   // Extract IDs of successful subprojects
      //   List<int> successIds = successList.map<int>((item) => item["subProjectId"] as int).toList();
      //   // Filter your local list
      //   List<CSubProjectEntity> sp = subProjects.where((e) => successIds.contains(e.subProjectId)).toList();
      //   // Now update only successful ones
      //   await DBHelper.cUpdateMultipleSubPrj(subProjects: sp);
      // }
      return response;
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<dynamic> cAddNewProject({required List<CNewProjectEntity> projects}) async {
    try {
      final userId = await StorageFunction.readIntData(StorageKey.userId);
      if (userId == null) {
        throw Exception("User not found");
      }
      final List<Map<String, dynamic>> bodyData = [];
      for (final prj in projects) {
        final jsonData = {
          "new_project_id": prj.prjId,
          "project_name": prj.prjName,
          "project_address": prj.prjAddr,
          "road_name": prj.roadName,
          "city_id": prj.cityId,
          "builder_name": prj.builderName,
          "architect_name": prj.architectName,
          "lat": prj.lat,
          "lng": prj.lng,
          "mobile_no": prj.mobile,
          "amenities_ids": prj.amenitiesIds,
          "approved_bank_ids": prj.approvedBankIds,
          "operating_model_id": prj.operatingModelId,
          "building_type_id": prj.buildingTypeId,
          "tenant_mix_id": prj.tenantMixId,
          "dos": prj.dos,
          "created_by": userId,
          "created_datetime_mob": prj.mobileCreatedDatetime?.replaceAll("T", " "),
        };
        bodyData.add(jsonData);
      }

      final String url = AppApiUrls.cAddNewProjectUrl;
      Map<String, dynamic> payload = {"lookup": "INSERT", "json_str": jsonEncode(bodyData)};
      final response = await DioClient().post(url, data: payload);
      if (response is Map<String, dynamic>) {
        List<dynamic> dataList = response["data"] ?? [];
        // Map: projectId -> response item
        Map<String, dynamic> responseMap = {for (var item in dataList) item["new_project_id"].toString(): item};
        for (var project in projects) {
          final resp = responseMap[project.prjId];
          if (resp != null) {
            final errStatus = resp["err_status"]?.toString() ?? "";
            if (errStatus.toLowerCase() == "ok") {
              project.globalSyncStatus = 1;
              project.errorMessage = ""; // Don't store error message
            } else {
              project.globalSyncStatus = 0;
              project.errorMessage = resp["err_status"]?.toString() ?? "Unknown error";
            }
          }
        }
        await DBHelper.cUpdateMultipleNewPrj(projects: projects);
      }
      return response;
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<dynamic> cAddNewSubPrj({required List<CNewSubProjectEntity> subProjects}) async {
    try {
      final userId = await StorageFunction.readIntData(StorageKey.userId);
      if (userId == null) {
        throw Exception("User not found");
      }
      final List<Map<String, dynamic>> bodyData = [];
      for (final subProject in subProjects) {
        final jsonData = {
          "new_sub_project_id": subProject.subPrjId,
          "new_project_id": subProject.prjId,
          "lf_project_id": subProject.prjIdLF,
          "new_sub_project_name": subProject.subPrjName,
          "storey": subProject.storey,
          "scr": subProject.scr,
          "maintenance": subProject.maintenance,
          "floor_plate": subProject.floorPlate,
          "is_carpet_or_saleable": subProject.carpetOrSaleable,
          "lease_bareshell": subProject.leaseBareshell,
          "lease_warmshell": subProject.leaseWarmshell,
          "lease_fully_furnished": subProject.leaseFullyFurnished,
          "outright_bareshell": subProject.outrightBareshell,
          "outright_warmshell": subProject.outrightWarmshell,
          "outright_fully_furnished": subProject.outrightFullyFurnished,
          "launch_date": subProject.launchDate,
          "end_date": subProject.endDate,
          "construction_stage_id": subProject.constructionStageId,
          "floor_slab": subProject.floorSlab,
          "total_supply": subProject.totalSupply,
          "sold_percent": subProject.soldPercent,
          "unsold_percent": subProject.unsoldPercent,
          "lease_percent": subProject.leasePercent,
          "vacant_percent": subProject.vacantPercent,
          "rera_no": subProject.reraNo,
          "remark": subProject.remark,
          "dos": subProject.dos,
          "created_by": userId,
          "created_datetime_mob": subProject.mobileCreatedDatetime?.replaceAll("T", " "),
        };

        bodyData.add(jsonData);
      }

      final String url = AppApiUrls.cAddNewSubProjectUrl;
      Map<String, dynamic> payload = {"lookup": "INSERT", "json_str": jsonEncode(bodyData)};
      final response = await DioClient().post(url, data: payload);
      if (response is Map<String, dynamic>) {
        List<dynamic> dataList = response["data"] ?? [];
        Map<String, dynamic> responseMap = {for (var item in dataList) item["new_sub_project_id"].toString(): item};
        for (var subPrj in subProjects) {
          final resp = responseMap[subPrj.subPrjId];
          if (resp != null) {
            final errStatus = resp["err_status"]?.toString() ?? "";
            if (errStatus.toLowerCase() == "ok") {
              subPrj.globalSyncStatus = 1;
              subPrj.errorMessage = ""; // Don't store error message
            } else {
              subPrj.globalSyncStatus = 0;
              subPrj.errorMessage = resp["err_status"]?.toString() ?? "Unknown error";
            }
          }
        }

        await DBHelper.cUpdateMultiNewSubPrj(subprojects: subProjects);
      }
      return response;
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ****************************************************************//
  // Pams Surveyor Module Services

  static Future<dynamic> psLoginUser({required String userEmail, required String password}) async {
    try {
      Map<String, dynamic> bodyData = {"username": userEmail, "password": password};

      return DioClient(baseUrl: AppApiUrls.psLoginBaseUrl).post(AppApiUrls.psLoginUrl, data: bodyData);
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<dynamic> psForgetPassword({required String userEmail, required String password}) async {
    try {
      Map<String, dynamic> bodyData = {"email": userEmail, "newPassword": password};

      return DioClient(baseUrl: AppApiUrls.psLoginBaseUrl).post(AppApiUrls.psForgetPassUrl, data: bodyData);
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<dynamic> psGetProjects({required String projectId}) async {
    try {
      String endUrl = AppApiUrls.psGetProjects(projectId: projectId);
      Map<String, dynamic> payload = {"projectId": null, "notProjectId": projectId, "ResponseType": "structure"};
      return DioClient(baseUrl: AppApiUrls.psBaseUrl).post(endUrl, data: payload);
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<dynamic> psPrjFinalSubmit({required List<Map<String, dynamic>> payload}) async {
    try {
      String endUrl = AppApiUrls.finalSubmitPrj;
      return DioClient(baseUrl: AppApiUrls.psBaseUrl).put(endUrl, data: jsonEncode(payload));
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<dynamic> psGetSubProjects() async {
    try {
      String endUrl = AppApiUrls.psGetSubProjects;
      return DioClient(baseUrl: AppApiUrls.psBaseUrl).get(endUrl);
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<dynamic> psGetPhotos() async {
    try {
      String endUrl = AppApiUrls.psGetPhotos;
      return DioClient(baseUrl: AppApiUrls.psBaseUrl).get(endUrl);
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<dynamic> psGetPhotosByPrjId({required int projectId}) async {
    try {
      String endUrl = AppApiUrls.psGetPhotoByPrjId(projectId: projectId);
      return DioClient(baseUrl: AppApiUrls.psBaseUrl).get(endUrl);
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<dynamic> psUploadImage({required List<PsPhotoDatum> imgData}) async {
    try {
      if (imgData.isEmpty) {
        throw Exception("imgData list cannot be empty");
      }

      FormData formData = FormData();

      // Prepare photosMetadataJson
      final List<Map<String, dynamic>> metadataList = imgData.map((item) {
        return {
          "file_name": path.basename(item.photoPath ?? ""),
          "photo_type": item.photoType ?? "",
          "remarks": item.remarks ?? "",
          "photo_lat": item.imgLat,
          "photo_lng": item.imgLng,
          "photo_app_id": item.id,
          "photo_loc_accuracy": item.imgLocAccuracy,
        };
      }).toList();

      formData.fields.add(MapEntry("projectId", imgData.first.projectId.toString()));
      formData.fields.add(MapEntry("photosMetadataJson", jsonEncode(metadataList)));

      // Add files
      for (final item in imgData) {
        if (item.photoPath == null || item.photoPath!.isEmpty) {
          throw Exception("photoPath cannot be null or empty");
        }

        formData.files.add(
          MapEntry("photos", await MultipartFile.fromFile(item.photoPath!, filename: path.basename(item.photoPath!))),
        );
      }

      final response = await DioClient(
        baseUrl: AppApiUrls.psBaseUrl,
      ).uploadFormdata(AppApiUrls.psUploadPhoto, formData: formData);

      return response;
    } on DioException catch (e) {
      throw Exception("Dio error: ${e.toString()}");
    } catch (e) {
      throw Exception("Unexpected error: ${e.toString()}");
    }
  }

  static Future<dynamic> psDeletePhotos({required int photoId}) async {
    try {
      String endUrl = AppApiUrls.psDeletePhotoById(imageId: photoId);
      return DioClient(baseUrl: AppApiUrls.psBaseUrl).delete(endUrl);
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<dynamic> createLandInfo({required List<Map<String, dynamic>> bodyData}) async {
    try {
      final projectUpadateUrl = AppApiUrls.psLandFormUrl;
      final response = await DioClient(baseUrl: AppApiUrls.psBaseUrl).post(projectUpadateUrl, data: bodyData);
      return response;
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<dynamic> updateLandInfo({required List<Map<String, dynamic>> bodyData}) async {
    try {
      final projectUpadateUrl = AppApiUrls.psUpdateLandFormUrl;
      final response = await DioClient(baseUrl: AppApiUrls.psBaseUrl).put(projectUpadateUrl, data: bodyData);
      return response;
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<dynamic> psGetLands({required int projectId}) async {
    try {
      String endUrl = AppApiUrls.psGetLandsUrl(projectId: projectId);
      return DioClient(baseUrl: AppApiUrls.psBaseUrl).get(endUrl);
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e);
    }
  }

  // ****************************************************************//
  // Construction Monitoring Module Services

  static getCmWing({required int projectId}) async {
    try {
      String endUrl = AppApiUrls.cmWingUrl;
      Map<String, dynamic> payLoad = {"projectId": projectId};
      return DioClient(baseUrl: AppApiUrls.psBaseUrl).post(endUrl, data: payLoad);
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<dynamic> cmWingFinalSubmit({required Map<String, dynamic> payload}) async {
    try {
      String endUrl = AppApiUrls.cmWingFinalSubmit;
      return DioClient(baseUrl: AppApiUrls.psBaseUrl).post(endUrl, data: jsonEncode(payload));
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<dynamic> addCmInfo({required List<Map<String, dynamic>> bodyData}) async {
    try {
      final endUrl = AppApiUrls.cmAddWingSurveyUrl;
      final response = await DioClient(baseUrl: AppApiUrls.psBaseUrl).post(endUrl, data: bodyData);
      return response;
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<dynamic> cmUploadImage({required List<PsPhotoDatum> imgData}) async {
    try {
      if (imgData.isEmpty) {
        throw Exception("imgData list cannot be empty");
      }

      FormData formData = FormData();

      // Prepare photosMetadataJson
      final List<Map<String, dynamic>> metadataList = imgData.map((item) {
        return {
          "file_name": path.basename(item.photoPath ?? ""),
          "photo_type": item.photoType ?? "",
          "remarks": item.remarks ?? "",
          "photo_lat": item.imgLat,
          "photo_lng": item.imgLng,
          "photo_app_id": item.id,
          "photo_loc_accuracy": item.imgLocAccuracy,
        };
      }).toList();
      formData.fields.add(MapEntry("projectId", imgData.first.projectId.toString()));
      formData.fields.add(MapEntry("wingId", imgData.first.wingId.toString()));
      formData.fields.add(MapEntry("buildingId", imgData.first.buildingId.toString()));
      formData.fields.add(MapEntry("photosMetadataJson", jsonEncode(metadataList)));

      // Add files
      for (final item in imgData) {
        if (item.photoPath == null || item.photoPath!.isEmpty) {
          throw Exception("photoPath cannot be null or empty");
        }

        formData.files.add(
          MapEntry("photos", await MultipartFile.fromFile(item.photoPath!, filename: path.basename(item.photoPath!))),
        );
      }

      final response = await DioClient(
        baseUrl: AppApiUrls.psBaseUrl,
      ).uploadFormdata(AppApiUrls.cmUploadPhoto, formData: formData);

      return response;
    } on DioException catch (e) {
      throw Exception("Dio error: ${e.toString()}");
    } catch (e) {
      throw Exception("Unexpected error: ${e.toString()}");
    }
  }

  static Future<dynamic> cmDeletePhotos({required int photoId}) async {
    try {
      String endUrl = AppApiUrls.cmDeletePhotoById(imageId: photoId);
      return DioClient(baseUrl: AppApiUrls.psBaseUrl).delete(endUrl);
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e);
    }
  }

  // cm add new building

  static Future<dynamic> cmAddBuilding({required List<Map<String, dynamic>> payload}) async {
    try {
      String endUrl = AppApiUrls.cmAddBuilding;
      return DioClient(baseUrl: AppApiUrls.psBaseUrl).post(endUrl, data: jsonEncode(payload));
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<dynamic> cmDeleteBuilding({required int buildingId}) async {
    try {
      String endUrl = AppApiUrls.cmDeleteBuilding(buildingId: buildingId);
      return DioClient(baseUrl: AppApiUrls.psBaseUrl).delete(endUrl);
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<dynamic> cmAddWing({required List<Map<String, dynamic>> payload}) async {
    try {
      String endUrl = AppApiUrls.cmAddWing;
      return DioClient(baseUrl: AppApiUrls.psBaseUrl).post(endUrl, data: jsonEncode(payload));
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<dynamic> cmDeleteWing({required int wingId}) async {
    try {
      String endUrl = AppApiUrls.cmDeleteWing(wingId: wingId);
      return DioClient(baseUrl: AppApiUrls.psBaseUrl).delete(endUrl);
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e);
    }
  }
}
