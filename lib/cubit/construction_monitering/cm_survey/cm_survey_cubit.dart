import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lf_survey/cubit/construction_monitering/cm_survey/cm_survey_state.dart';
import 'package:lf_survey/database/db_helper.dart';
import 'package:lf_survey/services/work_manager_task_register.dart';

class CmSurveyCubit extends Cubit<CmSurveyState> {
  CmSurveyCubit() : super(InitState());

  void getSurvey({int? wingId, String? localWingId}) async {
    try {
      emit(LoadingState());
      final response = await DBHelper.getAllCmSurveyByWingId(wingId: wingId, localWingId: localWingId);
      if (response.isNotEmpty) {
        emit(LoadedState(surveyData: response));
      } else {
        emit(ErrorState(message: "Data not found"));
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void syncProjects() {
    try {
      WorkManagerTaskRegister.syncCmSurvey();
      emit(SuccessState(message: "Syncing started..."));
    } catch (e) {
      String erMsg = e.toString().split(":").last;
      emit(ErrorState(message: erMsg));
    }
  }
}
