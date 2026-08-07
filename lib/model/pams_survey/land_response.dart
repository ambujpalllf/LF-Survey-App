import 'dart:convert';

PsLandResponse psLandResponseFromJson(String str) => PsLandResponse.fromJson(json.decode(str));

String psLandResponseToJson(PsLandResponse data) => json.encode(data.toJson());

class PsLandResponse {
  List<PsLandDatum>? data;
  String? status;
  String? message;

  PsLandResponse({this.data, this.status, this.message});

  factory PsLandResponse.fromJson(Map<String, dynamic> json) => PsLandResponse(
    data: json["data"] == null ? [] : List<PsLandDatum>.from(json["data"]!.map((x) => PsLandDatum.fromJson(x))),
    status: json["status"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "status": status,
    "message": message,
  };
}

class PsLandDatum {
  int? projectLandId;
  int? projectId;
  int? allocationId;
  String? landUse;
  double? lat;
  double? lng;
  String? localityClass;
  String? landSituatedOn;
  String? areaAsPerSite;
  String? areaAsPerOwnershipDocument;
  String? areaAsPerMeasurementSheet;
  String? areaAsPerApprovedPlan;
  String? areaOfPlotDeviation;
  String? permissibleFsiBuaResidential;
  String? permissibleFsiBuaCommercial;
  String? permissibleFsiBuaOthers;
  String? permissibleFsiBuaTotal;
  String? consumedFsiBuaResidential;
  String? consumedFsiBuaCommercial;
  String? consumedFsiBuaOthers;
  String? consumedFsiBuaTotal;
  String? buildUpAreaRemark;
  String? projectAreaDetailsFsiFarDetails;
  String? projectAreaDetailsPlotFsiFar;
  String? projectAreaDetailsPremiumFsiFar;
  String? projectAreaDetailsPremiumTdrFsi;
  String? projectAreaDetailsPremiumFungiableFsi;
  String? projectAreaDetailsFsiUnderRegulation1;
  String? projectAreaDetailsFsiUnderRegulation2;
  String? projectAreaDetailsTotalFsiFar;
  String? widthOfAccesssRoad;
  String? typeOfAccessRoad;
  String? eastAsPerSite;
  String? eastAsPerDocument;
  String? eastAsPerRera;
  String? eastDeviation;
  String? westAsPerSite;
  String? westAsPerDocument;
  String? westAsPerRera;
  String? westDeviation;
  String? northAsPerSite;
  String? northAsPerDocument;
  String? northAsPerRera;
  String? northDeviation;
  String? southAsPerSite;
  String? southAsPerDocument;
  String? southAsPerRera;
  String? southDeviation;
  String? civicAminitiesJson;
  String? criticalParametersSeismicZone;
  String? criticalParametersFloodProneArea;
  String? criticalParametersCoastalRegulatoryZone;
  String? criticalParametersZoningAsPerDevelopmentPlan;
  String? criticalParametersFallingInPresent;
  String? criticalParametersPropertyWithin30MFromRailway;
  String? criticalParametersPropertyNearHtLtLines;
  String? criticalParametersPresenceOfNallahWaterBodyNearby;
  String? criticalParametersFsiDeviation;
  String? criticalParametersVerticalDeviation;
  String? criticalParametersUnitDeviation;
  String? criticalParametersHabitation;
  String? criticalParametersRemarks;
  String? criticalParametersFallingInReservation;
  String? constructionStatus;
  String? constructionMaterialStatus;
  String? labourStatusonSite;
  String? projectCFByWhichBank;
  String? projectHomeloanAvailble;
  String? visitCharges;
  String? revisitRemarks;
  int? localSync;
  int? globalSync;

