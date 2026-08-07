class SubProjectEntity {
  int? subProjectId;
  String? dos;
  String? subProjectName;
  int? saleableRatepsf;
  int? carpetRatepsf;
  String? startDate;
  String? endDate;
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
  int? deleteFlag;
  int? hasVillas;
  String? percVilaStarted;
  String? percVilaPiling;
  String? percVilaPlinth;
  String? percVilaFloorslab;
  String? percVilaInternalWork;
  String? percVilaExternal;
  String? percVilaComplete;
  int? syncGlobalStatus;
  int? syncLocalStatus;
  int? flatSoldCount;
  int? projectId;
  String? surveyDate;
  String? qtrId;
  String? rateType;
  int? isCarpetOrSaleableChoosen;
  String? errMsg;
  int? flatgroupid;
  int? assignedNewPrj;

  SubProjectEntity({
    this.subProjectId,
    this.dos,
    this.subProjectName,
    this.saleableRatepsf,
    this.carpetRatepsf,
    this.startDate,
    this.endDate,
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
    this.syncGlobalStatus,
    this.syncLocalStatus,
    this.flatSoldCount,
    this.projectId,
    this.surveyDate,
    this.qtrId,
    this.rateType,
    this.isCarpetOrSaleableChoosen,
    this.errMsg,
    this.flatgroupid,
    this.assignedNewPrj,
  });

  // Convert a Map into a SubProjectEntity
  factory SubProjectEntity.fromJson(Map<String, dynamic> map) {
    return SubProjectEntity(
      subProjectId: map['subProjectId'],
      dos: map['dos'],
      subProjectName: map['subProjectName'],
      saleableRatepsf: map['saleableRatepsf'],
      carpetRatepsf: map['carpetRatepsf'],
      startDate: map['startDate'],
      endDate: map['endDate'],
      wings: map['wings'],
      storey: map['storey'],
      flatsPerFloor: map['flatsPerFloor'],
      projectStatusId: map['projectStatusId'],
      constructionProgressId: map['constructionProgressId'],
      floorSlab: map['floorSlab'],
      remarks: map['remarks'],
      scr: map['scr'],
      maintenancePersqft: map['maintenancePersqft'],
      stiltPark: map['stiltPark'],
      openPark: map['openPark'],
      podium: map['podium'],
      doublePodium: map['doublePodium'],
      basementPark: map['basementPark'],
      bookingStop: map['bookingStop'],
      floorRise: map['floorRise'],
      deleteFlag: map['deleteFlag'],
      hasVillas: map['hasVillas'],
      percVilaStarted: map['percVilaStarted'],
      percVilaPiling: map['percVilaPiling'],
      percVilaPlinth: map['percVilaPlinth'],
      percVilaFloorslab: map['percVilaFloorslab'],
      percVilaInternalWork: map['percVilaInternalWork'],
      percVilaExternal: map['percVilaExternal'],
      percVilaComplete: map['percVilaComplete'],
      syncGlobalStatus: map['syncGlobalStatus'],
      syncLocalStatus: map['syncLocalStatus'],
      flatSoldCount: map['flatSoldCount'],
      projectId: map['projectId'],
      surveyDate: map['surveyDate'],
      qtrId: map['qtrId'],
      rateType: map['rateType'],
      isCarpetOrSaleableChoosen: map['isCarpetOrSaleableChoosen'],
      errMsg: map['errMsg'],
      flatgroupid: map['flatgroupid'],
      assignedNewPrj: map['assignedNewPrj'],
    );
  }

  // Convert SubProjectEntity to Map
  Map<String, dynamic> toMap() {
    return {
      'subProjectId': subProjectId,
      'dos': dos,
      'subProjectName': subProjectName,
      'saleableRatepsf': saleableRatepsf,
      'carpetRatepsf': carpetRatepsf,
      'startDate': startDate,
      'endDate': endDate,
      'wings': wings,
      'storey': storey,
      'flatsPerFloor': flatsPerFloor,
      'projectStatusId': projectStatusId,
      'constructionProgressId': constructionProgressId,
      'floorSlab': floorSlab,
      'remarks': remarks,
      'scr': scr,
      'maintenancePersqft': maintenancePersqft,
      'stiltPark': stiltPark,
      'openPark': openPark,
      'podium': podium,
      'doublePodium': doublePodium,
      'basementPark': basementPark,
      'bookingStop': bookingStop,
      'floorRise': floorRise,
      'deleteFlag': deleteFlag,
      'hasVillas': hasVillas,
      'percVilaStarted': percVilaStarted,
      'percVilaPiling': percVilaPiling,
      'percVilaPlinth': percVilaPlinth,
      'percVilaFloorslab': percVilaFloorslab,
      'percVilaInternalWork': percVilaInternalWork,
      'percVilaExternal': percVilaExternal,
      'percVilaComplete': percVilaComplete,
      'syncGlobalStatus': syncGlobalStatus,
      'syncLocalStatus': syncLocalStatus,
      'flatSoldCount': flatSoldCount,
      'projectId': projectId,
      'surveyDate': surveyDate,
      'qtrId': qtrId,
      'rateType': rateType,
      'isCarpetOrSaleableChoosen': isCarpetOrSaleableChoosen,
      'errMsg': errMsg,
      'flatgroupid': flatgroupid,
      'assignedNewPrj': assignedNewPrj,
    };
  }

  SubProjectEntity copyWith({
    int? subProjectId,
    String? dos,
    String? subProjectName,
    int? saleableRatepsf,
    int? carpetRatepsf,
    String? startDate,
    String? endDate,
    int? wings,
    int? storey,
    int? flatsPerFloor,
    int? projectStatusId,
    int? constructionProgressId,
    int? floorSlab,
    String? remarks,
    int? scr,
    double? maintenancePersqft,
    String? stiltPark,
    String? openPark,
    String? podium,
    String? doublePodium,
    String? basementPark,
    int? bookingStop,
    int? floorRise,
    int? deleteFlag,
    int? hasVillas,
    String? percVilaStarted,
    String? percVilaPiling,
    String? percVilaPlinth,
    String? percVilaFloorslab,
    String? percVilaInternalWork,
    String? percVilaExternal,
    String? percVilaComplete,
    int? syncGlobalStatus,
    int? syncLocalStatus,
    int? flatSoldCount,
    int? projectId,
    String? surveyDate,
    String? qtrId,
    String? rateType,
    int? isCarpetOrSaleableChoosen,
    String? errMsg,
    int? flatgroupid,
  }) {
    return SubProjectEntity(
      subProjectId: subProjectId ?? this.subProjectId,
      dos: dos ?? this.dos,
      subProjectName: subProjectName ?? this.subProjectName,
      saleableRatepsf: saleableRatepsf ?? this.saleableRatepsf,
      carpetRatepsf: carpetRatepsf ?? this.carpetRatepsf,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      wings: wings ?? this.wings,
      storey: storey ?? this.storey,
      flatsPerFloor: flatsPerFloor ?? this.flatsPerFloor,
      projectStatusId: projectStatusId ?? this.projectStatusId,
      constructionProgressId: constructionProgressId ?? this.constructionProgressId,
      floorSlab: floorSlab ?? this.floorSlab,
      remarks: remarks ?? this.remarks,
      scr: scr ?? this.scr,
      maintenancePersqft: maintenancePersqft ?? this.maintenancePersqft,
      stiltPark: stiltPark ?? this.stiltPark,
      openPark: openPark ?? this.openPark,
      podium: podium ?? this.podium,
      doublePodium: doublePodium ?? this.doublePodium,
      basementPark: basementPark ?? this.basementPark,
      bookingStop: bookingStop ?? this.bookingStop,
      floorRise: floorRise ?? this.floorRise,
      deleteFlag: deleteFlag ?? this.deleteFlag,
      hasVillas: hasVillas ?? this.hasVillas,
      percVilaStarted: percVilaStarted ?? this.percVilaStarted,
      percVilaPiling: percVilaPiling ?? this.percVilaPiling,
      percVilaPlinth: percVilaPlinth ?? this.percVilaPlinth,
      percVilaFloorslab: percVilaFloorslab ?? this.percVilaFloorslab,
      percVilaInternalWork: percVilaInternalWork ?? this.percVilaInternalWork,
      percVilaExternal: percVilaExternal ?? this.percVilaExternal,
      percVilaComplete: percVilaComplete ?? this.percVilaComplete,
      syncGlobalStatus: syncGlobalStatus ?? this.syncGlobalStatus,
      syncLocalStatus: syncLocalStatus ?? this.syncLocalStatus,
      flatSoldCount: flatSoldCount ?? this.flatSoldCount,
      projectId: projectId ?? this.projectId,
      surveyDate: surveyDate ?? this.surveyDate,
      qtrId: qtrId ?? this.qtrId,
      rateType: rateType ?? this.rateType,
      isCarpetOrSaleableChoosen: isCarpetOrSaleableChoosen ?? this.isCarpetOrSaleableChoosen,
      errMsg: errMsg ?? this.errMsg,
      flatgroupid: flatgroupid ?? this.flatgroupid,
    );
  }
}
