class WingData {
  int? id;
  String? dos;
  int? wingId;
  int? projectId;
  String? wingName;
  String? updatedon;
  int? buildingId;
  String? buildingName;
  String? carpetRate;
  String? launchDate;
  String? scrLoading;
  String? clubCharges;
  String? saleableRate;
  String? numberOfSlabs;
  String? possessionDate;
  String? wingAddonJson;
  String? numberOfFloors;
  String? averageFloorRise;
  String? maintenanceCharges;
  String? stackParkingCharges;
  String? stiltParkingCharges;
  String? podiumParkingCharges;
  String? averageParkingCharges;
  String? basementParkingCharges;
  String? constructionProgressDos;
  String? mechanicalParkingCharges;
  String? createdBuildingId;
  String? createdWingId;
  String? errorMsg;
  bool? submitStatus;

  WingData({
    this.id,
    this.dos,
    this.wingId,
    this.projectId,
    this.wingName,
    this.updatedon,
    this.buildingId,
    this.buildingName,
    this.carpetRate,
    this.launchDate,
    this.scrLoading,
    this.clubCharges,
    this.saleableRate,
    this.numberOfSlabs,
    this.possessionDate,
    this.wingAddonJson,
    this.numberOfFloors,
    this.averageFloorRise,
    this.maintenanceCharges,
    this.stackParkingCharges,
    this.stiltParkingCharges,
    this.podiumParkingCharges,
    this.averageParkingCharges,
    this.basementParkingCharges,
    this.constructionProgressDos,
    this.mechanicalParkingCharges,
    this.createdBuildingId,
    this.createdWingId,
    this.errorMsg,
    this.submitStatus,
  });

  factory WingData.fromJson(Map<String, dynamic> json) => WingData(
    id: json['id'],
    dos: json["dos"],
    wingId: json["wing_id"],
    projectId: json["project_id"],
    wingName: json["wing_name"],
    updatedon: json["updated_on"],
    buildingId: json["building_id"],
    buildingName: json["building_name"],
    carpetRate: json["carpet_rate"],
    launchDate: json["launch_date"],
    scrLoading: json["scr_loading"],
    clubCharges: json["club_charges"],
    saleableRate: json["saleable_rate"],
    numberOfSlabs: json["number_of_slabs"],
    possessionDate: json["possession_date"],
    wingAddonJson: json["wing_addon_json"].toString(),
    numberOfFloors: json["number_of_floors"],
    averageFloorRise: json["average_floor_rise"],
    maintenanceCharges: json["maintenance_charges"],
    stackParkingCharges: json["stack_parking_charges"],
    stiltParkingCharges: json["stilt_parking_charges"],
    podiumParkingCharges: json["podium_parking_charges"],
    averageParkingCharges: json["average_parking_charges"],
    basementParkingCharges: json["basement_parking_charges"],
    constructionProgressDos: json["construction_progress_dos"],
    mechanicalParkingCharges: json["mechanical_parking_charges"],
    createdBuildingId: json["createdBuildingId"],
    createdWingId: json["createdWingId"],
    errorMsg: json["errorMsg"],
    // submitStatus: json["submit_status"] ?? false,
    submitStatus: json["submit_status"] is bool ? json["submit_status"] : json["submit_status"] == 1,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "dos": dos,
    "wing_id": wingId,
    "project_id": projectId,
    "wing_name": wingName,
    "building_id": buildingId,
    "building_name": buildingName,
    "carpet_rate": carpetRate,
    "launch_date": launchDate,
    "scr_loading": scrLoading,
    "club_charges": clubCharges,
    "saleable_rate": saleableRate,
    "number_of_slabs": numberOfSlabs,
    "possession_date": possessionDate,
    "wing_addon_json": wingAddonJson.toString(),
    "number_of_floors": numberOfFloors,
    "average_floor_rise": averageFloorRise,
    "maintenance_charges": maintenanceCharges,
    "stack_parking_charges": stackParkingCharges,
    "stilt_parking_charges": stiltParkingCharges,
    "podium_parking_charges": podiumParkingCharges,
    "average_parking_charges": averageParkingCharges,
    "basement_parking_charges": basementParkingCharges,
    "construction_progress_dos": constructionProgressDos,
    "mechanical_parking_charges": mechanicalParkingCharges,
    "createdBuildingId": createdBuildingId,
    "createdWingId": createdWingId,
    "errorMsg": errorMsg,
    // "submit_status": submitStatus,
    "submit_status": submitStatus == true ? 1 : 0,
  };
}
