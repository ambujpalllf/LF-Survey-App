class ImageModel {
  final int? id;
  final int imgTypeResOrCommercial;
  final int prjOrSprjId;
  final DateTime? dos;
  final String imagePath;
  final int sync;
  final double imgLat;
  final double imgLong;
  final double imgAccuracy;

  ImageModel({
    this.id,
    required this.imgTypeResOrCommercial,
    required this.prjOrSprjId,
    required this.dos,
    required this.imagePath,
    required this.sync,
    required this.imgLat,
    required this.imgLong,
    required this.imgAccuracy,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      id: json['id'],
      imgTypeResOrCommercial: json['imgTypeResOrCommercial'],
      prjOrSprjId: json['prjOrSprjId'],
      dos: json['dos'] == null ? null : DateTime.parse(json["dos"]),
      imagePath: json['imagePath'],
      sync: json['sync'],
      imgLat: (json['img_lat'] as num).toDouble(),
      imgLong: (json['img_long'] as num).toDouble(),
      imgAccuracy: (json['img_accuracy'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imgTypeResOrCommercial': imgTypeResOrCommercial,
      'prjOrSprjId': prjOrSprjId,
      'dos': dos!.toIso8601String(),
      'imagePath': imagePath,
      'sync': sync,
      'img_lat': imgLat,
      'img_long': imgLong,
      'img_accuracy': imgAccuracy,
    };
  }

  ImageModel copyWith({
    int? id,
    int? imgTypeResOrCommercial,
    int? prjOrSprjId,
    DateTime? dos,
    String? imagePath,
    int? sync,
    double? imgLat,
    double? imgLong,
    double? imgAccuracy,
  }) {
    return ImageModel(
      id: id ?? this.id,
      imgTypeResOrCommercial: imgTypeResOrCommercial ?? this.imgTypeResOrCommercial,
      prjOrSprjId: prjOrSprjId ?? this.prjOrSprjId,
      dos: dos ?? this.dos,
      imagePath: imagePath ?? this.imagePath,
      sync: sync ?? this.sync,
      imgLat: imgLat ?? this.imgLat,
      imgLong: imgLong ?? this.imgLong,
      imgAccuracy: imgAccuracy ?? this.imgAccuracy,
    );
  }
}
