class CSubProjectEntity {
  int? subProjectId;
  String? dos;
  String? subProjectName;
  int? storeyBasement;
  int? storeyPodium;
  int? storeyService;
  int? storeyHabitable;
  String? constStartDate;
  String? constEndDate;
  String? marketingStartDate;
  String? marketingEndDate;
  int? constructionProgressId;
  int? floorSlab;
  int? buildingTypeId;
  int? operationModelId;
  int? totalSupplySqft;
  int? soldAreaSqft;
  int? unsoldAreaSqft;
  int? leasedOccupiedArea;
  int? vacancyArea;
  int? minFloorplate;
  int? maxFloorplate;
  int? orBareshell;
  int? orWarmshell;
  int? orFullyFurnished;
  int? lrBareshell;
  int? lrWarmshell;
  int? lrFullyFurnished;
  int? projectStatusId;
  String? remarks;
  int? syncGlobalStatus;
  int? syncLocalStatus;
  int? projectId;

  CSubProjectEntity({
    this.subProjectId,
    this.dos,
    this.subProjectName,
    this.storeyBasement,
    this.storeyPodium,
    this.storeyService,
    this.storeyHabitable,
    this.constStartDate,
    this.constEndDate,
    this.marketingStartDate,
    this.marketingEndDate,
    this.constructionProgressId,
    this.floorSlab,
    this.buildingTypeId,
    this.operationModelId,
    this.totalSupplySqft,
    this.soldAreaSqft,
    this.unsoldAreaSqft,
    this.leasedOccupiedArea,
    this.vacancyArea,
    this.minFloorplate,
    this.maxFloorplate,
    this.orBareshell,
    this.orWarmshell,
    this.orFullyFurnished,
    this.lrBareshell,
    this.lrWarmshell,
    this.lrFullyFurnished,
    this.projectStatusId,
    this.remarks,
    this.syncGlobalStatus,
    this.syncLocalStatus,
    this.projectId,
  });

  /// copyWith
  CSubProjectEntity copyWith({
    int? subProjectId,
    String? dos,
    String? subProjectName,
    int? storeyBasement,
    int? storeyPodium,
    int? storeyService,
    int? storeyHabitable,
    String? constStartDate,
    String? constEndDate,
    String? marketingStartDate,
    String? marketingEndDate,
    int? constructionProgressId,
    int? floorSlab,
    int? buildingTypeId,
    int? operationModelId,
    int? totalSupplySqft,
    int? soldAreaSqft,
    int? unsoldAreaSqft,
    int? leasedOccupiedArea,
    int? vacancyArea,
    int? minFloorplate,
    int? maxFloorplate,
    int? orBareshell,
    int? orWarmshell,
    int? orFullyFurnished,
    int? lrBareshell,
    int? lrWarmshell,
    int? lrFullyFurnished,
    int? projectStatusId,
    String? remarks,
    int? syncGlobalStatus,
    int? syncLocalStatus,
    int? projectId,
  }) {
    return CSubProjectEntity(
      subProjectId: subProjectId ?? this.subProjectId,
      dos: dos ?? this.dos,
      subProjectName: subProjectName ?? this.subProjectName,
      storeyBasement: storeyBasement ?? this.storeyBasement,
      storeyPodium: storeyPodium ?? this.storeyPodium,
      storeyService: storeyService ?? this.storeyService,
      storeyHabitable: storeyHabitable ?? this.storeyHabitable,
      constStartDate: constStartDate ?? this.constStartDate,
      constEndDate: constEndDate ?? this.constEndDate,
      marketingStartDate: marketingStartDate ?? this.marketingStartDate,
      marketingEndDate: marketingEndDate ?? this.marketingEndDate,
      constructionProgressId: constructionProgressId ?? this.constructionProgressId,
      floorSlab: floorSlab ?? this.floorSlab,
      buildingTypeId: buildingTypeId ?? this.buildingTypeId,
      operationModelId: operationModelId ?? this.operationModelId,
      totalSupplySqft: totalSupplySqft ?? this.totalSupplySqft,
      soldAreaSqft: soldAreaSqft ?? this.soldAreaSqft,
      unsoldAreaSqft: unsoldAreaSqft ?? this.unsoldAreaSqft,
      leasedOccupiedArea: leasedOccupiedArea ?? this.leasedOccupiedArea,
      vacancyArea: vacancyArea ?? this.vacancyArea,
      minFloorplate: minFloorplate ?? this.minFloorplate,
      maxFloorplate: maxFloorplate ?? this.maxFloorplate,
      orBareshell: orBareshell ?? this.orBareshell,
      orWarmshell: orWarmshell ?? this.orWarmshell,
      orFullyFurnished: orFullyFurnished ?? this.orFullyFurnished,
      lrBareshell: lrBareshell ?? this.lrBareshell,
      lrWarmshell: lrWarmshell ?? this.lrWarmshell,
      lrFullyFurnished: lrFullyFurnished ?? this.lrFullyFurnished,
      projectStatusId: projectStatusId ?? this.projectStatusId,
      remarks: remarks ?? this.remarks,
      syncGlobalStatus: syncGlobalStatus ?? this.syncGlobalStatus,
      syncLocalStatus: syncLocalStatus ?? this.syncLocalStatus,
      projectId: projectId ?? this.projectId,
    );
  }

