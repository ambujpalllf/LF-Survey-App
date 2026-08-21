import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lf_survey/constants/storage_function.dart';
import 'package:lf_survey/constants/storage_key.dart';
import 'package:lf_survey/cubit/residential/add_new_project/add_new_prj_state.dart';
import 'package:lf_survey/database/db_helper.dart';
import 'package:lf_survey/model/db_model/residential/new_project_entity.dart';
import 'package:lf_survey/model/residential/project_spinner.dart';
import 'package:lf_survey/model/residential/rera_details_response.dart';
import 'package:lf_survey/model/residential/rera_response.dart';
import 'package:lf_survey/model/residential/user_response.dart';
import 'package:lf_survey/services/api_client.dart';
import 'package:lf_survey/services/work_manager_task_register.dart';

class AddNewPrjCubit extends Cubit<AddNewPrjState> {
  AddNewPrjCubit() : super(InitState());

  void fetchUserData() async {
    try {
      final userData = await StorageFunction.readStringData(StorageKey.userData);
      if (userData != null) {
        UserData user = UserData.fromJson(jsonDecode(userData));
        final decodedList = jsonDecode(user.jsonstr ?? "");
        final List<Map<String, dynamic>> prjEntryData = decodedList.cast<Map<String, dynamic>>();
        if (prjEntryData.isNotEmpty) {
          emit(
            UserDataState(
              qtrId: prjEntryData.first["NEW_PRJ_ENTRY_QTR_ID"],
              qtr: prjEntryData.first["NEW_PRJ_ENTRY_QTR"],
            ),
          );
        }
      }
    } catch (e) {
      String erStr = e.toString().split(":").last;
      emit(ErrorState(message: erStr));
    }
  }

