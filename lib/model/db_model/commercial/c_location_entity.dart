class CLocationEntity {
  int locationId;
  String locationName;
  int suburbId;
  bool checked;

  CLocationEntity({
    required this.locationId,
    required this.locationName,
    required this.suburbId,
    required this.checked,
  });

  Map<String, dynamic> toCLocationDB() {
    return {'locationId': locationId, 'locationName': locationName, 'suburbId': suburbId, 'checked': checked ? 1 : 0};
  }

  factory CLocationEntity.fromJson(Map<String, dynamic> map) {
    return CLocationEntity(
      locationId: map['locationId'],
      locationName: map['locationName'],
      suburbId: map['suburbId'],
      checked: map['checked'] == 1,
    );
  }
  CLocationEntity copyWith({int? locationId, String? locationName, int? suburbId, bool? checked}) {
    return CLocationEntity(
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
      suburbId: suburbId ?? this.suburbId,
      checked: checked ?? this.checked,
    );
  }
}
