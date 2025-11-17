import 'package:walldecor/models/all_library_model.dart';

class FavoriteImageModel {
  String? id;
  String? type;
  String? favoriteImageId;
  Url? url;
  ImageOwner? imageOwner;
  String? userId;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  FavoriteImageModel({
    this.id,
    this.type,
    this.favoriteImageId,
    this.url,
    this.imageOwner,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  FavoriteImageModel copyWith({
    String? id,
    String? type,
    String? favoriteImageId,
    Url? url,
    ImageOwner? imageOwner,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? v,
  }) =>
      FavoriteImageModel(
        id: id ?? this.id,
        type: type ?? this.type,
        favoriteImageId: favoriteImageId ?? this.favoriteImageId,
        url: url ?? this.url,
        imageOwner: imageOwner ?? this.imageOwner,
        userId: userId ?? this.userId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        v: v ?? this.v,
      );

  factory FavoriteImageModel.fromJson(Map<String, dynamic> json) => FavoriteImageModel(
        id: json["_id"] ?? '',
        type: json["type"] ?? '',
        favoriteImageId: json["id"] ?? '',
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
        "id": favoriteImageId,
        "url": url?.toJson(),
        "imageOwner": imageOwner?.toJson(),
        "userId": userId,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
      };
}