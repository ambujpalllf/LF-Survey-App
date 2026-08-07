class NewSubProjectEntity {
  String? subPrjid;
  int? projectId;
  String? newProjectId;
  int? qtrid;
  String? qtr;
  String? subPrjName;
  int? storey;
  int? scr;
  double? maintenance;
  int? flatsPerFloor;
  int? flatGroup;
  double? saleableLaunchPrice;
  double? carpetLaunchPrice;
  String? rateType;
  String? launchDate;
  String? endDate;
  int? constructionProgressId;
  String? constructionProgress;
  int? floorSlab;
  String? reraNo;
  String? remarks;
  int? floorRise;
  String? stiltParking;
  String? openParking;
  String? podiumParking;
  String? doublePodiumParking;
  String? basementParking;
  String? createdDateTime;
  int? syncLocalStatus;
  int? syncGlobalStatus;
  String? errMsg;

  NewSubProjectEntity({
    this.subPrjid,
    this.projectId,
    this.newProjectId,
    this.qtrid,
    this.qtr,
    this.subPrjName,
    this.storey,
    this.scr,
    this.maintenance,
    this.flatsPerFloor,
    this.flatGroup,
    this.saleableLaunchPrice,
    this.carpetLaunchPrice,
    this.rateType,
    this.launchDate,
    this.endDate,
    this.constructionProgressId,
    this.constructionProgress,
    this.floorSlab,
    this.reraNo,
    this.remarks,
    this.floorRise,
    this.stiltParking,
    this.openParking,
    this.podiumParking,
    this.doublePodiumParking,
    this.basementParking,
    this.createdDateTime,
    this.syncLocalStatus,
    this.syncGlobalStatus,
    this.errMsg,
  });

  Map<String, dynamic> toNewSubPrjentityMap() {
    return {
      'subPrjid': subPrjid,
      'projectId': projectId,
      'newProjectId': newProjectId,
      'qtrid': qtrid,
      'qtr': qtr,
      'subPrjName': subPrjName,
      'storey': storey,
      'scr': scr,
      'maintenance': maintenance,
      'flatsPerFloor': flatsPerFloor,
      'flatGroup': flatGroup,
      'saleableLaunchPrice': saleableLaunchPrice,
      'carpetLaunchPrice': carpetLaunchPrice,
      'rate_type': rateType,
      'launchDate': launchDate,
      'endDate': endDate,
      'constructionProgressId': constructionProgressId,
      'constructionProgress': constructionProgress,
      'floorSlab': floorSlab,
      'reraNo': reraNo,
      'remarks': remarks,
      'floorRise': floorRise,
      'stilt_parking': stiltParking,
      'open_parking': openParking,
      'podium_parking': podiumParking,
      'double_podium_parking': doublePodiumParking,
      'basement_parking': basementParking,
      'createdDateTime': createdDateTime,
      'syncLocalStatus': syncLocalStatus,
      'syncGlobalStatus': syncGlobalStatus,
      'errMsg': errMsg,
    };
  }

  Map<String, dynamic> mapApiSubProjectToEntity(Map<String, dynamic> apiMap) {
    return {
      'subPrjid': apiMap['NEW_SUB_PROJECT_ID'],
      'projectId': apiMap['PROJECT_ID'],
      'newProjectId': apiMap['NEW_PROJECT_ID'],
      'qtrid': apiMap['QTR_ID'],
      'qtr': "",
      'subPrjName': apiMap['PRJ_BUILDING_NAME'],
      'storey': apiMap['STOREY'],
      'scr': apiMap['SCR'],
      'maintenance': apiMap['MAINTENANCE'],
      'flatsPerFloor': apiMap['FLATS_PER_FLOOR'],
      'flatGroup': apiMap['FLAT_GROUP'],
      'saleableLaunchPrice': apiMap['LAUNCH_PRICE'],
      'carpetLaunchPrice': apiMap['CARPET_LAUNCH_PRICE'],
      'rate_type': apiMap['SIZE_TYPE'],
      'launchDate': apiMap['LAUNCH_DATE'],
      'endDate': apiMap['END_DATE'],
      'constructionProgressId': apiMap['CONSTRUCTION_PROGRESS_ID'],
      'constructionProgress': apiMap['CONSTRUCTION_PROGRESS'],
      'floorSlab': apiMap['FLOORSLAB'],
      'reraNo': apiMap['RERA_NO'],
      'remarks': apiMap['REMARKS'],
      'floorRise': apiMap['FLOORRISE'],
      'stilt_parking': apiMap['STILT_PARKING'],
      'open_parking': apiMap['OPEN_PARKING'],
      'podium_parking': apiMap['PODIUM_PARKING'],
      'double_podium_parking': apiMap['DOUBLE_PODIUM_PARKING'],
      'basement_parking': apiMap['BASEMENT_PARKING'],
      'createdDateTime': apiMap['CREATED_DATETIME_MOB'],
      'syncLocalStatus': 0,
      'syncGlobalStatus': 1,
      'errMsg': "Already Sync",
    };
  }

  factory NewSubProjectEntity.fromJson(Map<String, dynamic> map) {
    return NewSubProjectEntity(
      subPrjid: map['subPrjid'],
      projectId: map['projectId'],
      newProjectId: map['newProjectId'],
      qtrid: map['qtrid'],
      qtr: map['qtr'],
      subPrjName: map['subPrjName'],
      storey: map['storey'],
      scr: map['scr'],
      maintenance: map['maintenance']?.toDouble(),
      flatsPerFloor: map['flatsPerFloor'],
      flatGroup: map['flatGroup'],
      saleableLaunchPrice: map['saleableLaunchPrice']?.toDouble(),
      carpetLaunchPrice: map['carpetLaunchPrice']?.toDouble(),
      rateType: map['rate_type'],
      launchDate: map['launchDate'],
      endDate: map['endDate'],
      constructionProgressId: map['constructionProgressId'],
      constructionProgress: map['constructionProgress'],
      floorSlab: map['floorSlab'],
      reraNo: map['reraNo'],
      remarks: map['remarks'],
      floorRise: map['floorRise'],
      stiltParking: map['stilt_parking'],
      openParking: map['open_parking'],
      podiumParking: map['podium_parking'],
      doublePodiumParking: map['double_podium_parking'],
      basementParking: map['basement_parking'],
      createdDateTime: map['createdDateTime'],
      syncLocalStatus: map['syncLocalStatus'],
      syncGlobalStatus: map['syncGlobalStatus'],
      errMsg: map['errMsg'],
    );
  }
}
