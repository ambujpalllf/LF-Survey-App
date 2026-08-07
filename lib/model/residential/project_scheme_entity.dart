class ProjectSchemeEntity {
  int? schemeId;
  int? projectId;
  int? qtrId;
  String? openText;

  ProjectSchemeEntity({this.schemeId, this.projectId, this.qtrId, this.openText});

  /// Convert DB Map → Model
  factory ProjectSchemeEntity.fromJson(Map<String, dynamic> json) {
    return ProjectSchemeEntity(
      schemeId: json['schemeId'],
      projectId: json['projectId'],
      qtrId: json['qtrId'],
      openText: json['openText'],
    );
  }

  /// Convert Model → DB Map
  Map<String, dynamic> toMap() {
    return {'schemeId': schemeId, 'projectId': projectId, 'qtrId': qtrId, 'openText': openText};
  }
}
