import 'dart:convert';

ArchitectResponse architectResponseFromJson(String str) => ArchitectResponse.fromJson(json.decode(str));

String architectResponseToJson(ArchitectResponse data) => json.encode(data.toJson());

class ArchitectResponse {
  List<ArchitectDataum>? architectList;

  ArchitectResponse({this.architectList});

  factory ArchitectResponse.fromJson(Map<String, dynamic> json) => ArchitectResponse(
    architectList: json["architectList"] == null
        ? []
        : List<ArchitectDataum>.from(json["architectList"]!.map((x) => ArchitectDataum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "architectList": architectList == null ? [] : List<dynamic>.from(architectList!.map((x) => x.toJson())),
  };
}

class ArchitectDataum {
  int? architectId;
  String? architectName;

  ArchitectDataum({this.architectId, this.architectName});

  factory ArchitectDataum.fromJson(Map<String, dynamic> json) =>
      ArchitectDataum(architectId: json["architectId"], architectName: json["architectName"]);

  Map<String, dynamic> toJson() => {"architectId": architectId, "architectName": architectName};
}
