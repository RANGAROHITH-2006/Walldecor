import 'dart:convert';

class CategorytrendingModel {
    final String id;
    final String slug;
    final String title;
    final String description;
    final CoverPhoto coverPhoto;
    final List<PreviewPhoto> previewPhotos;

    CategorytrendingModel({
        required this.id,
        required this.slug,
        required this.title,
        required this.description,
        required this.coverPhoto,
        required this.previewPhotos,
    });

    CategorytrendingModel copyWith({
        String? id,
        String? slug,
        String? title,
        String? description,
        CoverPhoto? coverPhoto,
        List<PreviewPhoto>? previewPhotos,
    }) => 
        CategorytrendingModel(
            id: id ?? this.id,
            slug: slug ?? this.slug,
            title: title ?? this.title,
            description: description ?? this.description,
            coverPhoto: coverPhoto ?? this.coverPhoto,
            previewPhotos: previewPhotos ?? this.previewPhotos,
        );

    factory CategorytrendingModel.fromRawJson(String str) => CategorytrendingModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory CategorytrendingModel.fromJson(Map<String, dynamic> json) => CategorytrendingModel(
        id: json["id"],
        slug: json["slug"],
        title: json["title"],
        description: json["description"],
        coverPhoto: CoverPhoto.fromJson(json["cover_photo"]),
        previewPhotos: List<PreviewPhoto>.from(json["preview_photos"].map((x) => PreviewPhoto.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "slug": slug,
        "title": title,
        "description": description,
        "cover_photo": coverPhoto.toJson(),
        "preview_photos": List<dynamic>.from(previewPhotos.map((x) => x.toJson())),
    };
}

class CoverPhoto {
    final PreviewPhoto urls;

    CoverPhoto({
        required this.urls,
    });

    CoverPhoto copyWith({
        PreviewPhoto? urls,
    }) => 
        CoverPhoto(
            urls: urls ?? this.urls,
        );

    factory CoverPhoto.fromRawJson(String str) => CoverPhoto.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory CoverPhoto.fromJson(Map<String, dynamic> json) => CoverPhoto(
        urls: PreviewPhoto.fromJson(json["urls"]),
    );

    Map<String, dynamic> toJson() => {
        "urls": urls.toJson(),
    };
}

class PreviewPhoto {
    final String regular;
    final String small;

    PreviewPhoto({
        required this.regular,
        required this.small,
    });

    PreviewPhoto copyWith({
        String? regular,
        String? small,
    }) => 
        PreviewPhoto(
            regular: regular ?? this.regular,
            small: small ?? this.small,
        );

    factory PreviewPhoto.fromRawJson(String str) => PreviewPhoto.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory PreviewPhoto.fromJson(Map<String, dynamic> json) => PreviewPhoto(
        regular: json["regular"],
        small: json["small"],
    );

    Map<String, dynamic> toJson() => {
        "regular": regular,
        "small": small,
    };
}
