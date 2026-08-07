import 'dart:convert';

ProjectResponse projectResponseFromJson(String str) => ProjectResponse.fromJson(json.decode(str));

String projectResponseToJson(ProjectResponse data) => json.encode(data.toJson());

class ProjectResponse {
  List<ProjectsDatum>? projectsData;

  ProjectResponse({this.projectsData});

  factory ProjectResponse.fromJson(Map<String, dynamic> json) => ProjectResponse(
    projectsData: json["data"] == null
        ? []
        : List<ProjectsDatum>.from(json["data"]!.map((x) => ProjectsDatum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "data": projectsData == null ? [] : List<dynamic>.from(projectsData!.map((x) => x.toJson())),
  };
}

class ProjectsDatum {
  int? projectId;
  String? projectName;
  String? projectAddress;
  double? pxval;
  double? pyval;
  DateTime? dos;
  int? qtrId;
  String? projectPhoneNo;
  String? projectMobileNo;
  int? builderId;
  String? builderName;
  String? builderAddress;
  String? builderPhoneNo;
  String? builderMobileNo;
  String? roadName;
  int? locationId;
  String? locationName;
  int? suburbId;
  int? cityId;
  String? cityName;
  bool? reDevelopment;
  bool? newProjectUpdate; // new key add
  String? reraNo;
  String? cinNo;
  int? rejectId;
  int? fixedBy;
  int? rejectedSurveyorId;
  String? drinkingWater;
  int? totalWings;
  int? marketableWings;
  int? totalSupplyUnits;
  double? landParcelSize;
  int? landParcelSizeUnit;
  int? projectUnsold;
  String? bankIds;
  String? amenitiesIds;
  String? classification;
  String? top25Builder;
  bool? telFlag;
  int? prjSync;
  String? modularKitchenBrand;
  String? modularKitchenAvailability;
  String? schemeOthers;
  int? architectId;
  String? mobArchitectName;
  // List<dynamic>? schemeList;
  List<SchemeList>? schemeList;
  ProjectCosting? projectCosting;
  List<SubProjectsDatum>? subProjectsList;
  String? reraInfo;
  bool? localSync;
  bool? isWrongPXValPYVal;
  int? userid;
  String? syncCheckDate;

  ProjectsDatum({
    this.projectId,
    this.projectName,
    this.projectAddress,
    this.pxval,
    this.pyval,
    this.dos,
    this.qtrId,
    this.projectPhoneNo,
    this.projectMobileNo,
    this.builderId,
    this.builderName,
    this.builderAddress,
    this.builderPhoneNo,
    this.builderMobileNo,
    this.roadName,
    this.locationId,
    this.locationName,
    this.suburbId,
    this.cityId,
    this.cityName,
    this.reDevelopment,
    this.newProjectUpdate,
    this.reraNo,
    this.cinNo,
    this.rejectId,
    this.fixedBy,
    this.rejectedSurveyorId,
    this.drinkingWater,
    this.totalWings,
    this.marketableWings,
    this.totalSupplyUnits,
    this.landParcelSize,
    this.landParcelSizeUnit,
    this.projectUnsold,
    this.bankIds,
    this.amenitiesIds,
    this.classification,
    this.top25Builder,
    this.telFlag,
    this.prjSync,
    this.modularKitchenBrand,
    this.modularKitchenAvailability,
    this.schemeOthers,
    this.architectId,
    this.mobArchitectName,
    this.schemeList,
    this.projectCosting,
    this.subProjectsList,
    this.reraInfo,
    this.isWrongPXValPYVal,
    this.localSync,
    this.userid,
  });

  factory ProjectsDatum.fromJson(Map<String, dynamic> json) => ProjectsDatum(
    projectId: json["projectId"],
    projectName: json["projectName"],
    projectAddress: json["projectAddress"],
    pxval: json["pxval"],
    pyval: json["pyval"],
    dos: json["dos"] == null ? null : DateTime.parse(json["dos"]),
    qtrId: json["qtrId"],
    projectPhoneNo: json["projectPhoneNo"],
    projectMobileNo: json["projectMobileNo"],
    builderId: json["builderId"],
    builderName: json["builderName"],
    builderAddress: json["builderAddress"],
    builderPhoneNo: json["builderPhoneNo"],
    builderMobileNo: json["builderMobileNo"],
    roadName: json["roadName"],
    locationId: json["locationId"],
    locationName: json['locationName'],
    suburbId: json["suburbId"],
    cityId: json["cityId"],
    cityName: json["city"],
    // reDevelopment: json["reDevelopment"] == 1 ? true : false,
    // newProjectUpdate: json["newProjectUpdate"] == 1 ? true : false,
    reDevelopment: json["reDevelopment"],
    newProjectUpdate: json["newProjectUpdate"],
    reraNo: json["reraNo"],
    cinNo: json["cinNo"],
    rejectId: json["rejectId"],
    fixedBy: json["fixedBy"],
    rejectedSurveyorId: json["rejectedSurveyorId"],
    drinkingWater: json["drinkingWater"],
    totalWings: json["totalWings"],
    marketableWings: json["marketableWings"],
    totalSupplyUnits: json["totalSupplyUnits"],
    landParcelSize: json["landParcelSize"],
    landParcelSizeUnit: json["landParcelSizeUnit"],
    projectUnsold: json["projectUnsold"],
    bankIds: json["bankIds"],
    amenitiesIds: json["amenitiesIds"],
    classification: json["classification"],
    top25Builder: json["top25builder"],
    // telFlag: json["telFlag"] == 1 ? true : false,
    telFlag: json["telFlag"],
    prjSync: json["prjSync"],
    modularKitchenBrand: json["MODULAR_KITCHEN_BRAND"],
    modularKitchenAvailability: json["MODULAR_KITCHEN_AVAILABILITY"],
    schemeOthers: json["SCHEME_OTHERS"],
    architectId: json["ARCHITECT_ID"],
    mobArchitectName: json["MOB_ARCHITECT_NAME"],
    // schemeList: json["schemeList"] == null ? [] : List<dynamic>.from(json["schemeList"]!.map((x) => x)),
    schemeList: json["schemeList"] == null
        ? []
        : List<SchemeList>.from(json["schemeList"]!.map((x) => SchemeList.fromJson(x))),
    projectCosting: json["projectCosting"] == null ? null : ProjectCosting.fromJson(json["projectCosting"]),
    subProjectsList: json["subProjectsList"] == null
        ? []
        : List<SubProjectsDatum>.from(json["subProjectsList"]!.map((x) => SubProjectsDatum.fromJson(x))),
    reraInfo: json["rera_info"],
    isWrongPXValPYVal: json["isWrongPXValPYVal"] == 1,
    localSync: json["localSync"] == 1,
    userid: json["userid"],
  );

  Map<String, dynamic> toJson() => {
    "projectId": projectId,
    "projectName": projectName,
    "projectAddress": projectAddress,
    "pxval": pxval,
    "pyval": pyval,
    "dos": dos?.toIso8601String(),
    "qtrId": qtrId,
    "projectPhoneNo": projectPhoneNo,
    "projectMobileNo": projectMobileNo,
    "builderId": builderId,
    "builderName": builderName,
    "builderAddress": builderAddress,
    "builderPhoneNo": builderPhoneNo,
    "builderMobileNo": builderMobileNo,
    "roadName": roadName,
    "locationId": locationId,
    "locationName": locationName,
    "suburbId": suburbId,
    "cityId": cityId,
    "city": cityName,
    // "reDevelopment": reDevelopment == true ? 1 : 0,
    // "newProjectUpdate": newProjectUpdate == true ? 1 : 0,
    "reDevelopment": reDevelopment,
    "newProjectUpdate": newProjectUpdate,
    "reraNo": reraNo,
    "cinNo": cinNo,
    "rejectId": rejectId,
    "fixedBy": fixedBy,
    "rejectedSurveyorId": rejectedSurveyorId,
    "drinkingWater": drinkingWater,
    "totalWings": totalWings,
    "marketableWings": marketableWings,
    "totalSupplyUnits": totalSupplyUnits,
    "landParcelSize": landParcelSize,
    "landParcelSizeUnit": landParcelSizeUnit,
    "projectUnsold": projectUnsold,
    "bankIds": bankIds,
    "amenitiesIds": amenitiesIds,
    "classification": classification,
    "top25builder": top25Builder,
    "telFlag": telFlag == true ? 1 : 0,
    "prjSync": prjSync,
    "MODULAR_KITCHEN_BRAND": modularKitchenBrand,
    "MODULAR_KITCHEN_AVAILABILITY": modularKitchenAvailability,
    "SCHEME_OTHERS": schemeOthers,
    "ARCHITECT_ID": architectId,
    "MOB_ARCHITECT_NAME": mobArchitectName,
    "schemeList": schemeList == null ? [] : List<dynamic>.from(schemeList!.map((x) => x)),
    "projectCosting": projectCosting?.toJson(),
    "subProjectsList": subProjectsList == null ? [] : List<dynamic>.from(subProjectsList!.map((x) => x.toJson())),
    "rera_info": reraInfo,
    "isWrongPXValPYVal": (isWrongPXValPYVal ?? false) ? 1 : 0,
    "localSync": (localSync ?? false) ? 1 : 0,
    "userid": userid,
  };

  // for storing data in db
  Map<String, dynamic> toProjectDb() => {
    "projectId": projectId,
    "projectName": projectName,
    "projectAddress": projectAddress,
    "pxval": pxval,
    "pyval": pyval,
    "dos": dos?.toIso8601String(),
    "qtrId": qtrId,
    "projectPhoneNo": projectPhoneNo,
    "projectMobileNo": projectMobileNo,
    "builderId": builderId,
    "builderName": builderName,
    "builderAddress": builderAddress,
    "builderPhoneNo": builderPhoneNo,
    "builderMobileNo": builderMobileNo,
    "roadName": roadName,
    "locationId": locationId,
    "locationName": locationName,
    "suburbId": suburbId,
    "cityId": cityId,
    "city": cityName,
    "reDevelopment": reDevelopment == true ? 1 : 0,
    "newProjectUpdate": newProjectUpdate == true ? 1 : 0,
    "reraNo": reraNo,
    "cinNo": cinNo,
    "rejectId": rejectId,
    "fixedBy": fixedBy,
    "rejectedSurveyorId": rejectedSurveyorId,
    "drinkingWater": drinkingWater,
    "totalWings": totalWings,
    "marketableWings": marketableWings,
    "totalSupplyUnits": totalSupplyUnits,
    "landParcelSize": landParcelSize,
    "landParcelSizeUnit": landParcelSizeUnit,
    "projectUnsold": projectUnsold,
    "bankIds": bankIds,
    "amenitiesIds": amenitiesIds,
    "classification": classification,
    "top25builder": top25Builder,
    "telFlag": telFlag == true ? 1 : 0,
    "prjSync": prjSync,
    "MODULAR_KITCHEN_BRAND": modularKitchenBrand,
    "MODULAR_KITCHEN_AVAILABILITY": modularKitchenAvailability,
    "ARCHITECT_ID": architectId,
    "MOB_ARCHITECT_NAME": mobArchitectName,
    "rera_info": reraInfo,
    "isWrongPXValPYVal": (isWrongPXValPYVal ?? false) ? 1 : 0,
    "localSync": (localSync ?? false) ? 1 : 0,
    "userid": userid,
  };
}

class SchemeList {
  int? projectId;
  int? schemeId;
  int? qtrId;
  String? openText;

  SchemeList({this.projectId, this.schemeId, this.qtrId, this.openText});

  factory SchemeList.fromJson(Map<String, dynamic> json) => SchemeList(
    projectId: json["projectId"],
    schemeId: json["schemeId"],
    qtrId: json["qtrId"],
    openText: json["openText"],
  );

  Map<String, dynamic> toJson() => {"projectId": projectId, "schemeId": schemeId, "qtrId": qtrId, "openText": openText};
}

class ProjectCosting {
  int? pqcId;
  int? projectId;
  int? qtrId;
  double? baseCost;
  double? agreementCost;
  double? allInclusiveCost;
  double? baseCostSaleableSize;
  double? agreementCostSaleableSize;
  double? allInclusiveCostSaleableSize;
  double? baseCostCarpetSize;
  double? agreementCostCarpetSize;
  double? allInclusiveCostCarpetSize;
  double? baseCostReferenceUnitNumber;
  double? agreementCostReferenceUnitNumber;
  double? allInclusiveCostReferenceUnitNumber;
  String? baseCostIncluded;
  String? agreementCostIncluded;
  String? allInclusiveCostIncluded;
  int? baseCostFlatId;
  int? agreementCostFlatId;
  int? allInclusiveCostFlatId;

  ProjectCosting({
    this.pqcId,
    this.projectId,
    this.qtrId,
    this.baseCost,
    this.agreementCost,
    this.allInclusiveCost,
    this.baseCostSaleableSize,
    this.agreementCostSaleableSize,
    this.allInclusiveCostSaleableSize,
    this.baseCostCarpetSize,
    this.agreementCostCarpetSize,
    this.allInclusiveCostCarpetSize,
    this.baseCostReferenceUnitNumber,
    this.agreementCostReferenceUnitNumber,
    this.allInclusiveCostReferenceUnitNumber,
    this.baseCostIncluded,
    this.agreementCostIncluded,
    this.allInclusiveCostIncluded,
    this.baseCostFlatId,
    this.agreementCostFlatId,
    this.allInclusiveCostFlatId,
  });

  factory ProjectCosting.fromJson(Map<String, dynamic> json) => ProjectCosting(
    pqcId: json["PQC_ID"],
    projectId: json["PROJECT_ID"],
    qtrId: json["QTR_ID"],
    baseCost: json["BASE_COST"],
    agreementCost: json["AGREEMENT_COST"],
    allInclusiveCost: json["ALL_INCLUSIVE_COST"],
    baseCostSaleableSize: json["BASE_COST_SALEABLE_SIZE"],
    agreementCostSaleableSize: json["AGREEMENT_COST_SALEABLE_SIZE"],
    allInclusiveCostSaleableSize: json["ALL_INCLUSIVE_COST_SALEABLE_SIZE"],
    baseCostCarpetSize: json["BASE_COST_CARPET_SIZE"],
    agreementCostCarpetSize: json["AGREEMENT_COST_CARPET_SIZE"],
    allInclusiveCostCarpetSize: json["ALL_INCLUSIVE_COST_CARPET_SIZE"],
    baseCostReferenceUnitNumber: json["BASE_COST_REFERENCE_UNIT_NUMBER"],
    agreementCostReferenceUnitNumber: json["AGREEMENT_COST_REFERENCE_UNIT_NUMBER"],
    allInclusiveCostReferenceUnitNumber: json["ALL_INCLUSIVE_COST_REFERENCE_UNIT_NUMBER"],
    baseCostIncluded: json["BASE_COST_INCLUDED"],
    agreementCostIncluded: json["AGREEMENT_COST_INCLUDED"],
    allInclusiveCostIncluded: json["ALL_INCLUSIVE_COST_INCLUDED"],
    baseCostFlatId: json["BASE_COST_FLAT_ID"],
    agreementCostFlatId: json["AGREEMENT_COST_FLAT_ID"],
    allInclusiveCostFlatId: json["ALL_INCLUSIVE_COST_FLAT_ID"],
  );

  Map<String, dynamic> toJson() => {
    "PQC_ID": pqcId,
    "PROJECT_ID": projectId,
    "QTR_ID": qtrId,
    "BASE_COST": baseCost,
    "AGREEMENT_COST": agreementCost,
    "ALL_INCLUSIVE_COST": allInclusiveCost,
    "BASE_COST_SALEABLE_SIZE": baseCostSaleableSize,
    "AGREEMENT_COST_SALEABLE_SIZE": agreementCostSaleableSize,
    "ALL_INCLUSIVE_COST_SALEABLE_SIZE": allInclusiveCostSaleableSize,
    "BASE_COST_CARPET_SIZE": baseCostCarpetSize,
    "AGREEMENT_COST_CARPET_SIZE": agreementCostCarpetSize,
    "ALL_INCLUSIVE_COST_CARPET_SIZE": allInclusiveCostCarpetSize,
    "BASE_COST_REFERENCE_UNIT_NUMBER": baseCostReferenceUnitNumber,
    "AGREEMENT_COST_REFERENCE_UNIT_NUMBER": agreementCostReferenceUnitNumber,
    "ALL_INCLUSIVE_COST_REFERENCE_UNIT_NUMBER": allInclusiveCostReferenceUnitNumber,
    "BASE_COST_INCLUDED": baseCostIncluded,
    "AGREEMENT_COST_INCLUDED": agreementCostIncluded,
    "ALL_INCLUSIVE_COST_INCLUDED": allInclusiveCostIncluded,
    "BASE_COST_FLAT_ID": baseCostFlatId,
    "AGREEMENT_COST_FLAT_ID": agreementCostFlatId,
    "ALL_INCLUSIVE_COST_FLAT_ID": allInclusiveCostFlatId,
  };
  Map<String, dynamic> toPrjCostingJson() => {
    "PQC_ID": pqcId,
    "PROJECT_ID": projectId,
    "QTR_ID": qtrId,
    "BASE_COST": baseCost,
    "AGREEMENT_COST": agreementCost,
    "ALL_INCLUSIVE_COST": allInclusiveCost,
    "BASE_COST_SALEABLE_SIZE": baseCostSaleableSize,
    "AGREEMENT_COST_SALEABLE_SIZE": agreementCostSaleableSize,
    "ALL_INCLUSIVE_COST_SALEABLE_SIZE": allInclusiveCostSaleableSize,
    "BASE_COST_CARPET_SIZE": baseCostCarpetSize,
    "AGREEMENT_COST_CARPET_SIZE": agreementCostCarpetSize,
    "ALL_INCLUSIVE_COST_CARPET_SIZE": allInclusiveCostCarpetSize,
    "BASE_COST_REFERENCE_UNIT_NUMBER": baseCostReferenceUnitNumber,
    "AGREEMENT_COST_REFERENCE_UNIT_NUMBER": agreementCostReferenceUnitNumber,
    "ALL_INCLUSIVE_COST_REFERENCE_UNIT_NUMBER": allInclusiveCostReferenceUnitNumber,
    "BASE_COST_INCLUDED": baseCostIncluded,
    "AGREEMENT_COST_INCLUDED": agreementCostIncluded,
    "ALL_INCLUSIVE_COST_INCLUDED": allInclusiveCostIncluded,
    "BASE_COST_FLAT_ID": baseCostFlatId,
    "AGREEMENT_COST_FLAT_ID": agreementCostFlatId,
    "ALL_INCLUSIVE_COST_FLAT_ID": allInclusiveCostFlatId,
  };
}

class SubProjectsDatum {
  int? subProjectId;
  String? subProject;
  int? discountRatepsf;
  int? saleableRatepsf;
  int? carpetRatepsf;
  String? rateType;
  int? qtrId;
  DateTime? dos;
  DateTime? startDate;
  DateTime? endDate;
  DateTime? surveyDate;
  int? wings;
  int? storey;
  int? flatsPerFloor;
  int? projectStatusId;
  int? constructionProgressId;
  int? floorSlab;
  String? remarks;
  int? scr;
  double? maintenancePersqft;
  String? stiltPark;
  String? openPark;
  String? podium;
  String? doublePodium;
  String? basementPark;
  int? bookingStop;
  int? floorRise;
  bool? deleteFlag;
  bool? hasVillas;
  String? percVilaStarted;
  String? percVilaPiling;
  String? percVilaPlinth;
  String? percVilaFloorslab;
  String? percVilaInternalWork;
  String? percVilaExternal;
  String? percVilaComplete;
  int? syncStatus;
  int? flatgroupid;
  List<FlatsData>? flatsList;
  bool? isUpdate;
  bool? isNewSubProject;
  int? changeFlatSoldCount;

  SubProjectsDatum({
    this.subProjectId,
    this.subProject,
    this.discountRatepsf,
    this.saleableRatepsf,
    this.carpetRatepsf,
    this.rateType,
    this.qtrId,
    this.dos,
    this.startDate,
    this.endDate,
    this.surveyDate,
    this.wings,
    this.storey,
    this.flatsPerFloor,
    this.projectStatusId,
    this.constructionProgressId,
    this.floorSlab,
    this.remarks,
    this.scr,
    this.maintenancePersqft,
    this.stiltPark,
    this.openPark,
    this.podium,
    this.doublePodium,
    this.basementPark,
    this.bookingStop,
    this.floorRise,
    this.deleteFlag,
    this.hasVillas,
    this.percVilaStarted,
    this.percVilaPiling,
    this.percVilaPlinth,
    this.percVilaFloorslab,
    this.percVilaInternalWork,
    this.percVilaExternal,
    this.percVilaComplete,
    this.syncStatus,
    this.flatgroupid,
    this.flatsList,
    this.isUpdate,
    this.changeFlatSoldCount,
    this.isNewSubProject,
  });

  factory SubProjectsDatum.fromJson(Map<String, dynamic> json) => SubProjectsDatum(
    subProjectId: json["subProjectId"],
    subProject: json["subProject"],
    discountRatepsf: json["discountRatepsf"],
    saleableRatepsf: json["saleableRatepsf"],
    carpetRatepsf: json["carpetRatepsf"],
    rateType: json["rateType"],
    qtrId: json["qtrId"],
    dos: json["dos"] == null ? null : DateTime.parse(json["dos"]),
    startDate: json["startDate"] == null ? null : DateTime.parse(json["startDate"]),
    endDate: json["endDate"] == null ? null : DateTime.parse(json["endDate"]),
    surveyDate: json["surveyDate"] == null ? null : DateTime.parse(json["surveyDate"]),
    wings: json["wings"],
    storey: json["storey"],
    flatsPerFloor: json["flatsPerFloor"],
    projectStatusId: json["projectStatusId"],
    constructionProgressId: json["constructionProgressId"],
    floorSlab: json["floorSlab"],
    remarks: json["remarks"],
    scr: json["scr"],
    maintenancePersqft: json["maintenancePersqft"],
    stiltPark: json["stiltPark"],
    openPark: json["openPark"],
    podium: json["podium"],
    doublePodium: json["doublePodium"],
    basementPark: json["basementPark"],
    bookingStop: json["bookingStop"],
    floorRise: json["floorRise"],
    // deleteFlag: json["deleteFlag"] == 1 ? true : false,
    deleteFlag: json["deleteFlag"] is int ? json["deleteFlag"] == 1 : json["deleteFlag"] == true,
    hasVillas: json["hasVillas"] == 1 ? true : false,
    percVilaStarted: json["percVilaStarted"],
    percVilaPiling: json["percVilaPiling"],
    percVilaPlinth: json["percVilaPlinth"],
    percVilaFloorslab: json["percVilaFloorslab"],
    percVilaInternalWork: json["percVilaInternalWork"],
    percVilaExternal: json["percVilaExternal"],
    percVilaComplete: json["percVilaComplete"],
    syncStatus: json["syncStatus"],
    flatgroupid: json["flatgroupid"],
    flatsList: json["flatsList"] == null
        ? []
        : List<FlatsData>.from(json["flatsList"]!.map((x) => FlatsData.fromJson(x))),
    isUpdate: json["isUpdate"] == 1,
    changeFlatSoldCount: json["changeFlatSoldCount"],
    isNewSubProject: json["isNewSubProject"] == 1,
  );

  Map<String, dynamic> toJson() => {
    "subProjectId": subProjectId,
    "subProject": subProject,
    "discountRatepsf": discountRatepsf,
    "saleableRatepsf": saleableRatepsf,
    "carpetRatepsf": carpetRatepsf,
    "rateType": rateType,
    "qtrId": qtrId,
    "dos": dos?.toIso8601String(),
    "startDate": startDate?.toIso8601String(),
    "endDate": endDate?.toIso8601String(),
    "surveyDate": surveyDate?.toIso8601String(),
    "wings": wings,
    "storey": storey,
    "flatsPerFloor": flatsPerFloor,
    "projectStatusId": projectStatusId,
    "constructionProgressId": constructionProgressId,
    "floorSlab": floorSlab,
    "remarks": remarks,
    "scr": scr,
    "maintenancePersqft": maintenancePersqft,
    "stiltPark": stiltPark,
    "openPark": openPark,
    "podium": podium,
    "doublePodium": doublePodium,
    "basementPark": basementPark,
    "bookingStop": bookingStop,
    "floorRise": floorRise,
    "deleteFlag": deleteFlag,
    "hasVillas": hasVillas,
    "percVilaStarted": percVilaStarted,
    "percVilaPiling": percVilaPiling,
    "percVilaPlinth": percVilaPlinth,
    "percVilaFloorslab": percVilaFloorslab,
    "percVilaInternalWork": percVilaInternalWork,
    "percVilaExternal": percVilaExternal,
    "percVilaComplete": percVilaComplete,
    "syncStatus": syncStatus,
    "flatgroupid": flatgroupid,
    "flatsList": flatsList == null ? [] : List<dynamic>.from(flatsList!.map((x) => x.toJson())),
    "isUpdate": (isUpdate ?? false) ? 1 : 0,
    "changeFlatSoldCount": changeFlatSoldCount,
    "isNewSubProject": (isNewSubProject ?? false) ? 1 : 0,
  };
  Map<String, dynamic> toSubProjectDb() => {
    "subProjectId": subProjectId,
    "subProject": subProject,
    "discountRatepsf": discountRatepsf,
    "saleableRatepsf": saleableRatepsf,
    "carpetRatepsf": carpetRatepsf,
    "rateType": rateType,
    "qtrId": qtrId,
    "dos": dos?.toIso8601String(),
    "startDate": startDate?.toIso8601String(),
    "endDate": endDate?.toIso8601String(),
    "surveyDate": surveyDate?.toIso8601String(),
    "wings": wings,
    "storey": storey,
    "flatsPerFloor": flatsPerFloor,
    "projectStatusId": projectStatusId,
    "constructionProgressId": constructionProgressId,
    "floorSlab": floorSlab,
    "remarks": remarks,
    "scr": scr,
    "maintenancePersqft": maintenancePersqft,
    "stiltPark": stiltPark,
    "openPark": openPark,
    "podium": podium,
    "doublePodium": doublePodium,
    "basementPark": basementPark,
    "bookingStop": bookingStop,
    "floorRise": floorRise,
    "deleteFlag": (deleteFlag ?? false) ? 1 : 0,
    "hasVillas": hasVillas == true ? 1 : 0,
    "percVilaStarted": percVilaStarted,
    "percVilaPiling": percVilaPiling,
    "percVilaPlinth": percVilaPlinth,
    "percVilaFloorslab": percVilaFloorslab,
    "percVilaInternalWork": percVilaInternalWork,
    "percVilaExternal": percVilaExternal,
    "percVilaComplete": percVilaComplete,
    "flatgroupid": flatgroupid,
    "syncStatus": syncStatus,
    "isUpdate": (isUpdate ?? false) ? 1 : 0,
    "changeFlatSoldCount": changeFlatSoldCount ?? 0,
    "isNewSubProject": (isNewSubProject ?? false) ? 1 : 0,
  };
}

class FlatsData {
  int? localId;
  int? flatId;
  String? flat;
  int? flatSold;
  int? flatUnsold;
  String? sizeType;
  String? flatSize;
  double? flatSizeAvg;
  String? flatSizeCarpet;
  double? flatSizeCarpetAvg;
  bool? isUpdate;
  int? oldFlatSold;

  FlatsData({
    this.localId,
    this.flatId,
    this.flat,
    this.flatSold,
    this.flatUnsold,
    this.sizeType,
    this.flatSize,
    this.flatSizeAvg,
    this.flatSizeCarpet,
    this.flatSizeCarpetAvg,
    this.isUpdate,
    this.oldFlatSold,
  });

  factory FlatsData.fromJson(Map<String, dynamic> json) => FlatsData(
    localId: json["localId"],
    flatId: json["flatId"],
    flat: json["flat"],
    flatSold: json["flatSold"],
    flatUnsold: json["flatUnsold"],
    sizeType: json["sizeType"],
    flatSize: json["flatSize"],
    flatSizeAvg: json["flatSizeAvg"],
    flatSizeCarpet: json["flatSizeCarpet"],
    flatSizeCarpetAvg: json["flatSizeCarpetAvg"],
    isUpdate: json["isUpdate"] == 1,
    oldFlatSold: json["oldFlatSold"],
  );

  Map<String, dynamic> toJson() => {
    "flatId": flatId,
    "flat": flat,
    "flatSold": flatSold,
    "flatUnsold": flatUnsold,
    "sizeType": sizeType,
    "flatSize": flatSize,
    "flatSizeAvg": flatSizeAvg,
    "flatSizeCarpet": flatSizeCarpet,
    "flatSizeCarpetAvg": flatSizeCarpetAvg,
    "isUpdate": (isUpdate ?? false) ? 1 : 0,
    "oldFlatSold": oldFlatSold ?? flatSold, // this is store for booking stop checking
  };
}
