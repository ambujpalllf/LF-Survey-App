import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lf_survey/constants/storage_function.dart';
import 'package:lf_survey/constants/storage_key.dart';
import 'package:lf_survey/cubit/residential/sub_project/add_sprj_form/add_sprj_form_state.dart';
import 'package:lf_survey/database/db_helper.dart';
import 'package:lf_survey/model/db_model/residential/new_sub_project_entity.dart';
import 'package:lf_survey/model/residential/project_spinner.dart';
import 'package:lf_survey/model/residential/user_response.dart';

class AddNewSprjCubit extends Cubit<AddNewSprjFormState> {
  AddNewSprjCubit() : super(InitState());

  void fetchUserData() async {
    try {
      final userData = await StorageFunction.readStringData(StorageKey.userData);
      if (userData != null) {
        UserData user = UserData.fromJson(jsonDecode(userData));
        final decodedList = jsonDecode(user.jsonstr ?? "");
        final List<Map<String, dynamic>> prjEntryData = decodedList.cast<Map<String, dynamic>>();
        if (prjEntryData.isNotEmpty) {
          emit(
            UserDataState(
              qtrId: prjEntryData.first["NEW_PRJ_ENTRY_QTR_ID"],
              qtr: prjEntryData.first["NEW_PRJ_ENTRY_QTR"],
            ),
          );
        }
      }
    } catch (e) {
      String erStr = e.toString().split(":").last;
      emit(ErrorState(message: erStr));
    }
  }

