import 'dart:convert';

ProjectSearchResponse projectSearchResponseFromJson(String str) => ProjectSearchResponse.fromJson(json.decode(str));

String projectSearchResponseToJson(ProjectSearchResponse data) => json.encode(data.toJson());

class ProjectSearchResponse {
  List<ProjectSearchDatum>? data;
  String? status;
  String? message;

  ProjectSearchResponse({this.data, this.status, this.message});

  factory ProjectSearchResponse.fromJson(Map<String, dynamic> json) => ProjectSearchResponse(
    data: json["data"] == null
        ? []
        : List<ProjectSearchDatum>.from(json["data"]!.map((x) => ProjectSearchDatum.fromJson(x))),
    status: json["status"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "status": status,
    "message": message,
  };
}

class ProjectSearchDatum {
  int? projectId;
  String? projectName;

  ProjectSearchDatum({this.projectId, this.projectName});

  factory ProjectSearchDatum.fromJson(Map<String, dynamic> json) =>
      ProjectSearchDatum(projectId: json["PROJECT_ID"], projectName: json["PROJECT_NAME"]);

  Map<String, dynamic> toJson() => {"PROJECT_ID": projectId, "PROJECT_NAME": projectName};
}
