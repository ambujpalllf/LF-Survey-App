import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lf_survey/cubit/commercial/c_project_details/c_project_details_state.dart';
import 'package:url_launcher/url_launcher.dart';

class CProjectDetailsCubit extends Cubit<CProjectDetailsState> {
  CProjectDetailsCubit() : super(InitState());
  Future<void> openGoogleMapsDirection(double lat, double lng, String projectName) async {
    try {
      if (lat == 0.0 || lng == 0.0) {
        emit(
          ErrorState(message: "Location is not available for this project. Please try again later or contact support."),
        );
        return;
      }

      final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&destination_place_id=$projectName';
      final Uri uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        emit(ErrorState(message: "Unable to open Google Maps at the moment. Please check your device settings."));
      }
    } catch (e) {
      String erMsg = e.toString().split(":").last;
      emit(ErrorState(message: erMsg));
    }
  }
}
