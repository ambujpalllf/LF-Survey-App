class AppApiUrls {
  static const String baseUrl = "https://api.liasesforas.com/";
  static const String docBaseUrl = "http://lfcommunity.ressex.com/";

  // ************* Auth Urls **************
  static const String registerUrl = "lf/api/SurveyAppUsers/Registration";
  static const String loginUrl = "lf/api/SurveyAppUsers/Login";
  static String updateFBToken = "lf/api/SurveyAppUsers/UpdateFirebaseToken";
  static const String userGpsUrl = "lf/api/GPSTracker/Insert";

  // *********** Residential End Urls **************
  static String rejectReasonUrl = "lf/api/LFSurveyApp/GetRejectReason";
  static String projectSearchUrl({required String query}) {
    return "lf/api/LFSurveyApp/GetProjectSearch?SEARCH_TEXT=$query";
  }

  static String projectDetailsUrl({required String projectId}) {
    return "lf/api/LFSurveyApp/GetProjectDetail?PROJECT_ID=$projectId";
  }

  static String cityUrl({required int userId}) {
    return "lf/api/LFSurveyApp/fetchResiLocations?userid=$userId";
  }

  // static const String architectUrl = "mobapi/api/projects/getArchitect";
  static const String architectUrl = "lf/api/LFSurveyApp/getArchitect";
  static const String spinnerUrl = "lf/api/LFSurveyApp/GetSurveyAppSpinner";

  // static String getProjectUrl({required int userId, required String locationIds, required String projectIds}) {
  //   return "lf/api/LFSurveyApp/GetProjects?locationsIds=$locationIds&userId=$userId&projectId=$projectIds";
  // }
  static String getProjectUrl = "lf/api/LFSurveyApp/GetProjects";

  // It is not move into lf/api/LFSurveyApp
  static String updateProjectUrl({required int userId}) {
    return "mobapi/api/projects/$userId/projects";
  }

  // static const String projectSyncUrl = "mobapi/api/projects/syncedProject";
  static const String projectSyncUrl = "lf/api/LFSurveyApp/syncedProject";

  static const String broucherUrl = "ResidentialSurvey/jfupload.ashx";
  // It is not move into lf/api/LFSurveyApp
  static const String postUserImage = "mobapi/api/Upload/user/PostUserImage";

  static String reraSearchUrl({required int userId, required String query}) {
    return "lf/api/RERA/Search?search_txt=$query&client_id=$userId";
  }

  static const String reraDetailsUrl = "lf/api/RERA/GetRERA";

  static String addNewProjectUrl({required int userId}) {
    return "mobapi/api/projects/$userId/newproject";
  }

  static const String newPrjAndSubPrjUrl = "lf/api/LFSurveyApp/GetNewPrjAndSubPrj";
  // It is not move into lf/api/LFSurveyApp
  static const String insertNewPrjImageUrl = "mobapi/api/Upload/user/InsertNewPrjImage";
  // It is not move into lf/api/LFSurveyApp
  static const String fixProjectUrl = "mobapi/api/Validation/Fix";
  static const String prjLogoImgUrl = "ResidentialSurvey/jfprojectphotosupload.ashx";

  //********** Residential sub projects urls *********
  static const String saveSubPrj = "lf/api/LFSurveyApp/SaveSubPrj";
  static const String sprjPostUserImage = "mobapi/api/Upload/user/PostUserImage";
  static const String newSubPrjUrl = "lf/api/LFSurveyApp/NewSubProject";
  static const String deleteSubProject = "lf/api/LFSurveyApp/DeleteSubProject";
  ////// ********************************************//////////////////////
  ///  Commercial Module
  static String cCityUrl({required int userId}) {
    return "lf/api/LFCommSurvey/fetchComLocations?userid=$userId";
  }

  static String cFetchProjectsUrl({required String locationIds, required int userId}) {
    return 'lf/api/LFCommSurvey/GetProjects?locationsIds=$locationIds&emp_id=$userId';
  }

  static String cUpdateProjectUrl({required int userId}) {
    return "lf/api/LFCommSurvey/UpdateComProject?userid=$userId";
  }

  static String cUpdateSubPrjUrl({required int userId}) {
    return "lf/api/LFCommSurvey/UpdateComSubProject?userid=$userId";
  }

  static String cDownloadNewProjectUrl = "lf/api/LFCommSurvey/GetNewPrj";
  static String cDownloadNewSubPrjUrl = "lf/api/LFCommSurvey/GetNewSubPrj";
  static String cAddNewProjectUrl = "lf/api/LFCommSurvey/NewProject";
  static String cAddNewSubProjectUrl = "lf/api/LFCommSurvey/NewSubProject";

  ////// ********************************************//////////////////////
  ///  Pams Surveyor Urls

  // static const String psLoginBaseUrl = "https://pamsuatapi.liasesforas.com/api/pams/";
  // static const String psBaseUrl = "https://pamsuatapi.liasesforas.com/api/pams/survey/";
  static const String psLoginBaseUrl = "https://pamsapi.liasesforas.com/api/pams/";
  static const String psBaseUrl = "https://pamsapi.liasesforas.com/api/pams/survey/";
  static const String psLoginUrl = "Auth/login";
  static const String psForgetPassUrl = "Auth/forgot-password";
  static const String psUserLocationUrl = "InsertUserTrackingServe";
  static String psGetProjects({required String projectId}) {
    return "GetAllProjectsServe?notprojectId=$projectId";
  }

  static const String finalSubmitPrj = "UpdateProjectAllocationStatus";
  static const String psGetPhotos = "GetAllPhotos";
  static String psGetPhotoByPrjId({required int projectId}) {
    return projectId == 0 ? "GetAllPhotos" : "GetAllPhotos?projectIds=$projectId";
  }

  static const String psGetSubProjects = "GetWingByProjectId";

  static String psDeletePhotoById({required int imageId}) {
    return "DeletePhotoServe?photoId=$imageId";
  }

  static const String psUploadPhoto = "CreatePhotoServe";
  static String psGetLandsUrl({required int projectId}) {
    return "GetLandByProjectIdServe?projectId=$projectId";
  }

  static const String psLandFormUrl = "CreateLandServe";
  static const String psUpdateLandFormUrl = "UpdateLandServe";

  // Construction Module Urls
  static const String cmWingUrl = "GetWingByProjectIdServe";
  static const String cmAddWingSurveyUrl = "AddWingConstructionSurvey";
  static const String cmUploadPhoto = "AddWingPhotos";
  static const String cmWingFinalSubmit = "SubmitWingSurvey";
  static String cmDeletePhotoById({required int imageId}) {
    return "DeleteWingPhoto/$imageId";
  }

  // cm add new building
  static const String cmAddBuilding = "CreateBuilding";
  static String cmDeleteBuilding({required int buildingId}) {
    return "DeleteBuilding/$buildingId";
  }

  static const String cmAddWing = "CreateWing";
  static String cmDeleteWing({required int wingId}) {
    return "DeleteWing/$wingId";
  }
}
