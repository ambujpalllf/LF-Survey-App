class RejectReasonModel {
  List<RejectDatum>? data;
  String? status;
  String? message;

  RejectReasonModel({this.data, this.status, this.message});

  factory RejectReasonModel.fromJson(Map<String, dynamic> json) => RejectReasonModel(
    data: json["data"] == null ? [] : List<RejectDatum>.from(json["data"]!.map((x) => RejectDatum.fromJson(x))),
    status: json["status"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "status": status,
    "message": message,
  };
}

class RejectDatum {
  int? rejectId;
  int? projectId;
  int? qtrId;
  String? rejectByName;
  String? rejectReason;
  String? fixedByName;
  String? fixedRemarks;

  RejectDatum({
    this.rejectId,
    this.projectId,
    this.qtrId,
    this.rejectByName,
    this.rejectReason,
    this.fixedByName,
    this.fixedRemarks,
  });

  factory RejectDatum.fromJson(Map<String, dynamic> json) => RejectDatum(
    rejectId: json["rejectId"],
    projectId: json["projectId"],
    qtrId: json["qtrId"],
    rejectByName: json["rejectByName"],
    rejectReason: json["rejectReason"],
    fixedByName: json["fixedByName"],
    fixedRemarks: json["fixedRemarks"],
  );

  Map<String, dynamic> toJson() => {
    "rejectId": rejectId,
    "projectId": projectId,
    "qtrId": qtrId,
    "rejectByName": rejectByName,
    "rejectReason": rejectReason,
    "fixedByName": fixedByName,
    "fixedRemarks": fixedRemarks,
  };
}
