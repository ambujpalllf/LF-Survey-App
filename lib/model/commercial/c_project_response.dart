class CProjectResponse {
  int? projectId;
  String? projectName;
  String? reraNo;
  String? projectAddress;
  double? pxval;
  double? pyval;
  // DateTime? dos;
  String? dos;
  String? projectContactPerson;
  String? projectPhoneNo;
  String? projectMobileNo;
  int? builderId;
  String? builderName;
  String? builderAddress;
  String? builderContactPerson;
  String? builderPhoneNo;
  String? builderMobileNo;
  String? roadName;
  int? locationId;
  int? suburbId;
  int? cityId;
  int? tenantMixId;
  int? parkingOpen;
  int? parkingStacked;
  int? parkingStilt;
  int? parkingBasement;
  int? parkingPodium;
  double? parkingRatio;
  int? scr;
  int? maintenancePerSqft;
  int? propertyTax;
  double? landParcelSize;
  int? landParcelSizeUnit;
  CSubProjects? subProjects;

  CProjectResponse({
    this.projectId,
    this.projectName,
    this.reraNo,
    this.projectAddress,
    this.pxval,
    this.pyval,
    this.dos,
    this.projectContactPerson,
    this.projectPhoneNo,
    this.projectMobileNo,
    this.builderId,
    this.builderName,
    this.builderAddress,
    this.builderContactPerson,
    this.builderPhoneNo,
    this.builderMobileNo,
    this.roadName,
    this.locationId,
    this.suburbId,
    this.cityId,
    this.tenantMixId,
    this.parkingOpen,
    this.parkingStacked,
    this.parkingStilt,
    this.parkingBasement,
    this.parkingPodium,
    this.parkingRatio,
    this.scr,
    this.maintenancePerSqft,
    this.propertyTax,
    this.landParcelSize,
    this.landParcelSizeUnit,
    this.subProjects,
  });

  factory CProjectResponse.fromJson(Map<String, dynamic> json) => CProjectResponse(
    projectId: json["projectId"],
    projectName: json["projectName"],
    reraNo: json["reraNo"],
    projectAddress: json["projectAddress"],
    pxval: json["pxval"]?.toDouble(),
    pyval: json["pyval"]?.toDouble(),
    // dos: json["dos"] == null ? null : DateTime.parse(json["dos"]),
    dos: json["dos"],
    projectContactPerson: json["projectContactPerson"],
    projectPhoneNo: json["projectPhoneNo"],
    projectMobileNo: json["projectMobileNo"],
    builderId: json["builderId"],
    builderName: json["builderName"],
    builderAddress: json["builderAddress"],
    builderContactPerson: json["builderContactPerson"],
    builderPhoneNo: json["builderPhoneNo"],
    builderMobileNo: json["builderMobileNo"],
    roadName: json["roadName"],
    locationId: json["locationId"],
    suburbId: json["suburbId"],
    cityId: json["cityId"],
    tenantMixId: json["tenantMixId"],
    parkingOpen: json["parkingOpen"],
    parkingStacked: json["parkingStacked"],
    parkingStilt: json["parkingStilt"],
    parkingBasement: json["parkingBasement"],
    parkingPodium: json["parkingPodium"],
    parkingRatio: json["parkingRatio"],
    scr: json["scr"],
    maintenancePerSqft: json["maintenancePerSqft"],
    propertyTax: json["propertyTax"],
    landParcelSize: json["landParcelSize"],
    landParcelSizeUnit: json["landParcelSizeUnit"],
    subProjects: json["subProjects"] == null ? null : CSubProjects.fromJson(json["subProjects"]),
  );

  Map<String, dynamic> toJson() => {
    "projectId": projectId,
    "projectName": projectName,
    "reraNo": reraNo,
    "projectAddress": projectAddress,
    "pxval": pxval,
    "pyval": pyval,
    // "dos": dos?.toIso8601String(),
    "dos": dos,
    "projectContactPerson": projectContactPerson,
    "projectPhoneNo": projectPhoneNo,
    "projectMobileNo": projectMobileNo,
    "builderId": builderId,
    "builderName": builderName,
    "builderAddress": builderAddress,
    "builderContactPerson": builderContactPerson,
    "builderPhoneNo": builderPhoneNo,
    "builderMobileNo": builderMobileNo,
    "roadName": roadName,
    "locationId": locationId,
    "suburbId": suburbId,
    "cityId": cityId,
    "tenantMixId": tenantMixId,
    "parkingOpen": parkingOpen,
    "parkingStacked": parkingStacked,
    "parkingStilt": parkingStilt,
    "parkingBasement": parkingBasement,
    "parkingPodium": parkingPodium,
    "parkingRatio": parkingRatio,
    "scr": scr,
    "maintenancePerSqft": maintenancePerSqft,
    "propertyTax": propertyTax,
    "landParcelSize": landParcelSize,
    "landParcelSizeUnit": landParcelSizeUnit,
    "subProjects": subProjects?.toJson(),
  };
}

