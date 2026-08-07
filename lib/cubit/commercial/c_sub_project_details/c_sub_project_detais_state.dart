import 'package:lf_survey/model/db_model/commercial/c_sub_project_entity.dart';

abstract class CSubProjectDetaisState {}

class InitState extends CSubProjectDetaisState {}

class LocalDbState extends CSubProjectDetaisState {
  CSubProjectEntity subProjectData;
  LocalDbState({required this.subProjectData});
}

class MessageState extends CSubProjectDetaisState {
  final String message;
  MessageState({required this.message});
}
