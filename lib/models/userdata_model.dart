import 'dart:convert';

class User {
    final String id;
    final String firstName;
    final String lastName;
    final String firebaseUserId;
    final bool isGoogleLogin;
    final bool isAppleLogin;
    final dynamic profileImage;
    final List<dynamic> favoriteImage;
    final List<Library> UserLibrary;
    final List<dynamic> downloadedImage;
    final List<String> fcmToken;
    final String userType;
    final DateTime createdAt;
    final DateTime updatedAt;
    final String deviceId;
    final bool isRegistered;
    final String email;
    final bool darkMode;
    final bool isGuestLogin;
    final bool feedBackGiven;
    final bool isProUser;
    final bool isBlocked;
    final bool isTransferred;
    final bool isCreditEligible;
    final String expireTime;
    final bool autoRenew;

    User({
        required this.id,
        required this.firstName,
        required this.lastName,
        required this.firebaseUserId,
        required this.isGoogleLogin,
        required this.isAppleLogin,
        required this.profileImage,
        required this.favoriteImage,
        required this.UserLibrary,
        required this.downloadedImage,
        required this.fcmToken,
        required this.userType,
        required this.createdAt,
        required this.updatedAt,
        required this.deviceId,
        required this.isRegistered,
        required this.email,
        required this.darkMode,
        required this.isGuestLogin,
        required this.feedBackGiven,
        required this.isProUser,
        required this.isBlocked,
        required this.isTransferred,
        required this.isCreditEligible,
        required this.expireTime,
        required this.autoRenew,
    });

    /// Check if the user's subscription has expired
    bool get isSubscriptionExpired {
        if (!isProUser || expireTime.isEmpty) return true;
        
        try {
            DateTime expiredAt;
            
            // Handle GMT format: "Fri Dec 19 2025 09:48:04 GMT+0000"
            if (expireTime.contains('GMT')) {
                // Split the string and extract components
                final parts = expireTime.split(' ');
                if (parts.length >= 5) {
                    // parts = ["Fri", "Dec", "19", "2025", "09:48:04", "GMT+0000"]
                    final monthName = parts[1]; // Dec
                    final day = int.parse(parts[2]); // 19
                    final year = int.parse(parts[3]); // 2025
                    final timePart = parts[4]; // 09:48:04
                    
                    // Convert month name to number
                    final months = {
                        'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4,
                        'May': 5, 'Jun': 6, 'Jul': 7, 'Aug': 8,
                        'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
                    };
                    
                    final month = months[monthName];
                    if (month != null) {
                        // Parse time components
                        final timeComponents = timePart.split(':');
                        if (timeComponents.length >= 3) {
                            final hour = int.parse(timeComponents[0]);
                            final minute = int.parse(timeComponents[1]);
                            final second = int.parse(timeComponents[2]);
                            
                            // Create DateTime in UTC
                            expiredAt = DateTime.utc(year, month, day, hour, minute, second);
                        } else {
                            throw FormatException('Invalid time format: $timePart');
                        }
                    } else {
                        throw FormatException('Unknown month: $monthName');
                    }
                } else {
                    throw FormatException('Unexpected date format: $expireTime');
                }
            } else {
                // Try direct parsing for ISO format
                expiredAt = DateTime.parse(expireTime);
            }
            
            final now = DateTime.now().toUtc(); // Compare in UTC
            final isExpired = now.isAfter(expiredAt);
            
            print('🔍 DEBUG Date Parsing:');
            print('   Original expireTime: $expireTime');
            print('   Parsed expiredAt: $expiredAt');
            print('   Current time (UTC): $now');
            print('   Is expired: $isExpired');
            
            return isExpired;
        } catch (e) {
            print('❌ DEBUG Date parsing error: $e');
            print('   Original expireTime: $expireTime');
            return true; // If we can't parse the date, consider it expired
        }
    }

    /// Check if the user has an active subscription
    bool get hasActiveSubscription {
        return isProUser && !isSubscriptionExpired;
    }

    User copyWith({
        String? id,
        String? firstName,
        String? lastName,
        String? firebaseUserId,
        bool? isGoogleLogin,
        bool? isAppleLogin,
        dynamic profileImage,
        List<dynamic>? favoriteImage,
        List<Library>? UserLibrary,
        List<dynamic>? downloadedImage,
        List<String>? fcmToken,
        String? userType,
        DateTime? createdAt,
        DateTime? updatedAt,
        String? deviceId,
        bool? isRegistered,
        String? email,
        bool? darkMode,
        bool? isGuestLogin,
        bool? feedBackGiven,
        bool? isProUser,
        bool? isTransferred,
        bool? isCreditEligible,
        bool? isBlocked,
        String? expireTime,
        bool? autoRenew,
    }) => 
        User(
            id: id ?? this.id,
            firstName: firstName ?? this.firstName,
            lastName: lastName ?? this.lastName,
            firebaseUserId: firebaseUserId ?? this.firebaseUserId,
            isGoogleLogin: isGoogleLogin ?? this.isGoogleLogin,
            isAppleLogin: isAppleLogin ?? this.isAppleLogin,
            profileImage: profileImage ?? this.profileImage,
            favoriteImage: favoriteImage ?? this.favoriteImage,
            UserLibrary: UserLibrary ?? this.UserLibrary,
            downloadedImage: downloadedImage ?? this.downloadedImage,
            fcmToken: fcmToken ?? this.fcmToken,
            userType: userType ?? this.userType,
            createdAt: createdAt ?? this.createdAt,
            updatedAt: updatedAt ?? this.updatedAt,
            deviceId: deviceId ?? this.deviceId,
            isRegistered: isRegistered ?? this.isRegistered,
            email: email ?? this.email,
            darkMode: darkMode ?? this.darkMode,
            isGuestLogin: isGuestLogin ?? this.isGuestLogin,
            feedBackGiven: feedBackGiven ?? this.feedBackGiven,
            isProUser: isProUser ?? this.isProUser,
            isTransferred: isTransferred ?? this.isTransferred,
            isCreditEligible: isCreditEligible ?? this.isCreditEligible,
            isBlocked: isBlocked ?? this.isBlocked,
            expireTime: expireTime ?? this.expireTime,
            autoRenew: autoRenew ?? this.autoRenew,
        );

