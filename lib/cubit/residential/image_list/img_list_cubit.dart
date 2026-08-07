import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lf_survey/cubit/residential/image_list/img_list_state.dart';
import 'package:lf_survey/database/db_helper.dart';
import 'package:lf_survey/model/db_model/residential/image_entity.dart';
import 'package:lf_survey/services/work_manager_task_register.dart';

class ImageListCubit extends Cubit<ImageListState> {
  ImageListCubit() : super(InitState());

  fetchData({required int imageId, required int resident, required int commercial}) async {
    try {
      final imgFile = imageId != 0
          ? await DBHelper.fetcImgEntity(imageId: imageId)
          : await DBHelper.fetcAllImgEntity(resident: resident, commercial: commercial);
      if (imgFile.isNotEmpty) {
        emit(LoadedState(images: imgFile));
      }
    } catch (e) {
      String erStr = e.toString().split(":").last;
      emit(ErrorState(message: erStr));
    }
  }

  void deleteImg({required List<ImageEntity> imgData}) async {
    try {
      if (imgData.isEmpty) {
        emit(ErrorState(message: "No images available to delete. Please add images and try again."));
        return;
      }
      int response = 0;
      for (var img in imgData) {
        response = await DBHelper.deleteImgEntity(id: img.id!);
      }
      if (response > 0) {
        emit(DeleteState());
      }
    } catch (e) {
      String erStr = e.toString().split(":").last;
      emit(ErrorState(message: erStr));
    }
  }

  void syncImages({required List<ImageEntity> prjImage}) {
    try {
      if (prjImage.isEmpty) {
        emit(ErrorState(message: "No images available to sync. Please add images and try again."));
        return;
      }
      bool allSynced = prjImage.every((element) => element.sync == 1);
      if (allSynced) {
        emit(ErrorState(message: "All images are already synced."));
        return;
      }
      emit(SyncSate(message: "Image Sync Started..."));
      WorkManagerTaskRegister.syncMultiImage();
    } catch (e) {
      String erStr = e.toString().split(":").last;
      emit(ErrorState(message: erStr));
    }
  }
}
