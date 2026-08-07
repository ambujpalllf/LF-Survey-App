import 'package:lf_survey/model/construction_monitoring/cm_wing_response.dart';

class BuildingData {
  int? id;
  List<WingData>? wings;
  int? projectId;
  int? buildingId;
  String? createdBuildingId;
  String? buildingName;
  String? errorMsg;
  int? sync;
  BuildingData({
    this.id,
    this.wings,
    this.projectId,
    this.buildingId,
    this.buildingName,
    this.createdBuildingId,
    this.errorMsg,
    this.sync,
  });

  factory BuildingData.fromJson(Map<String, dynamic> json) => BuildingData(
    id: json["id"],
    wings: json["wings"] == null ? [] : List<WingData>.from(json["wings"]!.map((x) => WingData.fromJson(x))),
    projectId: json["project_id"],
    buildingId: json["building_id"],
    buildingName: json["building_name"],
    createdBuildingId: json["createdBuildingId"],
    errorMsg: json["errorMsg"],
    sync: json["sync"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "wings": wings == null ? [] : List<dynamic>.from(wings!.map((x) => x.toJson())),
    "project_id": projectId,
    "building_id": buildingId,
    "building_name": buildingName,
    "createdBuildingId": createdBuildingId,
    "errorMsg": errorMsg,
    "sync": sync,
  };

  Map<String, dynamic> toCMBuildingDB() => {
    "id": id,
    "project_id": projectId,
    "building_id": buildingId,
    "building_name": buildingName,
    "createdBuildingId": createdBuildingId,
    "errorMsg": errorMsg,
    "sync": sync,
  };
}
