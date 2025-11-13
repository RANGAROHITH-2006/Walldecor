import 'dart:convert';

class CategorydetailesModel {
    final String id;
    final Urls urls;
    final User user;

    CategorydetailesModel({
        required this.id,
        required this.urls,
        required this.user,
    });

    CategorydetailesModel copyWith({
        String? id,
        Urls? urls,
        User? user,
    }) => 
        CategorydetailesModel(
            id: id ?? this.id,
            urls: urls ?? this.urls,
            user: user ?? this.user,
        );

    factory CategorydetailesModel.fromRawJson(String str) => CategorydetailesModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory CategorydetailesModel.fromJson(Map<String, dynamic> json) => CategorydetailesModel(
        id: json["id"],
        urls: Urls.fromJson(json["urls"]),
        user: User.fromJson(json["user"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "urls": urls.toJson(),
        "user": user.toJson(),
    };
}

class Urls {
    final String full;
    final String regular;
    final String small;

    Urls({
        required this.full,
        required this.regular,
        required this.small,
    });

    Urls copyWith({
        String? full,
        String? regular,
        String? small,
    }) => 
        Urls(
            full: full ?? this.full,
            regular: regular ?? this.regular,
            small: small ?? this.small,
        );

    factory Urls.fromRawJson(String str) => Urls.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Urls.fromJson(Map<String, dynamic> json) => Urls(
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
  id: json["id"] ?? '',
  username: json["username"] ?? '',
  name: json["name"] ?? '',
  firstName: json["first_name"] ?? '',
  lastName: json["last_name"] ?? '',
  profileLink: json["profile_link"] ?? '',
  profileImage: json["profile_image"] ?? '',
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
