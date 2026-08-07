import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lf_survey/cubit/residential/sub_project/sprj_flat_details/s_prj_flat_details_state.dart';
import 'package:lf_survey/database/db_helper.dart';
import 'package:lf_survey/model/db_model/residential/flat_entity.dart';
import 'package:lf_survey/model/db_model/residential/sub_prj_entity.dart';
import 'package:lf_survey/model/residential/project_spinner.dart';

class SPrjFlatDetailsCubit extends Cubit<SPrjFlatDetailsState> {
  SPrjFlatDetailsCubit() : super(InitState());

  void getFlats({required int subProjectId, required int projectId}) async {
    try {
      emit(LoadingState());

      final result = await Future.wait([
        DBHelper.getFlats(subProjectId: subProjectId, projectId: projectId), // returns List<Map>
        DBHelper.getFlatType(), // returns List<Map>
        DBHelper.getSprjEntity(subPrjId: subProjectId, projectId: projectId), // returns Map<String, dynamic>
      ]);

      final response = result[0] as List<Map<String, dynamic>>;
      final response1 = result[1] as List<Map<String, dynamic>>;
      final response2 = result[2] as Map<String, dynamic>;

      if (response.isNotEmpty && response1.isNotEmpty) {
        List<FlatEntity> flatData = response.map((e) => FlatEntity.fromJson(e)).toList();

        List<FlatTypeList> flatTypeData = response1.map((e) => FlatTypeList.fromJson(e)).toList();

        SubProjectEntity subProjectsDatum = SubProjectEntity.fromJson(response2);
        emit(LoadedState(flatsData: flatData, flatstypeData: flatTypeData, subProjectsDatum: subProjectsDatum));
      }
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void updateBookingStop({required SubProjectEntity subProject}) async {
    try {
      await DBHelper.updateSprjEntity(subProject);
    } catch (e) {
      emit(ErrorState(message: e.toString()));
    }
  }

  void calculateFlatUnsold({required String flatUnsold}) {
    emit(FlatUnsoldCount(unsoldFlat: flatUnsold));
  }

  bool fieldsValidation({
    required int totalFlats,
    required FlatTypeList flatTypeData,
    required String scr,
    required String flatSold,
    required String saleableSize,
    required String carpetFlatSize,
    required bool isSaleble,
  }) {
    String scrMsg = "";
    String flatSoldMsg = "";
    String saleableMsg = "";
    String carpetMsg = "";

    // 1. EMPTY FIELD VALIDATION
    if (scr.isEmpty) scrMsg = "This field is required";
    if (flatSold.isEmpty) flatSoldMsg = "This field is required";

    if (isSaleble && saleableSize.isEmpty) {
      saleableMsg = "This field is required";
    }

    if (!isSaleble && carpetFlatSize.isEmpty) {
      carpetMsg = "This field is required";
    }

    // 2. SCR VALIDATION
    if (scr.isNotEmpty) {
      int? scrValue = int.tryParse(scr);
      if (scrValue == null) {
        scrMsg = "Invalid SCR value";
      } else {
        if (flatTypeData.flatTypeId == 3) {
          if (scrValue < 1 || scrValue > 20) {
            scrMsg = "Please enter correct SCR. Range is 1-20";
          }
        } else {
          if (scrValue < 10 || scrValue > 50) {
            scrMsg = "Please enter correct SCR. Range is 10-50";
          }
        }
      }
    }

    // Compare flat sold value with total flats
    int? value = int.tryParse(flatSold.replaceAll(',', ''));
    if (value != null && (value > totalFlats)) {
      flatSoldMsg = "Sold flat can not be greater than total flat";
    }

    // 3. SALEABLE SIZE VALIDATION
    if (isSaleble && saleableSize.isNotEmpty && flatTypeData.minValue != null && flatTypeData.maxValue != null) {
      saleableMsg = validateSize(saleableSize, flatTypeData.minValue!, flatTypeData.maxValue!, "saleable size");
    }

    // 4. CARPET FLAT SIZE VALIDATION
    if (!isSaleble && carpetFlatSize.isNotEmpty && flatTypeData.minValue != null && flatTypeData.maxValue != null) {
      carpetMsg = validateSize(carpetFlatSize, flatTypeData.minValue!, flatTypeData.maxValue!, "carpet size");
    }

    // Emit all messages
    emit(
      ValidationState(
        scrMsg: scrMsg,
        flatSoldMsg: flatSoldMsg,
        slaeableSizeMsg: saleableMsg,
        carpetFlatSizeMsg: carpetMsg,
      ),
    );

    // Return true if all fields are valid
    return scrMsg.isEmpty && flatSoldMsg.isEmpty && saleableMsg.isEmpty && carpetMsg.isEmpty;
  }

  // Helper function for size validation
  String validateSize(String size, int min, int max, String fieldName) {
    if (size.isEmpty) return "$fieldName is required";
    final regex = RegExp(r'^[0-9,]+$');

    if (!regex.hasMatch(size)) {
      return "Please enter correct $fieldName (digits & commas only)";
    }

    // int? value = int.tryParse(size.replaceAll(',', ''));
    // if (value != null && (value < min || value > max)) {
    //   return "Please enter values in Range $min - $max";
    // }

    List<String> separatedValue = size.split(",").toList();

    if (separatedValue.isNotEmpty) {
      for (String i in separatedValue) {
        int? value = int.tryParse(i.replaceAll(',', ''));
        if (value != null && (value < min || value > max)) {
          return "Please enter values in Range $min - $max";
        }
      }
    }

    return "";
  }

  int calcCarpetSize(String scr, String saleable) {
    try {
      scr = scr.trim();
      saleable = saleable.trim();

      final scrInt = int.parse(scr);
      final saleableInt = int.parse(saleable);

      final scrDouble = scrInt / 100;
      final scrCalc = 1.0 - scrDouble;

      return (scrCalc * saleableInt).toInt();
    } catch (e) {
      return 0;
    }
  }

  int calcSaleableSize(String scr, String carpet) {
    try {
      scr = scr.trim();
      carpet = carpet.trim();

      final scrInt = int.parse(scr);
      final carpetInt = int.parse(carpet);

      final scrDouble = scrInt / 100;
      final scrCalc = 1.0 - scrDouble;

      return (carpetInt / scrCalc).toInt();
    } catch (e) {
      return 0;
    }
  }

  double calculateAvg(List<String> values) {
    int count = 0;
    int total = 0;

    for (var string in values) {
      try {
        // Remove whitespace and parse to int
        int value = int.parse(string.trim());

        // Ignore -1 values
        if (value != -1) {
          count++;
          total += value;
        }
      } catch (e) {
        // Invalid number, skip
        debugPrint("Error parsing value: $string");
      }
    }

    if (total != 0 && count != 0) {
      double avg = total / count;

      // Round to 2 decimal places
      return double.parse(avg.toStringAsFixed(2));
    } else {
      return -1.0;
    }
  }

  String addValue(String existing, String newValue) {
    if (existing.trim().isEmpty) {
      return newValue.trim();
    }
    return "${existing.trim()},${newValue.trim()}";
  }

  void updateFlatDetails({
    required BuildContext context,
    required SubProjectEntity subProjectsDatum,
    required FlatEntity flatData,
    required String flatSold,
    required int totalFlats,
    required String scr,
    required String carpetFlatSize,
    required String saleableSize,
    required bool isSaleable,
  }) async {
    try {
      int flatSoldIntValue = int.tryParse(flatSold.trim()) ?? 0;

      final salesValues = saleableSize.split(",").map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      final carpetValues = carpetFlatSize.split(",").map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

      double flatSizeAvg = 0.0;
      double carpetSizeAvg = 0.0;

      String flatSize = "";
      String carpetSize = "";

      if (isSaleable) {
        // USER INPUT = SALEABLE → compute carpet
        flatSize = saleableSize;
        flatSizeAvg = calculateAvg(salesValues);

        String carpets = "";
        List<String> carpetList = [];

        for (var val in salesValues) {
          final converted = calcCarpetSize(scr, val).toString();
          carpets = addValue(carpets, converted);
          carpetList.add(converted);
        }

        // carpetSize = carpets;
        // carpetSizeAvg = calculateAvg(carpetList);
        carpetSize = carpetFlatSize;
        carpetSizeAvg = flatData.flatSizeCarpetAvg!;
      } else {
        // USER INPUT = CARPET → compute saleable
        carpetSize = carpetFlatSize;
        carpetSizeAvg = calculateAvg(carpetValues);

        String saleables = "";
        List<String> saleList = [];

        for (var val in carpetValues) {
          final converted = calcSaleableSize(scr, val).toString();
          saleables = addValue(saleables, converted);
          saleList.add(converted);
        }

        // flatSize = saleables;
        // flatSizeAvg = calculateAvg(saleList);
        flatSize = saleableSize;
        flatSizeAvg = flatData.flatSizeAvg!;
      }

      // change in sub project
      subProjectsDatum.scr = int.tryParse(scr);
      if (flatSoldIntValue <= totalFlats) {
        subProjectsDatum.flatSoldCount = flatSoldIntValue - flatData.oldFlatSold!;
      }
      //store old flatsold count
      // final oldSoldCount = flatData.oldFlatSold ?? 0;
      // now update
      // flatData.oldFlatSold = oldSoldCount;
      flatData.flatSizeAvg = flatSizeAvg;
      flatData.flatSizeCarpetAvg = carpetSizeAvg;
      flatData.flatSize = flatSize;
      flatData.flatSizeCarpet = carpetSize;
      flatData.flatSold = flatSoldIntValue;
      flatData.flatUnsold = totalFlats - flatSoldIntValue;
      flatData.dataFilled = 1;

      // Save to DB
      subProjectsDatum.errMsg = null;
      final response = await Future.wait([
        DBHelper.updateFlat(flatData: flatData),
        DBHelper.updateSprjEntity(subProjectsDatum),
      ]);

      if (response[0] > 0 && response[1] > 0) {
        if (!context.mounted) return;
        context.pop();
        emit(SuccessState(message: "Flat details updated successfully"));
      } else {
        emit(ErrorState(message: "Something went wrong"));
      }
    } catch (e) {
      emit(ErrorState(message: "$e"));
    }
  }
}
