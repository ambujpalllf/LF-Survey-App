import 'dart:convert';

SpinnerResponse spinnerResponseFromJson(String str) => SpinnerResponse.fromJson(json.decode(str));

String spinnerResponseToJson(SpinnerResponse data) => json.encode(data.toJson());

class SpinnerResponse {
  SpinnerData? data;

  SpinnerResponse({this.data});

  factory SpinnerResponse.fromJson(Map<String, dynamic> json) =>
      SpinnerResponse(data: json["data"] == null ? null : SpinnerData.fromJson(json["data"]));

  Map<String, dynamic> toJson() => {"data": data?.toJson()};
}

class SpinnerData {
  List<ConstProgressList>? constProgressList;
  List<ProjectStatusList>? projectStatusList;
  List<AreaUnitList>? areaUnitList;
  List<ApprovedBankList>? approvedBankList;
  List<AmenitiesList>? amenitiesList;
  List<RemarksList>? bookingStopRemarksList;
  List<RemarksList>? subProjectDeleteRemarksList;
  List<SchemesList>? schemesList;
  List<CostIncludedList>? costIncludedList;
  List<FlatTypeList>? flatTypeList;
  List<DrinkingWaterList>? drinkingWaterList;
  List<CityList>? cityList;
  List<ProjectScaleList>? projectScaleList;
  List<ModularKitchenList>? modularKitchenList;

  SpinnerData({
    this.constProgressList,
    this.projectStatusList,
    this.areaUnitList,
    this.approvedBankList,
    this.amenitiesList,
    this.bookingStopRemarksList,
    this.subProjectDeleteRemarksList,
    this.schemesList,
    this.costIncludedList,
    this.flatTypeList,
    this.drinkingWaterList,
    this.cityList,
    this.projectScaleList,
    this.modularKitchenList,
  });

