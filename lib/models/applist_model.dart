import 'dart:convert';

class ApplistModel {
    final List<ToolsBrain> zooq;
    final List<ToolsBrain> toolsBrain;

    ApplistModel({
        required this.zooq,
        required this.toolsBrain,
    });

    ApplistModel copyWith({
        List<ToolsBrain>? zooq,
        List<ToolsBrain>? toolsBrain,
    }) => 
        ApplistModel(
            zooq: zooq ?? this.zooq,
            toolsBrain: toolsBrain ?? this.toolsBrain,
        );

    factory ApplistModel.fromRawJson(String str) => ApplistModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory ApplistModel.fromJson(Map<String, dynamic> json) => ApplistModel(
        zooq: json["zooq"] != null ? List<ToolsBrain>.from(json["zooq"].map((x) => ToolsBrain.fromJson(x))) : [],
        toolsBrain: json["tools_brain"] != null ? List<ToolsBrain>.from(json["tools_brain"].map((x) => ToolsBrain.fromJson(x))) : [],
    );

    Map<String, dynamic> toJson() => {
        "zooq": List<dynamic>.from(zooq.map((x) => x.toJson())),
        "tools_brain": List<dynamic>.from(toolsBrain.map((x) => x.toJson())),
    };
}

class ToolsBrain {
    final String id;
    final String appName;
    final int appNumber;
    final Logo logo;
    final List<Logo> screenshot;
    final AndroidCompanyName androidCompanyName;
    final String androidUrl;
    final IosCompanyName iosCompanyName;
    final String iosUrl;
    final String rating;
    final bool isShown;
    final DateTime createdAt;
    final DateTime updatedAt;

    ToolsBrain({
        required this.id,
        required this.appName,
        required this.appNumber,
        required this.logo,
        required this.screenshot,
        required this.androidCompanyName,
        required this.androidUrl,
        required this.iosCompanyName,
        required this.iosUrl,
        required this.rating,
        required this.isShown,
        required this.createdAt,
        required this.updatedAt,
    });

    ToolsBrain copyWith({
        String? id,
        String? appName,
        int? appNumber,
        Logo? logo,
        List<Logo>? screenshot,
        AndroidCompanyName? androidCompanyName,
        String? androidUrl,
        IosCompanyName? iosCompanyName,
        String? iosUrl,
        String? rating,
        bool? isShown,
        DateTime? createdAt,
        DateTime? updatedAt,
    }) => 
        ToolsBrain(
            id: id ?? this.id,
            appName: appName ?? this.appName,
            appNumber: appNumber ?? this.appNumber,
            logo: logo ?? this.logo,
            screenshot: screenshot ?? this.screenshot,
            androidCompanyName: androidCompanyName ?? this.androidCompanyName,
            androidUrl: androidUrl ?? this.androidUrl,
            iosCompanyName: iosCompanyName ?? this.iosCompanyName,
            iosUrl: iosUrl ?? this.iosUrl,
            rating: rating ?? this.rating,
            isShown: isShown ?? this.isShown,
            createdAt: createdAt ?? this.createdAt,
            updatedAt: updatedAt ?? this.updatedAt,
        );

    factory ToolsBrain.fromRawJson(String str) => ToolsBrain.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory ToolsBrain.fromJson(Map<String, dynamic> json) => ToolsBrain(
        id: json["_id"] ?? "",
        appName: json["appName"] ?? "",
        appNumber: json["appNumber"] ?? 0,
        logo: json["logo"] != null ? Logo.fromJson(json["logo"]) : Logo.empty(),
        screenshot: json["screenshot"] != null ? List<Logo>.from(json["screenshot"].map((x) => Logo.fromJson(x))) : [],
        androidCompanyName: json["androidCompanyName"] != null ? androidCompanyNameValues.map[json["androidCompanyName"]] ?? AndroidCompanyName.ZOOQ_APP : AndroidCompanyName.ZOOQ_APP,
        androidUrl: json["androidURL"] ?? "",
        iosCompanyName: json["iosCompanyName"] != null ? iosCompanyNameValues.map[json["iosCompanyName"]] ?? IosCompanyName.EMPTY : IosCompanyName.EMPTY,
        iosUrl: json["iosURL"] ?? "",
        rating: json["rating"] ?? "",
        isShown: json["isShown"] ?? false,
        createdAt: json["createdAt"] != null ? DateTime.parse(json["createdAt"]) : DateTime.now(),
        updatedAt: json["updatedAt"] != null ? DateTime.parse(json["updatedAt"]) : DateTime.now(),
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "appName": appName,
        "appNumber": appNumber,
        "logo": logo.toJson(),
        "screenshot": List<dynamic>.from(screenshot.map((x) => x.toJson())),
        "androidCompanyName": androidCompanyNameValues.reverse[androidCompanyName],
        "androidURL": androidUrl,
        "iosCompanyName": iosCompanyNameValues.reverse[iosCompanyName],
        "iosURL": iosUrl,
        "rating": rating,
        "isShown": isShown,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
    };
}