  void fetchData() async {
    try {
      final response = await Future.wait([
        DBHelper.getConstProgress(),
        DBHelper.getProjectStatus(),
        DBHelper.getCity(),
      ]);
      final constProgressResp = response[0];
      final prjStatusResp = response[1];
      final cityResp = response[2];
      if (constProgressResp.isNotEmpty && prjStatusResp.isNotEmpty && cityResp.isNotEmpty) {
        List<ConstProgressList> constProgress = constProgressResp.map((e) => ConstProgressList.fromJson(e)).toList();
        List<CityList> cityList = cityResp.map((e) => CityList.fromJson(e)).toList();
        List<ProjectStatusList> prjStatus = prjStatusResp.map((e) => ProjectStatusList.fromJson(e)).toList();
        emit(LocalState(constProgress: constProgress, prjStatus: prjStatus, cities: cityList));
      } else {
        emit(ErrorState(message: "Something went wrong during fetch data from local db."));
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void selectDate({required DateTime selectDate}) {
    emit(SelectDateState(selectedDate: selectDate));
  }

  bool validateSubProject({
    required String subProjectName,
    Map<String, dynamic>? flatGroup,
    required int flatGroupId,
    required String storey,
    required String scr,
    required String maintenance,
    required String flats,
    required String priceType,
    required bool isSaleable,
    required String saleableLaunchPrice,
    required String carpetLaunchPrice,
    required String floorRise,
    required String launchDate,
    required String endDate,
    Map<String, dynamic>? constructionProgress,
    required String selectedConstProgress,
    required int selectedConstProgressId,
    required String stiltParking,
    required String openParking,
    required String podiumParking,
    required String doublePodiumParking,
    required String basementParking,
    required String remark,
    required bool isFloorSlab,
    required String floorSlab,
    required DateTime dos, // DOS from preference
  }) {
    // Validate dropdown maps
    if (!_validateMap(flatGroup, "flat group")) return false;
    if (!_validateMap(constructionProgress, "construction progress")) return false;

    // Validate required fields
    final fields = {
      "sub project name": subProjectName,
      "storey": storey,
      "scr": scr,
      "maintenance": maintenance,
      "flats": flats,
      // "saleable launch price": saleableLaunchPrice,
      // "carpet launch price": carpetLaunchPrice,
      "floor rise": floorRise,
      "launch date": launchDate,
      "end date": endDate,
      "stilt parking": stiltParking,
      "open parking": openParking,
      "podium parking": podiumParking,
      "double podium parking": doublePodiumParking,
      "basement parking": basementParking,
      "remark": remark,
    };

    for (var entry in fields.entries) {
      if (entry.value.trim().isEmpty) {
        emit(ErrorState(message: "Please fill all fields."));
        // emit(ErrorState(message: "Please fill ${entry.key}"));
        return false;
      }
    }

    // Saleable or Carpet Launch Price Validation
    if (isSaleable) {
      // Validate SALEABLE price
      if (saleableLaunchPrice.trim().isEmpty) {
        emit(ErrorState(message: "Please enter saleable launch price"));
        return false;
      }

      if (double.tryParse(saleableLaunchPrice) == null) {
        emit(ErrorState(message: "Invalid saleable launch price"));
        return false;
      }
    } else {
      // Validate CARPET price
      if (carpetLaunchPrice.trim().isEmpty) {
        emit(ErrorState(message: "Please enter carpet launch price"));
        return false;
      }

      if (double.tryParse(carpetLaunchPrice) == null) {
        emit(ErrorState(message: "Invalid carpet launch price"));
        return false;
      }
    }

    // Floor Slab validation (if enabled)
    if (isFloorSlab) {
      if (floorSlab.trim().isEmpty || int.tryParse(floorSlab) == null) {
        emit(ErrorState(message: "Floor slab can't be empty or invalid"));
        return false;
      }
    }

    // Convert numeric values
    final int? storeyVal = int.tryParse(storey);
    final int? scrVal = int.tryParse(scr);
    final int? floorSlabVal = int.tryParse(floorSlab);

    // Construction Progress validation
    if (selectedConstProgress.toLowerCase().contains("select")) {
      emit(ErrorState(message: "Please select construction progress"));
      return false;
    }

    // Floor slab rules
    if (selectedConstProgress.toLowerCase().contains("floor slab")) {
      if (storeyVal == 0) {
        emit(ErrorState(message: "Storey cannot be 0 when Construction Progress is Floor Slab"));
        return false;
      }
      if (floorSlabVal == null || floorSlabVal < 1) {
        emit(ErrorState(message: "Floor slab can't be empty or zero when construction progress is Floor Slab"));
        return false;
      }
      if (floorSlabVal > storeyVal!) {
        emit(ErrorState(message: "Floor Slab construction cannot be greater than Storey"));
        return false;
      }
    }

    // SCR validation (PLAIN + PLOT rules)

    if (scrVal == null) {
      emit(ErrorState(message: "Invalid SCR value"));
      return false;
    }

    if (scrVal == 0) {
      emit(ErrorState(message: "SCR cannot be 0"));
      return false;
    }

    if (flatGroupId == 3) {
      // Open Plots
      if (scrVal < 1 || scrVal > 20) {
        emit(ErrorState(message: "SCR range for Open Plots is 1 - 20"));
        return false;
      }
    } else {
      // Normal
      if (scrVal < 10 || scrVal > 50) {
        emit(ErrorState(message: "SCR range is 10 - 50"));
        return false;
      }
    }

    // Date Validation (End Date vs DOS + Progress Rules)
    try {
      // final sdf = DateFormat("dd MMM yyyy");
      // final dosSdf = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
      final DateTime parsedEndDate = DateFormat("dd-MMM-yyyy").parse(endDate);
      final DateTime parsedDos = dos;
      // final DateTime parsedDos = DateFormat("yyyy-MM-dd HH:mm:ss").parse(dos.toString());
      // final now = DateTime.now();

      // Rule: EndDate before DOS & not completed
      if (parsedEndDate.isBefore(parsedDos) && !selectedConstProgress.toLowerCase().contains("complete")) {
        emit(ErrorState(message: "End date cannot be before DOS unless status is Complete"));
        return false;
      }

      // Rule: EndDate after DOS but marked Complete
      if (parsedEndDate.isAfter(parsedDos) && selectedConstProgress.toLowerCase().contains("complete")) {
        emit(ErrorState(message: "Completed projects cannot have End Date after DOS"));
        return false;
      }

      // NOT STARTED rule
      if (selectedConstProgress.toLowerCase() == "not started") {
        DateTime minEndDate;
        if (flatGroupId == 3) {
          minEndDate = parsedDos.add(const Duration(days: 150)); // 5 months
        } else {
          minEndDate = DateTime(parsedDos.year + 1, parsedDos.month, parsedDos.day);
        }

        if (parsedEndDate.isBefore(minEndDate)) {
          emit(
            ErrorState(
              message: "End Date must be at least next year (or +5 months for plots) when Construction is Not Started",
            ),
          );
          return false;
        }
      }

      // EXTERNAL_WORK rule
      if (selectedConstProgress.toLowerCase() == "external work") {
        final minEnd = parsedDos.add(const Duration(days: 30));

        if (parsedEndDate.isBefore(minEnd)) {
          emit(ErrorState(message: "End Date should be at least 1 month more than DOS for External Work"));
          return false;
        }
      }
    } catch (e) {
      emit(ErrorState(message: "Invalid date format"));
      return false;
    }

    return true;
  }

  bool validateFields({
    required String subProjectName,
    Map<String, dynamic>? flatGroup,
    required int flatGroupId,
    required String storey,
    required String scr,
    required String maintenance,
    required String flats,
    required String priceType,
    required bool isSaleable,
    required String saleableLaunchPrice,
    required String carpetLaunchPrice,
    required String floorRise,
    required String launchDate,
    required String endDate,
    Map<String, dynamic>? constructionProgress,
    required String selectedConstProgress,
    required int selectedConstProgressId,
    required String remark,
    required bool isFloorSlab,
    required String floorSlab,
    required DateTime dos,
  }) {
    final Map<String, String> errors = {};
    // Validate dropdown maps
    if (flatGroup == null) {
      errors["flatGroup"] = "Please select flat group";
    }

    if (constructionProgress == null) {
      errors["constructionProgress"] = "Please select construction progress";
    }

    // Validate required fields
    final fields = {
      "subPrjName": subProjectName,
      "storey": storey,
      "scr": scr,
      "maintenance": maintenance,
      "flats": flats,
      "floorrise": floorRise,
      "launchdate": launchDate,
      "endDate": endDate,
      "remark": remark,
    };
    bool isEmpty(String val) => val.trim().isEmpty;
    fields.forEach((key, value) {
      if (isEmpty(value)) {
        errors[key] = "This field is required";
      }
    });

    // Saleable or Carpet Launch Price Validation
    if (isSaleable) {
      // Validate Saleable Price
      if (isEmpty(saleableLaunchPrice)) {
        errors["saleableLaunchPrice"] = "Enter saleable launch price";
      } else if (double.tryParse(saleableLaunchPrice) == null) {
        errors["saleableLaunchPrice"] = "Invalid saleable launch price";
      }
    } else {
      // Validate CARPET Price
      if (isEmpty(carpetLaunchPrice)) {
        errors["carpetLaunchPrice"] = "Enter carpet launch price";
      } else if (double.tryParse(carpetLaunchPrice) == null) {
        errors["carpetLaunchPrice"] = "Invalid carpet launch price";
      }
    }

    // Floor Slab validation (if enabled)

    if (isFloorSlab) {
      if (isEmpty(floorSlab) || int.tryParse(floorSlab) == null) {
        errors["floorSlab"] = "Floor slab can't be empty or invalid";
      }
    }
    // Convert numeric values
    final int? storeyVal = int.tryParse(storey);
    final int? scrVal = int.tryParse(scr);
    final int? floorSlabVal = int.tryParse(floorSlab);

    // Construction Progress validation
    if (selectedConstProgress.toLowerCase().contains("select")) {
      errors["constructionProgress"] = "Please select construction progress";
    }

    // Floor slab rules

    if (selectedConstProgress.toLowerCase().contains("floor slab")) {
      if (storeyVal == 0) {
        errors["storey"] = "Storey cannot be 0 when Construction Progress is Floor Slab";
      }
      if (floorSlabVal == null || floorSlabVal < 1) {
        errors["floorSlab"] = "Floor slab can't be empty or zero when construction progress is Floor Slab";
      }
      if (storeyVal != null && floorSlabVal != null && floorSlabVal > storeyVal) {
        errors["floorSlab"] = "Floor Slab construction cannot be greater than Storey";
      }
    }

    // SCR validation (PLAIN + PLOT rules)
    if (scrVal == null) {
      errors["scr"] = "Invalid SCR value";
    } else {
      if (scrVal == 0) {
        errors["scr"] = "SCR cannot be 0";
      } else if (flatGroupId == 3) {
        // Open Plots
        if (scrVal < 1 || scrVal > 20) {
          errors["scr"] = "SCR range for Open Plots is 1 - 20";
        }
      } else {
        // Normal
        if (scrVal < 10 || scrVal > 50) {
          errors["scr"] = "SCR range is 10 - 50";
        }
      }
    }

    // Date Validation (End Date vs DOS + Progress Rules)
    try {
      final parsedEndDate = DateFormat("dd-MMM-yyyy").parse(endDate);
      final parsedDos = dos;
      // Rule: EndDate after DOS but marked Complete
      if (parsedEndDate.isBefore(parsedDos) && !selectedConstProgress.toLowerCase().contains("complete")) {
        errors["endDate"] = "End date cannot be before DOS unless status is Complete";
      }
      // Rule: EndDate after DOS but marked Complete
      if (parsedEndDate.isAfter(parsedDos) && selectedConstProgress.toLowerCase().contains("complete")) {
        errors["endDate"] = "Completed projects cannot have End Date after DOS";
      }

      // NOT STARTED rule
      if (selectedConstProgress.toLowerCase() == "not started") {
        DateTime minEndDate = flatGroupId == 3
            ? parsedDos.add(const Duration(days: 90))
            : DateTime(parsedDos.year + 1, parsedDos.month, parsedDos.day);

        if (parsedEndDate.isBefore(minEndDate)) {
          errors["endDate"] =
              "End Date must be at least next year (or +5 months for plots) when Construction is Not Started";
        }
      }
      // EXTERNAL_WORK rule
      if (selectedConstProgress.toLowerCase() == "external work") {
        final minEnd = parsedDos.add(const Duration(days: 30));
        if (parsedEndDate.isBefore(minEnd)) {
          errors["endDate"] = "End Date should be at least 1 month more than DOS for External Work";
        }
      }
    } catch (e) {
      errors["endDate"] = "Invalid date format";
    }

    if (errors.isNotEmpty) {
      emit(ValidateState(errors: errors));
      return false;
    }
    return true;
  }

  bool _validateMap(Map<String, dynamic>? map, String fieldName) {
    if (map == null || map.isEmpty) {
      emit(ErrorState(message: "Please select $fieldName"));
      return false;
    }
    return true;
  }

  Future<bool> addSubProject({
    required String formType,
    required String subPrjId,
    required int projectId,
    required String newPrjId,
    required String subProjectName,
    Map<String, dynamic>? flatGroup,
    required int flatGroupId,
    required String storey,
    required String scr,
    required String maintenance,
    required String flats,
    required String priceType,
    required bool isSaleable,
    required String saleableLaunchPrice,
    required String carpetLaunchPrice,
    required String floorRise,
    required String launchDate,
    required String endDate,
    Map<String, dynamic>? constructionProgress,
    required String selectedConstProgress,
    required int selectedConstProgressId,
    required int projectStatusId,
    required String stiltParking,
    required String openParking,
    required String podiumParking,
    required String doublePodiumParking,
    required String basementParking,
    required String remark,
    required bool isFloorSlab,
    required String floorSlab,
    required DateTime dos,
    required int qtrId,
    required String qtr,
    required String reraNo,
  }) async {
    try {
      // Validate before processing
      final isValid =
          // validateSubProject(
          //   subProjectName: subProjectName,
          //   flatGroup: flatGroup,
          //   constructionProgress: constructionProgress,
          //   flatGroupId: flatGroupId,
          //   storey: storey,
          //   scr: scr,
          //   maintenance: maintenance,
          //   flats: flats,
          //   priceType: priceType,
          //   isSaleable: isSaleable,
          //   saleableLaunchPrice: saleableLaunchPrice,
          //   carpetLaunchPrice: carpetLaunchPrice,
          //   floorRise: floorRise,
          //   launchDate: launchDate,
          //   endDate: endDate,
          //   selectedConstProgress: selectedConstProgress,
          //   selectedConstProgressId: selectedConstProgressId,
          //   stiltParking: stiltParking,
          //   openParking: openParking,
          //   podiumParking: podiumParking,
          //   doublePodiumParking: doublePodiumParking,
          //   basementParking: basementParking,
          //   remark: remark,
          //   isFloorSlab: isFloorSlab,
          //   floorSlab: floorSlab,
          //   dos: dos,
          // );
          validateFields(
            subProjectName: subProjectName,
            flatGroup: flatGroup,
            flatGroupId: flatGroupId,
            storey: storey,
            scr: scr,
            maintenance: maintenance,
            flats: flats,
            priceType: priceType,
            isSaleable: isSaleable,
            saleableLaunchPrice: saleableLaunchPrice,
            carpetLaunchPrice: carpetLaunchPrice,
            floorRise: floorRise,
            launchDate: launchDate,
            endDate: endDate,
            constructionProgress: constructionProgress,
            selectedConstProgress: selectedConstProgress,
            selectedConstProgressId: selectedConstProgressId,
            remark: remark,
            isFloorSlab: isFloorSlab,
            floorSlab: floorSlab,
            dos: dos,
          );
      if (!isValid) return false;

      // Ensure userId is not null
      final userId = await StorageFunction.readIntData(StorageKey.userId);
      if (userId == null) throw "User ID missing in Storage";

      // Validate date strings before parsing
      if (launchDate.isEmpty) throw "Launch date cannot be empty";
      if (endDate.isEmpty) throw "End date cannot be empty";

      // Safe date parsing
      DateTime? startDate = DateFormat("dd-MMM-yyyy").tryParse(launchDate);
      DateTime? finalEndDate = DateFormat("dd-MMM-yyyy").tryParse(endDate);

      if (startDate == null) throw "Invalid launch date format";
      if (finalEndDate == null) throw "Invalid end date format";

      // Create unique subproject ID
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final String subProjectId = "${userId}_${projectId}_$timestamp";
      final String createdDateTime = DateFormat("dd-MMM-yyyy'T'HH:mm:ss").format(DateTime.now());

      // Safe model creation with tryParse everywhere
      String typeOfForm = formType.toLowerCase().trim();
      NewSubProjectEntity newSubProjectEntity = NewSubProjectEntity(
        subPrjid: typeOfForm == "update" ? subPrjId : subProjectId,
        projectId: projectId,
        newProjectId: newPrjId,
        qtrid: qtrId,
        qtr: qtr,
        subPrjName: subProjectName,
        storey: int.tryParse(storey),
        scr: int.tryParse(scr),
        maintenance: double.tryParse(maintenance),
        flatsPerFloor: int.tryParse(flats),
        flatGroup: flatGroupId,
        saleableLaunchPrice: double.tryParse(saleableLaunchPrice),
        carpetLaunchPrice: double.tryParse(carpetLaunchPrice),
        rateType: priceType,
        launchDate: launchDate,
        endDate: endDate,
        constructionProgressId: selectedConstProgressId,
        constructionProgress: selectedConstProgress,
        floorSlab: int.tryParse(floorSlab),
        reraNo: reraNo,
        remarks: remark,
        floorRise: int.tryParse(floorRise),
        stiltParking: stiltParking,
        openParking: openParking,
        podiumParking: podiumParking,
        doublePodiumParking: doublePodiumParking,
        basementParking: basementParking,
        createdDateTime: createdDateTime,
        syncLocalStatus: 1,
        syncGlobalStatus: 0,
      );

      final response = typeOfForm == "update"
          ? await DBHelper.updateNewSubProjectEntity(newSubProjectEntity)
          : await DBHelper.insertNewSubProject(newSubProjectEntity);

      if (response > 0) {
        String msg = typeOfForm == "update" ? "Data updated successfully" : "Data saved successfully";
        emit(SuccessState(message: msg));
        return true;
      } else {
        return false;
      }
    } catch (e) {
      emit(ErrorState(message: "$e"));
      return false;
    }
  }
}