  factory SpinnerData.fromJson(Map<String, dynamic> json) => SpinnerData(
    constProgressList: json["constProgressList"] == null
        ? []
        : List<ConstProgressList>.from(json["constProgressList"]!.map((x) => ConstProgressList.fromJson(x))),
    projectStatusList: json["projectStatusList"] == null
        ? []
        : List<ProjectStatusList>.from(json["projectStatusList"]!.map((x) => ProjectStatusList.fromJson(x))),
    areaUnitList: json["areaUnitList"] == null
        ? []
        : List<AreaUnitList>.from(json["areaUnitList"]!.map((x) => AreaUnitList.fromJson(x))),
    approvedBankList: json["approvedBankList"] == null
        ? []
        : List<ApprovedBankList>.from(json["approvedBankList"]!.map((x) => ApprovedBankList.fromJson(x))),
    amenitiesList: json["amenitiesList"] == null
        ? []
        : List<AmenitiesList>.from(json["amenitiesList"]!.map((x) => AmenitiesList.fromJson(x))),
    bookingStopRemarksList: json["bookingStopRemarksList"] == null
        ? []
        : List<RemarksList>.from(json["bookingStopRemarksList"]!.map((x) => RemarksList.fromJson(x))),
    subProjectDeleteRemarksList: json["subProjectDeleteRemarksList"] == null
        ? []
        : List<RemarksList>.from(json["subProjectDeleteRemarksList"]!.map((x) => RemarksList.fromJson(x))),
    schemesList: json["schemesList"] == null
        ? []
        : List<SchemesList>.from(json["schemesList"]!.map((x) => SchemesList.fromJson(x))),
    costIncludedList: json["costIncludedList"] == null
        ? []
        : List<CostIncludedList>.from(json["costIncludedList"]!.map((x) => CostIncludedList.fromJson(x))),
    flatTypeList: json["flatTypeList"] == null
        ? []
        : List<FlatTypeList>.from(json["flatTypeList"]!.map((x) => FlatTypeList.fromJson(x))),
    drinkingWaterList: json["drinkingWaterList"] == null
        ? []
        : List<DrinkingWaterList>.from(json["drinkingWaterList"]!.map((x) => DrinkingWaterList.fromJson(x))),
    cityList: json["city_list"] == null ? [] : List<CityList>.from(json["city_list"]!.map((x) => CityList.fromJson(x))),
    projectScaleList: json["project_scale_list"] == null
        ? []
        : List<ProjectScaleList>.from(json["project_scale_list"]!.map((x) => ProjectScaleList.fromJson(x))),
    modularKitchenList: json["modularKitchenList"] == null
        ? []
        : List<ModularKitchenList>.from(json["modularKitchenList"]!.map((x) => ModularKitchenList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "constProgressList": constProgressList == null ? [] : List<dynamic>.from(constProgressList!.map((x) => x.toJson())),
    "projectStatusList": projectStatusList == null ? [] : List<dynamic>.from(projectStatusList!.map((x) => x.toJson())),
    "areaUnitList": areaUnitList == null ? [] : List<dynamic>.from(areaUnitList!.map((x) => x.toJson())),
    "approvedBankList": approvedBankList == null ? [] : List<dynamic>.from(approvedBankList!.map((x) => x.toJson())),
    "amenitiesList": amenitiesList == null ? [] : List<dynamic>.from(amenitiesList!.map((x) => x.toJson())),
    "bookingStopRemarksList": bookingStopRemarksList == null
        ? []
        : List<dynamic>.from(bookingStopRemarksList!.map((x) => x.toJson())),
    "subProjectDeleteRemarksList": subProjectDeleteRemarksList == null
        ? []
        : List<dynamic>.from(subProjectDeleteRemarksList!.map((x) => x.toJson())),
    "schemesList": schemesList == null ? [] : List<dynamic>.from(schemesList!.map((x) => x.toJson())),
    "costIncludedList": costIncludedList == null ? [] : List<dynamic>.from(costIncludedList!.map((x) => x.toJson())),
    "flatTypeList": flatTypeList == null ? [] : List<dynamic>.from(flatTypeList!.map((x) => x.toJson())),
    "drinkingWaterList": drinkingWaterList == null ? [] : List<dynamic>.from(drinkingWaterList!.map((x) => x.toJson())),
    "city_list": cityList == null ? [] : List<dynamic>.from(cityList!.map((x) => x.toJson())),
    "project_scale_list": projectScaleList == null ? [] : List<dynamic>.from(projectScaleList!.map((x) => x.toJson())),
    "modularKitchenList": modularKitchenList == null
        ? []
        : List<dynamic>.from(modularKitchenList!.map((x) => x.toJson())),
  };
}

class AmenitiesList {
  int? amenitiesId;
  String? amenities;

  AmenitiesList({this.amenitiesId, this.amenities});

  factory AmenitiesList.fromJson(Map<String, dynamic> json) =>
      AmenitiesList(amenitiesId: json["amenitiesId"], amenities: json["amenities"]);

  Map<String, dynamic> toJson() => {"amenitiesId": amenitiesId, "amenities": amenities};
}

class ApprovedBankList {
  int? bankId;
  String? bankName;

  ApprovedBankList({this.bankId, this.bankName});

  factory ApprovedBankList.fromJson(Map<String, dynamic> json) =>
      ApprovedBankList(bankId: json["bankId"], bankName: json["bankName"]);

  Map<String, dynamic> toJson() => {"bankId": bankId, "bankName": bankName};
}

class AreaUnitList {
  int? areaUnitId;
  String? areaUnitName;
  double? sqftConvert;

  AreaUnitList({this.areaUnitId, this.areaUnitName, this.sqftConvert});

  factory AreaUnitList.fromJson(Map<String, dynamic> json) => AreaUnitList(
    areaUnitId: json["areaUnitId"],
    areaUnitName: json["areaUnitName"],
    sqftConvert: json["sqftConvert"],
  );

  Map<String, dynamic> toJson() => {"areaUnitId": areaUnitId, "areaUnitName": areaUnitName, "sqftConvert": sqftConvert};
}

class RemarksList {
  int? remarksId;
  String? remarks;

  RemarksList({this.remarksId, this.remarks});

  factory RemarksList.fromJson(Map<String, dynamic> json) =>
      RemarksList(remarksId: json["remarksId"], remarks: json["remarks"]);

  Map<String, dynamic> toJson() => {"remarksId": remarksId, "remarks": remarks};
}

class CityList {
  int? cityId;
  String? city;
  String? areaType;
  int? areaTypeFreeze;

  CityList({this.cityId, this.city, this.areaType, this.areaTypeFreeze});

  factory CityList.fromJson(Map<String, dynamic> json) => CityList(
    cityId: json["city_id"],
    city: json["city"],
    areaType: json["area_type"],
    areaTypeFreeze: json["area_type_freeze"],
  );

  Map<String, dynamic> toJson() => {
    "city_id": cityId,
    "city": city,
    "area_type": areaType,
    "area_type_freeze": areaTypeFreeze,
  };
}

class ConstProgressList {
  int? constProgressId;
  String? constProgress;

  ConstProgressList({this.constProgressId, this.constProgress});

  factory ConstProgressList.fromJson(Map<String, dynamic> json) =>
      ConstProgressList(constProgressId: json["constProgressId"], constProgress: json["constProgress"]);

  Map<String, dynamic> toJson() => {"constProgressId": constProgressId, "constProgress": constProgress};
}

class CostIncludedList {
  int? costId;
  String? costType;

  CostIncludedList({this.costId, this.costType});

  factory CostIncludedList.fromJson(Map<String, dynamic> json) =>
      CostIncludedList(costId: json["costId"], costType: json["costType"]);

  Map<String, dynamic> toJson() => {"costId": costId, "costType": costType};
}

class DrinkingWaterList {
  String? drinkingWater;

  DrinkingWaterList({this.drinkingWater});

  factory DrinkingWaterList.fromJson(Map<String, dynamic> json) =>
      DrinkingWaterList(drinkingWater: json["drinkingWater"]);

  Map<String, dynamic> toJson() => {"drinkingWater": drinkingWater};
}

class FlatTypeList {
  int? flatId;
  String? flatType;
  int? flatTypeId;
  int? minValue;
  int? maxValue;

  FlatTypeList({this.flatId, this.flatType, this.flatTypeId, this.minValue, this.maxValue});

  factory FlatTypeList.fromJson(Map<String, dynamic> json) => FlatTypeList(
    flatId: json["flatId"],
    flatType: json["flatType"],
    flatTypeId: json["flatTypeId"],
    minValue: json["min_value"],
    maxValue: json["max_value"],
  );

  Map<String, dynamic> toJson() => {
    "flatId": flatId,
    "flatType": flatType,
    "flatTypeId": flatTypeId,
    "min_value": minValue,
    "max_value": maxValue,
  };
}

class ModularKitchenList {
  String? modularKitchenId;
  String? modularKitchen;

  ModularKitchenList({this.modularKitchenId, this.modularKitchen});

  factory ModularKitchenList.fromJson(Map<String, dynamic> json) =>
      ModularKitchenList(modularKitchenId: json["modularKitchenId"], modularKitchen: json["modularKitchen"]);

  Map<String, dynamic> toJson() => {"modularKitchenId": modularKitchenId, "modularKitchen": modularKitchen};
}

class ProjectScaleList {
  int? scaleId;
  String? projectScale;

  ProjectScaleList({this.scaleId, this.projectScale});

  factory ProjectScaleList.fromJson(Map<String, dynamic> json) =>
      ProjectScaleList(scaleId: json["scale_id"], projectScale: json["project_scale"]);

  Map<String, dynamic> toJson() => {"scale_id": scaleId, "project_scale": projectScale};
}

class ProjectStatusList {
  int? projectStatusId;
  String? projectStatus;

  ProjectStatusList({this.projectStatusId, this.projectStatus});

  factory ProjectStatusList.fromJson(Map<String, dynamic> json) =>
      ProjectStatusList(projectStatusId: json["projectStatusId"], projectStatus: json["projectStatus"]);

  Map<String, dynamic> toJson() => {"projectStatusId": projectStatusId, "projectStatus": projectStatus};
}

class SchemesList {
  int? schemesId;
  String? schemesType;
  bool? isOpenText;

  SchemesList({this.schemesId, this.schemesType, this.isOpenText});

  factory SchemesList.fromJson(Map<String, dynamic> json) {
    dynamic val = json["isOpenText"];
    bool? isOpen;

    if (val is int) {
      isOpen = val == 1; // convert 1/0 to true/false
    } else if (val is bool) {
      isOpen = val; // already a bool
    }

    return SchemesList(
      schemesId: json["schemesId"] as int?,
      schemesType: json["schemesType"] as String?,
      isOpenText: isOpen,
    );
  }

  Map<String, dynamic> toJson() => {
    "schemesId": schemesId,
    "schemesType": schemesType,
    "isOpenText": isOpenText == true ? 1 : 0,
  };
}
