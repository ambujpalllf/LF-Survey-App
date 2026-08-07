import 'package:lf_survey/model/db_model/residential/image_entity.dart';

abstract class CPrjImgState {}

class InitState extends CPrjImgState {}

class SuccessSate extends CPrjImgState {
  final String message;
  SuccessSate({required this.message});
}

class ErrorState extends CPrjImgState {
  final String message;
  ErrorState({required this.message});
}

class ImagePickedState extends CPrjImgState {
  ImageEntity imageData;
  ImagePickedState({required this.imageData});
}

class ImagePickedGalleryState extends CPrjImgState {
  List<ImageEntity> imageData;
  ImagePickedGalleryState({required this.imageData});
}

class LoadedState extends CPrjImgState {
  List<ImageEntity> images;
  LoadedState({required this.images});
}

class DeleteState extends CPrjImgState {
  final int index;
  DeleteState({required this.index});
}
