import 'dart:convert';

CNewSubPrjResponse newSubPrjResponseFromJson(String str) => CNewSubPrjResponse.fromJson(json.decode(str));

String newSubPrjResponseToJson(CNewSubPrjResponse data) => json.encode(data.toJson());

class CNewSubPrjResponse {
  List<CNewSubPrjDatum>? data;
  String? status;
  String? message;

  CNewSubPrjResponse({this.data, this.status, this.message});

  factory CNewSubPrjResponse.fromJson(Map<String, dynamic> json) => CNewSubPrjResponse(
    data: json["data"] == null ? [] : List<CNewSubPrjDatum>.from(json["data"]!.map((x) => CNewSubPrjDatum.fromJson(x))),
    status: json["status"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "status": status,
    "message": message,
  };
}

class CNewSubPrjDatum {
  String? newSubProjectId;
  String? newProjectId;
  int? lfProjectId;
  String? newSubProjectName;
  int? storey;
  int? scr;
  double? maintenance;
  int? floorPlate;
  String? isCarpetOrSaleable;
  double? leaseBareshell;
  double? leaseWarmshell;
  double? leaseFullyFurnished;
  double? outrightBareshell;
  double? outrightWarmshell;
  double? outrightFullyFurnished;
  String? launchDate;
  String? endDate;
  int? constructionStageId;
  int? floorSlab;
  double? totalSupply;
  double? soldPercent;
  double? unsoldPercent;
  double? leasePercent;
  double? vacantPercent;
  String? reraNo;
  String? remark;
  String? dos;
  int? createdBy;
  String? createdDatetimeMob;

  CNewSubPrjDatum({
    this.newSubProjectId,
    this.newProjectId,
    this.lfProjectId,
    this.newSubProjectName,
    this.storey,
    this.scr,
    this.maintenance,
    this.floorPlate,
    this.isCarpetOrSaleable,
    this.leaseBareshell,
    this.leaseWarmshell,
    this.leaseFullyFurnished,
    this.outrightBareshell,
    this.outrightWarmshell,
    this.outrightFullyFurnished,
    this.launchDate,
    this.endDate,
    this.constructionStageId,
    this.floorSlab,
    this.totalSupply,
    this.soldPercent,
    this.unsoldPercent,
    this.leasePercent,
    this.vacantPercent,
    this.reraNo,
    this.remark,
    this.dos,
    this.createdBy,
    this.createdDatetimeMob,
  });

  factory CNewSubPrjDatum.fromJson(Map<String, dynamic> json) => CNewSubPrjDatum(
    newSubProjectId: json["NEW_SUB_PROJECT_ID"],
    newProjectId: json["NEW_PROJECT_ID"],
    lfProjectId: json["LF_PROJECT_ID"],
    newSubProjectName: json["NEW_SUB_PROJECT_NAME"],
    storey: json["STOREY"],
    scr: json["SCR"],
    maintenance: json["MAINTENANCE"],
    floorPlate: json["FLOOR_PLATE"],
    isCarpetOrSaleable: json["IS_CARPET_OR_SALEABLE"],
    leaseBareshell: json["LEASE_BARESHELL"],
    leaseWarmshell: json["LEASE_WARMSHELL"],
    leaseFullyFurnished: json["LEASE_FULLY_FURNISHED"],
    outrightBareshell: json["OUTRIGHT_BARESHELL"],
    outrightWarmshell: json["OUTRIGHT_WARMSHELL"],
    outrightFullyFurnished: json["OUTRIGHT_FULLY_FURNISHED"],
    launchDate: json["LAUNCH_DATE"],
    endDate: json["END_DATE"],
    constructionStageId: json["CONSTRUCTION_STAGE_ID"],
    floorSlab: json["FLOOR_SLAB"],
    totalSupply: json["TOTAL_SUPPLY"],
    soldPercent: json["SOLD_PERCENT"],
    unsoldPercent: json["UNSOLD_PERCENT"],
    leasePercent: json["LEASE_PERCENT"],
    vacantPercent: json["VACANT_PERCENT"],
    reraNo: json["RERA_NO"],
    remark: json["REMARK"],
    dos: json["DOS"],
    createdBy: json["CREATED_BY"],
    createdDatetimeMob: json["CREATED_DATETIME_MOB"],
  );

  Map<String, dynamic> toJson() => {
    "NEW_SUB_PROJECT_ID": newSubProjectId,
    "NEW_PROJECT_ID": newProjectId,
    "LF_PROJECT_ID": lfProjectId,
    "NEW_SUB_PROJECT_NAME": newSubProjectName,
    "STOREY": storey,
    "SCR": scr,
    "MAINTENANCE": maintenance,
    "FLOOR_PLATE": floorPlate,
    "IS_CARPET_OR_SALEABLE": isCarpetOrSaleable,
    "LEASE_BARESHELL": leaseBareshell,
    "LEASE_WARMSHELL": leaseWarmshell,
    "LEASE_FULLY_FURNISHED": leaseFullyFurnished,
    "OUTRIGHT_BARESHELL": outrightBareshell,
    "OUTRIGHT_WARMSHELL": outrightWarmshell,
    "OUTRIGHT_FULLY_FURNISHED": outrightFullyFurnished,
    "LAUNCH_DATE": launchDate,
    "END_DATE": endDate,
    "CONSTRUCTION_STAGE_ID": constructionStageId,
    "FLOOR_SLAB": floorSlab,
    "TOTAL_SUPPLY": totalSupply,
    "SOLD_PERCENT": soldPercent,
    "UNSOLD_PERCENT": unsoldPercent,
    "LEASE_PERCENT": leasePercent,
    "VACANT_PERCENT": vacantPercent,
    "RERA_NO": reraNo,
    "REMARK": remark,
    "DOS": dos,
    "CREATED_BY": createdBy,
    "CREATED_DATETIME_MOB": createdDatetimeMob,
  };
}
