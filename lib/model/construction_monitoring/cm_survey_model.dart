class CmSurveyModel {
  int? id;
  int? projectId;
  int? buildingId;
  int? wingId;
  String? localBuildingId;
  String? localWingId;
  String? noOfFloors;
  String? survayDate;
  String? plinth;
  String? noOfSlabsCompleted;
  String? brickWork;
  String? plasteringInternal;
  String? plasteringExternal;
  String? flooring;
  String? electrict;
  String? plumbing;
  String? woodWork;
  String? painting;
  String? remarks;
  int? globalSync;
  int? totalUnits;
  int? soldUnits;
  double? soldPercentage;
  int? unsoldUnits;
  double? unsoldPercentage;
  int? saleableRate;
  int? carpetRate;
  int? localSync;

  CmSurveyModel({
    this.id,
    this.projectId,
    this.buildingId,
    this.wingId,
    this.localBuildingId,
    this.localWingId,
    this.noOfFloors,
    this.survayDate,
    this.plinth,
    this.noOfSlabsCompleted,
    this.brickWork,
    this.plasteringInternal,
    this.plasteringExternal,
    this.flooring,
    this.electrict,
    this.plumbing,
    this.woodWork,
    this.painting,
    this.remarks,
    this.globalSync,
    this.localSync,
    this.totalUnits,
    this.soldUnits,
    this.soldPercentage,
    this.unsoldUnits,
    this.unsoldPercentage,
    this.carpetRate,
    this.saleableRate,
  });

  factory CmSurveyModel.fromJson(Map<String, dynamic> json) => CmSurveyModel(
    id: json['id'],
    projectId: json['projectId'],
    buildingId: json['buildingId'],
    wingId: json['wingId'],
    localBuildingId: json['localBuildingId'],
    localWingId: json['localWingId'],
    noOfFloors: json['numberOfFloor'],
    survayDate: json['surveyDate'],
    plinth: json['plinth'],
    noOfSlabsCompleted: json['no_of_slabs_completed'],
    brickWork: json['brick_work'],
    plasteringInternal: json['plastering_internal'],
    plasteringExternal: json['plastering_external'],
    flooring: json['flooring'],
    electrict: json['electrict'],
    plumbing: json['plumbing'],
    woodWork: json['wood_work'],
    painting: json['painting'],
    remarks: json['remarks'],
    globalSync: json['globalSync'],
    localSync: json['localSync'],
    totalUnits: json['totalUnits'],
    soldUnits: json['soldUnits'],
    soldPercentage: json['soldPercentage'],
    unsoldUnits: json['unsoldUnits'],
    unsoldPercentage: json['unsoldPercentage'],
    saleableRate: json['saleableRate'],
    carpetRate: json['carpetRate'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'projectId': projectId,
    'buildingId': buildingId,
    'wingId': wingId,
    'localBuildingId': localBuildingId,
    'localWingId': localWingId,
    'numberOfFloor': noOfFloors,
    'surveyDate': survayDate,
    'plinth': plinth,
    'no_of_slabs_completed': noOfSlabsCompleted,
    'brick_work': brickWork,
    'plastering_internal': plasteringInternal,
    'plastering_external': plasteringExternal,
    'flooring': flooring,
    'electrict': electrict,
    'plumbing': plumbing,
    'wood_work': woodWork,
    'painting': painting,
    'remarks': remarks,
    'globalSync': globalSync,
    'localSync': localSync,
    'totalUnits': totalUnits,
    'soldUnits': soldUnits,
    'soldPercentage': soldPercentage,
    'unsoldUnits': unsoldUnits,
    'unsoldPercentage': unsoldPercentage,
    'saleableRate': saleableRate,
    'carpetRate': carpetRate,
  };
}