  PsLandDatum({
    this.projectLandId,
    this.projectId,
    this.allocationId,
    this.landUse,
    this.lat,
    this.lng,
    this.localityClass,
    this.landSituatedOn,
    this.areaAsPerSite,
    this.areaAsPerOwnershipDocument,
    this.areaAsPerMeasurementSheet,
    this.areaAsPerApprovedPlan,
    this.areaOfPlotDeviation,
    this.permissibleFsiBuaResidential,
    this.permissibleFsiBuaCommercial,
    this.permissibleFsiBuaOthers,
    this.permissibleFsiBuaTotal,
    this.consumedFsiBuaResidential,
    this.consumedFsiBuaCommercial,
    this.consumedFsiBuaOthers,
    this.consumedFsiBuaTotal,
    this.buildUpAreaRemark,
    this.projectAreaDetailsFsiFarDetails,
    this.projectAreaDetailsPlotFsiFar,
    this.projectAreaDetailsPremiumFsiFar,
    this.projectAreaDetailsPremiumTdrFsi,
    this.projectAreaDetailsPremiumFungiableFsi,
    this.projectAreaDetailsFsiUnderRegulation1,
    this.projectAreaDetailsFsiUnderRegulation2,
    this.projectAreaDetailsTotalFsiFar,
    this.widthOfAccesssRoad,
    this.typeOfAccessRoad,
    this.eastAsPerSite,
    this.eastAsPerDocument,
    this.eastAsPerRera,
    this.eastDeviation,
    this.westAsPerSite,
    this.westAsPerDocument,
    this.westAsPerRera,
    this.westDeviation,
    this.northAsPerSite,
    this.northAsPerDocument,
    this.northAsPerRera,
    this.northDeviation,
    this.southAsPerSite,
    this.southAsPerDocument,
    this.southAsPerRera,
    this.southDeviation,
    this.civicAminitiesJson,
    this.criticalParametersSeismicZone,
    this.criticalParametersFloodProneArea,
    this.criticalParametersCoastalRegulatoryZone,
    this.criticalParametersZoningAsPerDevelopmentPlan,
    this.criticalParametersFallingInPresent,
    this.criticalParametersPropertyWithin30MFromRailway,
    this.criticalParametersPropertyNearHtLtLines,
    this.criticalParametersPresenceOfNallahWaterBodyNearby,
    this.criticalParametersFsiDeviation,
    this.criticalParametersVerticalDeviation,
    this.criticalParametersUnitDeviation,
    this.criticalParametersHabitation,
    this.criticalParametersRemarks,
    this.criticalParametersFallingInReservation,
    this.constructionStatus,
    this.constructionMaterialStatus,
    this.labourStatusonSite,
    this.projectCFByWhichBank,
    this.projectHomeloanAvailble,
    this.visitCharges,
    this.revisitRemarks,
    this.globalSync,
    this.localSync,
  });

