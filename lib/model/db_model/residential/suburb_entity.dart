class SuburbEntity {
  int suburbId;
  String suburbName;
  int cityId;

  SuburbEntity({required this.suburbId, required this.suburbName, required this.cityId});

  // Convert Suburb -> Map (for insert/update)
  Map<String, dynamic> toSuburbEntityMap() {
    return {'suburbId': suburbId, 'suburbName': suburbName, 'cityId': cityId};
  }

  // Convert Map -> Suburb (from database)
  factory SuburbEntity.fromJson(Map<String, dynamic> map) {
    return SuburbEntity(suburbId: map['suburbId'], suburbName: map['suburbName'], cityId: map['cityId']);
  }
}
