class CCityEntity {
  int cityId;
  String cityName;
  bool checked;

  CCityEntity({required this.cityId, required this.cityName, required this.checked});

  Map<String, dynamic> toCCityDB() {
    return {'cityId': cityId, 'cityName': cityName, 'checked': checked ? 1 : 0};
  }

  factory CCityEntity.fromMap(Map<String, dynamic> map) {
    return CCityEntity(cityId: map['cityId'], cityName: map['cityName'], checked: map['checked'] == 1);
  }
}
