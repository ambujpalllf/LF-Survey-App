import 'dart:convert';

PsPhotosResponse psPhotosResponseFromJson(String str) => PsPhotosResponse.fromJson(json.decode(str));

String psPhotosResponseToJson(PsPhotosResponse data) => json.encode(data.toJson());

class PsPhotosResponse {
  List<PsPhotoDatum>? data;
  String? status;
  String? message;

  PsPhotosResponse({this.data, this.status, this.message});

  factory PsPhotosResponse.fromJson(Map<String, dynamic> json) => PsPhotosResponse(
    data: json["data"] == null ? [] : List<PsPhotoDatum>.from(json["data"]!.map((x) => PsPhotoDatum.fromJson(x))),
    status: json["status"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "status": status,
    "message": message,
  };
}

class PsPhotoDatum {
  int? id;
  int? photoId;
  int? projectId;
  int? buildingId;
  int? wingId;
  String? localBuildingId;
  String? localWingId;
  String? photoType;
  String? photoPath;
  String? remarks;
  double? imgLat;
  double? imgLng;
  double? imgLocAccuracy;
  String? createdDateTime;
  String? imageCategory;
  int? sync;

  PsPhotoDatum({
    this.id,
    this.photoId,
    this.projectId,
    this.buildingId,
    this.wingId,
    this.localBuildingId,
    this.localWingId,
    this.photoType,
    this.photoPath,
    this.remarks,
    this.imgLat,
    this.imgLng,
    this.imgLocAccuracy,
    this.createdDateTime,
    this.imageCategory,
    this.sync,
  });

  factory PsPhotoDatum.fromJson(Map<String, dynamic> json) => PsPhotoDatum(
    id: json["id"],
    photoId: json["photo_id"],
    photoType: json["photo_type"],
    photoPath: json["photo_path"],
    remarks: json["remarks"],
    projectId: json["project_id"],
    buildingId: json["buildingId"],
    localBuildingId: json["localBuildingId"],
    localWingId: json["localWingId"],
    wingId: json["wingId"],
    imgLat: json["photo_lat"],
    imgLng: json["photo_lng"],
    imgLocAccuracy: json["photo_loc_accuracy"],
    createdDateTime: json["photo_created_date_time"],
    imageCategory: json["imageCategory"],
    sync: json["sync"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "photo_id": photoId,
    "photo_type": photoType,
    "photo_path": photoPath,
    "remarks": remarks,
    "project_id": projectId,
    "buildingId": buildingId,
    "wingId": wingId,
    "localBuildingId": localBuildingId,
    "localWingId": localWingId,
    "photo_lat": imgLat,
    "photo_lng": imgLng,
    "photo_loc_accuracy": imgLocAccuracy,
    "photo_created_date_time": createdDateTime,
    "imageCategory": imageCategory,
    "sync": sync,
  };
}
