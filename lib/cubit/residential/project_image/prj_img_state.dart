import 'package:lf_survey/model/db_model/residential/image_entity.dart';

abstract class PrjImgState {}

class InitState extends PrjImgState {}

class SuccessSate extends PrjImgState {
  final String message;
  SuccessSate({required this.message});
}

class ErrorState extends PrjImgState {
  final String message;
  ErrorState({required this.message});
}

class ImagePickedState extends PrjImgState {
  ImageEntity imageData;
  ImagePickedState({required this.imageData});
}

class ImagePickedGalleryState extends PrjImgState {
  List<ImageEntity> imageData;
  ImagePickedGalleryState({required this.imageData});
}

class LoadedState extends PrjImgState {
  List<ImageEntity> images;
  LoadedState({required this.images});
}

class DeleteState extends PrjImgState {
  final int index;
  DeleteState({required this.index});
}
