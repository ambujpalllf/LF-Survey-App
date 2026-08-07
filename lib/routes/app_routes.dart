import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lf_survey/cubit/commercial/c_add_new_project/c_add_new_prj_cubit.dart';
import 'package:lf_survey/cubit/commercial/c_add_new_sub_project/c_add_new_sub_project_cubit.dart';
import 'package:lf_survey/cubit/commercial/c_filter/c_filter_cubit.dart';
import 'package:lf_survey/cubit/commercial/c_new_%20project/c_new_project_cubit.dart';
import 'package:lf_survey/cubit/commercial/c_new_sub_projects/c_new_sub_projects_cubit.dart';
import 'package:lf_survey/cubit/commercial/c_prj_image/c_prj_img_cubit.dart';
import 'package:lf_survey/cubit/commercial/c_project/c_project_cubit.dart';
import 'package:lf_survey/cubit/commercial/c_project_details/c_project_details_cubit.dart';
import 'package:lf_survey/cubit/commercial/c_project_edit/c_project_edit_cubit.dart';
import 'package:lf_survey/cubit/commercial/c_sub_project/c_sub_project_cubit.dart';
import 'package:lf_survey/cubit/commercial/c_sub_project_details/c_sub_project_details_cubit.dart';
import 'package:lf_survey/cubit/commercial/c_sub_project_edit/c_sub_prj_edit_cubit.dart';
import 'package:lf_survey/cubit/construction_monitering/cm_building/cm_building_cubit.dart';
import 'package:lf_survey/model/construction_monitoring/cm_building_response.dart';
import 'package:lf_survey/model/construction_monitoring/cm_survey_model.dart';
import 'package:lf_survey/model/construction_monitoring/cm_wing_response.dart';
import 'package:lf_survey/model/db_model/commercial/c_new_project_entity.dart';
import 'package:lf_survey/model/db_model/commercial/c_project_entity.dart';
import 'package:lf_survey/model/db_model/commercial/c_sub_project_entity.dart';
import 'package:lf_survey/model/db_model/residential/new_project_entity.dart';
import 'package:lf_survey/model/db_model/residential/project_entity.dart';
import 'package:lf_survey/model/db_model/residential/sub_prj_entity.dart';
import 'package:lf_survey/model/pams_survey/ps_prj_response.dart';
import 'package:lf_survey/presentation/auth/pams_forget_password_page.dart';
import 'package:lf_survey/presentation/commercial/c_add_new_project_page.dart';
import 'package:lf_survey/presentation/commercial/c_add_new_sub_project_page.dart';
import 'package:lf_survey/presentation/commercial/c_download_page.dart';
import 'package:lf_survey/presentation/commercial/c_filter_page.dart';
import 'package:lf_survey/presentation/commercial/c_new_project_details_page.dart';
import 'package:lf_survey/presentation/commercial/c_new_project_page.dart';
import 'package:lf_survey/presentation/commercial/c_new_sub_projects_page.dart';
import 'package:lf_survey/presentation/commercial/c_prj_image_page.dart';
import 'package:lf_survey/presentation/commercial/c_project_details_page.dart';
import 'package:lf_survey/presentation/commercial/c_project_edit_page.dart';
import 'package:lf_survey/presentation/commercial/c_project_page.dart';
import 'package:lf_survey/presentation/commercial/c_sub_project_details_page.dart';
import 'package:lf_survey/presentation/commercial/c_sub_project_edit_page.dart';
import 'package:lf_survey/presentation/commercial/c_sub_project_page.dart';
import 'package:lf_survey/presentation/construction_monitoring/cm_add_img_page.dart';
import 'package:lf_survey/presentation/construction_monitoring/cm_buildings_page.dart';
import 'package:lf_survey/presentation/construction_monitoring/cm_form_page.dart';
import 'package:lf_survey/presentation/construction_monitoring/cm_img_list_page.dart';
import 'package:lf_survey/presentation/construction_monitoring/cm_prj_page.dart';
import 'package:lf_survey/presentation/construction_monitoring/cm_sub_prj_page.dart';
import 'package:lf_survey/presentation/construction_monitoring/cm_survey_page.dart';
import 'package:lf_survey/presentation/pams_survey/ps_category_page.dart';
import 'package:lf_survey/presentation/pams_survey/ps_image_list_page.dart';
import 'package:lf_survey/presentation/pams_survey/ps_land_form_page.dart';
import 'package:lf_survey/presentation/pams_survey/ps_lands_page.dart';
import 'package:lf_survey/presentation/pams_survey/ps_photo_page.dart';
import 'package:lf_survey/presentation/pams_survey/ps_prj_details_page.dart';
import 'package:lf_survey/presentation/pams_survey/ps_prj_page.dart';
import 'package:lf_survey/presentation/pams_survey/ps_sub_prj_page.dart';
import 'package:lf_survey/presentation/residential/project/add_new_project_page.dart';
import 'package:lf_survey/presentation/residential/project/filter_page.dart';
import 'package:lf_survey/presentation/residential/project/help_page.dart';
import 'package:lf_survey/presentation/residential/project/location_view_page.dart';
import 'package:lf_survey/presentation/residential/project/map_page.dart';
import 'package:lf_survey/presentation/residential/project/new_assign_prj_loc_filter_page.dart';
import 'package:lf_survey/presentation/residential/project/new_prj_image_page.dart';
import 'package:lf_survey/presentation/residential/project/new_project_details_page.dart';
import 'package:lf_survey/presentation/residential/project/new_project_page.dart';
import 'package:lf_survey/presentation/residential/project/prj_image_page.dart';
import 'package:lf_survey/presentation/residential/project/image_list_page.dart';
import 'package:lf_survey/presentation/residential/project/project_search_page.dart';
import 'package:lf_survey/presentation/residential/project/report_page.dart';
import 'package:lf_survey/presentation/residential/sub_project/new_flat_list_page.dart';
import 'package:lf_survey/presentation/residential/sub_project/new_sprj_list_page.dart';
import 'package:lf_survey/presentation/auth/auth_page.dart';
import 'package:lf_survey/presentation/residential/project/download_page.dart';
import 'package:lf_survey/presentation/residential/project/project_category_page.dart';
import 'package:lf_survey/presentation/residential/project/project_details_page.dart';
import 'package:lf_survey/presentation/residential/project/project_edit_form_page.dart';
import 'package:lf_survey/presentation/residential/project/project_page.dart';
import 'package:lf_survey/presentation/residential/sub_project/sub_project_details_form_page.dart';
import 'package:lf_survey/presentation/residential/sub_project/sub_project_details_page.dart';
import 'package:lf_survey/presentation/residential/sub_project/sub_project_flat_details_page.dart';
import 'package:lf_survey/presentation/residential/sub_project/add_new_sprj_form_page.dart';
import 'package:lf_survey/presentation/residential/sub_project/sub_project_page.dart';
import 'package:lf_survey/presentation/user_type_page.dart';
import 'package:lf_survey/routes/app_routes_name.dart';

