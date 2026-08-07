import 'dart:convert';

PrjSearchDetails prjSearchDetailsFromJson(String str) => PrjSearchDetails.fromJson(json.decode(str));

String prjSearchDetailsToJson(PrjSearchDetails data) => json.encode(data.toJson());

class PrjSearchDetails {
  List<PrjSearchDatum>? data;
  String? status;
  String? message;

  PrjSearchDetails({this.data, this.status, this.message});

  factory PrjSearchDetails.fromJson(Map<String, dynamic> json) => PrjSearchDetails(
    data: json["data"] == null ? [] : List<PrjSearchDatum>.from(json["data"]!.map((x) => PrjSearchDatum.fromJson(x))),
    status: json["status"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "status": status,
    "message": message,
  };
}

class PrjSearchDatum {
  int? projectId;
  String? reraNo;
  String? projectName;
  String? builder;
  String? address;
  String? projectcontact;
  String? buildercontact;
  int? builderid;
  String? city;
  String? suburb;
  String? area;
  String? location;
  String? road;

  PrjSearchDatum({
    this.projectId,
    this.reraNo,
    this.projectName,
    this.builder,
    this.address,
    this.projectcontact,
    this.buildercontact,
    this.builderid,
    this.city,
    this.suburb,
    this.area,
    this.location,
    this.road,
  });

  factory PrjSearchDatum.fromJson(Map<String, dynamic> json) => PrjSearchDatum(
    projectId: json["PROJECT_ID"],
    reraNo: json["RERA_NO"],
    projectName: json["PROJECT_NAME"],
    builder: json["BUILDER"],
    address: json["ADDRESS"],
    projectcontact: json["PROJECTCONTACT"],
    buildercontact: json["BUILDERCONTACT"],
    builderid: json["BUILDERID"],
    city: json["CITY"],
    suburb: json["SUBURB"],
    area: json["AREA"],
    location: json["LOCATION"],
    road: json["ROAD"],
  );

  Map<String, dynamic> toJson() => {
    "PROJECT_ID": projectId,
    "RERA_NO": reraNo,
    "PROJECT_NAME": projectName,
    "BUILDER": builder,
    "ADDRESS": address,
    "PROJECTCONTACT": projectcontact,
    "BUILDERCONTACT": buildercontact,
    "BUILDERID": builderid,
    "CITY": city,
    "SUBURB": suburb,
    "AREA": area,
    "LOCATION": location,
    "ROAD": road,
  };
}
