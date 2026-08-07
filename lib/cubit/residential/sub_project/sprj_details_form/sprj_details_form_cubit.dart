import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lf_survey/constants/utils.dart';
import 'package:lf_survey/cubit/residential/sub_project/sprj_details_form/sprj_details_form_state.dart';
import 'package:lf_survey/database/db_helper.dart';
import 'package:lf_survey/model/db_model/residential/flat_entity.dart';
import 'package:lf_survey/model/db_model/residential/sub_prj_entity.dart';
import 'package:lf_survey/model/residential/project_spinner.dart';
import 'package:lf_survey/services/work_manager_task_register.dart';

class SPrjDetailsFormCubit extends Cubit<SPrjDetailsFormState> {
  SPrjDetailsFormCubit() : super(InitState());
  List<FlatEntity> flatList = [];

  void fetchData({required int subProjectId, required int projectId}) async {
    try {
      final results = await Future.wait([
        DBHelper.getConstProgress(),
        DBHelper.getProjectStatus(),
        DBHelper.getBookingStopRemarks(),
        DBHelper.getSubProjectDeleteRemarks(),
        DBHelper.getSprjEntity(projectId: projectId, subPrjId: subProjectId),
        DBHelper.getFlats(projectId: projectId, subProjectId: subProjectId),
      ]);
      final List constProgressResponse = results[0] as List;
      final List projectStatusResponse = results[1] as List;
      final List bookingStopResponse = results[2] as List;
      final List deleteRemarkResponse = results[3] as List;
      final subProjectResponse = results[4] as Map<String, dynamic>;
      final flatResponse = results[5] as List<Map<String, dynamic>>;
      List<ConstProgressList> constProgress = constProgressResponse.map((e) => ConstProgressList.fromJson(e)).toList();
      List<ProjectStatusList> projectStatus = projectStatusResponse.map((e) => ProjectStatusList.fromJson(e)).toList();
      List<RemarksList> bookingStopRemarks = bookingStopResponse.map((e) => RemarksList.fromJson(e)).toList();
      List<RemarksList> subProjectDeleteRemarks = deleteRemarkResponse.map((e) => RemarksList.fromJson(e)).toList();
      SubProjectEntity subProjectsDatum = SubProjectEntity.fromJson(subProjectResponse);
      flatList.clear();
      flatList = flatResponse.map((e) => FlatEntity.fromJson(e)).toList();
      emit(
        LocalDbState(
          constProgress: constProgress,
          projectStatus: projectStatus,
          bookingStopRemarks: bookingStopRemarks,
          subProjectDeleteRemarks: subProjectDeleteRemarks,
          subProjectsDatum: subProjectsDatum,
        ),
      );
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  bool validationFields({
    // required SubProjectsDatum subProjectData,
    required SubProjectEntity subProjectData,
    required String storey,
    required String scr,
    String saleableRatePSF = "",
    String carpetRatePSF = "",
    Map<String, dynamic>? constProgress,
    String endDate = "",
    String floorSlab = "",
    bool isBooking = false,
    bool isDeleteSubProject = false,
    List selectedBookingRemarks = const [],
    List selectedDeleteRemarks = const [],
  }) {
    String scrMsg = "";
    String errorMsg = "";
    int? storeyValue;
    if (storey.isNotEmpty) {
      storeyValue = int.parse(storey);
    }
    // check flat value is update or not
    if (subProjectData.syncGlobalStatus == 1) {
      errorMsg = "You can not edit the project now";
    } else if (flatList.isNotEmpty) {
      int allFlatSize = flatList.length;
      int filledFlatSize = 0;
      for (var item in flatList) {
        if (item.dataFilled == 1) {
          filledFlatSize++;
        }
      }

      if (filledFlatSize < allFlatSize) {
        errorMsg = "Please save Flat Data first.";
      } else {
        // scr validation
        if (scr.isEmpty) {
          scrMsg = "SCR cannot be empty";
        } else {
          int? scrVal = int.tryParse(scr);

          if (scrVal == null) {
            scrMsg = "Invalid SCR value";
          } else if (scrVal == 0) {
            scrMsg = "SCR cannot be 0";
          } else if (scrVal < 10 && subProjectData.flatgroupid != 13) {
            scrMsg = "SCR cannot be < 10";
            // for open plots
          } else if (scrVal > 20 && subProjectData.flatgroupid == 13) {
            scrMsg = "SCR cannot be > 20 for open plots";
          } else if (scrVal > 50) {
            scrMsg = "SCR cannot be > 50";
          }
        }

        // saleable and carpet vlidation
        bool isSaleable = subProjectData.rateType?.toLowerCase() == "saleable";
        if (isSaleable == false) {
          if (carpetRatePSF.isEmpty || carpetRatePSF == "0") {
            errorMsg = "Please enter Correct Carpet Rate PSF";
          }
        } else {
          if (saleableRatePSF.isEmpty || saleableRatePSF == "0") {
            errorMsg = "Please enter Correct Saleable Rate PSF";
          }
        }

        // end date validation
        if (constProgress != null) {
          String constStatus = constProgress["title"];
          if (endDate.isNotEmpty) {
            DateTime? end = Utils.tryParseDate(endDate);
            // DateTime? dosDate = tryParseDate(dos);
            DateTime? dosDate = Utils.tryParseDate(subProjectData.dos.toString());
            if (end != null && dosDate != null) {
              if (constStatus.toLowerCase() == "complete" && end.isAfter(dosDate)) {
                errorMsg = "End Date cannot be after DOS when project is Complete.";
              } else if (constStatus.toLowerCase() == "not started") {
                DateTime limit = subProjectData.subProjectName!.toLowerCase().contains("plot")
                    ? DateTime(dosDate.year, dosDate.month + 5, dosDate.day)
                    : DateTime(dosDate.year + 1, dosDate.month, dosDate.day);

                if (end.isBefore(limit)) {
                  errorMsg = "End Date cannot be current Date or previous Date, as Construction is Not Started.";
                }
              } else if (constStatus.toLowerCase() == "external work") {
                DateTime limit = DateTime(dosDate.year, dosDate.month + 1, dosDate.day);
                if (end.isBefore(limit)) {
                  errorMsg = "End Date should be at least one Month more than current DOS for External Work stage.";
                }
              }
            }
          } else {
            errorMsg = "End date cannot be empty";
          }
          // validation for floor slab
          if (constStatus.toLowerCase() == "floor slab") {
            if (floorSlab.isEmpty || int.tryParse(floorSlab) == null || int.parse(floorSlab) < 1) {
              errorMsg = "Floor slab can't be empty or zero when Construction Status is Floor Slab";
            }
            // else if (floorSlab.isNotEmpty &&
            //     int.tryParse(floorSlab) != null &&
            //     int.parse(floorSlab) > subProjectData.storey!) {
            //   errorMsg = "No. of Floor Slab cannot be greater than No. of Storey.";
            // }
            else if (floorSlab.isNotEmpty && int.tryParse(floorSlab) != null && int.parse(floorSlab) > storeyValue!) {
              errorMsg = "No. of Floor Slab cannot be greater than No. of Storey.";
            }
          }
        } else {
          errorMsg = "Please select Construction Status value from dropdown";
        }

        // BOOKING STOP VALIDATION
        if (isBooking == true) {
          if (subProjectData.flatSoldCount == 0) {
            if (selectedBookingRemarks.isEmpty) {
              errorMsg = "Please select booking remark";
            }
          } else {
            errorMsg = "Booking Stop cannot happen, as you have changed flat sold.";
          }
        }

        // DELETE VALIDATION
        if (isDeleteSubProject == true) {
          if (selectedDeleteRemarks.isEmpty) {
            errorMsg = "Please select delete remark";
          }
        }
      }
    }

    emit(ErrorState(message: errorMsg, scrMsg: scrMsg));
    return errorMsg.isEmpty && scrMsg.isEmpty;
  }

  void updateSubProject({
    required SubProjectEntity subProjectData,
    required String storey,
    required String flatsPerFloor,
    required String scr,
    required bool isSaleable,
    required String saleableRatePSF,
    required String carpetRatePSF,
    // required String startingDate,
    required String endDate,
    required int constructionProgressId,
    required ProjectStatusList projectStatus,
    required String floorSlab,
    required String remark,
    required String maintenancePerSqft,
    required String stiltParking,
    required String openParking,
    required String podiumParking,
    required String doublePodiumParking,
    required String basementParking,
    required bool isBooking,
    required List bookingRemark,
    required String floorRise,
    required bool isDeleteSubProject,
    required List deleteRemark,
    required String percVilaStarted,
    required String percVilaPiling,
    required String percVilaPlinth,
    required String percVilaFloorslab,
    required String percVilaInternalWork,
    required String percVilaExternal,
    required String percVilaComplete,
  }) async {
    try {
      emit(LoadingState());
      String combinedRemark = [
        if (remark.isNotEmpty) remark,
        ...deleteRemark.map(
          (e) => e["title"] == "Other"
              ? "${e["title"]}: ${e["message"]}" // include message for "Other"
              : e["title"],
        ),
        ...bookingRemark.map((e) => e["title"]),
      ].join(",");
      subProjectData.storey = int.tryParse(storey);
      subProjectData.flatsPerFloor = int.tryParse(flatsPerFloor);
      subProjectData.scr = int.tryParse(scr);
      // subProjectData.rateType = isSaleable?"Saleable":"Carpet";
      subProjectData.saleableRatepsf = int.tryParse(saleableRatePSF);
      subProjectData.carpetRatepsf = int.tryParse(carpetRatePSF);
      // subProjectData.startDate = DateFormat("yyyy-MM-dd").parse(startingDate);
      DateTime parsedDate = Utils.tryParseDate(endDate)!;
      subProjectData.endDate = DateTime(parsedDate.year, parsedDate.month, parsedDate.day, 0, 0, 0).toIso8601String();
      subProjectData.constructionProgressId = constructionProgressId;
      subProjectData.projectStatusId = projectStatus.projectStatusId;
      subProjectData.floorSlab = int.tryParse(floorSlab);
      subProjectData.remarks = combinedRemark;
      subProjectData.maintenancePersqft = double.tryParse(maintenancePerSqft);
      subProjectData.stiltPark = maintenancePerSqft;
      subProjectData.openPark = openParking;
      subProjectData.podium = podiumParking;
      subProjectData.doublePodium = doublePodiumParking;
      subProjectData.basementPark = basementParking;
      subProjectData.bookingStop = isBooking == true ? 1 : 0;
      subProjectData.floorRise = int.tryParse(floorRise);
      subProjectData.deleteFlag = isDeleteSubProject == true ? 1 : 0;
      // subProjectData.syncStatus = 1;
      subProjectData.syncLocalStatus = 1;
      if (subProjectData.hasVillas == 1) {
        subProjectData.percVilaStarted = percVilaStarted;
        subProjectData.percVilaPiling = percVilaPiling;
        subProjectData.percVilaPlinth = percVilaPlinth;
        subProjectData.percVilaFloorslab = percVilaFloorslab;
        subProjectData.percVilaInternalWork = percVilaInternalWork;
        subProjectData.percVilaExternal = percVilaExternal;
        subProjectData.percVilaComplete = percVilaComplete;
      }
      final surveDate = DateTime.now();
      subProjectData.surveyDate = DateTime(
        surveDate.year,
        surveDate.month,
        surveDate.day,
        surveDate.hour,
        surveDate.minute,
        surveDate.second,
      ).toIso8601String();
      // await ApiClient.saveSubPrj(subProjects: [subProjectData]);
      final flatResponse = await DBHelper.getFlats(
        projectId: subProjectData.projectId!,
        subProjectId: subProjectData.subProjectId!,
      );

      if (flatResponse.isNotEmpty) {
        final flatData = flatResponse.map((e) => FlatEntity.fromJson(e)).toList();

        for (final item in flatData) {
          if (item.dataFilled == 0) {
            emit(ErrorState(message: "Please fill all flats data before sync."));
            return;
          }
        }
      }

      final response = await DBHelper.updateSprjEntity(subProjectData);
      WorkManagerTaskRegister.updateSubProject(subProjects: [subProjectData]);
      if (response > 0) {
        emit(SuccessState(message: "Sub project updated successfully"));
      } else {
        emit(ErrorState(message: "Something went wrong"));
      }
    } catch (e) {
      String erMsg = e.toString().split(":").last;
      emit(ErrorState(message: erMsg));
    }
  }
}