CustomTransitionPage buildTransitionPage({required Widget child}) {
  return CustomTransitionPage(
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0.1, 0.0), end: Offset.zero).animate(animation),
          child: child,
        ),
      );
    },
  );
}

final GoRouter appRoutes = GoRouter(
  // initialLocation: AppRoutesName.loginPage,
  initialLocation: AppRoutesName.userTypePage,
  routes: [
    GoRoute(
      name: AppRoutesName.userTypePage,
      path: AppRoutesName.userTypePage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return buildTransitionPage(child: UserTypePage());
      },
    ),
    GoRoute(
      name: AppRoutesName.loginPage,
      path: AppRoutesName.loginPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>?;
        final userType = extra?["userType"] as String;
        return buildTransitionPage(child: AuthPage(userType: userType));
      },
    ),
    GoRoute(
      name: AppRoutesName.pamsForgetPasswordPage,
      path: AppRoutesName.pamsForgetPasswordPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return buildTransitionPage(child: PamsForgetPasswordPage());
      },
    ),
    //************* Residential routes************

    // project routes
    GoRoute(
      name: AppRoutesName.projectCategoryPage,
      path: AppRoutesName.projectCategoryPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return buildTransitionPage(child: ProjectCategoryPage());
      },
    ),
    GoRoute(
      name: AppRoutesName.projectSearchPage,
      path: AppRoutesName.projectSearchPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return buildTransitionPage(child: ProjectSearchPage());
      },
    ),
    GoRoute(
      name: AppRoutesName.projectPage,
      path: AppRoutesName.projectPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return buildTransitionPage(child: ProjectPage());
      },
    ),
    GoRoute(
      name: AppRoutesName.locationViewPage,
      path: AppRoutesName.locationViewPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>?;
        final List<ProjectEntity> projects = (extra?["resiPrjects"] as List<ProjectEntity>? ?? []);
        final List<CProjectEntity> cProjects = (extra?["cProjects"] as List<CProjectEntity>? ?? []);
        final String type = extra?["type"] ?? "";
        return buildTransitionPage(
          child: LocationViewPage(resiProject: projects, commercialProject: cProjects, type: type),
        );
      },
    ),
    GoRoute(
      name: AppRoutesName.projectDetailsPage,
      path: AppRoutesName.projectDetailsPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>?;
        // final projectsDatum = extra?["projectData"] as ProjectsDatum;
        final projectsDatum = extra?["projectData"] as ProjectEntity;
        return buildTransitionPage(child: ProjectDetailsPage(projectData: projectsDatum));
      },
    ),
    GoRoute(
      name: AppRoutesName.projectEditFormPage,
      path: AppRoutesName.projectEditFormPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>?;
        // final projectsDatum = extra?["projectData"] as ProjectsDatum?;
        final projectsDatum = extra?["projectData"] as ProjectEntity?;
        return buildTransitionPage(child: ProjectEditFormPage(projectData: projectsDatum!));
      },
    ),
    GoRoute(
      name: AppRoutesName.downloadPage,
      path: AppRoutesName.downloadPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>?;
        final title = extra?["appBarTitle"] ?? "";
        return buildTransitionPage(child: DownloadPage(appBarTitle: title));
      },
    ),
    GoRoute(
      name: AppRoutesName.helpPage,
      path: AppRoutesName.helpPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>?;
        final String prjType = extra?['projectType'] ?? "";
        return buildTransitionPage(child: HelpPage(projectType: prjType));
      },
    ),
    GoRoute(
      name: AppRoutesName.reportPage,
      path: AppRoutesName.reportPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return buildTransitionPage(child: ReportPage());
      },
    ),
    GoRoute(
      name: AppRoutesName.imageListPage,
      path: AppRoutesName.imageListPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>?;
        final int projectId = extra?['projectId'] ?? 0;
        final int subProjectId = extra?['subProjectId'] ?? 0;
        final int resident = extra?['resident'] ?? 0;
        final int commercial = extra?['commercial'] ?? 0;
        return buildTransitionPage(
          child: ImageListPage(
            projectId: projectId,
            subProjectId: subProjectId,
            resident: resident,
            commercial: commercial,
          ),
        );
      },
    ),
    GoRoute(
      name: AppRoutesName.prjImgPage,
      path: AppRoutesName.prjImgPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>?;
        final int projectId = extra?['projectId'] ?? 0;
        final String dos = extra?['dos'] ?? '';
        final String appBarTitle = extra?['appBarTitle'] ?? '';
        final int subProjectId = extra?['subProjectId'] ?? 0;
        return buildTransitionPage(
          child: PrjImagePage(projectId: projectId, subProjectId: subProjectId, dos: dos, appBarTitle: appBarTitle),
        );
      },
    ),
    GoRoute(
      name: AppRoutesName.newProjectsPage,
      path: AppRoutesName.newProjectsPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return buildTransitionPage(child: NewProjectPage());
      },
    ),
    GoRoute(
      name: AppRoutesName.addNewPrjPage,
      path: AppRoutesName.addNewPrjPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return buildTransitionPage(child: AddNewProjectPage());
      },
    ),
    GoRoute(
      name: AppRoutesName.mapPage,
      path: AppRoutesName.mapPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return buildTransitionPage(child: MapPage());
      },
    ),
    GoRoute(
      name: AppRoutesName.newProjectDetailsPage,
      path: AppRoutesName.newProjectDetailsPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>?;
        final projectsData = extra?["newProjectData"] as NewProjectEntity?;
        return buildTransitionPage(child: NewProjectDetailsPage(newProjectEntity: projectsData!));
      },
    ),
    GoRoute(
      name: AppRoutesName.addNewImagePrjPage,
      path: AppRoutesName.addNewImagePrjPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>?;
        final String projectId = extra?['projectId'] ?? "";
        final String? prjType = extra?['prjType'];
        return buildTransitionPage(
          child: NewPrjImagePage(projectId: projectId, projectType: prjType),
        );
      },
    ),
    GoRoute(
      name: AppRoutesName.filterPage,
      path: AppRoutesName.filterPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return buildTransitionPage(child: FilterPage());
      },
    ),
    GoRoute(
      name: AppRoutesName.newAssignPrjLocFilterPage,
      path: AppRoutesName.newAssignPrjLocFilterPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return buildTransitionPage(child: NewAssignPrjLocFilterPage());
      },
    ),
    // sub project
    GoRoute(
      name: AppRoutesName.subProjectPage,
      path: AppRoutesName.subProjectPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>?;

        // final projectsDatum = extra?["projectData"] as ProjectsDatum?;
        final projectsDatum = extra?["projectData"] as ProjectEntity?;
        return buildTransitionPage(child: SubProjectPage(projectData: projectsDatum!));
      },
    ),

    GoRoute(
      name: AppRoutesName.subProjectDetailsPage,
      path: AppRoutesName.subProjectDetailsPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>?;
        final subProjectsDatum = extra?["subProjectData"] as SubProjectEntity?;
        final projectsDatum = extra?["projectData"] as ProjectEntity?;
        return buildTransitionPage(
          child: SubProjectDetailsPage(subProjectsDatum: subProjectsDatum!, projectData: projectsDatum!),
        );
      },
    ),

    GoRoute(
      name: AppRoutesName.subProjectDetailsFormPage,
      path: AppRoutesName.subProjectDetailsFormPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>?;
        final subProjectsDatum = extra?["subProjectData"] as SubProjectEntity?;
        return buildTransitionPage(child: SubProjectDetailsFormPage(subProjectsDatum: subProjectsDatum!));
      },
    ),
    GoRoute(
      name: AppRoutesName.newSubPrjListPage,
      path: AppRoutesName.newSubPrjListPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>?;
        final projectId = extra?["projectId"];
        final newPrjId = extra?["newProjectId"];
        final reraNo = extra?["reraNo"];
        final cityId = extra?["cityId"];
        return buildTransitionPage(
          child: NewSPrjListPage(projectId: projectId, newProjectId: newPrjId, reraNo: reraNo ?? "", cityId: cityId),
        );
      },
    ),
    GoRoute(
      name: AppRoutesName.addNewSPrjFormPage,
      path: AppRoutesName.addNewSPrjFormPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>?;
        final projectId = extra?["projectId"];
        final newProjectId = extra?["newProjectId"];
        final reraNo = extra?["reraNo"];
        final newPrjEntity = extra?["newPrjEntity"];
        final cityId = extra?["cityId"];
        final formType = extra?["formType"];
        final isFreeze = extra?["isFreeze"];
        return buildTransitionPage(
          child: AddNewSPrjFormPage(
            newProjectId: newProjectId,
            cityId: cityId,
            projectId: projectId,
            reraNo: reraNo,
            newSubPrjEntity: newPrjEntity,
            formType: formType,
            isFreeze: isFreeze,
          ),
        );
      },
    ),
    GoRoute(
      name: AppRoutesName.subProjectFlatDetailsPage,
      path: AppRoutesName.subProjectFlatDetailsPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>?;
        final subProjectsDatum = extra?["subProjectData"] as SubProjectEntity?;
        return buildTransitionPage(child: SubProjectFlatDetailsPage(subProjectsDatum: subProjectsDatum!));
      },
    ),

    GoRoute(
      name: AppRoutesName.newFlatListPage,
      path: AppRoutesName.newFlatListPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>?;
        final flatGroupId = extra?["flatGroupId"];
        final subPrjId = extra?["subPrjId"];
        final rateType = extra?["rateType"];
        final syncGlobalStatus = extra?["syncGlobalStatus"];
        return buildTransitionPage(
          child: NewFlatListPage(
            flatgroupId: flatGroupId,
            subPrjId: subPrjId,
            rateType: rateType,
            syncGlobalStatus: syncGlobalStatus,
          ),
        );
      },
    ),

    //************************************************************* */
    //Commercial Routes
    GoRoute(
      name: AppRoutesName.cProjectPage,
      path: AppRoutesName.cProjectPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return buildTransitionPage(
          child: BlocProvider<CProjectCubit>(create: (context) => CProjectCubit(), child: CProjectPage()),
        );
      },
    ),
    GoRoute(
      name: AppRoutesName.cProjectDetailsPage,
      path: AppRoutesName.cProjectDetailsPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>?;
        final projectData = extra?["projectData"] as CProjectEntity;
        return buildTransitionPage(
          child: BlocProvider<CProjectDetailsCubit>(
            create: (context) => CProjectDetailsCubit(),
            child: CProjectDetailsPage(projectData: projectData),
          ),
        );
      },
    ),
    GoRoute(
      name: AppRoutesName.cSubProjectPage,
      path: AppRoutesName.cSubProjectPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>?;
        final projectData = extra?["projectData"] as CProjectEntity;
        return buildTransitionPage(
          child: BlocProvider<CSubProjectCubit>(
            create: (_) => CSubProjectCubit(),
            child: CSubProjectPage(project: projectData),
          ),
        );
      },
    ),
    GoRoute(
      name: AppRoutesName.cSubProjectDetailsPage,
      path: AppRoutesName.cSubProjectDetailsPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>?;
        final subproject = extra?["subProjectData"] as CSubProjectEntity;
        return buildTransitionPage(
          child: BlocProvider<CSubProjectDetailsCubit>(
            create: (context) => CSubProjectDetailsCubit(),
            child: CSubProjectDetailsPage(subProjectData: subproject),
          ),
        );
      },
    ),
    GoRoute(
      name: AppRoutesName.cSubProjectEditPage,
      path: AppRoutesName.cSubProjectEditPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>?;
        final subproject = extra?["subProjectData"] as CSubProjectEntity;
        return buildTransitionPage(
          child: BlocProvider<CSubPrjEditCubit>(
            create: (context) => CSubPrjEditCubit(),
            child: CSubProjectEditPage(subProjectData: subproject),
          ),
        );
      },
    ),

    GoRoute(
      name: AppRoutesName.cProjectImagePage,
      path: AppRoutesName.cProjectImagePage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>?;
        String appBarTitle = extra?["appBarTitle"];
        int prjId = extra?['prjId'];
        int subPrjId = extra?['subPrjId'];
        String dos = extra?['dos'];
        return buildTransitionPage(
          child: BlocProvider(
            create: (context) => CPrjImgCubit(),
            child: CPrjImagePage(appBarTitle: appBarTitle, projectId: prjId, subProjectId: subPrjId, dos: dos),
          ),
        );
      },
    ),
    GoRoute(
      name: AppRoutesName.cPrjEditPage,
      path: AppRoutesName.cPrjEditPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>?;
        final project = extra?["projectData"] as CProjectEntity;
        return buildTransitionPage(
          child: BlocProvider(
            create: (context) => CProjectEditCubit(),
            child: CProjectEditPage(projectEntity: project),
          ),
        );
      },
    ),
    GoRoute(
      name: AppRoutesName.cDownloadPage,
      path: AppRoutesName.cDownloadPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>?;
        final String title = extra?["appBarTitle"] as String;
        return buildTransitionPage(child: CDownloadPage(appBarTitle: title));
      },
    ),
    GoRoute(
      name: AppRoutesName.cFilterPage,
      path: AppRoutesName.cFilterPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return buildTransitionPage(
          child: BlocProvider(create: (context) => CFilterCubit(), child: CFilterPage()),
        );
      },
    ),
    GoRoute(
      name: AppRoutesName.cNewProjectPage,
      path: AppRoutesName.cNewProjectPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return buildTransitionPage(
          child: BlocProvider(create: (context) => CNewProjectCubit(), child: CNewProjectPage()),
        );
      },
    ),
    GoRoute(
      name: AppRoutesName.cNewProjectDetatilsPage,
      path: AppRoutesName.cNewProjectDetatilsPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>?;
        final project = extra?["projectData"] as CNewProjectEntity;
        return buildTransitionPage(child: CNewProjectDetailsPage(projectData: project));
      },
    ),
    GoRoute(
      name: AppRoutesName.cAddNewProjectPage,
      path: AppRoutesName.cAddNewProjectPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>?;
        final project = extra?["projectData"];
        return buildTransitionPage(
          child: BlocProvider(
            create: (context) => CAddNewPrjCubit(),
            child: CAddNewProjectPage(projectData: project),
          ),
        );
      },
    ),
    GoRoute(
      name: AppRoutesName.cNewSubProjectPage,
      path: AppRoutesName.cNewSubProjectPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>?;
        final newProject = extra?["newProjectData"];
        final project = extra?["projectData"];
        return buildTransitionPage(
          child: BlocProvider(
            create: (context) => CNewSubProjectsCubit(),
            child: CNewSubProjectsPage(cNewProjectEntity: newProject, project: project),
          ),
        );
      },
    ),
    GoRoute(
      name: AppRoutesName.cAddNewSubProjectPage,
      path: AppRoutesName.cAddNewSubProjectPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>?;
        final newProject = extra?["newProjectData"];
        final project = extra?["projectData"];
        final newSubProject = extra?["newSubProject"];
        return buildTransitionPage(
          child: BlocProvider(
            create: (context) => CAddNewSubProjectCubit(),
            child: CAddNewSubProjectPage(
              cNewProjectEntity: newProject,
              project: project,
              cNewSubProjects: newSubProject,
            ),
          ),
        );
      },
    ),
    //************************************************************* */
    // Construction Monitoring Routes
    GoRoute(
      name: AppRoutesName.cmPrjPage,
      path: AppRoutesName.cmPrjPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return buildTransitionPage(child: CMPrjPage());
      },
    ),
    GoRoute(
      name: AppRoutesName.cmSubPrjPage,
      path: AppRoutesName.cmSubPrjPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>?;
        final prjData = extra?["projectData"] as PsPrjDatum;
        final buildingData = extra?["buildingData"] as BuildingData;
        return buildTransitionPage(
          child: CMSubPrjPage(prjDatum: prjData, buildingData: buildingData),
        );
      },
    ),
    GoRoute(
      name: AppRoutesName.cmSurveyPage,
      path: AppRoutesName.cmSurveyPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>?;
        final wingData = extra?["wingData"] as WingData;
        return buildTransitionPage(child: CmSurveyPage(wingData: wingData));
      },
    ),
    GoRoute(
      name: AppRoutesName.cmFormPage,
      path: AppRoutesName.cmFormPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>?;
        final wingData = extra?["wingData"] as WingData;
        bool? isViewOnly = extra?["isViewOnly"] as bool?;
        final CmSurveyModel? surveyData = extra?["surveyData"] as CmSurveyModel?;

        return buildTransitionPage(
          child: CMFormPage(wingData: wingData, surveyData: surveyData, isViewOnly: isViewOnly ?? false),
        );
      },
    ),
    GoRoute(
      name: AppRoutesName.cmImgPage,
      path: AppRoutesName.cmImgPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>?;
        final wingData = extra?["wingData"] as WingData;
        return buildTransitionPage(child: CmAddImgPage(wingData: wingData));
      },
    ),

    GoRoute(
      name: AppRoutesName.cmImgListPage,
      path: AppRoutesName.cmImgListPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        // final extra = state.extra as Map<String, dynamic>?;
        // final wingData = extra?["wingData"] as Wing;
        return buildTransitionPage(child: CmImgListPage());
      },
    ),

    GoRoute(
      name: AppRoutesName.cmBuildingPage,
      path: AppRoutesName.cmBuildingPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>?;
        final prjData = extra?["projectData"] as PsPrjDatum;
        return buildTransitionPage(
          child: BlocProvider(
            create: (context) => CmBuildingCubit(),
            child: CmBuildingsPage(prjDatum: prjData),
          ),
        );
      },
    ),

    //************************************************************* */
    // PAMS Survey Routes
    GoRoute(
      name: AppRoutesName.psCategoryPage,
      path: AppRoutesName.psCategoryPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return buildTransitionPage(child: PsCategoryPage());
      },
    ),
    GoRoute(
      name: AppRoutesName.psPrjPage,
      path: AppRoutesName.psPrjPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return buildTransitionPage(child: PsPrjPage());
      },
    ),
    GoRoute(
      name: AppRoutesName.psSubPrjPage,
      path: AppRoutesName.psSubPrjPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return buildTransitionPage(child: PsSubPrjPage());
      },
    ),
    GoRoute(
      name: AppRoutesName.psPrjDetailsPage,
      path: AppRoutesName.psPrjDetailsPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>?;
        final prjData = extra?["projectData"] as PsPrjDatum;
        return buildTransitionPage(child: PsPrjDetailsPage(prjDatum: prjData));
      },
    ),
    GoRoute(
      name: AppRoutesName.psPhotoPage,
      path: AppRoutesName.psPhotoPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>?;
        final prjData = extra?["projectData"] as PsPrjDatum;
        return buildTransitionPage(child: PsPhotoPage(prjDatum: prjData));
      },
    ),
    GoRoute(
      name: AppRoutesName.psLandFormPage,
      path: AppRoutesName.psLandFormPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>?;
        final PsPrjDatum prjData = extra?["projectData"] as PsPrjDatum;
        return buildTransitionPage(child: PsLandFormPage(prjDatum: prjData));
      },
    ),
    GoRoute(
      name: AppRoutesName.psLandsPage,
      path: AppRoutesName.psLandsPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final extra = state.extra as Map<String, dynamic>?;
        final prjData = extra?["projectData"] as PsPrjDatum;
        return buildTransitionPage(child: PsLandsPage(prjDatum: prjData));
      },
    ),
    GoRoute(
      name: AppRoutesName.psImgSyncPage,
      path: AppRoutesName.psImgSyncPage,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return buildTransitionPage(child: PsImageListPage());
      },
    ),
  ],
);
