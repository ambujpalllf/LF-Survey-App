import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lf_survey/constants/utils.dart';
import 'package:lf_survey/cubit/pams_survey/ps_land_form/ps_land_form_state.dart';
import 'package:lf_survey/database/db_helper.dart';
import 'package:lf_survey/model/pams_survey/land_response.dart';
import 'package:lf_survey/services/work_manager_task_register.dart';
import 'package:location/location.dart';

class PsLandFormCubit extends Cubit<PsLandFormState> {
  PsLandFormCubit() : super(InitState());

  void getLands({required int projectId}) async {
    try {
      emit(LoadingState());
      final localData = await DBHelper.getPsLandInfo(projectId: projectId);
      if (localData.isNotEmpty) {
        emit(LoadedState(lands: localData));
        return;
      } else {
        emit(ErrorState(message: "Data not found"));
      }
      // final response = await ApiClient.psGetLands(projectId: projectId);
      // if (response != null && response["status"] == "OK") {
      //   final landResponse = PsLandResponse.fromJson(response);
      //   final landData = landResponse.data ?? [];
      //   if (landData.isEmpty) {
      //     emit(ErrorState(message: "No Data Found"));
      //     return;
      //   }
      //   for (final item in landData) {
      //     await DBHelper.insertPsLandInfo(landData: item);
      //   }
      //   emit(LoadedState(lands: landData));
      // } else {
      //   emit(ErrorState(message: response?["message"] ?? "Something went wrong"));
      // }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void getLocation({required BuildContext context}) async {
    try {
      final result = await Utils.checkLocationAndGpsPermission(context);
      if (result == true) {
        emit(LocaLoadingState());
        LocationData? locationData = await Utils.getCurrentLocation();
        if (locationData != null) {
          emit(LocLoadedState(location: locationData));
        }
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  bool validationFields({
    required int projetctId,
    required String eSite,
    // required String eDocument,
    // required String eRera,
    // required String eSiteBoundaries,
    required String wSite,
    // required String wDocument,
    // required String wRera,
    // required String wSiteBoundaries,
    required String nSite,
    // required String nDocument,
    // required String nRera,
    // required String nSiteBoundaries,
    required String sSite,
    // required String sDocument,
    // required String sRera,
    // required String sSiteBoundaries,
    // required String sesmicZone,
    // required String proneArea,
    // required String coastalRegZone,
    // required String zoningAPDevPlan,
    // required String faillingPresent,
    // required String within30FromRailway,
    // required String propertyNearHTLines,
    // required String presenceNallah,
    // required String fsiDeviation,
    // required String verticalDeviation,
    // required String unitDeviation,
    // required String habitation,
    // required String fallingReservationAPDev,
    // required String remarks,
  }) {
    final fields = [
      eSite,
      // eDocument,
      // eRera,
      // eSiteBoundaries,
      wSite,
      // wDocument,
      // wRera,
      // wSiteBoundaries,
      nSite,
      // nDocument,
      // nRera,
      // nSiteBoundaries,
      sSite,
      // sDocument,
      // sRera,
      // sSiteBoundaries,
      // sesmicZone,
      // proneArea,
      // coastalRegZone,
      // zoningAPDevPlan,
      // faillingPresent,
      // within30FromRailway,
      // propertyNearHTLines,
      // presenceNallah,
      // fsiDeviation,
      // verticalDeviation,
      // unitDeviation,
      // habitation,
      // fallingReservationAPDev,
      // remarks,
    ];

    // Check projectId if needed
    if (projetctId <= 0) {
      return false;
    }

    // Check empty strings
    for (final field in fields) {
      if (field.trim().isEmpty) {
        return false;
      }
    }

    return true;
  }

  void submitMethod({
    required int projectId,
    required String eSite,
    required double lat,
    required double lng,
    // required String eDocument,
    // required String eRera,
    // required String eSiteBoundaries,
    required String wSite,
    // required String wDocument,
    // required String wRera,
    // required String wSiteBoundaries,
    required String nSite,
    // required String nDocument,
    // required String nRera,
    // required String nSiteBoundaries,
    required String sSite,
    // required String sDocument,
    // required String sRera,
    // required String sSiteBoundaries,
    required String typeAccessRoad,
    required String widthAccessRoad,
    required String constructionStatus,
    required String materialStatus,
    required String labourStatus,
    required String bankName,
    required String loanBankName,
    // required String seismicZone,
    // required String proneArea,
    // required String coastalRegZone,
    // required String zoningAPDevPlan,
    // required String faillingPresent,
    // required String within30FromRailway,
    // required String propertyNearHTLines,
    // required String presenceNallah,
    // required String fsiDeviation,
    // required String verticalDeviation,
    // required String unitDeviation,
    // required String habitation,
    // required String fallingReservationAPDev,
    // required String remarks,
    required bool isUpdate,
    int projectLandId = 0,
    required int allocationId,
    required String visitCharges,
    required String revisitRemarks,
  }) async {
    try {
      emit(LoadingState());
      // if (!validationFields(
      //   projetctId: projectId,
      //   eSite: eSite,
      //   // eDocument: eDocument,
      //   // eRera: eRera,
      //   // eSiteBoundaries: eSiteBoundaries,
      //   wSite: wSite,
      //   // wDocument: wDocument,
      //   // wRera: wRera,
      //   // wSiteBoundaries: wSiteBoundaries,
      //   nSite: nSite,
      //   // nDocument: nDocument,
      //   // nRera: nRera,
      //   // nSiteBoundaries: nSiteBoundaries,
      //   sSite: sSite,
      //   // sDocument: sDocument,
      //   // sRera: sRera,
      //   // sSiteBoundaries: sSiteBoundaries,
      //   // sesmicZone: seismicZone,
      //   // proneArea: proneArea,
      //   // coastalRegZone: coastalRegZone,
      //   // zoningAPDevPlan: zoningAPDevPlan,
      //   // faillingPresent: faillingPresent,
      //   // within30FromRailway: within30FromRailway,
      //   // propertyNearHTLines: propertyNearHTLines,
      //   // presenceNallah: presenceNallah,
      //   // fsiDeviation: fsiDeviation,
      //   // verticalDeviation: verticalDeviation,
      //   // unitDeviation: unitDeviation,
      //   // habitation: habitation,
      //   // fallingReservationAPDev: fallingReservationAPDev,
      //   // remarks: remarks,
      // )) {
      //   emit(ErrorState(message: "Please fill all required fields"));
      //   return;
      // }

      PsLandDatum landDatum = PsLandDatum(
        projectId: projectId,
        lat: lat,
        lng: lng,
        projectLandId: projectLandId,
        eastAsPerSite: eSite,
        westAsPerSite: wSite,
        northAsPerSite: nSite,
        southAsPerSite: sSite,
        typeOfAccessRoad: typeAccessRoad,
        widthOfAccesssRoad: widthAccessRoad,
        constructionStatus: constructionStatus,
        constructionMaterialStatus: materialStatus,
        labourStatusonSite: labourStatus,
        projectCFByWhichBank: bankName,
        projectHomeloanAvailble: loanBankName,
        // criticalParametersSeismicZone: seismicZone,
        // criticalParametersFloodProneArea: proneArea,
        // criticalParametersCoastalRegulatoryZone: coastalRegZone,
        // criticalParametersZoningAsPerDevelopmentPlan: zoningAPDevPlan,
        // criticalParametersFallingInPresent: faillingPresent,
        // criticalParametersPropertyWithin30MFromRailway: within30FromRailway,
        // criticalParametersPropertyNearHtLtLines: propertyNearHTLines,
        // criticalParametersPresenceOfNallahWaterBodyNearby: presenceNallah,
        // criticalParametersFsiDeviation: fsiDeviation,
        // criticalParametersVerticalDeviation: verticalDeviation,
        // criticalParametersUnitDeviation: unitDeviation,
        // criticalParametersHabitation: habitation,
        // criticalParametersRemarks: remarks,
        // criticalParametersFallingInReservation: fallingReservationAPDev,
        allocationId: allocationId,
        visitCharges: visitCharges,
        revisitRemarks: revisitRemarks,
        localSync: 1,
        globalSync: 0,
      );
      isUpdate ? await DBHelper.updatePsLandInfo(landData: landDatum) : DBHelper.insertPsLandInfo(landData: landDatum);

      // isUpdate
      //     ? WorkManagerTaskRegister.syncUpdatePsPrjTechInfo(projectId: projectId)
      //     : WorkManagerTaskRegister.syncPsPrjTechInfo(projectId: projectId);
      WorkManagerTaskRegister.syncUpdatePsPrjTechInfo(projectId: projectId);
      emit(SucccessState(message: isUpdate ? "Changes saved successfully." : "Submission completed successfully."));
    } catch (e) {
      String erMsg = e.toString().split(":").last;
      emit(ErrorState(message: erMsg));
    }
  }
}
