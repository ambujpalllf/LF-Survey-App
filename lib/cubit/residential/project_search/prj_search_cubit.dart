import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lf_survey/cubit/residential/project_search/prj_search_state.dart';
import 'package:lf_survey/model/residential/prj_search_details.dart';
import 'package:lf_survey/model/residential/project_search_response.dart';
import 'package:lf_survey/services/api_client.dart';
import 'package:url_launcher/url_launcher.dart';

class PrjSearchCubit extends Cubit<PrjSearchState> {
  PrjSearchCubit() : super(InitState());

  void clearMethod() {
    emit(ClearState());
  }

  void searchProject({required String query}) async {
    try {
      String searchText = query.trim().toLowerCase();
      if (searchText.isEmpty) {
        emit(ClearState());
        return;
      }
      if (searchText.length >= 2) {
        emit(LoadingState());
        final response = await ApiClient.projectSearch(query: searchText);
        if (response != null && response["status"] == "OK") {
          ProjectSearchResponse projectSearchResponse = ProjectSearchResponse.fromJson(response);
          emit(LoadedState(projects: projectSearchResponse.data ?? []));
        } else {
          emit(LoadedState(projects: []));
        }
      } else {
        emit(ClearState());
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void getPrjDetails({required String projectId}) async {
    try {
      emit(LoadingState());
      final response = await ApiClient.projectDetails(projectId: projectId);
      if (response != null) {
        PrjSearchDetails prjDetails = PrjSearchDetails.fromJson(response);
        emit(PrjDetailsState(prjDetails: prjDetails));
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  Future<void> openProjectImgUrl({required String projectId}) async {
    try {
      final url = "https://lfcommunity.ressex.com/ResidentialSurvey/ProjectPhotos.aspx?pid=$projectId";
      final Uri uri = Uri.parse(url);

      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }
}
