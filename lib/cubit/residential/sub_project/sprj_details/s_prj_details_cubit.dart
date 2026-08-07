import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lf_survey/cubit/residential/sub_project/sprj_details/s_prj_details_state.dart';
import 'package:lf_survey/database/db_helper.dart';
import 'package:lf_survey/model/db_model/residential/sub_prj_entity.dart';
import 'package:lf_survey/model/residential/project_spinner.dart';

class SPrjDetailsCubit extends Cubit<SPrjDetailsState> {
  SPrjDetailsCubit() : super(InitState());

  void fetchCity({required int projectId, required int subPrjId}) async {
    try {
      final results = await Future.wait([
        DBHelper.getCity(),
        DBHelper.getSprjEntity(projectId: projectId, subPrjId: subPrjId),
      ]);

      // Extract results safely
      final List<Map<String, dynamic>> cityResponse = results[0] as List<Map<String, dynamic>>;

      final Map<String, dynamic>? subProjectResponse = results[1] as Map<String, dynamic>?;

      // Convert city list
      final List<CityList> cityData = cityResponse.map((e) => CityList.fromJson(e)).toList();

      // Convert sub project (if exists)
      final SubProjectEntity? subProjectData = subProjectResponse != null
          ? SubProjectEntity.fromJson(subProjectResponse)
          : null;
      if (cityData.isNotEmpty && subProjectData != null) {
        emit(LocalDbState(cityData: cityData, subProjectData: subProjectData));
      } else {
        emit(ErrorState(message: "Something went wrong"));
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  // void updateSubProject({required SubProjectsDatum subProjectData, required String reraType}) async {
  //   try {
  //     subProjectData.rateType = reraType;
  //     final response = await DBHelper.updateSubProject(subProjectData);
  //     if (response > 0) {
  //       await DBHelper.insertSPrjFreezeType(sPrjId: subProjectData.subProjectId!, areaTypeFreeze: 1);
  //       emit(SuccessState(message: "Data Saved successful"));
  //     } else {
  //       emit(ErrorState(message: "Something went wrong"));
  //     }
  //   } catch (e) {
  //     emit(ErrorState(message: e.toString()));
  //   }
  // }

  void updateSubProject({required SubProjectEntity subProjectsDatum}) async {
    try {
      final response = await DBHelper.updateSprjEntity(subProjectsDatum);
      if (response > 0) {
        emit(SuccessState(message: "Data Saved successfully"));
      } else {
        emit(ErrorState(message: "Something went wrong"));
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }
}
