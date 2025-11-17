import 'dart:convert';

class LibraryDetailsModel {
    final String id;
    final String name;
    final List<SavedImage> savedImage;

    LibraryDetailsModel({
        required this.id,
        required this.name,
        required this.savedImage,
    });

    LibraryDetailsModel copyWith({
        String? id,
        String? name,
        List<SavedImage>? savedImage,
    }) => 
        LibraryDetailsModel(
            id: id ?? this.id,
            name: name ?? this.name,
            savedImage: savedImage ?? this.savedImage,
        );

    factory LibraryDetailsModel.fromRawJson(String str) => LibraryDetailsModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

   factory LibraryDetailsModel.fromJson(Map<String, dynamic> json) => LibraryDetailsModel(
  id: json["_id"] ?? "",
  name: json["name"] ?? "",
  savedImage: json["savedImage"] == null
      ? []
      : List<SavedImage>.from(
          json["savedImage"].map((x) => SavedImage.fromJson(x)),
        ),
);
    Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "savedImage": List<dynamic>.from(savedImage.map((x) => x.toJson())),
    };
}

class SavedImage {
    final String savedImageId;
    final Url url;
    final ImageOwner imageOwner;
    final String id;

    SavedImage({
        required this.savedImageId,
        required this.url,
        required this.imageOwner,
        required this.id,
    });

    SavedImage copyWith({
        String? savedImageId,
        Url? url,
        ImageOwner? imageOwner,
        String? id,
    }) => 
        SavedImage(
            savedImageId: savedImageId ?? this.savedImageId,
            url: url ?? this.url,
            imageOwner: imageOwner ?? this.imageOwner,
            id: id ?? this.id,
        );

    factory SavedImage.fromRawJson(String str) => SavedImage.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory SavedImage.fromJson(Map<String, dynamic> json) => SavedImage(
        savedImageId: json["id"] ?? "",
        url: Url.fromJson(json["url"]),
        imageOwner: ImageOwner.fromJson(json["imageOwner"]),
        id: json["_id"] ?? "",
    );

    Map<String, dynamic> toJson() => {
        "id": savedImageId,
        "url": url.toJson(),
        "imageOwner": imageOwner.toJson(),
        "_id": id,
    };
}

class ImageOwner {
    final String id;
    final String username;
    final String name;
    final String firstName;
    final String lastName;
    final String profileLink;
    final String profileImage;

    ImageOwner({
        required this.id,
        required this.username,
        required this.name,
        required this.firstName,
        required this.lastName,
        required this.profileLink,
        required this.profileImage,
    });

    ImageOwner copyWith({
        String? id,
        String? username,
        String? name,
        String? firstName,
        String? lastName,
        String? profileLink,
        String? profileImage,
    }) => 
        ImageOwner(
            id: id ?? this.id,
            username: username ?? this.username,
            name: name ?? this.name,
            firstName: firstName ?? this.firstName,
            lastName: lastName ?? this.lastName,
            profileLink: profileLink ?? this.profileLink,
            profileImage: profileImage ?? this.profileImage,
        );

    factory ImageOwner.fromRawJson(String str) => ImageOwner.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory ImageOwner.fromJson(Map<String, dynamic> json) => ImageOwner(
        id: json["id"] ?? "",
        username: json["username"] ?? "",
        name: json["name"] ?? "",
        firstName: json["first_name"] ?? "",
        lastName: json["last_name"] ?? "",
        profileLink: json["profile_link"] ?? "",
        profileImage: json["profile_image"] ?? "",
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "name": name,
        "first_name": firstName,
        "last_name": lastName,
        "profile_link": profileLink,
        "profile_image": profileImage,
    };
}

class Url {
    final String full;
    final String regular;
    final String small;

    Url({
        required this.full,
        required this.regular,
        required this.small,
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

    factory Url.fromRawJson(String str) => Url.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Url.fromJson(Map<String, dynamic> json) => Url(
        full: json["full"],
        regular: json["regular"],
        small: json["small"],
    );

    Map<String, dynamic> toJson() => {
        "full": full,
        "regular": regular,
        "small": small,
    };
}
