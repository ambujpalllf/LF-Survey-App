import 'dart:convert';
import 'package:lf_survey/model/construction_monitoring/cm_building_response.dart';
import 'package:lf_survey/model/pams_survey/land_response.dart';

PsPrjResponse psPrjResponseFromJson(String str) => PsPrjResponse.fromJson(json.decode(str));

String psPrjResponseToJson(PsPrjResponse data) => json.encode(data.toJson());

class PsPrjResponse {
  List<PsPrjDatum>? data;
  String? status;
  String? message;

  PsPrjResponse({this.data, this.status, this.message});

  factory PsPrjResponse.fromJson(Map<String, dynamic> json) => PsPrjResponse(
    data: json["data"] == null ? [] : List<PsPrjDatum>.from(json["data"].map((x) => PsPrjDatum.fromJson(x))),
    status: json["status"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "status": status,
    "message": message,
  };
}

class PsPrjDatum {
  int? projectId;
  String? projectName;
  String? reraRegNo;
  int? lfprojectId;
  int? superProjectId;
  String? projectAddonJson;
  String? builderGroup;
  int? spvId;
  double? lat;
  double? lng;
  int? locationId;
  String? legalAddress;
  int? constructionTypeId;
  String? constructionQuality;
  String? geoType;
  bool? isGreen;
  int? legalAdvisorId;
  int? caId;
  bool? hasSolar;
  bool? hasRainHarvest;
  bool? hasSewage;
  bool? hasGenBackup;
  String? parkingJsonAsPerApprovedPlan;
  String? parkingJsonAsPerSalesSheet;
  int? architectId;
  int? contractorId;
  String? projectBuildingName;
  String? projectAddressRoadName;
  String? projectAddressSubLocality;
  String? projectAddressNearbyLandmark;
  String? projectAddressCity;
  String? projectAddressDistrict;
  String? projectAddressState;
  String? projectAddressPincode;
  String? confirmationAddress;
  List<int>? amenitiesIds;
  bool? isItTheTallestBuilding;
  bool? areAllResidentsCelebrities;
  bool? areAllUnitsLarge;
  bool? hasSolarPower;
  bool? hasRainwaterHarvesting;
  bool? hasSewageTreatment;
  bool? hasGeneratorBackup;
  String? readyReckonerValue;
  DateTime? reraStartDate;
  DateTime? reraCompletionDate;
  DateTime? reraExtendedCompletionDate;
  String? reraLitigationCount;
  String? reraLitigationDetails;
  String? reraRemarks;
  String? reraName;
  String? districtName;
  String? talukaName;
  String? villageName;
  String? zoneName;
  String? surveyNumber;
  // List<WingData>? wings;
  List<BuildingData>? buildings;
  int? apfStatus;
  int? cmStatus;
  int? allocationId;
  int? localSync;
  int? globalSync;
  PsLandDatum? landDetails;

  PsPrjDatum({
    this.projectId,
    this.projectName,
    this.reraRegNo,
    this.lfprojectId,
    this.superProjectId,
    this.projectAddonJson,
    this.builderGroup,
    this.spvId,
    this.lat,
    this.lng,
    this.locationId,
    this.legalAddress,
    this.constructionTypeId,
    this.constructionQuality,
    this.geoType,
    this.isGreen,
    this.legalAdvisorId,
    this.caId,
    this.hasSolar,
    this.hasRainHarvest,
    this.hasSewage,
    this.hasGenBackup,
    this.parkingJsonAsPerApprovedPlan,
    this.parkingJsonAsPerSalesSheet,
    this.architectId,
    this.contractorId,
    this.projectBuildingName,
    this.projectAddressRoadName,
    this.projectAddressSubLocality,
    this.projectAddressNearbyLandmark,
    this.projectAddressCity,
    this.projectAddressDistrict,
    this.projectAddressState,
    this.projectAddressPincode,
    this.confirmationAddress,
    this.amenitiesIds,
    this.isItTheTallestBuilding,
    this.areAllResidentsCelebrities,
    this.areAllUnitsLarge,
    this.hasSolarPower,
    this.hasRainwaterHarvesting,
    this.hasSewageTreatment,
    this.hasGeneratorBackup,
    this.readyReckonerValue,
    this.reraStartDate,
    this.reraCompletionDate,
    this.reraExtendedCompletionDate,
    this.reraLitigationCount,
    this.reraLitigationDetails,
    this.reraRemarks,
    this.reraName,
    this.districtName,
    this.talukaName,
    this.villageName,
    this.zoneName,
    this.surveyNumber,
    // this.wings,
    this.buildings,
    this.apfStatus,
    this.cmStatus,
    this.allocationId,
    this.globalSync,
    this.localSync,
    this.landDetails,
  });

