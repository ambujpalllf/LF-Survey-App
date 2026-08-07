import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lf_survey/cubit/residential/filter/filter_state.dart';
import 'package:lf_survey/database/db_helper.dart';

class FilterCubit extends Cubit<FilterState> {
  FilterCubit() : super(InitState());

  void getFilter() async {
    try {
      Map<String, dynamic>? filterData = await DBHelper.getFilterQuery();
      if (filterData == null || filterData['prjType'] != "res") return;
      Map<String, dynamic> filterQuery = jsonDecode(filterData['query']);
      if (filterQuery.isEmpty) {
        return;
      }
      emit(LocalDBState(queryData: filterQuery));
    } catch (e) {
      String erMsg = e.toString().split(":").last;
      emit(ErrorState(message: erMsg));
    }
  }

  void applyFilter({required Map<String, dynamic> query}) async {
    try {
      String filterQuery = jsonEncode(query);
      await DBHelper.saveFilterQuery(filterQuery: filterQuery, isResidential: true);
    } catch (e) {
      String erMsg = e.toString().split(":").last;
      emit(ErrorState(message: erMsg));
    }
  }

  void clearFilter() async {
    try {
      await DBHelper.clearFilterQuery();
    } catch (e) {
      String erMsg = e.toString().split(":").last;
      emit(ErrorState(message: erMsg));
    }
  }
}
