class NewPrjImageEntity {
  int? id;
  String? prjId;
  String? imageUri;
  double? imgLat;
  double? imgLng;
  double? imgLocAccuracy;
  String? createdDatetime;
  int? syncStatus;

  NewPrjImageEntity({
    this.id,
    this.prjId,
    this.imageUri,
    this.imgLat,
    this.imgLng,
    this.imgLocAccuracy,
    this.createdDatetime,
    this.syncStatus,
  });

  Map<String, dynamic> toNewPrjImgMap() {
    return {
      'id': id,
      'prj_id': prjId,
      'image_uri': imageUri,
      'img_lat': imgLat,
      'img_lng': imgLng,
      'img_loc_accuracy': imgLocAccuracy,
      'created_datetime': createdDatetime,
      'sync_status': syncStatus,
    };
  }

  factory NewPrjImageEntity.fromJson(Map<String, dynamic> map) {
    return NewPrjImageEntity(
      id: map['id'],
      prjId: map['prj_id'],
      imageUri: map['image_uri'],
      imgLat: map['img_lat'],
      imgLng: map['img_lng'],
      imgLocAccuracy: map['img_loc_accuracy'],
      createdDatetime: map['created_datetime'],
      syncStatus: map['sync_status'],
    );
  }
}
