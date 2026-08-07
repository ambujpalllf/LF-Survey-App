class LocationModel {
  int? id;
  double lat;
  double long;
  double accuracy;
  int timeStamp;
  int batteryPercentage;
  int mobileAppId;
  int userId;
  String isMock;
  String provider;
  LocationModel({
    this.id,
    required this.lat,
    required this.long,
    required this.accuracy,
    required this.timeStamp,
    required this.batteryPercentage,
    required this.mobileAppId,
    required this.userId,
    required this.isMock,
    required this.provider,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
    id: json['id'],
    lat: json['lat'],
    long: json['long'],
    accuracy: json['accuracy'],
    timeStamp: json['timeStamp'],
    batteryPercentage: json['batteryPercentage'],
    mobileAppId: json['mobileAppId'],
    userId: json['userId'],
    isMock: json['isMock'],
    provider: json['provider'],
  );

  Map<String, dynamic> toLocationDb() => {
    'id': id,
    'lat': lat,
    'long': long,
    'accuracy': accuracy,
    'timeStamp': timeStamp,
    'batteryPercentage': batteryPercentage,
    'mobileAppId': mobileAppId,
    'userId': userId,
    'isMock': isMock,
    'provider': provider,
  };
}
