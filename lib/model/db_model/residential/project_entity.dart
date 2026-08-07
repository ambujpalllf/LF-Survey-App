class ProjectEntity {
  int? projectId;
  String? dos;
  String? projectName;
  String? projectAddress;
  double? pxval;
  double? pyval;
  String? projectPhoneNo;
  String? projectMobileNo;
  int? builderId;
  String? builderName;
  String? builderAddress;
  String? builderPhoneNo;
  String? builderMobileNo;
  String? roadName;
  int? locationId;
  String? locationName;
  int? suburbId;
  int? cityId;
  String? cityName;
  int? reDevelopment;
  String? reraNo;
  String? drinkingWater;
  int? totalWings;
  int? marketableWings;
  int? totalSupplyUnits;
  double? landParcelSize;
  int? landParcelSizeUnit;
  int? syncGlobalStatus;
  int? syncLocalStatus;
  int? projectUnsold;
  int? qtrId;
  String? projectCosting;
  String? modularKitchenBrand;
  String? architectName;
  int? architectId;
  int? isWrongPXValPYVal;
  int? rejectId;
  int? fixedBy;
  int? rejectedSurveyorId;
  String? cinNo;
  String? schemeOthers;
  int? telFlag;
  int? userId;
  String? syncCheckDate;
  String? reraInfo;
  int? newProjectUpdate;
  int? assignedNewPrj;

  ProjectEntity({
    this.projectId,
    this.dos,
    this.projectName,
    this.projectAddress,
    this.pxval,
    this.pyval,
    this.projectPhoneNo,
    this.projectMobileNo,
    this.builderId,
    this.builderName,
    this.builderAddress,
    this.builderPhoneNo,
    this.builderMobileNo,
    this.roadName,
    this.locationId,
    this.locationName,
    this.suburbId,
    this.cityId,
    this.cityName,
    this.reDevelopment,
    this.reraNo,
    this.drinkingWater,
    this.totalWings,
    this.marketableWings,
    this.totalSupplyUnits,
    this.landParcelSize,
    this.landParcelSizeUnit,
    this.syncGlobalStatus,
    this.syncLocalStatus,
    this.projectUnsold,
    this.qtrId,
    this.projectCosting,
    this.modularKitchenBrand,
    this.architectName,
    this.architectId,
    this.isWrongPXValPYVal,
    this.rejectId,
    this.fixedBy,
    this.rejectedSurveyorId,
    this.cinNo,
    this.schemeOthers,
    this.telFlag,
    this.userId,
    this.syncCheckDate,
    this.reraInfo,
    this.newProjectUpdate,
    this.assignedNewPrj,
  });

  // ---------- FROM MAP ----------
  factory ProjectEntity.fromJson(Map<String, dynamic> map) {
    return ProjectEntity(
      projectId: map['projectId'],
      dos: map['dos'],
      projectName: map['projectName'],
      projectAddress: map['projectAddress'],
      pxval: map['pxval'],
      pyval: map['pyval'],
      projectPhoneNo: map['projectPhoneNo'],
      projectMobileNo: map['projectMobileNo'],
      builderId: map['builderId'],
      builderName: map['builderName'],
      builderAddress: map['builderAddress'],
      builderPhoneNo: map['builderPhoneNo'],
      builderMobileNo: map['builderMobileNo'],
      roadName: map['roadName'],
      locationId: map['locationId'],
      locationName: map['locationName'],
      suburbId: map['suburbId'],
      cityId: map['cityId'],
      cityName: map['city'],
      reDevelopment: map['reDevelopment'],
      reraNo: map['reraNo'],
      drinkingWater: map['drinkingWater'],
      totalWings: map['totalWings'],
      marketableWings: map['marketableWings'],
      totalSupplyUnits: map['totalSupplyUnits'],
      landParcelSize: map['landParcelSize'],
      landParcelSizeUnit: map['landParcelSizeUnit'],
      syncGlobalStatus: map['syncGlobalStatus'],
      syncLocalStatus: map['syncLocalStatus'],
      projectUnsold: map['projectUnsold'],
      qtrId: map['qtrId'],
      projectCosting: map['projectCosting'],
      modularKitchenBrand: map['modularKitchenBrand'],
      architectName: map['architectName'],
      architectId: map['architectId'],
      isWrongPXValPYVal: map['IsWrongPXValPYVal'],
      rejectId: map['rejectId'],
      fixedBy: map['fixedBy'],
      rejectedSurveyorId: map['rejectedSurveyorId'],
      cinNo: map['cinNo'],
      schemeOthers: map['SCHEME_OTHERS'],
      telFlag: map['telFlag'],
      userId: map['userid'],
      syncCheckDate: map['syncCheckDate'],
      reraInfo: map['rera_info'],
      newProjectUpdate: map['newProjectUpdate'],
      assignedNewPrj: map['assignedNewPrj'],
    );
  }

  // ---------- TO MAP ----------
  Map<String, dynamic> toPrjDb() {
    // final costing = projectCosting != null
    //     ? ProjectCosting.fromJson(jsonDecode(projectCosting!) as Map<String, dynamic>)
    //     : null;
    return {
      'projectId': projectId,
      'dos': dos,
      'projectName': projectName,
      'projectAddress': projectAddress,
      'pxval': pxval,
      'pyval': pyval,
      'projectPhoneNo': projectPhoneNo,
      'projectMobileNo': projectMobileNo,
      'builderId': builderId,
      'builderName': builderName,
      'builderAddress': builderAddress,
      'builderPhoneNo': builderPhoneNo,
      'builderMobileNo': builderMobileNo,
      'roadName': roadName,
      'locationId': locationId,
      'locationName': locationName,
      'suburbId': suburbId,
      'cityId': cityId,
      'city': cityName,
      'reDevelopment': reDevelopment,
      'reraNo': reraNo,
      'drinkingWater': drinkingWater,
      'totalWings': totalWings,
      'marketableWings': marketableWings,
      'totalSupplyUnits': totalSupplyUnits,
      'landParcelSize': landParcelSize,
      'landParcelSizeUnit': landParcelSizeUnit,
      'syncGlobalStatus': syncGlobalStatus,
      'syncLocalStatus': syncLocalStatus,
      'projectUnsold': projectUnsold,
      'qtrId': qtrId,
      'projectCosting': projectCosting,
      'modularKitchenBrand': modularKitchenBrand,
      'architectName': architectName,
      'architectId': architectId,
      'IsWrongPXValPYVal': isWrongPXValPYVal,
      'rejectId': rejectId,
      'fixedBy': fixedBy,
      'rejectedSurveyorId': rejectedSurveyorId,
      'cinNo': cinNo,
      'SCHEME_OTHERS': schemeOthers,
      'telFlag': telFlag,
      'userid': userId,
      'syncCheckDate': syncCheckDate,
      'rera_info': reraInfo,
      'newProjectUpdate': newProjectUpdate,
      'assignedNewPrj': assignedNewPrj,
    };
  }
}
