import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:lf_survey/cubit/auth/auth_cubit.dart';
import 'package:lf_survey/cubit/auth/ps_signin_cubit.dart';
import 'package:lf_survey/cubit/commercial/c_download/c_download_cubit.dart';
import 'package:lf_survey/cubit/construction_monitering/cm_add_image/cm_add_img_cubit.dart';
import 'package:lf_survey/cubit/construction_monitering/cm_form/cm_form_cubit.dart';
import 'package:lf_survey/cubit/construction_monitering/cm_img_list/cm_img_list_cubit.dart';
import 'package:lf_survey/cubit/construction_monitering/cm_project/cm_prj_cubit.dart';
import 'package:lf_survey/cubit/construction_monitering/cm_sub_prj/cm_sub_prj_cubit.dart';
import 'package:lf_survey/cubit/construction_monitering/cm_survey/cm_survey_cubit.dart';
import 'package:lf_survey/cubit/pams_survey/ps_image_list/ps_img_list_cubit.dart';
import 'package:lf_survey/cubit/pams_survey/ps_land/ps_land_cubit.dart';
import 'package:lf_survey/cubit/pams_survey/ps_land_form/ps_land_form_cubit.dart';
import 'package:lf_survey/cubit/pams_survey/ps_photo/ps_photo_cubit.dart';
import 'package:lf_survey/cubit/pams_survey/ps_project/ps_project_cubit.dart';
import 'package:lf_survey/cubit/residential/add_new_project/add_new_prj_cubit.dart';
import 'package:lf_survey/cubit/residential/download/download_cubit.dart';
import 'package:lf_survey/cubit/residential/filter/filter_cubit.dart';
import 'package:lf_survey/cubit/residential/map_view/map_cubit.dart';
import 'package:lf_survey/cubit/residential/new_assign_prj_locations/new_assign_prj_loc_cubit.dart';
import 'package:lf_survey/cubit/residential/new_prj_details/new_prj_details_cubit.dart';
import 'package:lf_survey/cubit/residential/new_project/new_project_cubit.dart';
import 'package:lf_survey/cubit/residential/new_project_image/new_prj_img_cubit.dart';
import 'package:lf_survey/cubit/residential/project/project_cubit.dart';
import 'package:lf_survey/cubit/residential/project_details/prj_details_cubit.dart';
import 'package:lf_survey/cubit/residential/project_edit/project_edit_cubit.dart';
import 'package:lf_survey/cubit/residential/project_image/prj_img_cubit.dart';
import 'package:lf_survey/cubit/residential/image_list/img_list_cubit.dart';
import 'package:lf_survey/cubit/residential/project_search/prj_search_cubit.dart';
import 'package:lf_survey/cubit/residential/sub_project/add_sprj_form/add_sprj_cubit.dart';
import 'package:lf_survey/cubit/residential/sub_project/new_flats/new_flats_cubit.dart';
import 'package:lf_survey/cubit/residential/sub_project/new_sub_projects/new_sprj_cubit.dart';
import 'package:lf_survey/cubit/residential/sub_project/sprj_details/s_prj_details_cubit.dart';
import 'package:lf_survey/cubit/residential/sub_project/sprj_details_form/sprj_details_form_cubit.dart';
import 'package:lf_survey/cubit/residential/sub_project/sub_project_cubit.dart';
import 'package:lf_survey/cubit/residential/sub_project/sprj_flat_details/s_prj_flat_details_cubit.dart';
import 'package:lf_survey/cubit/user_cubit/user_cubit.dart';
import 'package:lf_survey/firebase_options.dart';
import 'package:lf_survey/routes/app_routes.dart';
import 'package:lf_survey/services/foreground_task_handler.dart';
import 'package:lf_survey/services/notification_services.dart';
import 'package:lf_survey/services/work_manager.dart';
import 'package:lf_survey/services/work_manager_task_register.dart';
import 'package:workmanager/workmanager.dart';

@pragma("vm:entry-point")
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Only show local notification if this is a data-only message
  if (message.notification == null && message.data.isNotEmpty) {
    // NotificationServices().showNotification(message);
    NotificationServices().handleLocalData(message);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    // Workmanager().initialize(callbackDispatcher);
    await Workmanager().initialize(callbackDispatcher);
    FlutterForegroundTask.initCommunicationPort();
    ForegroundTaskHandler.initService();
   await WorkManagerTaskRegister.syncLocation();
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      NotificationServices().handleLocalData(initialMessage);
    }
  }
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark, // ANDROID
      statusBarBrightness: Brightness.dark, // IOS
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => UserCubit()),
        BlocProvider(create: (_) => AuthCubit()),

        //******* Residential Section ************
        BlocProvider(create: (_) => DownloadCubit()),
        BlocProvider(create: (_) => FilterCubit()),
        BlocProvider(create: (_) => NewAssignPrjLocCubit()),

        // Project Section
        BlocProvider(create: (_) => PrjSearchCubit()),
        BlocProvider(create: (_) => ProjectCubit()),
        BlocProvider(create: (_) => PrjDetailsCubit()),
        BlocProvider(create: (_) => ProjectEditCubit()),
        BlocProvider(create: (_) => PrjImgCubit()),
        BlocProvider(create: (_) => ImageListCubit()),
        BlocProvider(create: (_) => NewProjectCubit()),
        BlocProvider(create: (_) => AddNewPrjCubit()),
        BlocProvider(create: (_) => MapCubit()),
        BlocProvider(create: (_) => NewPrjDetailsCubit()),
        BlocProvider(create: (_) => NewPrjImgCubit()),

        // Sub-Project
        BlocProvider(create: (_) => SubProjectCubit()),
        BlocProvider(create: (_) => SPrjFlatDetailsCubit()),
        BlocProvider(create: (_) => SPrjDetailsFormCubit()),
        BlocProvider(create: (_) => SPrjDetailsCubit()),
        BlocProvider(create: (_) => NewSprjCubit()),
        BlocProvider(create: (_) => AddNewSprjCubit()),
        BlocProvider(create: (_) => NewFlatsCubit()),

        // Commercial Module
        BlocProvider(create: (_) => CDownloadCubit()),

        // Construction Monitoring
        BlocProvider(create: (_) => CmPrjCubit()),
        BlocProvider(create: (_) => CmSubPrjCubit()),
        BlocProvider(create: (_) => CMFormCubit()),
        BlocProvider(create: (_) => CmAddImgCubit()),
        BlocProvider(create: (_) => CmImgListCubit()),
        BlocProvider(create: (_) => CmSurveyCubit()),

        // Pams Surveyor Module
        BlocProvider(create: (_) => PsSigninCubit()),
        BlocProvider(create: (_) => PsProjectCubit()),
        BlocProvider(create: (_) => PsPhotoCubit()),
        BlocProvider(create: (_) => PsLandCubit()),
        BlocProvider(create: (_) => PsLandFormCubit()),
        BlocProvider(create: (_) => PsImgListCubit()),
      ],
      child: MaterialApp.router(debugShowCheckedModeBanner: false, title: "LF Surveyor", routerConfig: appRoutes),
    );
  }
}
