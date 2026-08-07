import 'package:lf_survey/model/db_model/residential/new_prj_img_entity.dart';

abstract class NewPrjImgState {}

class InitState extends NewPrjImgState {}

class SuccessSate extends NewPrjImgState {
  final String message;
  SuccessSate({required this.message});
}

class ErrorState extends NewPrjImgState {
  final String message;
  ErrorState({required this.message});
}

class ImagePickedState extends NewPrjImgState {
  NewPrjImageEntity imageData;
  ImagePickedState({required this.imageData});
}

class ImagePickedGalleryState extends NewPrjImgState {
  List<NewPrjImageEntity> imageData;
  ImagePickedGalleryState({required this.imageData});
}

class LoadedState extends NewPrjImgState {
  List<NewPrjImageEntity> images;
  LoadedState({required this.images});
}

class DeleteState extends NewPrjImgState {
  final int index;
  DeleteState({required this.index});
}
