import 'dart:io';
import 'dart:math';
import 'package:app_settings/app_settings.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lf_survey/constants/storage_function.dart';
import 'package:lf_survey/constants/storage_key.dart';
import 'package:lf_survey/database/db_helper.dart';
import 'package:lf_survey/model/db_model/residential/project_entity.dart';
import 'package:lf_survey/model/db_model/residential/sub_prj_entity.dart';
import 'package:lf_survey/services/api_client.dart';

class NotificationServices {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Request Notification Permission
  void requestNotificationPermission() async {
    try {
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
        criticalAlert: true,
        provisional: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint("User  granted permission.");
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint("User granted provisional.");
      } else {
        AppSettings.openAppSettings(type: AppSettingsType.notification);
        debugPrint("Permission is  denied.");
      }
      // Also request local notification permission for iOS
      if (Platform.isIOS) {
        await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(alert: true, badge: true, sound: true);
      }
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future<String> getDeviceToken() async {
    try {
      if (Platform.isIOS) {
        final deviceInfo = DeviceInfoPlugin();
        final iosInfo = await deviceInfo.iosInfo;
        if (!iosInfo.isPhysicalDevice) {
          debugPrint(" Skipping FCM token fetch on iOS Simulator.");
          return "";
        }

        //  Wait for APNs token
        String? apnsToken;
        int retry = 0;
        while (apnsToken == null && retry < 5) {
          apnsToken = await messaging.getAPNSToken();
          if (apnsToken == null) {
            await Future.delayed(Duration(seconds: 1));
            retry++;
          }
        }

        if (apnsToken == null) {
          return "";
        }

        debugPrint("APNs Token: $apnsToken");
      }

      // Now safe to call getToken()
      String? token = await messaging.getToken();
      if (token != null) {
        debugPrint("FCM Device Token: $token");
        return token;
      } else {
        return "";
      }
    } catch (e) {
      debugPrint("$e");
      return "";
    }
  }

  void isTokenRefresh() {
    messaging.onTokenRefresh.listen((token) async {
      try {
        await StorageFunction.writeStringData(StorageKey.firebaseToken, token);
        final response = await ApiClient.updateFirebaseToken(firebaseToken: token);
        if (response != null && response['status'].toString().toLowerCase() == "ok") {
          List data = response['data'] ?? [];
          if (data.isNotEmpty) {
            Map<String, dynamic> respData = data.first;
            if (respData['result'] == 1) {
              await StorageFunction.writeStringData(StorageKey.firebaseToken, "");
            }
          }
        }
      } catch (e) {
        debugPrint("$e");
      }
    });
  }

  // when application is active in android and ios
  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) async {
      try {
        // iOS foreground handling
        if (Platform.isIOS) {
          await foregroundMessage();
        }

        // Initialize local notification (for both platforms)
        if (!context.mounted) return;
        initLocalNotification(context, message);

        /// =======================
        /// 1. SHOW NOTIFICATION
        /// =======================
        if (message.notification != null) {
          await showNotification(
            notificationTitle: message.notification?.title ?? "",
            notificationBody: message.notification?.body ?? "",
          );
        }

        /// =======================
        /// 2. HANDLE DATA PAYLOAD
        /// =======================
        debugPrint("HHHHHHHHHHHHHHHHHHHHHH Message Data: ${message.data}");
        if (message.data.isNotEmpty) {
          // SAFELY READ DATA (everything is String in FCM)
          String newPrjMsg = message.data["newProject"] ?? "";

          if (newPrjMsg.isNotEmpty || newPrjMsg != "") {
            await showNotification(
              notificationTitle: "New Project Assigned",
              notificationBody: "Please open app and download assigned new projects",
            );
            return;
          }

          /// SAFE PARSING
          int rejectId = int.tryParse(message.data["rejectId"] ?? "0") ?? 0;
          int projectId = int.tryParse(message.data["projectId"] ?? "0") ?? 0;
          int fixedBy = int.tryParse(message.data["fixedBy"] ?? "0") ?? 0;
          int qtrId = int.tryParse(message.data["qtrId"] ?? "0") ?? 0;

          String subPrjId = message.data["subProjectId"] ?? "";

          /// SHOW NOTIFICATION
          await showNotification(
            notificationTitle: "Project $projectId",
            notificationBody: "Marked as rejected. Please fix and resubmit the project.",
          );

          /// =======================
          /// 3. UPDATE PROJECT
          /// =======================
          final prjMapData = await DBHelper.getSingleProject(projectId: projectId);

          if (prjMapData != null && prjMapData.isNotEmpty) {
            ProjectEntity prjData = ProjectEntity.fromJson(prjMapData);
            prjData.rejectId = rejectId;
            prjData.fixedBy = fixedBy;
            prjData.qtrId = qtrId;

            await DBHelper.updateProject(prjData);
          }

          /// =======================
          /// 4. HANDLE SUB PROJECTS
          /// =======================
          final subprjMapData = await DBHelper.fetchAllSprjEntityByPrjId(projectId: projectId);

          List<SubProjectEntity> subPrjData = subprjMapData.map((e) => SubProjectEntity.fromJson(e)).toList();

          if (subPrjId.isNotEmpty) {
            List<int> subProjectIds = subPrjId
                .split(',')
                .map((e) => int.tryParse(e.trim()) ?? 0)
                .where((e) => e != 0)
                .toList();

            for (var id in subProjectIds) {
              SubProjectEntity? subproject = subPrjData
                  .where((e) => e.subProjectId == id)
                  .cast<SubProjectEntity?>()
                  .firstWhere((e) => e != null, orElse: () => null);

              if (subproject != null) {
                subproject.syncLocalStatus = 0;
                subproject.syncGlobalStatus = 0;
                await DBHelper.updateSprjEntity(subproject);
              }
            }
          }
        }
      } catch (e) {
        debugPrint("FCM Error: $e");
      }
    });
  }

  // initialize show notification method
  void initLocalNotification(BuildContext context, RemoteMessage message) async {
    try {
      var androidInitializationSettings = const AndroidInitializationSettings('@mipmap/ic_launcher');
      var iosInitializationSettings = const DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );
      var initializationSettings = InitializationSettings(
        android: androidInitializationSettings,
        iOS: iosInitializationSettings,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (payload) {
          handleMessage(context, message);
        },
      );
    } catch (e) {
      debugPrint("$e");
    }
  }

  // show local notifiaction
  Future<void> showNotification({required String notificationTitle, required String notificationBody}) async {
    try {
      AndroidNotificationChannel channel = AndroidNotificationChannel(
        // Random.secure().nextInt(1000).toString(),
        'high_importance_channel',
        "High Importance Notification",
        // importance: Importance.max,
        importance: Importance.high,
      );

      AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        channel.id.toString(),
        channel.name.toString(),
        channelDescription: "This channel is used for important notifications.",
        importance: Importance.high,
        // importance: Importance.max,
        priority: Priority.high,
        ticker: "ticker",
      );

      DarwinNotificationDetails iosNotificationDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: iosNotificationDetails,
      );
      Future.delayed(Duration.zero, () {
        _flutterLocalNotificationsPlugin.show(
          // 0,
          // If you use a unique notification ID, Android creates a new notification each time.
          // If you use the same notification ID, Android updates/replaces the existing notification
          // instead of creating a new one.
          Random().nextInt(100000),
          // message.notification?.title.toString(),
          // message.notification?.body.toString(),
          notificationTitle,
          notificationBody,
          notificationDetails,
        );
      });
    } catch (e) {
      debugPrint("$e");
    }
  }

  // handle Navigation
  void handleMessage(BuildContext context, RemoteMessage message) {
    if (message.data["type"] == "Msg") {
      // Navigator.push(context, MaterialPageRoute(builder: (_) => MessagePage()));
    }
  }

  // When our application in background state
  // Future<void> setUpInteractMessage(context) async {
  //   try {
  //     //When App is terminated state
  //     RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  //     if (initialMessage != null) {
  //       // handleMessage(context, initialMessage);
  //       handleLocalData(initialMessage);
  //     }

  //     // When App is in background.
  //     FirebaseMessaging.onMessageOpenedApp.listen((message) {
  //       handleMessage(context, message);
  //     });
  //   } catch (e) {
  //     debugPrint("$e");
  //   }
  // }

  // For IOS Push Notification you have an iCloud Account it just as gmail account
  // For Ios Froreground Message
  Future foregroundMessage() async {
    try {
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      debugPrint("$e");
    }
  }

  void handleLocalData(RemoteMessage message) async {
    if (message.data.isNotEmpty) {
      // SAFELY READ DATA (everything is String in FCM)
      String newPrjMsg = message.data["newProject"] ?? "";

      if (newPrjMsg.isNotEmpty || newPrjMsg != "") {
        await showNotification(
          notificationTitle: "New Project Assigned",
          notificationBody: "Please open app and download assigned new projects",
        );
        return;
      }

      /// SAFE PARSING
      int rejectId = int.tryParse(message.data["rejectId"] ?? "0") ?? 0;
      int projectId = int.tryParse(message.data["projectId"] ?? "0") ?? 0;
      int fixedBy = int.tryParse(message.data["fixedBy"] ?? "0") ?? 0;
      int qtrId = int.tryParse(message.data["qtrId"] ?? "0") ?? 0;

      String subPrjId = message.data["subProjectId"] ?? "";

      /// SHOW NOTIFICATION
      await showNotification(
        notificationTitle: "Project $projectId",
        notificationBody: "Marked as rejected. Please fix and resubmit the project.",
      );

      /// =======================
      /// 3. UPDATE PROJECT
      /// =======================
      final prjMapData = await DBHelper.getSingleProject(projectId: projectId);

      if (prjMapData != null && prjMapData.isNotEmpty) {
        ProjectEntity prjData = ProjectEntity.fromJson(prjMapData);
        prjData.rejectId = rejectId;
        prjData.fixedBy = fixedBy;
        prjData.qtrId = qtrId;

        await DBHelper.updateProject(prjData);
      }

      /// =======================
      /// 4. HANDLE SUB PROJECTS
      /// =======================
      final subprjMapData = await DBHelper.fetchAllSprjEntityByPrjId(projectId: projectId);

      List<SubProjectEntity> subPrjData = subprjMapData.map((e) => SubProjectEntity.fromJson(e)).toList();

      if (subPrjId.isNotEmpty) {
        List<int> subProjectIds = subPrjId
            .split(',')
            .map((e) => int.tryParse(e.trim()) ?? 0)
            .where((e) => e != 0)
            .toList();

        for (var id in subProjectIds) {
          SubProjectEntity? subproject = subPrjData
              .where((e) => e.subProjectId == id)
              .cast<SubProjectEntity?>()
              .firstWhere((e) => e != null, orElse: () => null);

          if (subproject != null) {
            subproject.syncLocalStatus = 0;
            subproject.syncGlobalStatus = 0;
            await DBHelper.updateSprjEntity(subproject);
          }
        }
      }
    }
  }

  Future<void> projectInitLocalNotification({
    required String notificationTitle,
    required String notificationBody,
  }) async {
    try {
      var androidInitializationSettings = const AndroidInitializationSettings('@mipmap/ic_launcher');
      var iosInitializationSettings = const DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );
      var initializationSettings = InitializationSettings(
        android: androidInitializationSettings,
        iOS: iosInitializationSettings,
      );

      await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
      showNotification(notificationTitle: notificationTitle, notificationBody: notificationBody);
    } catch (e) {
      debugPrint("$e");
    }
  }
}
