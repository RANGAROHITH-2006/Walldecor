import 'package:walldecor/models/all_library_model.dart';

class DownloadImageModel {
  String? id;
  String? type;
  String? downloadImageId;
  Url? url;
  ImageOwner? imageOwner;
  String? userId;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  DownloadImageModel({
    this.id,
    this.type,
    this.downloadImageId,
    this.url,
    this.imageOwner,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  DownloadImageModel copyWith({
    String? id,
    String? type,
    String? downloadImageId,
    Url? url,
    ImageOwner? imageOwner,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? v,
  }) =>
      DownloadImageModel(
        id: id ?? this.id,
        type: type ?? this.type,
        downloadImageId: downloadImageId ?? this.downloadImageId,
        url: url ?? this.url,
        imageOwner: imageOwner ?? this.imageOwner,
        userId: userId ?? this.userId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        v: v ?? this.v,
      );

  factory DownloadImageModel.fromJson(Map<String, dynamic> json) => DownloadImageModel(
        id: json["_id"] ?? '',
        type: json["type"] ?? '',
        downloadImageId: json["id"] ?? '',
        url: json["url"] == null ? null : Url.fromJson(json["url"]),
        imageOwner: json["imageOwner"] == null
            ? null
            : ImageOwner.fromJson(json["imageOwner"]),
        userId: json["userId"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        v: json["__v"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "type": type,
        "id": downloadImageId,
        "url": url?.toJson(),
        "imageOwner": imageOwner?.toJson(),
        "userId": userId,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
      };
}

class Url {
  String? full;
  String? regular;
  String? small;

  Url({
    this.full,
    this.regular,
    this.small,
  });

  Url copyWith({
    String? full,
    String? regular,
    String? small,
  }) =>
      Url(
        full: full ?? this.full,
        regular: regular ?? this.regular,
        small: small ?? this.small,
      );

  factory Url.fromJson(Map<String, dynamic> json) => Url(
        full: json["full"] ?? '',
        regular: json["regular"] ?? '',
        small: json["small"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "full": full,
        "regular": regular,
        "small": small,
      };
}
