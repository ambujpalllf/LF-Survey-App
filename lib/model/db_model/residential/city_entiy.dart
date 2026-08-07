class CityEntity {
  int cityId;
  String cityName;
  bool checked;

  CityEntity({required this.cityId, required this.cityName, required this.checked});

  // Convert City -> Map
  Map<String, dynamic> toCityEntityMap() {
    return {'cityId': cityId, 'cityName': cityName, 'checked': checked ? 1 : 0};
  }

  // Convert Map -> City
  factory CityEntity.fromMap(Map<String, dynamic> map) {
    return CityEntity(cityId: map['cityId'], cityName: map['cityName'], checked: map['checked'] == 1);
  }
}
