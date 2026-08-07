class LocationEntity {
  int locationId;
  String locationName;
  int suburbId;
  bool checked;

  LocationEntity({required this.locationId, required this.locationName, required this.suburbId, required this.checked});

  /// Location -> Map
  Map<String, dynamic> toLocationEntityMap() {
    return {'locationId': locationId, 'locationName': locationName, 'suburbId': suburbId, 'checked': checked ? 1 : 0};
  }

  /// Map -> Location
  factory LocationEntity.fromJson(Map<String, dynamic> map) {
    return LocationEntity(
      locationId: map['locationId'],
      locationName: map['locationName'],
      suburbId: map['suburbId'],
      checked: map['checked'] == 1,
    );
  }
}
