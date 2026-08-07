class NewFlatEntity {
  String? newFlatId;
  String? newSubProjectId;
  int? flatTypeId;
  String? flatType;
  String? flatSize;
  String? carpetSize;
  String? areaType;
  int? flatSold;
  int? totalFlats;
  String? createdDateTime;
  int? syncGlobalStatus;

  NewFlatEntity({
    this.newFlatId,
    this.newSubProjectId,
    this.flatTypeId,
    this.flatType,
    this.flatSize,
    this.carpetSize,
    this.areaType,
    this.flatSold,
    this.totalFlats,
    this.createdDateTime,
    this.syncGlobalStatus,
  });

  /// Convert Model → Map (for insert/update)
  Map<String, dynamic> toNewFlatEntityMap() {
    return {
      'newFlatId': newFlatId,
      'new_sub_project_id': newSubProjectId,
      'flatTypeId': flatTypeId,
      'flatType': flatType,
      'flatSize': flatSize,
      'carpetSize': carpetSize,
      'areaType': areaType,
      'flatSold': flatSold,
      'totalFlats': totalFlats,
      'createdDateTime': createdDateTime,
      'syncGlobalStatus': syncGlobalStatus,
    };
  }

  Map<String, dynamic> mapApiFlatToEntity(Map<String, dynamic> apiMap) {
    return {
      'newFlatId': apiMap['NEW_FLAT_ID'],
      'new_sub_project_id': apiMap['NEW_SUB_PROJECT_ID'],
      'flatTypeId': apiMap['FLAT_TYPE_ID'],
      'flatType': apiMap['FLAT'],
      'flatSize': apiMap['FLAT_SIZE'],
      'carpetSize': apiMap['CARPET_SIZE'],
      'areaType': apiMap['AREA_TYPE'],
      'flatSold': apiMap['SOLD'],
      'totalFlats': apiMap['TOTAL'],
      'createdDateTime': apiMap['CREATED_DATETIME_MOB'],
      'syncGlobalStatus': 1,
    };
  }

  /// Convert Map → Model (for fetch)
  factory NewFlatEntity.fromJson(Map<String, dynamic> map) {
    return NewFlatEntity(
      newFlatId: map['newFlatId'],
      newSubProjectId: map['new_sub_project_id'],
      flatTypeId: map['flatTypeId'],
      flatType: map['flatType'],
      flatSize: map['flatSize'],
      carpetSize: map['carpetSize'],
      areaType: map['areaType'],
      flatSold: map['flatSold'],
      totalFlats: map['totalFlats'],
      createdDateTime: map['createdDateTime'],
      syncGlobalStatus: map['syncGlobalStatus'],
    );
  }
}
