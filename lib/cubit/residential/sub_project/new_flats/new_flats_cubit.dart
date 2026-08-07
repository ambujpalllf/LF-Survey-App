import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lf_survey/cubit/residential/sub_project/new_flats/new_flats_state.dart';
import 'package:lf_survey/database/db_helper.dart';
import 'package:lf_survey/model/db_model/residential/new_flat_entity.dart';
import 'package:lf_survey/model/residential/project_spinner.dart';

class NewFlatsCubit extends Cubit<NewFlatsState> {
  NewFlatsCubit() : super(InitState());

  void fetchData() async {
    try {
      final response = await DBHelper.getFlatType();
      if (response.isNotEmpty) {
        List<FlatTypeList> flats = response.map((e) => FlatTypeList.fromJson(e)).toList();
        emit(LocalDbState(flats: flats));
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void fetchFlatData({required String suprj}) async {
    try {
      emit(LoadingState());
      final response = await DBHelper.fetchAllNewFlatsBySubPrjId(suprj);
      if (response.isNotEmpty) {
        emit(FlatLoadedState(flats: response));
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  // bool fieldsValidation({
  //   required List<NewFlatEntity> flats,
  //   required Map<String, dynamic>? selectedFlatType,
  //   required String rateType,
  //   required String salebaleFlat,
  //   required String carpetFlat,
  //   required String soldFlats,
  //   required String totalFlats,
  // }) {
  //   bool isValid = true;
  //   if (selectedFlatType == null) {
  //     isValid = false;
  //     emit(ErrorState(message: "Please Enter all the fields."));
  //   } else if (flats.isNotEmpty) {
  //     bool isContain = flats.any((e) => e.flatTypeId == selectedFlatType["flatTypeId"]);
  //     if (isContain) {
  //       isValid = false;
  //       emit(ErrorState(message: "Flat Type already Entered, Duplicate Flat entry."));
  //     }
  //   } else if ((rateType.toLowerCase() == "saleable" && salebaleFlat.isEmpty) ||
  //       soldFlats.isEmpty ||
  //       totalFlats.isEmpty) {
  //     isValid = false;
  //     emit(ErrorState(message: "Please Enter all the fields."));
  //   } else if ((rateType.toLowerCase() == "carpet" && carpetFlat.isEmpty) || soldFlats.isEmpty || totalFlats.isEmpty) {
  //     isValid = false;
  //     emit(ErrorState(message: "Please Enter all the fields."));
  //   } else if (totalFlats == "0") {
  //     isValid = false;
  //     emit(ErrorState(message: "Total Flats count cannot be zero."));
  //   } else if (soldFlats.isNotEmpty && totalFlats.isNotEmpty) {
  //     int flatCount = int.tryParse(soldFlats) ?? 0;
  //     int totalflatCount = int.tryParse(totalFlats) ?? 0;
  //     if (flatCount > totalflatCount) {
  //       isValid = false;
  //       emit(ErrorState(message: "Sold cannot be greater than Total."));
  //     }
  //   }
  //   if (rateType.toLowerCase() == "saleable" && salebaleFlat.isNotEmpty) {
  //     List<int> saleableSize = salebaleFlat
  //         .split(',')
  //         .where((e) => e.trim().isNotEmpty)
  //         .map((e) => int.parse(e.trim()))
  //         .toList();
  //     String erMsg = "";
  //     for (var sale in saleableSize) {
  //       if (sale < selectedFlatType?["min_value"] || sale > selectedFlatType?["min_value"]) {
  //         isValid = false;
  //         erMsg =
  //             "Please Enter correct Size. Value can be in range ${selectedFlatType?["min_value"]} - ${selectedFlatType?["min_value"]}";
  //       }
  //     }
  //     if (isValid == false) {
  //       emit(ErrorState(message: erMsg));
  //     }
  //   }
  //   if (rateType.toLowerCase() != "carpet" && carpetFlat.isNotEmpty) {
  //     List<int> carpetSize = carpetFlat
  //         .split(',')
  //         .where((e) => e.trim().isNotEmpty)
  //         .map((e) => int.parse(e.trim()))
  //         .toList();
  //     String erMsg = "";
  //     for (var sale in carpetSize) {
  //       if (sale < selectedFlatType?["min_value"] || sale > selectedFlatType?["min_value"]) {
  //         isValid = false;
  //         erMsg =
  //             "Please Enter correct Size. Value can be in range ${selectedFlatType?["min_value"]} - ${selectedFlatType?["min_value"]}";
  //       }
  //     }
  //     emit(ErrorState(message: erMsg));
  //   }
  //   return isValid;
  // }
  bool fieldsValidation({
    required bool isUpdate,
    required List<NewFlatEntity> flats,
    required Map<String, dynamic>? selectedFlatType,
    required String rateType,
    required String salebaleFlat,
    required String carpetFlat,
    required String soldFlats,
    required String totalFlats,
  }) {
    // 1. Flat type validation
    if (selectedFlatType == null) {
      emit(ErrorState(message: "Please enter all the fields."));
      return false;
    }

    // 2. Duplicate flat type check
    if (isUpdate == false && flats.any((e) => e.flatTypeId == selectedFlatType["flatId"])) {
      emit(ErrorState(message: "Flat Type already entered. Duplicate flat entry."));
      return false;
    }

    // 3. Required fields check
    if (soldFlats.isEmpty || totalFlats.isEmpty) {
      emit(ErrorState(message: "Please enter all the fields."));
      return false;
    }

    if (rateType.toLowerCase() == "saleable" && salebaleFlat.isEmpty) {
      emit(ErrorState(message: "Please enter saleable size."));
      return false;
    }

    if (rateType.toLowerCase() == "carpet" && carpetFlat.isEmpty) {
      emit(ErrorState(message: "Please enter carpet size."));
      return false;
    }

    // 4. Total flats cannot be zero
    final int totalCount = int.tryParse(totalFlats) ?? 0;
    final int soldCount = int.tryParse(soldFlats) ?? 0;

    if (totalCount == 0) {
      emit(ErrorState(message: "Total flats count cannot be zero."));
      return false;
    }

    // 5. Sold vs Total validation
    if (soldCount > totalCount) {
      emit(ErrorState(message: "Sold cannot be greater than Total."));
      return false;
    }

    // 6. Size range validation
    int minValue = selectedFlatType["min_value"];
    int maxValue = selectedFlatType["max_value"];
    bool validateSize(String value) {
      final sizes = value.split(',').where((e) => e.trim().isNotEmpty).map((e) => int.tryParse(e.trim())).toList();

      for (final size in sizes) {
        if (size == null || size < minValue || size > maxValue) {
          emit(ErrorState(message: "Please enter correct size. Value should be in range $minValue - $maxValue"));
          return false;
        }
      }
      return true;
    }

    if (rateType.toLowerCase() == "saleable" && salebaleFlat.isNotEmpty) {
      return validateSize(salebaleFlat);
    }

    if (rateType.toLowerCase() == "carpet" && carpetFlat.isNotEmpty) {
      return validateSize(carpetFlat);
    }

    return true;
  }

  Future<bool> saveMethod({
    required String subPrjId,
    required List<NewFlatEntity> flats,
    required Map<String, dynamic>? selectedFlatType,
    required String rateType,
    required String salebaleFlat,
    required String carpetFlat,
    required String soldFlats,
    required String totalFlats,
    required bool isUpdate,
    required String preFlatId,
  }) async {
    try {
      final isValid = fieldsValidation(
        flats: flats,
        selectedFlatType: selectedFlatType,
        rateType: rateType,
        salebaleFlat: salebaleFlat,
        carpetFlat: carpetFlat,
        soldFlats: soldFlats,
        totalFlats: totalFlats,
        isUpdate: isUpdate,
      );
      if (isValid == false) return false;
      DateTime currentTime = DateTime.now();
      String createTime = DateFormat("dd-MMM-yyyy'T'HH:mm:ss").format(currentTime);
      final timestamp = currentTime.millisecondsSinceEpoch ~/ 1000;
      String flatId = "${subPrjId}_$timestamp";
      NewFlatEntity newFlatEntity = NewFlatEntity(
        newFlatId: isUpdate ? preFlatId : flatId,
        newSubProjectId: subPrjId,
        flatTypeId: selectedFlatType?["flatId"],
        flatType: selectedFlatType?["flatType"],
        flatSize: salebaleFlat,
        carpetSize: carpetFlat,
        areaType: rateType,
        flatSold: int.tryParse(soldFlats),
        totalFlats: int.tryParse(totalFlats),
        createdDateTime: createTime,
        syncGlobalStatus: 0,
      );
      final response = isUpdate
          ? await DBHelper.updateNewFlatEntity(newFlatEntity)
          : await DBHelper.insertNewFlatEntity(newFlatEntity);
      if (response > 0) {
        emit(SuccessState(message: isUpdate ? "Data updated successfully" : "Data saved successfully"));
        return true;
      } else {
        emit(ErrorState(message: "Something went wrong during flat inserting"));
        return false;
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
      return false;
    }
  }

  void deleteFlat({required String suprj, required int index}) async {
    try {
      emit(LoadingState());
      final response = await DBHelper.deleteNewFlatEntity(suprj);
      if (response > 0) {
        emit(DeleteState(index: index));
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }
}
