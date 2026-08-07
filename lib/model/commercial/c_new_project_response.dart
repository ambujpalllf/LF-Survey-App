import 'dart:convert';

CNewProjectResponse newProjectResponseFromJson(String str) => CNewProjectResponse.fromJson(json.decode(str));

String newProjectResponseToJson(CNewProjectResponse data) => json.encode(data.toJson());

class CNewProjectResponse {
  List<CNewProjectDatum>? data;
  String? status;
  String? message;

  CNewProjectResponse({this.data, this.status, this.message});

  factory CNewProjectResponse.fromJson(Map<String, dynamic> json) => CNewProjectResponse(
    data: json["data"] == null
        ? []
        : List<CNewProjectDatum>.from(json["data"]!.map((x) => CNewProjectDatum.fromJson(x))),
    status: json["status"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "status": status,
    "message": message,
  };
}

class CNewProjectDatum {
  String? newProjectId;
  String? projectName;
  String? dos;
  String? projectAddress;
  String? roadName;
  String? builderName;
  String? architectName;
  double? lat;
  double? lng;
  String? mobileNo;
  String? amenitiesIds;
  String? approvedBankIds;
  int? operatingModelId;
  int? buildingTypeId;
  int? tenantMixId;
  int? createdBy;
  String? createdDatetimeMob;
  int? lfProjectId;

  CNewProjectDatum({
    this.newProjectId,
    this.projectName,
    this.dos,
    this.projectAddress,
    this.roadName,
    this.builderName,
    this.architectName,
    this.lat,
    this.lng,
    this.mobileNo,
    this.amenitiesIds,
    this.approvedBankIds,
    this.operatingModelId,
    this.buildingTypeId,
    this.tenantMixId,
    this.createdBy,
    this.createdDatetimeMob,
    this.lfProjectId,
  });

  factory CNewProjectDatum.fromJson(Map<String, dynamic> json) => CNewProjectDatum(
    newProjectId: json["NEW_PROJECT_ID"],
    projectName: json["PROJECT_NAME"],
    dos: json["DOS"],
    projectAddress: json["PROJECT_ADDRESS"],
    roadName: json["ROAD_NAME"],
    builderName: json["BUILDER_NAME"],
    architectName: json["ARCHITECT_NAME"],
    lat: json["LAT"]?.toDouble(),
    lng: json["LNG"]?.toDouble(),
    mobileNo: json["MOBILE_NO"],
    amenitiesIds: json["AMENITIES_IDS"],
    approvedBankIds: json["APPROVED_BANK_IDS"],
    operatingModelId: json["OPERATING_MODEL_ID"],
    buildingTypeId: json["BUILDING_TYPE_ID"],
    tenantMixId: json["TENANT_MIX_ID"],
    createdBy: json["CREATED_BY"],
    createdDatetimeMob: json["CREATED_DATETIME_MOB"],
    lfProjectId: json["LF_PROJECT_ID"],
  );

  Map<String, dynamic> toJson() => {
    "NEW_PROJECT_ID": newProjectId,
    "PROJECT_NAME": projectName,
    "DOS": dos,
    "PROJECT_ADDRESS": projectAddress,
    "ROAD_NAME": roadName,
    "BUILDER_NAME": builderName,
    "ARCHITECT_NAME": architectName,
    "LAT": lat,
    "LNG": lng,
    "MOBILE_NO": mobileNo,
    "AMENITIES_IDS": amenitiesIds,
    "APPROVED_BANK_IDS": approvedBankIds,
    "OPERATING_MODEL_ID": operatingModelId,
    "BUILDING_TYPE_ID": buildingTypeId,
    "TENANT_MIX_ID": tenantMixId,
    "CREATED_BY": createdBy,
    "CREATED_DATETIME_MOB": createdDatetimeMob,
    "LF_PROJECT_ID": lfProjectId,
  };
}