    factory User.fromRawJson(String str) => User.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["_id"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        firebaseUserId: json["firebaseUserId"],
        isGoogleLogin: json["isGoogleLogin"],
        isAppleLogin: json["isAppleLogin"],
        profileImage: json["profileImage"],
        favoriteImage: List<dynamic>.from(json["favoriteImage"].map((x) => x)),
        UserLibrary: List<Library>.from(json["library"].map((x) => Library.fromJson(x))),
        downloadedImage: List<dynamic>.from(json["downloadedImage"].map((x) => x)),
        fcmToken: List<String>.from(json["FCMToken"].map((x) => x)),
        userType: json["userType"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        deviceId: json["deviceId"],
        isRegistered: json["isRegistered"],
        email: json["email"],
        darkMode: json["darkMode"],
        isGuestLogin: json["isGuestLogin"],
        feedBackGiven: json["feedBackGiven"],
        isProUser: json["isProUser"],
        isTransferred: json["isTransferred"] ,
        isCreditEligible: json["isCreditEligible"],
        isBlocked: json["isBlocked"],
        expireTime: json["expireTime"],
        autoRenew: json["autoRenew"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "firstName": firstName,
        "lastName": lastName,
        "firebaseUserId": firebaseUserId,
        "isGoogleLogin": isGoogleLogin,
        "isAppleLogin": isAppleLogin,
        "profileImage": profileImage,
        "favoriteImage": List<dynamic>.from(favoriteImage.map((x) => x)),
        "library": List<dynamic>.from(UserLibrary.map((x) => x.toJson())),
        "downloadedImage": List<dynamic>.from(downloadedImage.map((x) => x)),
        "FCMToken": List<dynamic>.from(fcmToken.map((x) => x)),
        "userType": userType,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "deviceId": deviceId,
        "isRegistered": isRegistered,
        "email": email,
        "darkMode": darkMode,
        "isGuestLogin": isGuestLogin,
        "feedBackGiven": feedBackGiven,
        "isProUser": isProUser,
        "isTransferred": isTransferred,
        "isCreditEligible": isCreditEligible,
        "isBlocked": isBlocked,
        "expireTime": expireTime,
        "autoRenew": autoRenew,
    };
}

class Library {
    final String id;
    final String name;
    final List<SavedImage> savedImage;
    final String userId;
    final DateTime createdAt;
    final DateTime updatedAt;
    final int v;

    Library({
        required this.id,
        required this.name,
        required this.savedImage,
        required this.userId,
        required this.createdAt,
        required this.updatedAt,
        required this.v,
    });

    Library copyWith({
        String? id,
        String? name,
        List<SavedImage>? savedImage,
        String? userId,
        DateTime? createdAt,
        DateTime? updatedAt,
        int? v,
    }) => 
        Library(
            id: id ?? this.id,
            name: name ?? this.name,
            savedImage: savedImage ?? this.savedImage,
            userId: userId ?? this.userId,
            createdAt: createdAt ?? this.createdAt,
            updatedAt: updatedAt ?? this.updatedAt,
            v: v ?? this.v,
        );

    factory Library.fromRawJson(String str) => Library.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Library.fromJson(Map<String, dynamic> json) => Library(
        id: json["_id"],
        name: json["name"],
        savedImage: List<SavedImage>.from(json["savedImage"].map((x) => SavedImage.fromJson(x))),
        userId: json["userId"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        v: json["__v"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "savedImage": List<dynamic>.from(savedImage.map((x) => x.toJson())),
        "userId": userId,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "__v": v,
    };
}

class SavedImage {
    final Url url;
    final ImageOwner imageOwner;
    final String savedImageId;
    final String id;

    SavedImage({
        required this.url,
        required this.imageOwner,
        required this.savedImageId,
        required this.id,
    });

    SavedImage copyWith({
        Url? url,
        ImageOwner? imageOwner,
        String? savedImageId,
        String? id,
    }) => 
        SavedImage(
            url: url ?? this.url,
            imageOwner: imageOwner ?? this.imageOwner,
            savedImageId: savedImageId ?? this.savedImageId,
            id: id ?? this.id,
        );

    factory SavedImage.fromRawJson(String str) => SavedImage.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory SavedImage.fromJson(Map<String, dynamic> json) => SavedImage(
        url: Url.fromJson(json["url"]),
        imageOwner: ImageOwner.fromJson(json["imageOwner"]),
        savedImageId: json["id"],
        id: json["_id"],
    );

    Map<String, dynamic> toJson() => {
        "url": url.toJson(),
        "imageOwner": imageOwner.toJson(),
        "id": savedImageId,
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
