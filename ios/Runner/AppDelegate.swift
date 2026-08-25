// import Flutter
// import UIKit

// @main
// @objc class AppDelegate: FlutterAppDelegate {
//   override func application(
//     _ application: UIApplication,
//     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//   ) -> Bool {
//     GeneratedPluginRegistrant.register(with: self)
//     return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//   }
// }
// import UIKit
// import Flutter
// import FirebaseCore
// import flutter_foreground_task
// import workmanager_apple
// import UserNotifications

// @main
// @objc class AppDelegate: FlutterAppDelegate {

//   override func application(
//     _ application: UIApplication,
//     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//   ) -> Bool {

//      // Initialize Firebase BEFORE registering Flutter plugins
//     if FirebaseApp.app() == nil {
//       FirebaseApp.configure()
//     }

//     // Register normal Flutter plugins
//     GeneratedPluginRegistrant.register(with: self)

//     // Register plugins for Workmanager background isolate
//     // WorkmanagerPlugin.setPluginRegistrantCallback { registry in
//     //   GeneratedPluginRegistrant.register(with: registry)
//     // }

//        // IMPORTANT:
//     // Register plugins for the Workmanager background Flutter engine.
//     WorkmanagerPlugin.setPluginRegistrantCallback { registry in
//       GeneratedPluginRegistrant.register(with: registry)
//     }

//     // Foreground task plugin
//     SwiftFlutterForegroundTaskPlugin.setPluginRegistrantCallback { registry in
//       GeneratedPluginRegistrant.register(with: registry)
//     }

//     // if #available(iOS 10.0, *) {
//     //   UNUserNotificationCenter.current().delegate =
//     //       self as? UNUserNotificationCenterDelegate
//     // }
//      // Notification delegate
//     UNUserNotificationCenter.current().delegate = self

//     // Background fetch
//     UIApplication.shared.setMinimumBackgroundFetchInterval(
//       UIApplication.backgroundFetchIntervalMinimum
//     )

//     return super.application(
//       application,
//       didFinishLaunchingWithOptions: launchOptions
//     )
//   }
// }
import UIKit
import Flutter
import FirebaseCore
import flutter_foreground_task
import workmanager_apple
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions:
      [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // Firebase must be configured before Flutter plugins are registered.
    FirebaseApp.configure()

     // Workmanager periodic task registration
    // WorkmanagerPlugin.registerPeriodicTask(
    //   withIdentifier: "com.lfsurvey.syncLocation",
    //   frequency: NSNumber(value: 15 * 60)
    // )

    // Register Flutter plugins.
    GeneratedPluginRegistrant.register(with: self)

    // Workmanager background isolate.
    WorkmanagerPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }

    // Foreground task background isolate.
    SwiftFlutterForegroundTaskPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }

    // Notification delegate.
    UNUserNotificationCenter.current().delegate = self

    // Background fetch.
    // UIApplication.shared.setMinimumBackgroundFetchInterval(
    //   UIApplication.backgroundFetchIntervalMinimum
    // )
    UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(60 * 15))

    return super.application(
      application,
      didFinishLaunchingWithOptions: launchOptions
    )
  }
}