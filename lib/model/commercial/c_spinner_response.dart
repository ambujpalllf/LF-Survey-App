class CSpinnerData {
  List<CConstProgressList>? constProgressList;
  List<CProjectStatusList>? projectStatusList;
  List<CAreaUnitList>? areaUnitList;
  List<CApprovedBankList>? approvedBankList;
  List<CAmenitiesList>? amenitiesList;
  List<CCityList>? cityList;
  List<COperatingModelList>? operatingModelList;
  List<CBuildingTypeList>? buildingTypeList;
  List<CTenantMixList>? tenantMixList;

  CSpinnerData({
    this.constProgressList,
    this.projectStatusList,
    this.areaUnitList,
    this.approvedBankList,
    this.amenitiesList,
    this.cityList,
    this.operatingModelList,
    this.buildingTypeList,
    this.tenantMixList,
  });

  factory CSpinnerData.fromJson(Map<String, dynamic> json) => CSpinnerData(
    constProgressList: json["constProgressList"] == null
        ? []
        : List<CConstProgressList>.from(json["constProgressList"]!.map((x) => CConstProgressList.fromJson(x))),
    projectStatusList: json["projectStatusList"] == null
        ? []
        : List<CProjectStatusList>.from(json["projectStatusList"]!.map((x) => CProjectStatusList.fromJson(x))),
    areaUnitList: json["areaUnitList"] == null
        ? []
        : List<CAreaUnitList>.from(json["areaUnitList"]!.map((x) => CAreaUnitList.fromJson(x))),
    approvedBankList: json["approvedBankList"] == null
        ? []
        : List<CApprovedBankList>.from(json["approvedBankList"]!.map((x) => CApprovedBankList.fromJson(x))),
    amenitiesList: json["amenitiesList"] == null
        ? []
        : List<CAmenitiesList>.from(json["amenitiesList"]!.map((x) => CAmenitiesList.fromJson(x))),
    cityList: json["city_list"] == null
        ? []
        : List<CCityList>.from(json["city_list"]!.map((x) => CCityList.fromJson(x))),
    operatingModelList: json["operatingModelList"] == null
        ? []
        : List<COperatingModelList>.from(json["operatingModelList"]!.map((x) => COperatingModelList.fromJson(x))),
    buildingTypeList: json["buildingTypeList"] == null
        ? []
        : List<CBuildingTypeList>.from(json["buildingTypeList"]!.map((x) => CBuildingTypeList.fromJson(x))),
    tenantMixList: json["tenantMixList"] == null
        ? []
        : List<CTenantMixList>.from(json["tenantMixList"]!.map((x) => CTenantMixList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "constProgressList": constProgressList == null ? [] : List<dynamic>.from(constProgressList!.map((x) => x.toJson())),
    "projectStatusList": projectStatusList == null ? [] : List<dynamic>.from(projectStatusList!.map((x) => x.toJson())),
    "areaUnitList": areaUnitList == null ? [] : List<dynamic>.from(areaUnitList!.map((x) => x.toJson())),
    "approvedBankList": approvedBankList == null ? [] : List<dynamic>.from(approvedBankList!.map((x) => x.toJson())),
    "amenitiesList": amenitiesList == null ? [] : List<dynamic>.from(amenitiesList!.map((x) => x.toJson())),
    "city_list": cityList == null ? [] : List<dynamic>.from(cityList!.map((x) => x.toJson())),
    "operatingModelList": operatingModelList == null
        ? []
        : List<dynamic>.from(operatingModelList!.map((x) => x.toJson())),
    "buildingTypeList": buildingTypeList == null ? [] : List<dynamic>.from(buildingTypeList!.map((x) => x.toJson())),
    "tenantMixList": tenantMixList == null ? [] : List<dynamic>.from(tenantMixList!.map((x) => x.toJson())),
  };
}

class CAmenitiesList {
  int? amenitiesId;
  String? amenities;

  CAmenitiesList({this.amenitiesId, this.amenities});

  factory CAmenitiesList.fromJson(Map<String, dynamic> json) =>
      CAmenitiesList(amenitiesId: json["amenitiesId"], amenities: json["amenities"]);

  Map<String, dynamic> toJson() => {"amenitiesId": amenitiesId, "amenities": amenities};
}

class CApprovedBankList {
  int? bankId;
  String? bankName;

  CApprovedBankList({this.bankId, this.bankName});

  factory CApprovedBankList.fromJson(Map<String, dynamic> json) =>
      CApprovedBankList(bankId: json["bankId"], bankName: json["bankName"]);

  Map<String, dynamic> toJson() => {"bankId": bankId, "bankName": bankName};
}

class CAreaUnitList {
  int? areaUnitId;
  String? areaUnitName;
  double? sqftConvert;

  CAreaUnitList({this.areaUnitId, this.areaUnitName, this.sqftConvert});

  factory CAreaUnitList.fromJson(Map<String, dynamic> json) => CAreaUnitList(
    areaUnitId: json["areaUnitId"],
    areaUnitName: json["areaUnitName"],
    sqftConvert: json["sqftConvert"],
  );

  Map<String, dynamic> toJson() => {"areaUnitId": areaUnitId, "areaUnitName": areaUnitName, "sqftConvert": sqftConvert};
}

class CBuildingTypeList {
  int? buildingTypeId;
  String? buildingType;

  CBuildingTypeList({this.buildingTypeId, this.buildingType});

  factory CBuildingTypeList.fromJson(Map<String, dynamic> json) =>
      CBuildingTypeList(buildingTypeId: json["buildingTypeId"], buildingType: json["buildingType"]);

  Map<String, dynamic> toJson() => {"buildingTypeId": buildingTypeId, "buildingType": buildingType};
}

class CCityList {
  int? cityId;
  String? city;
  String? areaType;

  CCityList({this.cityId, this.city, this.areaType});

  factory CCityList.fromJson(Map<String, dynamic> json) =>
      CCityList(cityId: json["city_id"], city: json["city"], areaType: json["area_type"]);

  Map<String, dynamic> toJson() => {"city_id": cityId, "city": city, "area_type": areaType};
}

class CConstProgressList {
  int? constProgressId;
  String? constProgress;

  CConstProgressList({this.constProgressId, this.constProgress});

  factory CConstProgressList.fromJson(Map<String, dynamic> json) =>
      CConstProgressList(constProgressId: json["constProgressId"], constProgress: json["constProgress"]);

  Map<String, dynamic> toJson() => {"constProgressId": constProgressId, "constProgress": constProgress};
}

class COperatingModelList {
  int? operatingModelId;
  String? operatingModel;

  COperatingModelList({this.operatingModelId, this.operatingModel});

  factory COperatingModelList.fromJson(Map<String, dynamic> json) =>
      COperatingModelList(operatingModelId: json["operatingModelId"], operatingModel: json["operatingModel"]);

  Map<String, dynamic> toJson() => {"operatingModelId": operatingModelId, "operatingModel": operatingModel};
}

class CProjectStatusList {
  int? projectStatusId;
  String? projectStatus;

  CProjectStatusList({this.projectStatusId, this.projectStatus});

  factory CProjectStatusList.fromJson(Map<String, dynamic> json) =>
      CProjectStatusList(projectStatusId: json["projectStatusId"], projectStatus: json["projectStatus"]);

  Map<String, dynamic> toJson() => {"projectStatusId": projectStatusId, "projectStatus": projectStatus};
}

class CTenantMixList {
  int? tenantMixId;
  String? tenantMix;

  CTenantMixList({this.tenantMixId, this.tenantMix});

  factory CTenantMixList.fromJson(Map<String, dynamic> json) =>
      CTenantMixList(tenantMixId: json["tenantMixId"], tenantMix: json["tenantMix"]);

  Map<String, dynamic> toJson() => {"tenantMixId": tenantMixId, "tenantMix": tenantMix};
}
