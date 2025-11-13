import 'dart:convert';

class Welcome {
    final String id;
    final String title;
    final CoverPhoto coverPhoto;
    final User user;

    Welcome({
        required this.id,
        required this.title,
        required this.coverPhoto,
        required this.user,
    });

    Welcome copyWith({
        String? id,
        String? title,
        CoverPhoto? coverPhoto,
        User? user,
    }) => 
        Welcome(
            id: id ?? this.id,
            title: title ?? this.title,
            coverPhoto: coverPhoto ?? this.coverPhoto,
            user: user ?? this.user,
        );

    factory Welcome.fromRawJson(String str) => Welcome.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Welcome.fromJson(Map<String, dynamic> json) => Welcome(
        id: json["id"],
        title: json["title"],
        coverPhoto: CoverPhoto.fromJson(json["cover_photo"]),
        user: User.fromJson(json["user"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "cover_photo": coverPhoto.toJson(),
        "user": user.toJson(),
    };
}

class CoverPhoto {
    final Urls urls;

    CoverPhoto({
        required this.urls,
    });

    CoverPhoto copyWith({
        Urls? urls,
    }) => 
        CoverPhoto(
            urls: urls ?? this.urls,
        );

    factory CoverPhoto.fromRawJson(String str) => CoverPhoto.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory CoverPhoto.fromJson(Map<String, dynamic> json) => CoverPhoto(
        urls: Urls.fromJson(json["urls"]),
    );

    Map<String, dynamic> toJson() => {
        "urls": urls.toJson(),
    };
}

class Urls {
    final String regular;
    final String small;

    Urls({
        required this.regular,
        required this.small,
    });

    Urls copyWith({
        String? regular,
        String? small,
    }) => 
        Urls(
            regular: regular ?? this.regular,
            small: small ?? this.small,
        );

    factory Urls.fromRawJson(String str) => Urls.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Urls.fromJson(Map<String, dynamic> json) => Urls(
        regular: json["regular"],
        small: json["small"],
    );

    Map<String, dynamic> toJson() => {
        "regular": regular,
        "small": small,
    };
}

class User {
    final String id;
    final String username;
    final String name;
    final String firstName;
    final String lastName;
    final String profileLink;
    final String profileImage;

    User({
        required this.id,
        required this.username,
        required this.name,
        required this.firstName,
        required this.lastName,
        required this.profileLink,
        required this.profileImage,
    });

    User copyWith({
        String? id,
        String? username,
        String? name,
        String? firstName,
        String? lastName,
        String? profileLink,
        String? profileImage,
    }) => 
        User(
            id: id ?? this.id,
            username: username ?? this.username,
            name: name ?? this.name,
            firstName: firstName ?? this.firstName,
            lastName: lastName ?? this.lastName,
            profileLink: profileLink ?? this.profileLink,
            profileImage: profileImage ?? this.profileImage,
        );

    factory User.fromRawJson(String str) => User.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        username: json["username"],
        name: json["name"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        profileLink: json["profile_link"],
        profileImage: json["profile_image"],
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
