class FlatEntity {
  String id;
  int? flatId;
  String? flatType;
  int? flatSold;
  int? oldFlatSold;
  int? flatUnsold;
  String? flatSize;
  String? flatSizeCarpet;
  double? flatSizeAvg;
  double? flatSizeCarpetAvg;
  int? subProjectId;
  int? projectId;
  int? isSaleableEnable;
  String? sizeType;
  int? dataFilled;

  FlatEntity({
    required this.id,
    this.flatId,
    this.flatType,
    this.flatSold,
    this.oldFlatSold,
    this.flatUnsold,
    this.flatSize,
    this.flatSizeCarpet,
    this.flatSizeAvg,
    this.flatSizeCarpetAvg,
    this.subProjectId,
    this.projectId,
    this.isSaleableEnable,
    this.sizeType,
    this.dataFilled,
  });

  // Convert Map → Object
  factory FlatEntity.fromJson(Map<String, dynamic> json) {
    return FlatEntity(
      id: json['id'] as String,
      flatId: json['flatId'] as int?,
      flatType: json['flatType'] as String?,
      flatSold: json['flatSold'] as int?,
      oldFlatSold: json['oldFlatSold'] as int?,
      flatUnsold: json['flatUnsold'] as int?,
      flatSize: json['flatSize'] as String?,
      flatSizeCarpet: json['flatSizeCarpet'] as String?,
      flatSizeAvg: (json['flatSizeAvg'] as num?)?.toDouble(),
      flatSizeCarpetAvg: (json['flatSizeCarpetAvg'] as num?)?.toDouble(),
      subProjectId: json['subProjectId'] as int?,
      projectId: json['projectId'] as int?,
      isSaleableEnable: json['isSaleableEnable'] as int?,
      sizeType: json['sizeType'] as String?,
      dataFilled: json['dataFilled'] as int?,
    );
  }

  //  Convert Object → Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'flatId': flatId,
      'flatType': flatType,
      'flatSold': flatSold,
      'oldFlatSold': oldFlatSold,
      'flatUnsold': flatUnsold,
      'flatSize': flatSize,
      'flatSizeCarpet': flatSizeCarpet,
      'flatSizeAvg': flatSizeAvg,
      'flatSizeCarpetAvg': flatSizeCarpetAvg,
      'subProjectId': subProjectId,
      'projectId': projectId,
      'isSaleableEnable': isSaleableEnable,
      'sizeType': sizeType,
      'dataFilled': dataFilled,
    };
  }

  // Copy helper (optional but recommended)
  FlatEntity copyWith({
    String? id,
    int? flatId,
    String? flatType,
    int? flatSold,
    int? flatUnsold,
    String? flatSize,
    String? flatSizeCarpet,
    double? flatSizeAvg,
    double? flatSizeCarpetAvg,
    int? subProjectId,
    int? projectId,
    int? isSaleableEnable,
    String? sizeType,
    int? dataFilled,
  }) {
    return FlatEntity(
      id: id ?? this.id,
      flatId: flatId ?? this.flatId,
      flatType: flatType ?? this.flatType,
      flatSold: flatSold ?? this.flatSold,
      flatUnsold: flatUnsold ?? this.flatUnsold,
      flatSize: flatSize ?? this.flatSize,
      flatSizeCarpet: flatSizeCarpet ?? this.flatSizeCarpet,
      flatSizeAvg: flatSizeAvg ?? this.flatSizeAvg,
      flatSizeCarpetAvg: flatSizeCarpetAvg ?? this.flatSizeCarpetAvg,
      subProjectId: subProjectId ?? this.subProjectId,
      projectId: projectId ?? this.projectId,
      isSaleableEnable: isSaleableEnable ?? this.isSaleableEnable,
      sizeType: sizeType ?? this.sizeType,
      dataFilled: dataFilled ?? this.dataFilled,
    );
  }
}
