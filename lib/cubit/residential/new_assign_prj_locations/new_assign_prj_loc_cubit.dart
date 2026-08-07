import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lf_survey/cubit/residential/new_assign_prj_locations/new_assign_prj_loc_state.dart';
import 'package:lf_survey/database/db_helper.dart';
import 'package:lf_survey/model/db_model/residential/project_entity.dart';

class NewAssignPrjLocCubit extends Cubit<NewAssignPrjLocState> {
  NewAssignPrjLocCubit() : super(InitState());

  Future<void> getProject() async {
    try {
      emit(LoadingState());
      final response = await DBHelper.getProjects();
      if (response.isNotEmpty) {
        final projects = response.map((e) => ProjectEntity.fromJson(e)).where((e) => e.assignedNewPrj == 1).toList();
        // List<Map<String, dynamic>> locations = projects
        //     .map((e) => {"locationId": e.locationId, "title": e.locationName, "isSelected": false})
        //     .toList();
        final seen = <int>{};

        // List<Map<String, dynamic>> locations = projects
        //     .where((e) => seen.add(e.locationId!))
        //     .map((e) => {"locationId": e.locationId, "title": e.locationName, "isSelected": false})
        //     .toList();
        List<Map<String, dynamic>> locations = projects
            .where((e) => seen.add(e.cityId!))
            .map((e) => {"cityId": e.cityId, "cityName": e.cityName, "isSelected": false})
            .toList();
        emit(LocalDbState(locations: locations));
      } else {
        emit(LocalDbState(locations: [])); // handle empty case
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void searchItem({required List<Map<String, dynamic>> locations, required String query}) {
    try {
      if (query.trim().isEmpty) {
        emit(SearchedState(locations: locations));
        return;
      }

      final lowerQuery = query.toLowerCase();

      final filteredLocations = locations.where((location) {
        return location.values.any((value) {
          if (value == null) return false;
          return value.toString().toLowerCase().contains(lowerQuery);
        });
      }).toList();

      emit(SearchedState(locations: filteredLocations));
    } catch (e) {
      emit(ErrorState(message: 'Search failed: ${e.toString()}'));
    }
  }

  void toggleItemSelection({required List<Map<String, dynamic>> locations, required int index}) {
    try {
      final updatedList = List<Map<String, dynamic>>.from(locations);

      updatedList[index]["isSelected"] = !(updatedList[index]["isSelected"] ?? false);

      emit(SearchedState(locations: updatedList));
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void toggleSelectAll({required List<Map<String, dynamic>> locations, required bool isSelected}) {
    try {
      final updatedList = locations.map((item) {
        return {...item, "isSelected": isSelected};
      }).toList();

      emit(SearchedState(locations: updatedList));
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }
}