  factory PsLandDatum.fromJson(Map<String, dynamic> json) => PsLandDatum(
    projectLandId: json["project_land_id"],
    projectId: json["project_id"],
    allocationId: json["allocationId"],
    landUse: json["land_use"],
    lat: json['lat'],
    lng: json['lng'],
    localityClass: json["locality_class"],
    landSituatedOn: json["land_situated_on"],
    areaAsPerSite: json["area_as_per_site"],
    areaAsPerOwnershipDocument: json["area_as_per_ownership_document"],
    areaAsPerMeasurementSheet: json["area_as_per_measurement_sheet"],
    areaAsPerApprovedPlan: json["area_as_per_approved_plan"],
    areaOfPlotDeviation: json["area_of_plot_deviation"],
    permissibleFsiBuaResidential: json["permissible_fsi_bua_residential"],
    permissibleFsiBuaCommercial: json["permissible_fsi_bua_commercial"],
    permissibleFsiBuaOthers: json["permissible_fsi_bua_others"],
    permissibleFsiBuaTotal: json["permissible_fsi_bua_total"],
    consumedFsiBuaResidential: json["consumed_fsi_bua_residential"],
    consumedFsiBuaCommercial: json["consumed_fsi_bua_commercial"],
    consumedFsiBuaOthers: json["consumed_fsi_bua_others"],
    consumedFsiBuaTotal: json["consumed_fsi_bua_total"],
    buildUpAreaRemark: json["build_up_area_remark"],
    projectAreaDetailsFsiFarDetails: json["project_area_details_fsi_far_details"],
    projectAreaDetailsPlotFsiFar: json["project_area_details_plot_fsi_far"],
    projectAreaDetailsPremiumFsiFar: json["project_area_details_premium_fsi_far"],
    projectAreaDetailsPremiumTdrFsi: json["project_area_details_premium_tdr_fsi"],
    projectAreaDetailsPremiumFungiableFsi: json["project_area_details_premium_fungiable_fsi"],
    projectAreaDetailsFsiUnderRegulation1: json["project_area_details_fsi_under_regulation_1"],
    projectAreaDetailsFsiUnderRegulation2: json["project_area_details_fsi_under_regulation_2"],
    projectAreaDetailsTotalFsiFar: json["project_area_details_total_fsi_far"],
    widthOfAccesssRoad: json["width_of_accesss_road"],
    typeOfAccessRoad: json["type_of_access_road"],
    eastAsPerSite: json["east_as_per_site"],
    eastAsPerDocument: json["east_as_per_document"],
    eastAsPerRera: json["east_as_per_rera"],
    eastDeviation: json["east_deviation"],
    westAsPerSite: json["west_as_per_site"],
    westAsPerDocument: json["west_as_per_document"],
    westAsPerRera: json["west_as_per_rera"],
    westDeviation: json["west_deviation"],
    northAsPerSite: json["north_as_per_site"],
    northAsPerDocument: json["north_as_per_document"],
    northAsPerRera: json["north_as_per_rera"],
    northDeviation: json["north_deviation"],
    southAsPerSite: json["south_as_per_site"],
    southAsPerDocument: json["south_as_per_document"],
    southAsPerRera: json["south_as_per_rera"],
    southDeviation: json["south_deviation"],
    civicAminitiesJson: json["civic_aminities_json"] != null ? jsonEncode(json["civic_aminities_json"]) : null,
    criticalParametersSeismicZone: json["critical_parameters_seismic_zone"],
    criticalParametersFloodProneArea: json["critical_parameters_flood_prone_area"],
    criticalParametersCoastalRegulatoryZone: json["critical_parameters_coastal_regulatory_zone"],
    criticalParametersZoningAsPerDevelopmentPlan: json["critical_parameters_zoning_as_per_development_plan"],
    criticalParametersFallingInPresent: json["critical_parameters_falling_in_present"],
    criticalParametersPropertyWithin30MFromRailway: json["critical_parameters_property_within_30m_from_railway"],
    criticalParametersPropertyNearHtLtLines: json["critical_parameters_property_near_ht_lt_lines"],
    criticalParametersPresenceOfNallahWaterBodyNearby: json["critical_parameters_presence_of_nallah_water_body_nearby"],
    criticalParametersFsiDeviation: json["critical_parameters_fsi_deviation"],
    criticalParametersVerticalDeviation: json["critical_parameters_vertical_deviation"],
    criticalParametersUnitDeviation: json["critical_parameters_unit_deviation"],
    criticalParametersHabitation: json["critical_parameters_habitation"],
    criticalParametersRemarks: json["critical_parameters_remarks"],
    criticalParametersFallingInReservation: json["critical_parameters_falling_in_reservation"],
    constructionStatus: json["construction_status"],
    constructionMaterialStatus: json["construction_material_status"],
    labourStatusonSite: json["labour_statuson_site"],
    projectCFByWhichBank: json["projectcfby_which_bank"],
    projectHomeloanAvailble: json["project_homeloan_availble"],
    revisitRemarks: json["revisitRemarks"],
    visitCharges: json["visitCharges"],
    localSync: json["localSync"],
    globalSync: json["globalSync"],
  );

