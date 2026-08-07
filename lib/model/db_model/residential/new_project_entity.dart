class NewProjectEntity {
  String? prjId;
  String? prjName;
  String? prjAddr;
  double? lat;
  double? lng;
  int? userId;
  int? cityId;
  String? builderName;
  String? architectName;
  String? mobileNo;
  String? prjAmenitiesIds;
  String? prjApprovedBanksIds;
  int? prjScaleId;
  bool? isLottery;
  bool? isRedevelopment;
  String? createdDateTime;
  int? qtrId;
  String? qtr;
  String? reraPrjType;
  String? reraNo;
  bool? reraNotLaunch;
  int? syncLocalStatus;
  int? syncGlobalStatus;

  NewProjectEntity({
    this.prjId,
    this.prjName,
    this.prjAddr,
    this.lat,
    this.lng,
    this.userId,
    this.cityId,
    this.builderName,
    this.architectName,
    this.mobileNo,
    this.prjAmenitiesIds,
    this.prjApprovedBanksIds,
    this.prjScaleId,
    this.isLottery,
    this.isRedevelopment,
    this.createdDateTime,
    this.qtrId,
    this.qtr,
    this.reraPrjType,
    this.reraNo,
    this.reraNotLaunch,
    this.syncLocalStatus,
    this.syncGlobalStatus,
  });

  factory NewProjectEntity.fromJson(Map<String, dynamic> map) {
    return NewProjectEntity(
      prjId: map['prjId'],
      prjName: map['prjName'],
      prjAddr: map['prjAddr'],
      // lat: (map['lat'] as num).toDouble(),
      // lng: (map['lng'] as num).toDouble(),
      lat: map['lat'],
      lng: map['lng'],
      userId: map['userId'],
      cityId: map['cityId'],
      builderName: map['builderName'],
      architectName: map['architectName'],
      mobileNo: map['mobileNo'],
      prjAmenitiesIds: map['prjAmenitiesIds'],
      prjApprovedBanksIds: map['prjApprovedBanksIds'],
      prjScaleId: map['prjScaleId'],
      isLottery: map['isLottery'] == 1,
      isRedevelopment: map['isRedevelopment'] == 1,
      createdDateTime: map['createdDateTime'],
      qtrId: map['qtrId'],
      qtr: map['qtr'],
      reraPrjType: map['reraPrjType'],
      reraNo: map['reraNo'],
      reraNotLaunch: map['rera_not_launched'] == 1,
      syncLocalStatus: map['syncLocalStatus'],
      syncGlobalStatus: map['syncGlobalStatus'],
    );
  }

  Map<String, dynamic> toNewProjectEntityMap() {
    return {
      'prjId': prjId,
      'prjName': prjName,
      'prjAddr': prjAddr,
      'lat': lat,
      'lng': lng,
      'userId': userId,
      'cityId': cityId,
      'builderName': builderName,
      'architectName': architectName,
      'mobileNo': mobileNo,
      'prjAmenitiesIds': prjAmenitiesIds,
      'prjApprovedBanksIds': prjApprovedBanksIds,
      'prjScaleId': prjScaleId,
      'isLottery': isLottery == true ? 1 : 0,
      'isRedevelopment': isRedevelopment == true ? 1 : 0,
      'createdDateTime': createdDateTime,
      'qtrId': qtrId,
      'qtr': qtr,
      'reraPrjType': reraPrjType,
      'reraNo': reraNo,
      'rera_not_launched': reraNotLaunch == true ? 1 : 0,
      'syncLocalStatus': syncLocalStatus,
      'syncGlobalStatus': syncGlobalStatus,
    };
  }

  Map<String, dynamic> mapApiProjectToEntity(Map<String, dynamic> apiMap) {
    return {
      'prjId': apiMap['NEW_PROJECT_ID'],
      'prjName': apiMap['PROJECT_NAME'],
      'prjAddr': apiMap['PROJECT_ADDRESS'],
      'lat': apiMap['LAT'],
      'lng': apiMap['LNG'],
      'userId': apiMap['CREATED_BY'],
      'cityId': apiMap['CITY_ID'],
      'builderName': apiMap['BUILDER_NAME'],
      'architectName': apiMap['ARCHITECT_NAME'],
      'mobileNo': apiMap['MOBILE_NO'],
      'prjAmenitiesIds': apiMap['AMENITIES_IDS'],
      'prjApprovedBanksIds': apiMap['APPROVED_BANK_IDS'],
      'prjScaleId': apiMap['PROJECT_SCALE_ID'],
      'isLottery': apiMap['PROJECT_IS_LOTTERY'] == true ? 1 : 0,
      'isRedevelopment': apiMap['PROJECT_IS_REDEVELOPMENT'] == true ? 1 : 0,
      'createdDateTime': apiMap['CREATED_DATETIME_MOB'].toString(),
      'qtrId': _toInt(apiMap['QTR_ID']),
      'qtr': qtr,
      'rera_not_launched': apiMap['rera_not_launched'] == true ? 1 : 0,
      'syncLocalStatus': 0,
      'syncGlobalStatus': 1,
    };
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  NewProjectEntity copyWith({
    String? prjId,
    String? prjName,
    String? prjAddr,
    double? lat,
    double? lng,
    int? userId,
    int? cityId,
    String? builderName,
    String? architectName,
    String? mobileNo,
    String? prjAmenitiesIds,
    String? prjApprovedBanksIds,
    int? prjScaleId,
    bool? isLottery,
    bool? isRedevelopment,
    String? createdDateTime,
    int? qtrId,
    String? qtr,
    String? reraPrjType,
    String? reraNo,
    bool? reraNotLaunch,
    int? syncLocalStatus,
    int? syncGlobalStatus,
  }) {
    return NewProjectEntity(
      prjId: prjId ?? this.prjId,
      prjName: prjName ?? this.prjName,
      prjAddr: prjAddr ?? this.prjAddr,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      userId: userId ?? this.userId,
      cityId: cityId ?? this.cityId,
      builderName: builderName ?? this.builderName,
      architectName: architectName ?? this.architectName,
      mobileNo: mobileNo ?? this.mobileNo,
      prjAmenitiesIds: prjAmenitiesIds ?? this.prjAmenitiesIds,
      prjApprovedBanksIds: prjApprovedBanksIds ?? this.prjApprovedBanksIds,
      prjScaleId: prjScaleId ?? this.prjScaleId,
      isLottery: isLottery ?? this.isLottery,
      isRedevelopment: isRedevelopment ?? this.isRedevelopment,
      createdDateTime: createdDateTime ?? this.createdDateTime,
      qtrId: qtrId ?? this.qtrId,
      qtr: qtr ?? this.qtr,
      reraPrjType: reraPrjType ?? this.reraPrjType,
      reraNo: reraNo ?? this.reraNo,
      reraNotLaunch: reraNotLaunch ?? this.reraNotLaunch,
      syncLocalStatus: syncLocalStatus ?? this.syncLocalStatus,
      syncGlobalStatus: syncGlobalStatus ?? this.syncGlobalStatus,
    );
  }
}
