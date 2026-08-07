import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lf_survey/cubit/commercial/c_project_edit/c_project_edit_state.dart';
import 'package:lf_survey/database/db_helper.dart';
import 'package:lf_survey/model/db_model/commercial/c_project_entity.dart';
import 'package:lf_survey/services/work_manager_task_register.dart';

class CProjectEditCubit extends Cubit<CProjectEditState> {
  CProjectEditCubit() : super(InitState());

  void fetchData() async {
    try {
      final response = await Future.wait([DBHelper.cGetArea(), DBHelper.cGetTenantMixEntity()]);
      if (response.isNotEmpty) {
        emit(LocalDbState(areaUnit: response[0], tenant: response[1]));
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void updateProject({
    required CProjectEntity projectData,
    String? reraNo,
    String? openParking,
    String? stackedParking,
    String? stiltParking,
    String? basementParking,
    String? podiumParking,
    String? parkingRatio,
    String? scr,
    String? maintenance,
    String? propertyTax,
    int? selectedAreaUnitId,
    String? landParcelSize,
    int? tenantId,
  }) async {
    try {
      emit(LoadingState());
      int? parseInt(String? value) {
        if (value == null || value.trim().isEmpty) return null;
        return int.tryParse(value.trim());
      }

      double? parseDouble(String? value) {
        if (value == null || value.trim().isEmpty) return null;
        return double.tryParse(value.trim());
      }

      projectData.rerano = reraNo;
      projectData.parkingOpen = parseInt(openParking);
      projectData.parkingStacked = parseInt(stackedParking);
      projectData.parkingStilt = parseInt(stiltParking);
      projectData.parkingBasement = parseInt(basementParking);
      projectData.parkingPodium = parseInt(podiumParking);
      projectData.parkingRatio = parseDouble(parkingRatio);
      projectData.scr = parseDouble(scr);
      projectData.maintenancePerSqft = parseDouble(maintenance);
      projectData.propertyTax = parseInt(propertyTax);
      projectData.landParcelSizeUnit = selectedAreaUnitId;
      projectData.landParcelSize = parseDouble(landParcelSize);
      projectData.tenantMixId = tenantId;
      projectData.syncLocalStatus = 1;
      projectData.syncGlobalStatus = 0;
      final response = await DBHelper.cUpdateProject(project: projectData);
      if (response > 0) {
        // This sync only particular project when provide project id
        // WorkManagerTaskRegister.cSyncUpdateProject(projectId: projectData.projectId ?? 0);
        // It is sync all unsync project when provide project id 0
        WorkManagerTaskRegister.cSyncUpdateProject(projectId: 0);
        emit(SuccessState(message: "Your data has been saved successfully."));
      } else {
        emit(InitState());
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }
}