  void downloadProjectSpinner() async {
    try {
      final response = await ApiClient.fetchProjectSpinner();
      if (response != null) {
        SpinnerResponse spinnerResponse = SpinnerResponse.fromJson(response);
        emit(
          LocalDbState(
            cities: spinnerResponse.data?.cityList ?? [],
            amenties: spinnerResponse.data?.amenitiesList ?? [],
            approveBanks: spinnerResponse.data?.approvedBankList ?? [],
            projectScales: spinnerResponse.data?.projectScaleList ?? [],
          ),
        );
      } else {
        emit(ErrorState(message: "No Drop-down Data Downloaded."));
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void fetchData() async {
    try {
      final cityRes = await DBHelper.getCity();
      final amentiesRes = await DBHelper.getAmenities();
      final bankRes = await DBHelper.getApprovedBank();
      final prjScaleRes = await DBHelper.getProjectScale();
      if (cityRes.isNotEmpty && amentiesRes.isNotEmpty && bankRes.isNotEmpty && prjScaleRes.isNotEmpty) {
        List<CityList> cities = cityRes.map((e) => CityList.fromJson(e)).toList();
        List<AmenitiesList> amenties = amentiesRes.map((e) => AmenitiesList.fromJson(e)).toList();
        List<ApprovedBankList> approveBanks = bankRes.map((e) => ApprovedBankList.fromJson(e)).toList();
        List<ProjectScaleList> projectScales = prjScaleRes.map((e) => ProjectScaleList.fromJson(e)).toList();
        emit(
          LocalDbState(cities: cities, amenties: amenties, approveBanks: approveBanks, projectScales: projectScales),
        );
      }
    } catch (e) {
      String erStr = e.toString().split(":").last;
      emit(ErrorState(message: erStr));
    }
  }

  void reraSearch({required String query}) async {
    emit(LoadingState());
    try {
      if (query.trim().isEmpty) {
        emit(ReraSearch(reraDatum: []));
        return;
      }
      if (query.length >= 3) {
        final response = await ApiClient.fetchRera(query: query);
        debugPrint("GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG: $response");
        if (response != null) {
          ReraResponse reraResponse = ReraResponse.fromJson(response);
          if (reraResponse.data!.isNotEmpty) {
            emit(ReraSearch(reraDatum: reraResponse.data!));
          } else {
            emit(ErrorState(message: "No Data Found"));
          }
        }
      }
      //  else {
      //   emit(ErrorState(message: "No Data Found"));
      // }
    } catch (e) {
      String erStr = e.toString().split(":").last;
      emit(ErrorState(message: erStr));
    }
  }

  void reraInfoAction() {
    emit(ReraInfoState());
  }

  void fetchReraDetails({required int reraId}) async {
    try {
      final response = await ApiClient.fetchReraDetails(reraId: reraId);
      if (response != null) {
        ReraDetailsResponse reraDetailsResponse = ReraDetailsResponse.fromJson(response);
        emit(ReraDetailsState(reraDetails: reraDetailsResponse.data!));
        debugPrint("Get rera details: $response");
      }
    } catch (e) {
      String erStr = e.toString().split(":").last;
      emit(ErrorState(message: erStr));
    }
  }

  void selectProjectType({required dynamic value}) {
    emit(SelectPrjTypeSate(projectType: value));
  }

  void selectLottery({required bool isLottery}) {
    emit(LotteryState(isLottery: isLottery));
  }

  void selectReraLaunch({required bool isReraLaunch}) {
    emit(ReraLaunchState(isReraLaunch: isReraLaunch));
  }

  void selectRedevlopment({required bool isRedevelopment}) {
    emit(RedevelopState(isRedevelop: isRedevelopment));
  }

  bool validationFields({
    required Map<String, dynamic>? projectType,
    required String reraNo,
    required String projectName,
    required String projectAddress,
    required int cityId,
    required String builderName,
    required String architectName,
    required String lat,
    required String lng,
    required String mobileNumber,
    required List<Map<String, dynamic>> selectedAmenties,
    required List<Map<String, dynamic>> selectedBanks,
    required Map<String, dynamic>? selectedPrjScales,
  }) {
    String reraMsg = "";
    String prjMsg = "";
    String prjAddMsg = "";
    String builderMsg = "";
    String archiMsg = "";
    String latMsg = "";
    String lngMsg = "";
    String mobMsg = "";

    bool isValid = true;

    /// RERA validation
    if (projectType == null) {
      emit(ErrorState(message: "Please select RERA Type."));
      return false;
    } else if (projectType["title"] == "RERA Project" && reraNo.isEmpty) {
      reraMsg = "Please select RERA, it is required field.";
      isValid = false;
    } else if (projectType["title"] == "RERA pre-Launch" && reraNo.isEmpty) {
      reraMsg = "Please enter RERA No.";
      isValid = false;
    }

    /// Project Name
    if (projectName.isEmpty) {
      prjMsg = "Please enter Project Name";
      isValid = false;
    }

    /// Project Address
    if (projectAddress.isEmpty) {
      prjAddMsg = "Please enter Project Address";
      isValid = false;
    }

    /// City
    if (cityId == 0) {
      emit(ErrorState(message: "Please select City"));
      return false;
    }

    /// Builder
    if (builderName.isEmpty) {
      builderMsg = "Please enter Builder Name";
      isValid = false;
    }

    if (architectName.isEmpty) {
      archiMsg = "Please enter Architect Name";
      isValid = false;
    }

    /// Latitude
    if (lat.isEmpty || double.tryParse(lat) == null || lat == "0.0") {
      latMsg = "Please enter valid Latitude";
      isValid = false;
    }

    /// Longitude
    if (lng.isEmpty || double.tryParse(lng) == null || lng == "0.0") {
      lngMsg = "Please enter valid Longitude";
      isValid = false;
    }

    /// Mobile
    if (mobileNumber.isEmpty) {
      mobMsg = "Please enter Mobile No.";
      isValid = false;
    }

    /// Amenities
    if (selectedAmenties.isEmpty) {
      emit(ErrorState(message: "Please select Amenities"));
      return false;
    }

    /// Banks
    if (selectedBanks.isEmpty) {
      emit(ErrorState(message: "Please select Approved Banks"));
      return false;
    }

    /// Project Scale
    if (selectedPrjScales == null) {
      emit(ErrorState(message: "Please Select Project Scale."));
      return false;
    }

    /// Emit field-level errors
    emit(
      FieldsValidation(
        reraMsg: reraMsg,
        prjMsg: prjMsg,
        prjAddMsg: prjAddMsg,
        builderMsg: builderMsg,
        archiMsg: archiMsg,
        latMsg: latMsg,
        lngMsg: lngMsg,
        mobMsg: mobMsg,
      ),
    );

    return isValid;
  }

  Future<bool> saveProject({
    required int qtrId,
    required String qtr,
    required Map<String, dynamic>? projectType,
    required String reraNo,
    required String projectName,
    required String projectAddress,
    required int cityId,
    required String builderName,
    required String architectName,
    required String lat,
    required String lng,
    required String mobileNumber,
    required List<Map<String, dynamic>> selectedAmenties,
    required List<Map<String, dynamic>> selectedBanks,
    required Map<String, dynamic>? selectedPrjScales,
    required bool lottery,
    required bool redevelopment,
    required bool reraNotLaunch,
  }) async {
    try {
      final isValid = validationFields(
        projectType: projectType,
        reraNo: reraNo,
        projectName: projectName,
        projectAddress: projectAddress,
        cityId: cityId,
        builderName: builderName,
        architectName: architectName,
        lat: lat,
        lng: lng,
        mobileNumber: mobileNumber,
        selectedAmenties: selectedAmenties,
        selectedBanks: selectedBanks,
        selectedPrjScales: selectedPrjScales,
      );
      if (!isValid) return false;
      final userId = await StorageFunction.readIntData(StorageKey.userId);
      if (userId == null) {
        emit(ErrorState(message: "User id is null."));
        return false;
      }
      String amentiesId = selectedAmenties.map((e) => e["id"]).join(", ");
      String banksId = selectedBanks.map((e) => e["id"]).join(", ");
      DateTime currentTime = DateTime.now();
      String formattedDate = DateFormat("yyyy-MM-dd HH:mm:ss").format(currentTime);
      String projectId = "${userId}_${currentTime.millisecondsSinceEpoch}";
      NewProjectEntity newProjectEntity = NewProjectEntity(
        prjId: projectId,
        prjName: projectName,
        prjAddr: projectAddress,
        lat: double.tryParse(lat),
        lng: double.tryParse(lng),
        userId: userId,
        cityId: cityId,
        builderName: builderName,
        architectName: architectName,
        mobileNo: mobileNumber,
        prjAmenitiesIds: amentiesId,
        prjApprovedBanksIds: banksId,
        prjScaleId: selectedPrjScales?["id"],
        isLottery: lottery,
        isRedevelopment: redevelopment,
        createdDateTime: formattedDate,
        qtrId: qtrId,
        qtr: qtr,
        reraPrjType: projectType?["title"],
        reraNo: reraNo,
        reraNotLaunch: reraNotLaunch,
        syncLocalStatus: 1,
        syncGlobalStatus: 0,
      );
      final response = await DBHelper.insertNewProject(newProjectEntity);
      if (response > 0) {
        WorkManagerTaskRegister.syncNewProject(projectId: newProjectEntity.prjId ?? "");
        // final result = await ApiClient.addNewProject(newProjectEntityData: [newProjectEntity]);
        emit(SuccessState(message: "New Project Added Succesfully"));
        return true;
      } else {
        emit(ErrorState(message: "Failed to save project."));
        return false;
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
      return false;
    }
  }
}
