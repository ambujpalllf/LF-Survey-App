import 'dart:convert';

CitiesResponse citiesResponseFromJson(String str) => CitiesResponse.fromJson(json.decode(str));

String citiesResponseToJson(CitiesResponse data) => json.encode(data.toJson());

class CitiesResponse {
  List<CitiesDatum>? citiesList;

  CitiesResponse({this.citiesList});

  factory CitiesResponse.fromJson(Map<String, dynamic> json) => CitiesResponse(
    citiesList: json["citiesList"] == null
        ? []
        : List<CitiesDatum>.from(json["citiesList"]!.map((x) => CitiesDatum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "citiesList": citiesList == null ? [] : List<dynamic>.from(citiesList!.map((x) => x.toJson())),
  };
}

class CitiesDatum {
  int? cityId;
  String? cityName;
  List<SuburbsList>? suburbsList;
  CitiesDatum({this.cityId, this.cityName, this.suburbsList});

  factory CitiesDatum.fromJson(Map<String, dynamic> json) => CitiesDatum(
    cityId: json["cityId"],
    cityName: json["cityName"],
    suburbsList: json["suburbsList"] == null
        ? []
        : List<SuburbsList>.from(json["suburbsList"]!.map((x) => SuburbsList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "cityId": cityId,
    "cityName": cityName,
    "suburbsList": suburbsList == null ? [] : List<dynamic>.from(suburbsList!.map((x) => x.toJson())),
  };
}

class SuburbsList {
  int? suburbId;
  String? suburbName;
  List<LocationsList>? locationsList;

  SuburbsList({this.suburbId, this.suburbName, this.locationsList});

  factory SuburbsList.fromJson(Map<String, dynamic> json) => SuburbsList(
    suburbId: json["suburbId"],
    suburbName: json["suburbName"],
    locationsList: json["locationsList"] == null
        ? []
        : List<LocationsList>.from(json["locationsList"]!.map((x) => LocationsList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "suburbId": suburbId,
    "suburbName": suburbName,
    "locationsList": locationsList == null ? [] : List<dynamic>.from(locationsList!.map((x) => x.toJson())),
  };
}

class LocationsList {
  int? locationId;
  String? locationName;

  LocationsList({this.locationId, this.locationName});

  factory LocationsList.fromJson(Map<String, dynamic> json) =>
      LocationsList(locationId: json["locationId"], locationName: json["locationName"]);

  Map<String, dynamic> toJson() => {"locationId": locationId, "locationName": locationName};
}
