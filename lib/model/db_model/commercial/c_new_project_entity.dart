class CNewProjectEntity {
  String? prjId;
  String? prjName;
  String? prjAddr;
  String? roadName;
  int? cityId;
  String? builderName;
  String? architectName;
  double? lat;
  double? lng;
  String? mobile;
  String? amenitiesIds;
  String? approvedBankIds;
  int? operatingModelId;
  int? buildingTypeId;
  int? tenantMixId;
  String? dos;
  String? mobileCreatedDatetime;
  int? localSyncStatus;
  int? globalSyncStatus;
  String? errorMessage;

  CNewProjectEntity({
    this.prjId,
    this.prjName,
    this.prjAddr,
    this.roadName,
    this.cityId,
    this.builderName,
    this.architectName,
    this.lat,
    this.lng,
    this.mobile,
    this.amenitiesIds,
    this.approvedBankIds,
    this.operatingModelId,
    this.buildingTypeId,
    this.tenantMixId,
    this.dos,
    this.mobileCreatedDatetime,
    this.localSyncStatus,
    this.globalSyncStatus,
    this.errorMessage,
  });

  /// Convert object → Map
  Map<String, dynamic> toMap() {
    return {
      'prjId': prjId,
      'prjName': prjName,
      'prjAddr': prjAddr,
      'roadName': roadName,
      'cityId': cityId,
      'builderName': builderName,
      'architectName': architectName,
      'lat': lat,
      'lng': lng,
      'mobile': mobile,
      'amenitiesIds': amenitiesIds,
      'approvedBankIds': approvedBankIds,
      'operatingModelId': operatingModelId,
      'buildingTypeId': buildingTypeId,
      'tenantMixId': tenantMixId,
      'dos': dos,
      'mobileCreatedDatetime': mobileCreatedDatetime,
      'localSyncStatus': localSyncStatus,
      'globalSyncStatus': globalSyncStatus,
      'errorMessage': errorMessage,
    };
  }

  /// Convert Map → object
  factory CNewProjectEntity.fromMap(Map<String, dynamic> map) {
    return CNewProjectEntity(
      prjId: map['prjId'],
      prjName: map['prjName'],
      prjAddr: map['prjAddr'],
      roadName: map['roadName'],
      cityId: map['cityId'],
      builderName: map['builderName'],
      architectName: map['architectName'],
      lat: map['lat'],
      lng: map['lng'],
      mobile: map['mobile'],
      amenitiesIds: map['amenitiesIds'],
      approvedBankIds: map['approvedBankIds'],
      operatingModelId: map['operatingModelId'],
      buildingTypeId: map['buildingTypeId'],
      tenantMixId: map['tenantMixId'],
      dos: map['dos'],
      mobileCreatedDatetime: map['mobileCreatedDatetime'],
      localSyncStatus: map['localSyncStatus'],
      globalSyncStatus: map['globalSyncStatus'],
      errorMessage: map['errorMessage'],
    );
  }
}
