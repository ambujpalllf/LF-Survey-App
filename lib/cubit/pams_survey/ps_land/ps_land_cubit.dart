import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lf_survey/cubit/pams_survey/ps_land/ps_land_state.dart';
import 'package:lf_survey/model/pams_survey/land_response.dart';
import 'package:lf_survey/services/api_client.dart';

class PsLandCubit extends Cubit<PsLandState> {
  PsLandCubit() : super(InitState());

  void getLands({required int projectId}) async {
    try {
      emit(LoadingState());
      final response = await ApiClient.psGetLands(projectId: projectId);
      if (response != null && response["status"] == "OK") {
        PsLandResponse landResponse = PsLandResponse.fromJson(response);
        emit(LoadedState(lands: landResponse.data ?? []));
      } else {
        emit(ErrorState(message: response["message"]));
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }
}
