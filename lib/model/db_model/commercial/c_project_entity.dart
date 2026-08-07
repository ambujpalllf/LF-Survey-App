class CProjectEntity {
  int? projectId;
  int? locationId;
  int? suburbId;
  int? cityId;
  double? pxval;
  double? pyval;
  String? dos;
  String? projectName;
  String? projectAddress;
  String? projectPhoneNo;
  String? projectContactPerson;
  String? projectMobileNo;
  int? builderId;
  String? builderName;
  String? builderAddress;
  String? builderContactPerson;
  String? builderPhoneNo;
  String? builderMobileNo;
  String? roadName;
  int? parkingOpen;
  int? parkingStacked;
  int? parkingStilt;
  int? parkingBasement;
  int? parkingPodium;
  double? parkingRatio;
  double? scr;
  double? maintenancePerSqft;
  int? propertyTax;
  int? landParcelSizeUnit;
  double? landParcelSize;
  int? tenantMixId;
  int? syncGlobalStatus;
  int? syncLocalStatus;
  String? rerano;
  int? telFlag;
  int? userid;

  CProjectEntity({
    this.projectId,
    this.locationId,
    this.suburbId,
    this.cityId,
    this.pxval,
    this.pyval,
    this.dos,
    this.projectName,
    this.projectAddress,
    this.projectPhoneNo,
    this.projectContactPerson,
    this.projectMobileNo,
    this.builderId,
    this.builderName,
    this.builderAddress,
    this.builderContactPerson,
    this.builderPhoneNo,
    this.builderMobileNo,
    this.roadName,
    this.parkingOpen,
    this.parkingStacked,
    this.parkingStilt,
    this.parkingBasement,
    this.parkingPodium,
    this.parkingRatio,
    this.scr,
    this.maintenancePerSqft,
    this.propertyTax,
    this.landParcelSizeUnit,
    this.landParcelSize,
    this.tenantMixId,
    this.syncGlobalStatus,
    this.syncLocalStatus,
    this.rerano,
    this.telFlag,
    this.userid,
  });

  /// copyWith method
  CProjectEntity copyWith({
    int? projectId,
    int? locationId,
    int? suburbId,
    int? cityId,
    double? pxval,
    double? pyval,
    String? dos,
    String? projectName,
    String? projectAddress,
    String? projectPhoneNo,
    String? projectContactPerson,
    String? projectMobileNo,
    int? builderId,
    String? builderName,
    String? builderAddress,
    String? builderContactPerson,
    String? builderPhoneNo,
    String? builderMobileNo,
    String? roadName,
    int? parkingOpen,
    int? parkingStacked,
    int? parkingStilt,
    int? parkingBasement,
    int? parkingPodium,
    double? parkingRatio,
    double? scr,
    double? maintenancePerSqft,
    int? propertyTax,
    int? landParcelSizeUnit,
    double? landParcelSize,
    int? tenantMixId,
    int? syncGlobalStatus,
    int? syncLocalStatus,
    String? rerano,
    int? telFlag,
    int? userid,
  }) {
    return CProjectEntity(
      projectId: projectId ?? this.projectId,
      locationId: locationId ?? this.locationId,
      suburbId: suburbId ?? this.suburbId,
      cityId: cityId ?? this.cityId,
      pxval: pxval ?? this.pxval,
      pyval: pyval ?? this.pyval,
      dos: dos ?? this.dos,
      projectName: projectName ?? this.projectName,
      projectAddress: projectAddress ?? this.projectAddress,
      projectPhoneNo: projectPhoneNo ?? this.projectPhoneNo,
      projectContactPerson: projectContactPerson ?? this.projectContactPerson,
      projectMobileNo: projectMobileNo ?? this.projectMobileNo,
      builderId: builderId ?? this.builderId,
      builderName: builderName ?? this.builderName,
      builderAddress: builderAddress ?? this.builderAddress,
      builderContactPerson: builderContactPerson ?? this.builderContactPerson,
      builderPhoneNo: builderPhoneNo ?? this.builderPhoneNo,
      builderMobileNo: builderMobileNo ?? this.builderMobileNo,
      roadName: roadName ?? this.roadName,
      parkingOpen: parkingOpen ?? this.parkingOpen,
      parkingStacked: parkingStacked ?? this.parkingStacked,
      parkingStilt: parkingStilt ?? this.parkingStilt,
      parkingBasement: parkingBasement ?? this.parkingBasement,
      parkingPodium: parkingPodium ?? this.parkingPodium,
      parkingRatio: parkingRatio ?? this.parkingRatio,
      scr: scr ?? this.scr,
      maintenancePerSqft: maintenancePerSqft ?? this.maintenancePerSqft,
      propertyTax: propertyTax ?? this.propertyTax,
      landParcelSizeUnit: landParcelSizeUnit ?? this.landParcelSizeUnit,
      landParcelSize: landParcelSize ?? this.landParcelSize,
      tenantMixId: tenantMixId ?? this.tenantMixId,
      syncGlobalStatus: syncGlobalStatus ?? this.syncGlobalStatus,
      syncLocalStatus: syncLocalStatus ?? this.syncLocalStatus,
      rerano: rerano ?? this.rerano,
      telFlag: telFlag ?? this.telFlag,
      userid: userid ?? this.userid,
    );
  }

  /// Convert Map -> Object
  factory CProjectEntity.fromMap(Map<String, dynamic> map) {
    return CProjectEntity(
      projectId: map['projectId'],
      locationId: map['locationId'],
      suburbId: map['suburbId'],
      cityId: map['cityId'],
      pxval: map['pxval'],
      pyval: map['pyval'],
      dos: map['dos'],
      projectName: map['projectName'],
      projectAddress: map['projectAddress'],
      projectPhoneNo: map['projectPhoneNo'],
      projectContactPerson: map['projectContactPerson'],
      projectMobileNo: map['projectMobileNo'],
      builderId: map['builderId'],
      builderName: map['builderName'],
      builderAddress: map['builderAddress'],
      builderContactPerson: map['builderContactPerson'],
      builderPhoneNo: map['builderPhoneNo'],
      builderMobileNo: map['builderMobileNo'],
      roadName: map['roadName'],
      parkingOpen: map['parkingOpen'],
      parkingStacked: map['parkingStacked'],
      parkingStilt: map['parkingStilt'],
      parkingBasement: map['parkingBasement'],
      parkingPodium: map['parkingPodium'],
      parkingRatio: map['parkingRatio'],
      scr: map['scr'],
      maintenancePerSqft: map['maintenancePerSqft'],
      propertyTax: map['propertyTax'],
      landParcelSizeUnit: map['landParcelSizeUnit'],
      landParcelSize: map['landParcelSize'],
      tenantMixId: map['tenantMixId'],
      syncGlobalStatus: map['syncGlobalStatus'],
      syncLocalStatus: map['syncLocalStatus'],
      rerano: map['rerano'],
      telFlag: map['telFlag'],
      userid: map['userid'],
    );
  }

  /// Convert Object -> Map
  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'locationId': locationId,
      'suburbId': suburbId,
      'cityId': cityId,
      'pxval': pxval,
      'pyval': pyval,
      'dos': dos,
      'projectName': projectName,
      'projectAddress': projectAddress,
      'projectPhoneNo': projectPhoneNo,
      'projectContactPerson': projectContactPerson,
      'projectMobileNo': projectMobileNo,
      'builderId': builderId,
      'builderName': builderName,
      'builderAddress': builderAddress,
      'builderContactPerson': builderContactPerson,
      'builderPhoneNo': builderPhoneNo,
      'builderMobileNo': builderMobileNo,
      'roadName': roadName,
      'parkingOpen': parkingOpen,
      'parkingStacked': parkingStacked,
      'parkingStilt': parkingStilt,
      'parkingBasement': parkingBasement,
      'parkingPodium': parkingPodium,
      'parkingRatio': parkingRatio,
      'scr': scr,
      'maintenancePerSqft': maintenancePerSqft,
      'propertyTax': propertyTax,
      'landParcelSizeUnit': landParcelSizeUnit,
      'landParcelSize': landParcelSize,
      'tenantMixId': tenantMixId,
      'syncGlobalStatus': syncGlobalStatus,
      'syncLocalStatus': syncLocalStatus,
      'rerano': rerano,
      'telFlag': telFlag,
      'userid': userid,
    };
  }
}