  /// Map -> Object
  factory CSubProjectEntity.fromMap(Map<String, dynamic> map) {
    return CSubProjectEntity(
      subProjectId: map['subProjectId'],
      dos: map['dos'],
      subProjectName: map['subProjectName'],
      storeyBasement: map['storeyBasement'],
      storeyPodium: map['storeyPodium'],
      storeyService: map['storeyService'],
      storeyHabitable: map['storeyHabitable'],
      constStartDate: map['constStartDate'],
      constEndDate: map['constEndDate'],
      marketingStartDate: map['marketingStartDate'],
      marketingEndDate: map['marketingEndDate'],
      constructionProgressId: map['constructionProgressId'],
      floorSlab: map['floorSlab'],
      buildingTypeId: map['buildingTypeId'],
      operationModelId: map['operationModelId'],
      totalSupplySqft: map['totalSupplySqft'],
      soldAreaSqft: map['soldAreaSqft'],
      unsoldAreaSqft: map['unsoldAreaSqft'],
      leasedOccupiedArea: map['leasedOccupiedArea'],
      vacancyArea: map['vacancyArea'],
      minFloorplate: map['minFloorplate'],
      maxFloorplate: map['maxFloorplate'],
      orBareshell: map['orBareshell'],
      orWarmshell: map['orWarmshell'],
      orFullyFurnished: map['orFullyFurnished'],
      lrBareshell: map['lrBareshell'],
      lrWarmshell: map['lrWarmshell'],
      lrFullyFurnished: map['lrFullyFurnished'],
      projectStatusId: map['projectStatusId'],
      remarks: map['remarks'],
      syncGlobalStatus: map['syncGlobalStatus'],
      syncLocalStatus: map['syncLocalStatus'],
      projectId: map['projectId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'subProjectId': subProjectId,
      'dos': dos,
      'subProjectName': subProjectName,
      'storeyBasement': storeyBasement,
      'storeyPodium': storeyPodium,
      'storeyService': storeyService,
      'storeyHabitable': storeyHabitable,
      'constStartDate': constStartDate,
      'constEndDate': constEndDate,
      'marketingStartDate': marketingStartDate,
      'marketingEndDate': marketingEndDate,
      'constructionProgressId': constructionProgressId,
      'floorSlab': floorSlab,
      'buildingTypeId': buildingTypeId,
      'operationModelId': operationModelId,
      'totalSupplySqft': totalSupplySqft,
      'soldAreaSqft': soldAreaSqft,
      'unsoldAreaSqft': unsoldAreaSqft,
      'leasedOccupiedArea': leasedOccupiedArea,
      'vacancyArea': vacancyArea,
      'minFloorplate': minFloorplate,
      'maxFloorplate': maxFloorplate,
      'orBareshell': orBareshell,
      'orWarmshell': orWarmshell,
      'orFullyFurnished': orFullyFurnished,
      'lrBareshell': lrBareshell,
      'lrWarmshell': lrWarmshell,
      'lrFullyFurnished': lrFullyFurnished,
      'projectStatusId': projectStatusId,
      'remarks': remarks,
      'syncGlobalStatus': syncGlobalStatus,
      'syncLocalStatus': syncLocalStatus,
      'projectId': projectId,
    };
  }
}
