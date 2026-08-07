import 'package:lf_survey/model/db_model/residential/image_entity.dart';

abstract class ImageListState {}

class InitState extends ImageListState {}

class LoadedState extends ImageListState {
  List<ImageEntity> images;
  LoadedState({required this.images});
}

class SuccessSate extends ImageListState {
  final String message;
  SuccessSate({required this.message});
}

class SyncSate extends ImageListState {
  final String message;
  SyncSate({required this.message});
}

class ErrorState extends ImageListState {
  final String message;
  ErrorState({required this.message});
}

class DeleteState extends ImageListState {}
