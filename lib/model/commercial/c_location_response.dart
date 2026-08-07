class CLocationResponse {
  List<CCitiesList>? citiesList;
  CLocationResponse({this.citiesList});

  factory CLocationResponse.fromJson(Map<String, dynamic> json) => CLocationResponse(
    citiesList: json["citiesList"] == null
        ? []
        : List<CCitiesList>.from(json["citiesList"]!.map((x) => CCitiesList.fromJson(x))),
  );
  Map<String, dynamic> toJson() => {
    "citiesList": citiesList == null ? [] : List<dynamic>.from(citiesList!.map((x) => x.toJson())),
  };
}

class CCitiesList {
  int? cityId;
  String? cityName;
  List<CSuburbsList>? suburbsList;
  CCitiesList({this.cityId, this.cityName, this.suburbsList});

  factory CCitiesList.fromJson(Map<String, dynamic> json) => CCitiesList(
    cityId: json["cityId"],
    cityName: json["cityName"],
    suburbsList: json["suburbsList"] == null
        ? []
        : List<CSuburbsList>.from(json["suburbsList"]!.map((x) => CSuburbsList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "cityId": cityId,
    "cityName": cityName,
    "suburbsList": suburbsList == null ? [] : List<dynamic>.from(suburbsList!.map((e) => e.toJson())),
  };
}

class CSuburbsList {
  int? suburbId;
  String? suburbName;
  List<CLocationsList>? locationsList;

  CSuburbsList({this.suburbId, this.suburbName, this.locationsList});

  factory CSuburbsList.fromJson(Map<String, dynamic> json) => CSuburbsList(
    suburbId: json["suburbId"],
    suburbName: json["suburbName"],
    locationsList: json["locationsList"] == null
        ? []
        : List<CLocationsList>.from(json["locationsList"]!.map((x) => CLocationsList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "suburbId": suburbId,
    "suburbName": suburbName,
    "locationsList": locationsList == null ? [] : List<dynamic>.from(locationsList!.map((x) => x.toJson())),
  };
}

class CLocationsList {
  int? locationId;
  String? locationName;

  CLocationsList({this.locationId, this.locationName});

  factory CLocationsList.fromJson(Map<String, dynamic> json) =>
      CLocationsList(locationId: json["locationId"], locationName: json["locationName"]);

  Map<String, dynamic> toJson() => {"locationId": locationId, "locationName": locationName};
}