  factory PsPrjDatum.fromJson(Map<String, dynamic> json) {
    // List<WingData> parsedWings = [];

    // if (json['wings'] != null && json['wings'] is List) {
    //   parsedWings = (json['wings'] as List).map((e) => WingData.fromJson(e)).toList();
    // }

    List<BuildingData> parsedBuildings = [];
    if (json['buildings'] != null && json['buildings'] is List) {
      parsedBuildings = (json['buildings'] as List).map((e) => BuildingData.fromJson(e)).toList();
    }
    return PsPrjDatum(
      projectId: json["project_id"],
      projectName: json["project_name"],
      reraRegNo: json["rera_reg_no"],
      lfprojectId: json["lfproject_id"],
      superProjectId: json["super_project_id"],
      // projectAddonJson: json["project_addon_json"],
      projectAddonJson: json["project_addon_json"] != null ? jsonEncode(json["project_addon_json"]) : null,
      builderGroup: json["builder_group"],
      spvId: json["spv_id"],
      lat: json["lat"]?.toDouble(),
      lng: json["lng"]?.toDouble(),
      locationId: json["location_id"],
      legalAddress: json["legal_address"],
      constructionTypeId: json["construction_type_id"],
      constructionQuality: json["construction_quality"],
      geoType: json["geo_type"],
      isGreen: json["is_green"] == 1,
      legalAdvisorId: json["legal_advisor_id"],
      caId: json["ca_id"],
      hasSolar: json["has_solar"] == 1,
      hasRainHarvest: json["has_rain_harvest"] == 1,
      hasSewage: json["has_sewage"] == 1,
      hasGenBackup: json["has_gen_backup"] == 1,
      parkingJsonAsPerApprovedPlan: json["parking_json_as_per_approved_plan"] != null
          ? jsonEncode(json["parking_json_as_per_approved_plan"])
          : null,
      parkingJsonAsPerSalesSheet: json["parking_json_as_per_sales_sheet"] != null
          ? jsonEncode(json["parking_json_as_per_sales_sheet"])
          : null,
      architectId: json["architect_id"],
      contractorId: json["contractor_id"],
      projectBuildingName: json["project_building_name"],
      projectAddressRoadName: json["project_address_road_name"],
      projectAddressSubLocality: json["project_address_sub_locality"],
      projectAddressNearbyLandmark: json["project_address_nearby_landmark"],
      projectAddressCity: json["project_address_city"],
      projectAddressDistrict: json["project_address_district"],
      projectAddressState: json["project_address_state"],
      projectAddressPincode: json["project_address_pincode"],
      confirmationAddress: json["confirmation_address"],
      amenitiesIds: json["amenities_ids"] == null ? [] : List<int>.from(jsonDecode(json["amenities_ids"].toString())),
      // amenitiesIds: json["amenities_ids"] == null ? [] : List<int>.from(json["amenities_ids"]!.map((x) => x)),
      isItTheTallestBuilding: json["is_it_the_tallest_building"] == 1,
      areAllResidentsCelebrities: json["are_all_residents_celebrities"] == 1,
      areAllUnitsLarge: json["are_all_units_large"] == 1,
      hasSolarPower: json["has_solar_power"] == 1,
      hasRainwaterHarvesting: json["has_rainwater_harvesting"] == 1,
      hasSewageTreatment: json["has_sewage_treatment"] == 1,
      hasGeneratorBackup: json["has_generator_backup"] == 1,
      readyReckonerValue: json["ready_reckoner_value"],
      reraStartDate: json["rera_start_date"] == null ? null : DateTime.parse(json["rera_start_date"]),
      reraCompletionDate: json["rera_completion_date"] == null ? null : DateTime.parse(json["rera_completion_date"]),
      reraExtendedCompletionDate: json["rera_extended_completion_date"] == null
          ? null
          : DateTime.parse(json["rera_extended_completion_date"]),
      reraLitigationCount: json["rera_litigation_count"],
      reraLitigationDetails: json["rera_litigation_details"],
      reraRemarks: json["rera_remarks"],
      reraName: json["rera_name"],
      districtName: json["district_name"],
      talukaName: json["taluka_name"],
      villageName: json["village_name"],
      zoneName: json["zone_name"],
      surveyNumber: json["survey_number"],
      // wings: parsedWings,
      buildings: parsedBuildings,
      apfStatus: json["apf_status"],
      cmStatus: json["cm_status"],
      allocationId: json["allocation_id"],
      localSync: json["localSync"],
      globalSync: json["globalSync"],
      landDetails: json["land_details"] == null ? null : PsLandDatum.fromJson(json["land_details"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "project_id": projectId,
    "project_name": projectName,
    "rera_reg_no": reraRegNo,
    "lfproject_id": lfprojectId,
    "super_project_id": superProjectId,
    "project_addon_json": projectAddonJson,
    "builder_group": builderGroup,
    "spv_id": spvId,
    "lat": lat,
    "lng": lng,
    "location_id": locationId,
    "legal_address": legalAddress,
    "construction_type_id": constructionTypeId,
    "construction_quality": constructionQuality,
    "geo_type": geoType,
    "is_green": isGreen,
    "legal_advisor_id": legalAdvisorId,
    "ca_id": caId,
    "has_solar": hasSolar,
    "has_rain_harvest": hasRainHarvest,
    "has_sewage": hasSewage,
    "has_gen_backup": hasGenBackup,
    "parking_json_as_per_approved_plan": parkingJsonAsPerApprovedPlan,
    "parking_json_as_per_sales_sheet": parkingJsonAsPerSalesSheet,
    "architect_id": architectId,
    "contractor_id": contractorId,
    "project_building_name": projectBuildingName,
    "project_address_road_name": projectAddressRoadName,
    "project_address_sub_locality": projectAddressSubLocality,
    "project_address_nearby_landmark": projectAddressNearbyLandmark,
    "project_address_city": projectAddressCity,
    "project_address_district": projectAddressDistrict,
    "project_address_state": projectAddressState,
    "project_address_pincode": projectAddressPincode,
    "confirmation_address": confirmationAddress,
    "amenities_ids": amenitiesIds,
    "is_it_the_tallest_building": isItTheTallestBuilding,
    "are_all_residents_celebrities": areAllResidentsCelebrities,
    "are_all_units_large": areAllUnitsLarge,
    "has_solar_power": hasSolarPower,
    "has_rainwater_harvesting": hasRainwaterHarvesting,
    "has_sewage_treatment": hasSewageTreatment,
    "has_generator_backup": hasGeneratorBackup,
    "ready_reckoner_value": readyReckonerValue,
    "rera_start_date": reraStartDate?.toIso8601String(),
    "rera_completion_date": reraCompletionDate?.toIso8601String(),
    "rera_extended_completion_date": reraExtendedCompletionDate?.toIso8601String(),
    "rera_litigation_count": reraLitigationCount,
    "rera_litigation_details": reraLitigationDetails,
    "rera_remarks": reraRemarks,
    "rera_name": reraName,
    "district_name": districtName,
    "taluka_name": talukaName,
    "village_name": villageName,
    "zone_name": zoneName,
    "survey_number": surveyNumber,
    // "wings": jsonEncode(wings?.map((e) => e.toJson()).toList()),
    "buildings": jsonEncode(buildings?.map((e) => e.toJson()).toList()),
  };

  Map<String, dynamic> toPsPrjDB() => {
    "project_id": projectId,
    "project_name": projectName,
    "rera_reg_no": reraRegNo,
    "lfproject_id": lfprojectId,
    "super_project_id": superProjectId,
    "project_addon_json": projectAddonJson != null ? jsonEncode(projectAddonJson) : null,
    "builder_group": builderGroup,
    "spv_id": spvId,
    "lat": lat,
    "lng": lng,
    "location_id": locationId,
    "legal_address": legalAddress,
    "construction_type_id": constructionTypeId,
    "construction_quality": constructionQuality,
    "geo_type": geoType,
    "is_green": isGreen == true ? 1 : 0,
    "legal_advisor_id": legalAdvisorId,
    "ca_id": caId,
    "has_solar": hasSolar == true ? 1 : 0,
    "has_rain_harvest": hasRainHarvest == true ? 1 : 0,
    "has_sewage": hasSewage == true ? 1 : 0,
    "has_gen_backup": hasGenBackup == true ? 1 : 0,
    "parking_json_as_per_approved_plan": parkingJsonAsPerApprovedPlan != null
        ? jsonEncode(parkingJsonAsPerApprovedPlan)
        : null,
    "parking_json_as_per_sales_sheet": parkingJsonAsPerSalesSheet != null
        ? jsonEncode(parkingJsonAsPerSalesSheet)
        : null,
    "architect_id": architectId,
    "contractor_id": contractorId,
    "project_building_name": projectBuildingName,
    "project_address_road_name": projectAddressRoadName,
    "project_address_sub_locality": projectAddressSubLocality,
    "project_address_nearby_landmark": projectAddressNearbyLandmark,
    "project_address_city": projectAddressCity,
    "project_address_district": projectAddressDistrict,
    "project_address_state": projectAddressState,
    "project_address_pincode": projectAddressPincode,
    "confirmation_address": confirmationAddress,
    "amenities_ids": amenitiesIds != null ? jsonEncode(amenitiesIds) : null,
    "is_it_the_tallest_building": isItTheTallestBuilding == true ? 1 : 0,
    "are_all_residents_celebrities": areAllResidentsCelebrities == true ? 1 : 0,
    "are_all_units_large": areAllUnitsLarge == true ? 1 : 0,
    "has_solar_power": hasSolarPower == true ? 1 : 0,
    "has_rainwater_harvesting": hasRainwaterHarvesting == true ? 1 : 0,
    "has_sewage_treatment": hasSewageTreatment == true ? 1 : 0,
    "has_generator_backup": hasGeneratorBackup == true ? 1 : 0,
    "ready_reckoner_value": readyReckonerValue,
    "rera_start_date": reraStartDate?.toIso8601String(),
    "rera_completion_date": reraCompletionDate?.toIso8601String(),
    "rera_extended_completion_date": reraExtendedCompletionDate?.toIso8601String(),
    "rera_litigation_count": reraLitigationCount,
    "rera_litigation_details": reraLitigationDetails,
    "rera_remarks": reraRemarks,
    "rera_name": reraName,
    "district_name": districtName,
    "taluka_name": talukaName,
    "village_name": villageName,
    "zone_name": zoneName,
    "survey_number": surveyNumber,
    // "wings": jsonEncode(wings?.map((e) => e.toJson()).toList()),
    "apf_status": apfStatus,
    "cm_status": cmStatus,
    "allocation_id": allocationId,
    "localSync": localSync ?? 0,
    "globalSync": globalSync ?? 0,
  };
}