  Map<String, dynamic> toJson() => {
    "project_land_id": projectLandId,
    "project_id": projectId,
    "allocationId": allocationId,
    "land_use": landUse,
    "lat": lat,
    "lng": lng,
    "locality_class": localityClass,
    "land_situated_on": landSituatedOn,
    "area_as_per_site": areaAsPerSite,
    "area_as_per_ownership_document": areaAsPerOwnershipDocument,
    "area_as_per_measurement_sheet": areaAsPerMeasurementSheet,
    "area_as_per_approved_plan": areaAsPerApprovedPlan,
    "area_of_plot_deviation": areaOfPlotDeviation,
    "permissible_fsi_bua_residential": permissibleFsiBuaResidential,
    "permissible_fsi_bua_commercial": permissibleFsiBuaCommercial,
    "permissible_fsi_bua_others": permissibleFsiBuaOthers,
    "permissible_fsi_bua_total": permissibleFsiBuaTotal,
    "consumed_fsi_bua_residential": consumedFsiBuaResidential,
    "consumed_fsi_bua_commercial": consumedFsiBuaCommercial,
    "consumed_fsi_bua_others": consumedFsiBuaOthers,
    "consumed_fsi_bua_total": consumedFsiBuaTotal,
    "build_up_area_remark": buildUpAreaRemark,
    "project_area_details_fsi_far_details": projectAreaDetailsFsiFarDetails,
    "project_area_details_plot_fsi_far": projectAreaDetailsPlotFsiFar,
    "project_area_details_premium_fsi_far": projectAreaDetailsPremiumFsiFar,
    "project_area_details_premium_tdr_fsi": projectAreaDetailsPremiumTdrFsi,
    "project_area_details_premium_fungiable_fsi": projectAreaDetailsPremiumFungiableFsi,
    "project_area_details_fsi_under_regulation_1": projectAreaDetailsFsiUnderRegulation1,
    "project_area_details_fsi_under_regulation_2": projectAreaDetailsFsiUnderRegulation2,
    "project_area_details_total_fsi_far": projectAreaDetailsTotalFsiFar,
    "width_of_accesss_road": widthOfAccesssRoad,
    "type_of_access_road": typeOfAccessRoad,
    "east_as_per_site": eastAsPerSite,
    "east_as_per_document": eastAsPerDocument,
    "east_as_per_rera": eastAsPerRera,
    "east_deviation": eastDeviation,
    "west_as_per_site": westAsPerSite,
    "west_as_per_document": westAsPerDocument,
    "west_as_per_rera": westAsPerRera,
    "west_deviation": westDeviation,
    "north_as_per_site": northAsPerSite,
    "north_as_per_document": northAsPerDocument,
    "north_as_per_rera": northAsPerRera,
    "north_deviation": northDeviation,
    "south_as_per_site": southAsPerSite,
    "south_as_per_document": southAsPerDocument,
    "south_as_per_rera": southAsPerRera,
    "south_deviation": southDeviation,
    "civic_aminities_json": civicAminitiesJson,
    "critical_parameters_seismic_zone": criticalParametersSeismicZone,
    "critical_parameters_flood_prone_area": criticalParametersFloodProneArea,
    "critical_parameters_coastal_regulatory_zone": criticalParametersCoastalRegulatoryZone,
    "critical_parameters_zoning_as_per_development_plan": criticalParametersZoningAsPerDevelopmentPlan,
    "critical_parameters_falling_in_present": criticalParametersFallingInPresent,
    "critical_parameters_property_within_30m_from_railway": criticalParametersPropertyWithin30MFromRailway,
    "critical_parameters_property_near_ht_lt_lines": criticalParametersPropertyNearHtLtLines,
    "critical_parameters_presence_of_nallah_water_body_nearby": criticalParametersPresenceOfNallahWaterBodyNearby,
    "critical_parameters_fsi_deviation": criticalParametersFsiDeviation,
    "critical_parameters_vertical_deviation": criticalParametersVerticalDeviation,
    "critical_parameters_unit_deviation": criticalParametersUnitDeviation,
    "critical_parameters_habitation": criticalParametersHabitation,
    "critical_parameters_remarks": criticalParametersRemarks,
    "critical_parameters_falling_in_reservation": criticalParametersFallingInReservation,
    "construction_status": constructionStatus,
    "construction_material_status": constructionMaterialStatus,
    "labour_statuson_site": labourStatusonSite,
    "projectcfby_which_bank": projectCFByWhichBank,
    "project_homeloan_availble": projectHomeloanAvailble,
    "revisitRemarks": revisitRemarks,
    "visitCharges": visitCharges,
    "localSync": localSync ?? 0,
    "globalSync": globalSync ?? 0,
  };
}
