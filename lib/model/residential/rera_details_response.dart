import 'dart:convert';

ReraDetailsResponse reraDetailsResponseFromJson(String str) => ReraDetailsResponse.fromJson(json.decode(str));

String reraDetailsResponseToJson(ReraDetailsResponse data) => json.encode(data.toJson());

class ReraDetailsResponse {
  List<ReraDetails>? data;
  String? status;
  String? message;

  ReraDetailsResponse({this.data, this.status, this.message});

  factory ReraDetailsResponse.fromJson(Map<String, dynamic> json) => ReraDetailsResponse(
    data: json["data"] == null ? [] : List<ReraDetails>.from(json["data"]!.map((x) => ReraDetails.fromJson(x))),
    status: json["status"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "status": status,
    "message": message,
  };
}

class ReraDetails {
  int? id;
  String? reraRegNo;
  String? promoterName;
  String? projectName;
  String? projectAddress;

  ReraDetails({this.id, this.reraRegNo, this.promoterName, this.projectName, this.projectAddress});

  factory ReraDetails.fromJson(Map<String, dynamic> json) => ReraDetails(
    id: json["id"],
    reraRegNo: json["rera_reg_no"],
    promoterName: json["promoter_name"],
    projectName: json["project_name"],
    projectAddress: json["project_address"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "rera_reg_no": reraRegNo,
    "promoter_name": promoterName,
    "project_name": projectName,
    "project_address": projectAddress,
  };
}
