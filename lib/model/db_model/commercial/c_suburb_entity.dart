class CSuburbEntity {
  int suburbId;
  String suburbName;
  int cityId;

  CSuburbEntity({required this.suburbId, required this.suburbName, required this.cityId});
  Map<String, dynamic> toCSuburbDB() {
    return {'suburbId': suburbId, 'suburbName': suburbName, 'cityId': cityId};
  }

  factory CSuburbEntity.fromJson(Map<String, dynamic> map) {
    return CSuburbEntity(suburbId: map['suburbId'], suburbName: map['suburbName'], cityId: map['cityId']);
  }
}
