import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lf_survey/cubit/residential/new_prj_details/new_prj_details_state.dart';
import 'package:lf_survey/database/db_helper.dart';
import 'package:lf_survey/model/residential/project_spinner.dart';

class NewPrjDetailsCubit extends Cubit<NewPrjDetailsState> {
  NewPrjDetailsCubit() : super(InitState());
  void fetchData() async {
    try {
      final cityRes = await DBHelper.getCity();
      if (cityRes.isNotEmpty) {
        List<CityList> cities = cityRes.map((e) => CityList.fromJson(e)).toList();
        emit(LocalDbState(city: cities));
      }
    } catch (e) {
      String erStr = e.toString().split(":").last;
      emit(ErrorState(message: erStr));
    }
  }
}