enum AndroidCompanyName {
    GENERATIVE_AI,
    GENXI_IO,
    ZOOQ_APP
}

final androidCompanyNameValues = EnumValues({
    "Generative AI": AndroidCompanyName.GENERATIVE_AI,
    "genxi.io": AndroidCompanyName.GENXI_IO,
    "zooq.app": AndroidCompanyName.ZOOQ_APP
});

enum IosCompanyName {
    EMPTY,
    PAR_SOLUTION
}

final iosCompanyNameValues = EnumValues({
    "": IosCompanyName.EMPTY,
    "Par Solution": IosCompanyName.PAR_SOLUTION
});

class Logo {
    final String id;
    final String description;
    final String title;
    final String imageUrl;
    final String thumbnail;
    final UserId userId;
    final DateTime createdAt;
    final DateTime updatedAt;
    final int v;

    Logo({
        required this.id,
        required this.description,
        required this.title,
        required this.imageUrl,
        required this.thumbnail,
        required this.userId,
        required this.createdAt,
        required this.updatedAt,
        required this.v,
    });

    // Factory constructor for empty Logo
    factory Logo.empty() => Logo(
        id: "",
        description: "",
        title: "",
        imageUrl: "",
        thumbnail: "",
        userId: UserId.THE_6535_F80_D40_C98514658994_BF,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        v: 0,
    );

    Logo copyWith({
        String? id,
        String? description,
        String? title,
        String? imageUrl,
        String? thumbnail,
        UserId? userId,
        DateTime? createdAt,
        DateTime? updatedAt,
        int? v,
    }) => 
        Logo(
            id: id ?? this.id,
            description: description ?? this.description,
            title: title ?? this.title,
            imageUrl: imageUrl ?? this.imageUrl,
            thumbnail: thumbnail ?? this.thumbnail,
            userId: userId ?? this.userId,
            createdAt: createdAt ?? this.createdAt,
            updatedAt: updatedAt ?? this.updatedAt,
            v: v ?? this.v,
        );

    factory Logo.fromRawJson(String str) => Logo.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Logo.fromJson(Map<String, dynamic> json) => Logo(
        id: json["_id"] ?? "",
        description: json["description"] ?? "",
        title: json["title"] ?? "",
        imageUrl: json["imageURL"] ?? "",
        thumbnail: json["thumbnail"] ?? "",
        userId: json["userId"] != null ? userIdValues.map[json["userId"]] ?? UserId.THE_6535_F80_D40_C98514658994_BF : UserId.THE_6535_F80_D40_C98514658994_BF,
        createdAt: json["createdAt"] != null ? DateTime.parse(json["createdAt"]) : DateTime.now(),
        updatedAt: json["updatedAt"] != null ? DateTime.parse(json["updatedAt"]) : DateTime.now(),
        v: json["__v"] ?? 0,
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "description": description,
        "title": title,
        "imageURL": imageUrl,
        "thumbnail": thumbnail,
        "userId": userIdValues.reverse[userId],
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "__v": v,
    };
}

enum UserId {
    THE_6535_F80_D40_C98514658994_BF
}

final userIdValues = EnumValues({
    "6535f80d40c98514658994bf": UserId.THE_6535_F80_D40_C98514658994_BF
});

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
            reverseMap = map.map((k, v) => MapEntry(v, k));
            return reverseMap;
    }
}
