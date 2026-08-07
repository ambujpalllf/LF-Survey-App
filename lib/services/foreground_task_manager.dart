import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lf_survey/constants/storage_function.dart';
import 'package:lf_survey/constants/storage_key.dart';
import 'package:lf_survey/constants/utils.dart';
import 'package:lf_survey/database/db_helper.dart';
import 'package:lf_survey/model/location_model.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(ForegroundTaskManager());
}

class ForegroundTaskManager extends TaskHandler {
  // Called when the task is started.
  // @override
  // Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
  //   final result = await Utils.checkLocationGPS();
  //   if (result == true) {
  //     final userId = await StorageFunction.readIntData(StorageKey.userId);
  //     Position currentLocation = await Geolocator.getCurrentPosition();
  //     final battery = Battery();
  //     final batteryPercentage = await battery.batteryLevel;
  //     // if (currentLocation != null) {
  //     LocationModel data = LocationModel(
  //       lat: currentLocation.latitude,
  //       long: currentLocation.longitude,
  //       accuracy: currentLocation.accuracy,
  //       timeStamp: timestamp.millisecondsSinceEpoch ~/ 1000,
  //       batteryPercentage: batteryPercentage,
  //       isMock: currentLocation.isMocked.toString(),
  //       provider: "",
  //       mobileAppId: 1,
  //       userId: userId ?? 0,
  //     );
  //     await DBHelper.insertLocation(locationData: data);
  //     // }

  //     debugPrint('onStart(starter: ${starter.name})');
  //     debugPrint('on Location get (location: $currentLocation)');
  //   } else {
  //     FlutterForegroundTask.stopService();
  //     return;
  //   }
  // }
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    try {
      final result = await Utils.checkLocationGPS();

      if (!result) {
        await FlutterForegroundTask.stopService();
        return;
      }

      // Double-check location service
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        debugPrint('Location service is disabled');
        await FlutterForegroundTask.stopService();
        return;
      }

      final userId = await StorageFunction.readIntData(StorageKey.userId);

      final currentLocation = await Geolocator.getCurrentPosition();

      final battery = Battery();
      final batteryPercentage = await battery.batteryLevel;

      final data = LocationModel(
        lat: currentLocation.latitude,
        long: currentLocation.longitude,
        accuracy: currentLocation.accuracy,
        timeStamp: timestamp.millisecondsSinceEpoch ~/ 1000,
        batteryPercentage: batteryPercentage,
        isMock: currentLocation.isMocked.toString(),
        provider: "",
        mobileAppId: 1,
        userId: userId ?? 0,
      );

      await DBHelper.insertLocation(locationData: data);

      debugPrint('onStart(starter: ${starter.name})');
      debugPrint('Location: ${currentLocation.latitude}, ${currentLocation.longitude}');
    } on LocationServiceDisabledException catch (e) {
      debugPrint('LocationServiceDisabledException: $e');
      await FlutterForegroundTask.stopService();
    } on PermissionDeniedException catch (e) {
      debugPrint('PermissionDeniedException: $e');
      await FlutterForegroundTask.stopService();
    } catch (e) {
      await FlutterForegroundTask.stopService();
    }
  }

  // Called based on the eventAction set in ForegroundTaskOptions.
  // @override
  // void onRepeatEvent(DateTime timestamp) async {
  //   final result = await Utils.checkLocationGPS();
  //   if (result == true) {
  //     Position currentLocation = await Geolocator.getCurrentPosition();
  //     final userId = await StorageFunction.readIntData(StorageKey.userId);
  //     final battery = Battery();
  //     final batteryPercentage = await battery.batteryLevel;
  //     // if (currentLocation != null) {
  //     LocationModel data = LocationModel(
  //       lat: currentLocation.latitude,
  //       long: currentLocation.longitude,
  //       accuracy: currentLocation.accuracy,
  //       timeStamp: timestamp.millisecondsSinceEpoch ~/ 1000,
  //       batteryPercentage: batteryPercentage,
  //       isMock: currentLocation.isMocked.toString(),
  //       provider: "",
  //       mobileAppId: 1,
  //       userId: userId ?? 0,
  //     );
  //     await DBHelper.insertLocation(locationData: data);
  //   } else {
  //     FlutterForegroundTask.stopService();
  //     return;
  //   }
  // }

  @override
  void onRepeatEvent(DateTime timestamp) async {
    try {
      final result = await Utils.checkLocationGPS();
      if (!result) {
        FlutterForegroundTask.stopService();
        return;
      }
      // Double-check location service
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        debugPrint('Location service is disabled');
        await FlutterForegroundTask.stopService();
        return;
      }
      Position currentLocation = await Geolocator.getCurrentPosition();
      final userId = await StorageFunction.readIntData(StorageKey.userId);
      final battery = Battery();
      final batteryPercentage = await battery.batteryLevel;
      LocationModel data = LocationModel(
        lat: currentLocation.latitude,
        long: currentLocation.longitude,
        accuracy: currentLocation.accuracy,
        timeStamp: timestamp.millisecondsSinceEpoch ~/ 1000,
        batteryPercentage: batteryPercentage,
        isMock: currentLocation.isMocked.toString(),
        provider: "",
        mobileAppId: 1,
        userId: userId ?? 0,
      );
      await DBHelper.insertLocation(locationData: data);
    } on LocationServiceDisabledException {
      FlutterForegroundTask.stopService();
    } catch (e) {
      FlutterForegroundTask.stopService();
    }
  }

  // Called when the task is destroyed.
  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    debugPrint('onDestroy(isTimeout: $isTimeout)');
    try {
      final result = await Utils.checkLocationGPS();
      if (result == true) {
        Position currentLocation = await Geolocator.getCurrentPosition();
        final userId = await StorageFunction.readIntData(StorageKey.userId);
        final battery = Battery();
        final batteryPercentage = await battery.batteryLevel;
        LocationModel data = LocationModel(
          lat: currentLocation.latitude,
          long: currentLocation.longitude,
          accuracy: currentLocation.accuracy,
          timeStamp: timestamp.millisecondsSinceEpoch ~/ 1000,
          batteryPercentage: batteryPercentage,
          isMock: currentLocation.isMocked.toString(),
          provider: "",
          mobileAppId: 1,
          userId: userId ?? 0,
        );
        await DBHelper.insertLocation(locationData: data);
      } else {
        FlutterForegroundTask.stopService();
        return;
      }
    } catch (e) {
      debugPrint('Error getting location onDestroy: $e');
    }
    FlutterForegroundTask.stopService();
  }

  // Called when data is sent using `FlutterForegroundTask.sendDataToTask`.
  @override
  void onReceiveData(Object data) {
    debugPrint('onReceiveData: $data');
  }

  // Called when the notification button is pressed.
  @override
  void onNotificationButtonPressed(String id) {
    debugPrint('onNotificationButtonPressed: $id');
  }

  // Called when the notification itself is pressed.
  @override
  void onNotificationPressed() {
    debugPrint('onNotificationPressed');
  }

  // Called when the notification itself is dismissed.
  @override
  void onNotificationDismissed() {
    debugPrint('onNotificationDismissed');
  }
}
