class CNewSubProjectEntity {
  String? subPrjId;
  String? prjId;
  int? prjIdLF;
  String? subPrjName;
  int? storey;
  int? scr;
  double? maintenance;
  int? floorPlate;
  String? carpetOrSaleable;
  double? leaseBareshell;
  double? leaseWarmshell;
  double? leaseFullyFurnished;
  double? outrightBareshell;
  double? outrightWarmshell;
  double? outrightFullyFurnished;
  String? launchDate;
  String? endDate;
  int? constructionStageId;
  int? floorSlab;
  double? totalSupply;
  double? soldPercent;
  double? unsoldPercent;
  double? leasePercent;
  double? vacantPercent;
  String? reraNo;
  String? remark;
  String? dos;
  String? mobileCreatedDatetime;
  int? localSyncStatus;
  int? globalSyncStatus;
  String? errorMessage;

  CNewSubProjectEntity({
    this.subPrjId,
    this.prjId,
    this.prjIdLF,
    this.subPrjName,
    this.storey,
    this.scr,
    this.maintenance,
    this.floorPlate,
    this.carpetOrSaleable,
    this.leaseBareshell,
    this.leaseWarmshell,
    this.leaseFullyFurnished,
    this.outrightBareshell,
    this.outrightWarmshell,
    this.outrightFullyFurnished,
    this.launchDate,
    this.endDate,
    this.constructionStageId,
    this.floorSlab,
    this.totalSupply,
    this.soldPercent,
    this.unsoldPercent,
    this.leasePercent,
    this.vacantPercent,
    this.reraNo,
    this.remark,
    this.dos,
    this.mobileCreatedDatetime,
    this.localSyncStatus,
    this.globalSyncStatus,
    this.errorMessage,
  });

  factory CNewSubProjectEntity.fromMap(Map<String, dynamic> map) {
    return CNewSubProjectEntity(
      subPrjId: map['subPrjId'],
      prjId: map['prjId'],
      prjIdLF: map['prjIdLF'],
      subPrjName: map['subPrjName'],
      storey: map['storey'],
      scr: map['scr'],
      maintenance: map['maintenance'],
      floorPlate: map['floorPlate'],
      carpetOrSaleable: map['carpetOrSaleable'],
      leaseBareshell: map['leaseBareshell'],
      leaseWarmshell: map['leaseWarmshell'],
      leaseFullyFurnished: map['leaseFullyFurnished'],
      outrightBareshell: map['outrightBareshell'],
      outrightWarmshell: map['outrightWarmshell'],
      outrightFullyFurnished: map['outrightFullyFurnished'],
      launchDate: map['launchDate'],
      endDate: map['endDate'],
      constructionStageId: map['constructionStageId'],
      floorSlab: map['floorSlab'],
      totalSupply: map['totalSupply'],
      soldPercent: map['soldPercent'],
      unsoldPercent: map['unsoldPercent'],
      leasePercent: map['leasePercent'],
      vacantPercent: map['vacantPercent'],
      reraNo: map['reraNo'],
      remark: map['remark'],
      dos: map['dos'],
      mobileCreatedDatetime: map['mobileCreatedDatetime'],
      localSyncStatus: map['localSyncStatus'],
      globalSyncStatus: map['globalSyncStatus'],
      errorMessage: map['errorMessage'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'subPrjId': subPrjId,
      'prjId': prjId,
      'prjIdLF': prjIdLF,
      'subPrjName': subPrjName,
      'storey': storey,
      'scr': scr,
      'maintenance': maintenance,
      'floorPlate': floorPlate,
      'carpetOrSaleable': carpetOrSaleable,
      'leaseBareshell': leaseBareshell,
      'leaseWarmshell': leaseWarmshell,
      'leaseFullyFurnished': leaseFullyFurnished,
      'outrightBareshell': outrightBareshell,
      'outrightWarmshell': outrightWarmshell,
      'outrightFullyFurnished': outrightFullyFurnished,
      'launchDate': launchDate,
      'endDate': endDate,
      'constructionStageId': constructionStageId,
      'floorSlab': floorSlab,
      'totalSupply': totalSupply,
      'soldPercent': soldPercent,
      'unsoldPercent': unsoldPercent,
      'leasePercent': leasePercent,
      'vacantPercent': vacantPercent,
      'reraNo': reraNo,
      'remark': remark,
      'dos': dos,
      'mobileCreatedDatetime': mobileCreatedDatetime,
      'localSyncStatus': localSyncStatus,
      'globalSyncStatus': globalSyncStatus,
      'errorMessage': errorMessage,
    };
  }
}
