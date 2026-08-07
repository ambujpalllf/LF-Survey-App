import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lf_survey/constants/storage_function.dart';
import 'package:lf_survey/constants/storage_key.dart';
import 'package:lf_survey/cubit/construction_monitering/cm_building/cm_building_state.dart';
import 'package:lf_survey/database/db_helper.dart';
import 'package:lf_survey/model/construction_monitoring/cm_building_response.dart';
import 'package:lf_survey/model/construction_monitoring/cm_wing_response.dart';
import 'package:lf_survey/services/api_client.dart';
import 'package:lf_survey/services/work_manager_task_register.dart';

class CmBuildingCubit extends Cubit<CmBuildingState> {
  CmBuildingCubit() : super(InitState());

  void getBuildings({required int projectId}) async {
    try {
      final response = await Future.wait([
        DBHelper.getCMAllBuildingByPrjId(projectId: projectId),
        DBHelper.getCMAllWingsByBuildingId(projectId: projectId),
      ]);
      if (response.isNotEmpty) {
        List<BuildingData> buildings = response[0] as List<BuildingData>;
        List<WingData> wings = response[1] as List<WingData>;
        emit(LoadedState(buildings: buildings, wings: wings));
      } else {
        emit(ErrorState(message: "No building records are available for this project."));
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void getWings({required int projectId}) async {
    try {
      final response = await DBHelper.getCMAllWingsByBuildingId(projectId: projectId);
      if (response.isNotEmpty) {
        emit(WingState(wings: response));
      } else {
        emit(ErrorState(message: "No wing records are available for this project."));
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void addBuilding({required int projectId, required String buildingName}) async {
    try {
      int? userId = await StorageFunction.readIntData(StorageKey.userId);
      DateTime now = DateTime.now();
      BuildingData bData = BuildingData(
        projectId: projectId,
        buildingName: buildingName,
        createdBuildingId: "${userId}_${now.millisecondsSinceEpoch}",
        sync: 0,
      );
      final response = await DBHelper.cmInsertBuilding(building: bData);
      if (response > 0) {
        getBuildings(projectId: projectId);
        WorkManagerTaskRegister.syncCmAddBuilding(projectId: projectId, buildingName: buildingName);
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void delete({int? buildingId, required int index, required int id}) async {
    try {
      if (buildingId != 0 && buildingId != null) {
        final response = await ApiClient.cmDeleteBuilding(buildingId: buildingId);
        if (response != null) {
          await DBHelper.cmDeleteBuilding(id: id);
          emit(DeleteState(index: index));
        }
      } else {
        await DBHelper.cmDeleteBuilding(id: id);
        emit(DeleteState(index: index));
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void addWing({
    required int projectId,
    int? buildingId,
    required String createdBuildingId,
    required String wingName,
  }) async {
    try {
      int? userId = await StorageFunction.readIntData(StorageKey.userId);
      DateTime now = DateTime.now();
      WingData wingData = WingData(
        projectId: projectId,
        buildingId: buildingId,
        wingName: wingName,
        createdBuildingId: createdBuildingId,
        createdWingId: "${userId}_${now.millisecondsSinceEpoch}",
      );
      final response = await DBHelper.cmInsertWing(wing: wingData);
      if (response > 0) {
        getWings(projectId: projectId);
        WorkManagerTaskRegister.syncCmAddWing(
          projectId: projectId,
          buildingId: buildingId,
          createdBuildingId: createdBuildingId,
          wingName: wingName,
        );
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }
}
