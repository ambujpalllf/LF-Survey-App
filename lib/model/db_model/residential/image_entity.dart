class ImageEntity {
  int? id;
  int? resident;
  int? commercial;
  int? imageId;
  String? imageUri;
  String? dos;
  int? sync;
  int? type;
  String? imgLat;
  String? imgLon;

  ImageEntity({
    this.id,
    this.resident,
    this.commercial,
    this.imageId,
    this.imageUri,
    this.dos,
    this.sync,
    this.type,
    this.imgLat,
    this.imgLon,
  });

  /// Convert object to DB map
  Map<String, dynamic> toImDb() {
    return {
      // 'id': id,
      'RESIDENT': resident,
      'COMMERICIAL': commercial,
      'imageId': imageId,
      'imageUri': imageUri,
      'dos': dos,
      'sync': sync,
      'type': type,
      'img_lat': imgLat,
      'img_lon': imgLon,
    };
  }

  /// Create object from DB map
  factory ImageEntity.fromJson(Map<String, dynamic> map) {
    return ImageEntity(
      id: map['id'],
      resident: map['RESIDENT'],
      commercial: map['COMMERICIAL'],
      imageId: map['imageId'],
      imageUri: map['imageUri'],
      dos: map['dos'],
      sync: map['sync'],
      type: map['type'],
      imgLat: map['img_lat'],
      imgLon: map['img_lon'],
    );
  }

  /// Copy method
  ImageEntity copyWith({
    int? id,
    int? resident,
    int? commercial,
    int? imageId,
    String? imageUri,
    String? dos,
    int? sync,
    int? type,
    String? imgLat,
    String? imgLon,
  }) {
    return ImageEntity(
      id: id ?? this.id,
      resident: resident ?? this.resident,
      commercial: commercial ?? this.commercial,
      imageId: imageId ?? this.imageId,
      imageUri: imageUri ?? this.imageUri,
      dos: dos ?? this.dos,
      sync: sync ?? this.sync,
      type: type ?? this.type,
      imgLat: imgLat ?? this.imgLat,
      imgLon: imgLon ?? this.imgLon,
    );
  }
}
