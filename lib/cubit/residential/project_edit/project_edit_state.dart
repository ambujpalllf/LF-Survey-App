import 'package:lf_survey/model/db_model/residential/project_entity.dart';
import 'package:lf_survey/model/db_model/residential/sub_prj_entity.dart';
import 'package:lf_survey/model/residential/archi_response.dart';
import 'package:lf_survey/model/residential/project_response.dart';
import 'package:lf_survey/model/residential/project_scheme_entity.dart';
import 'package:lf_survey/model/residential/project_spinner.dart';

abstract class ProjectEditState {}

class InitState extends ProjectEditState {}

class ProjectCostState extends ProjectEditState {
  ProjectCosting projectCostingData;
  ProjectCostState({required this.projectCostingData});
}

class AreaUnitState extends ProjectEditState {
  List<AreaUnitList> areaUnit;
  AreaUnitState({required this.areaUnit});
}

class LocalDbState extends ProjectEditState {
  List<AreaUnitList> areaUnit;
  List<SchemesList> schmeData;
  List<FlatTypeList> flatType;
  List<CostIncludedList> costIncluded;
  List<SubProjectEntity> subProjects;
  List<CityList> cities;
  List<ArchitectDataum> architects;
  List<ProjectSchemeEntity> prjschemes;
  List<ApprovedBankList> approveBanks;
  LocalDbState({
    required this.areaUnit,
    required this.schmeData,
    required this.flatType,
    required this.costIncluded,
    required this.subProjects,
    required this.cities,
    required this.architects,
    required this.prjschemes,
    required this.approveBanks,
  });
}

class PrjSchemState extends ProjectEditState {
  List<ProjectSchemeEntity> prjschemes;
  PrjSchemState({required this.prjschemes});
}

class PrjUpdateCastingState extends ProjectEditState {}

class PrjCastingState extends ProjectEditState {
  ProjectEntity project;
  PrjCastingState({required this.project});
}

class ErrorState extends ProjectEditState {
  String message;
  ErrorState({required this.message});
}

class SuccessSate extends ProjectEditState {
  String message;
  SuccessSate({required this.message});
}

class EditDialogueState extends ProjectEditState {
  final String saleError;
  final String carpetError;
  final String flatTypeError;
  EditDialogueState({required this.carpetError, required this.saleError, required this.flatTypeError});
}

class SearchArchiState extends ProjectEditState {
  List<ArchitectDataum> architects;
  SearchArchiState({required this.architects});
}

class SelectArchiState extends ProjectEditState {
  ArchitectDataum architect;
  SelectArchiState({required this.architect});
}