class CSubProjects {
  List<ComSubProjectsList>? comSubProjectsList;

  CSubProjects({this.comSubProjectsList});

  factory CSubProjects.fromJson(Map<String, dynamic> json) => CSubProjects(
    comSubProjectsList: json["comSubProjectsList"] == null
        ? []
        : List<ComSubProjectsList>.from(json["comSubProjectsList"]!.map((x) => ComSubProjectsList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "comSubProjectsList": comSubProjectsList == null
        ? []
        : List<dynamic>.from(comSubProjectsList!.map((x) => x.toJson())),
  };
}

class ComSubProjectsList {
  int? subProjectId;
  String? subProjectName;
  int? projectStatusId;
  int? storeyBasement;
  int? storeyPodium;
  int? storeyService;
  int? storeyHabitable;
  //   DateTime? dos;
  //   DateTime? constStartDate;
  //   DateTime? constEndDate;
  //   DateTime? marketingStartDate;
  //   DateTime? marketingEndDate;
  //   DateTime? surveyDate;
  String? dos;
  String? constStartDate;
  String? constEndDate;
  String? marketingStartDate;
  String? marketingEndDate;
  String? surveyDate;
  int? constructionProgressId;
  int? floorSlab;
  int? totalSupplySqft;
  int? soldAreaSqft;
  int? unsoldAreaSqft;
  int? leasedOccupiedArea;
  int? vacancyArea;
  int? minFloorplate;
  int? maxFloorplate;
  int? orBareshell;
  int? orWarmshell;
  int? orFullyFurnished;
  int? lrBareshell;
  int? lrWarmshell;
  int? lrFullyFurnished;
  int? buildingTypeId;
  int? operationModelId;
  String? remarks;
  int? syncStatus;

  ComSubProjectsList({
    this.subProjectId,
    this.subProjectName,
    this.projectStatusId,
    this.storeyBasement,
    this.storeyPodium,
    this.storeyService,
    this.storeyHabitable,
    this.dos,
    this.constStartDate,
    this.constEndDate,
    this.marketingStartDate,
    this.marketingEndDate,
    this.surveyDate,
    this.constructionProgressId,
    this.floorSlab,
    this.totalSupplySqft,
    this.soldAreaSqft,
    this.unsoldAreaSqft,
    this.leasedOccupiedArea,
    this.vacancyArea,
    this.minFloorplate,
    this.maxFloorplate,
    this.orBareshell,
    this.orWarmshell,
    this.orFullyFurnished,
    this.lrBareshell,
    this.lrWarmshell,
    this.lrFullyFurnished,
    this.buildingTypeId,
    this.operationModelId,
    this.remarks,
    this.syncStatus,
  });

  factory ComSubProjectsList.fromJson(Map<String, dynamic> json) => ComSubProjectsList(
    subProjectId: json["subProjectId"],
    subProjectName: json["subProjectName"],
    projectStatusId: json["projectStatusId"],
    storeyBasement: json["storeyBasement"],
    storeyPodium: json["storeyPodium"],
    storeyService: json["storeyService"],
    storeyHabitable: json["storeyHabitable"],
    // dos: json["dos"] == null ? null : DateTime.parse(json["dos"]),
    // constStartDate: json["constStartDate"] == null ? null : DateTime.parse(json["constStartDate"]),
    // constEndDate: json["constEndDate"] == null ? null : DateTime.parse(json["constEndDate"]),
    // marketingStartDate: json["marketingStartDate"] == null ? null : DateTime.parse(json["marketingStartDate"]),
    // marketingEndDate: json["marketingEndDate"] == null ? null : DateTime.parse(json["marketingEndDate"]),
    // surveyDate: json["surveyDate"] == null ? null : DateTime.parse(json["surveyDate"]),
    dos: json["dos"],
    constStartDate: json["constStartDate"],
    constEndDate: json["constEndDate"],
    marketingStartDate: json["marketingStartDate"],
    marketingEndDate: json["marketingEndDate"],
    surveyDate: json["surveyDate"],
    constructionProgressId: json["constructionProgressId"],
    floorSlab: json["floorSlab"],
    totalSupplySqft: json["totalSupplySqft"],
    soldAreaSqft: json["soldAreaSqft"],
    unsoldAreaSqft: json["unsoldAreaSqft"],
    leasedOccupiedArea: json["leasedOccupiedArea"],
    vacancyArea: json["vacancyArea"],
    minFloorplate: json["minFloorplate"],
    maxFloorplate: json["maxFloorplate"],
    orBareshell: json["orBareshell"],
    orWarmshell: json["orWarmshell"],
    orFullyFurnished: json["orFullyFurnished"],
    lrBareshell: json["lrBareshell"],
    lrWarmshell: json["lrWarmshell"],
    lrFullyFurnished: json["lrFullyFurnished"],
    buildingTypeId: json["buildingTypeId"],
    operationModelId: json["operationModelId"],
    remarks: json["remarks"],
    syncStatus: json["syncStatus"],
  );

  Map<String, dynamic> toJson() => {
    "subProjectId": subProjectId,
    "subProjectName": subProjectName,
    "projectStatusId": projectStatusId,
    "storeyBasement": storeyBasement,
    "storeyPodium": storeyPodium,
    "storeyService": storeyService,
    "storeyHabitable": storeyHabitable,
    // "dos": dos?.toIso8601String(),
    // "constStartDate": constStartDate?.toIso8601String(),
    // "constEndDate": constEndDate?.toIso8601String(),
    // "marketingStartDate": marketingStartDate?.toIso8601String(),
    // "marketingEndDate": marketingEndDate?.toIso8601String(),
    // "surveyDate": surveyDate?.toIso8601String(),
    "dos": dos,
    "constStartDate": constStartDate,
    "constEndDate": constEndDate,
    "marketingStartDate": marketingStartDate,
    "marketingEndDate": marketingEndDate,
    "surveyDate": surveyDate,
    "constructionProgressId": constructionProgressId,
    "floorSlab": floorSlab,
    "totalSupplySqft": totalSupplySqft,
    "soldAreaSqft": soldAreaSqft,
    "unsoldAreaSqft": unsoldAreaSqft,
    "leasedOccupiedArea": leasedOccupiedArea,
    "vacancyArea": vacancyArea,
    "minFloorplate": minFloorplate,
    "maxFloorplate": maxFloorplate,
    "orBareshell": orBareshell,
    "orWarmshell": orWarmshell,
    "orFullyFurnished": orFullyFurnished,
    "lrBareshell": lrBareshell,
    "lrWarmshell": lrWarmshell,
    "lrFullyFurnished": lrFullyFurnished,
    "buildingTypeId": buildingTypeId,
    "operationModelId": operationModelId,
    "remarks": remarks,
    "syncStatus": syncStatus,
  };
}
