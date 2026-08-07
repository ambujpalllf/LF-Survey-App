import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lf_survey/cubit/construction_monitering/cm_sub_prj/cm_sub_prj_state.dart';
import 'package:lf_survey/database/db_helper.dart';
import 'package:lf_survey/model/construction_monitoring/cm_survey_model.dart';
import 'package:lf_survey/model/construction_monitoring/cm_wing_response.dart';
import 'package:lf_survey/model/pams_survey/ps_photo_response.dart';
import 'package:lf_survey/services/api_client.dart';

class CmSubPrjCubit extends Cubit<CmSubPrjState> {
  CmSubPrjCubit() : super(InitState());

  // void getWings({required int projectId}) async {
  //   try {
  //     emit(LoadingState());
  //     final localData = await DBHelper.getCMAllWingsByPrjId(projectId: projectId);
  //     if (localData.isNotEmpty) {
  //       emit(LoadedState(wingData: localData));
  //       return;
  //     } else {
  //       emit(ErrorState(message: "No Data Found"));
  //     }
  //   } catch (e) {
  //     String erMsg = e.toString().split(":").last;
  //     emit(ErrorState(message: erMsg));
  //   }
  // }
  void getWings({required int projectId, int? buildingId, String? createdBuildingId}) async {
    try {
      emit(LoadingState());
      final localData = await DBHelper.getCMAllWingsByBuildingId(
        projectId: projectId,
        buildingId: buildingId,
        createdBuildingId: createdBuildingId,
      );
      if (localData.isNotEmpty) {
        emit(LoadedState(wingData: localData));
        return;
      } else {
        emit(ErrorState(message: "No Data Found"));
      }
    } catch (e) {
      String erMsg = e.toString().split(":").last;
      emit(ErrorState(message: erMsg));
    }
  }

  void getSurvey({required int projectId}) async {
    try {
      emit(LoadingState());

      final response = await Future.wait([
        DBHelper.cmGetAllWingSurvey(),
        DBHelper.getAllCmImageByPrjId(projectId: projectId),
      ]);

      final List<CmSurveyModel> survey = response[0] as List<CmSurveyModel>;

      final List<PsPhotoDatum> image = response[1] as List<PsPhotoDatum>;

      emit(SurveyState(surveyData: survey, imageData: image));
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void searchWings({required String query, required List<WingData> wings}) async {
    try {
      if (query.isEmpty) {
        emit(SearchState(wings: wings));
        return;
      }

      final filteredWings = wings.where((wing) {
        return wing.wingName!.toLowerCase().contains(query.toLowerCase());
      }).toList();
      emit(SearchState(wings: filteredWings));
    } catch (e) {
      String erMsg = e.toString().split(":").last;
      emit(ErrorState(message: erMsg));
    }
  }

  void finalSubmitWing({required int allocationId, required WingData wingData}) async {
    try {
      Map<String, dynamic> payload = {
        "allocationId": allocationId,
        "wingId": wingData.wingId,
        "remarks": "string",
        "appId": "${wingData.wingId}",
      };

      final response = await ApiClient.cmWingFinalSubmit(payload: payload);
      final responseData = response;

      final status = responseData["status"]?.toString().toUpperCase();
      final message = responseData["message"] ?? "Something went wrong.";

      if (status == "OK") {
        final data = responseData["data"];

        if (data != null) {
          final int returnedWingId = int.parse(data["wing_id"].toString());

          if (returnedWingId == wingData.wingId) {
            emit(SuccessState(message: message));
            wingData.submitStatus = true;
            await DBHelper.updateCmWingsByWingId(wing: wingData);
            emit(WingUpdateState(wing: wingData));
            return;
          }
        } else {
          emit(ErrorState(message: "No data found."));
        }
      } else {
        emit(ErrorState(message: message));
      }
    } catch (e) {
      final errorMessage = e.toString().contains(":") ? e.toString().split(":").last.trim() : e.toString();
      emit(ErrorState(message: errorMessage));
    }
  }

  void deletewing({required int id, required int index, int? wingId}) async {
    try {
      if (wingId != null && wingId != 0) {
        final response = await ApiClient.cmDeleteWing(wingId: wingId);
        if (response != null) {
          await DBHelper.cmDeleteWing(id: id);
          emit(DeleteState(index: index));
        }
      } else {
        await DBHelper.cmDeleteWing(id: id);
        emit(DeleteState(index: index));
      }
    } catch (e) {
      final errorMessage = e.toString().contains(":") ? e.toString().split(":").last.trim() : e.toString();
      emit(ErrorState(message: errorMessage));
    }
  }
}
