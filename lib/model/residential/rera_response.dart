import 'dart:convert';

ReraResponse reraResponseFromJson(String str) => ReraResponse.fromJson(json.decode(str));

String reraResponseToJson(ReraResponse data) => json.encode(data.toJson());

class ReraResponse {
  List<ReraDatum>? data;
  String? status;
  String? message;

  ReraResponse({this.data, this.status, this.message});

  factory ReraResponse.fromJson(Map<String, dynamic> json) => ReraResponse(
    data: json["data"] == null ? [] : List<ReraDatum>.from(json["data"]!.map((x) => ReraDatum.fromJson(x))),
    status: json["status"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "status": status,
    "message": message,
  };
}

class ReraDatum {
  String? mastertype;
  int? id;
  int? projectId;
  String? name;
  String? value;

  ReraDatum({this.mastertype, this.id, this.projectId, this.name, this.value});

  factory ReraDatum.fromJson(Map<String, dynamic> json) => ReraDatum(
    mastertype: json["mastertype"],
    id: json["id"],
    projectId: json["project_id"],
    name: json["name"],
    value: json["value"],
  );

  Map<String, dynamic> toJson() => {
    "mastertype": mastertype,
    "id": id,
    "project_id": projectId,
    "name": name,
    "value": value,
  };
}
