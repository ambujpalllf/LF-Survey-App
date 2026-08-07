import 'dart:convert';

CmProgressResponse cmProgressResponseFromJson(String str) => CmProgressResponse.fromJson(json.decode(str));
String cmProgressResponseToJson(CmProgressResponse data) => json.encode(data.toJson());

class CmProgressResponse {
  String? status;
  String? message;
  CmProgressDatum? data;
  CmProgressResponse({this.data, this.message, this.status});

  factory CmProgressResponse.fromJson(Map<String, dynamic> json) =>
      CmProgressResponse(status: json["status"], message: json["message"], data: json["data"]);

  Map<String, dynamic> toJson() => {"status": status, "message": message, "data": data};
}

class CmProgressDatum {
  List<RowDatum>? rowDatum;
  String? numberOfSlabs;
  String? numberOfFloors;
  double? overAllProgress;

  CmProgressDatum({this.rowDatum, this.numberOfFloors, this.numberOfSlabs, this.overAllProgress});

  factory CmProgressDatum.fromJson(Map<String, dynamic> json) => CmProgressDatum(
    rowDatum: json["rows"] == null ? [] : List<RowDatum>.from(json["rows"]!.map((x) => RowDatum.formJson(x))),
    numberOfFloors: json["number_of_floors"],
    numberOfSlabs: json["number_of_slabs"],
    overAllProgress: json["overall_progress"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "rows": rowDatum == null ? [] : List<dynamic>.from(rowDatum!.map((x) => x.toJson())),
    "number_of_slabs": numberOfSlabs,
    "number_of_floors": numberOfFloors,
    "overall_progress": overAllProgress,
  };

  Map<String, dynamic> toDbJson() => {
    "rows": jsonEncode(rowDatum!.map((x) => x.toJson()).toList()),
    "number_of_slabs": numberOfSlabs,
    "number_of_floors": numberOfFloors,
    "overall_progress": overAllProgress,
  };
}

class RowDatum {
  int? wingId;
  String? progress;
  String? wingName;
  String? completion;
  int? constructionProgressId;
  String? constructionStageBreakupItems;
  int? constructionProgressWingLinkId;

  RowDatum({
    this.wingId,
    this.progress,
    this.wingName,
    this.completion,
    this.constructionProgressId,
    this.constructionStageBreakupItems,
    this.constructionProgressWingLinkId,
  });

  factory RowDatum.formJson(Map<String, dynamic> json) => RowDatum(
    wingId: json["wing_id"],
    progress: json["progress"],
    wingName: json["wing_name"],
    completion: json["completion"],
    constructionProgressId: json["construction_progress_id"],
    constructionStageBreakupItems: json["construction_stage_breakup_items"],
    constructionProgressWingLinkId: json["construction_progress_wing_link_id"],
  );

  Map<String, dynamic> toJson() => {
    "wing_id": wingId,
    "progress": progress,
    "wing_name": wingName,
    "completion": completion,
    "construction_progress_id": constructionProgressId,
    "construction_stage_breakup_items": constructionStageBreakupItems,
    "construction_progress_wing_link_id": constructionProgressWingLinkId,
  };
}
