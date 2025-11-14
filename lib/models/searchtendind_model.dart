import 'dart:convert';

class TrengingSearchModel {
    final String text;
    final String thumbnail;

    TrengingSearchModel({
        required this.text,
        required this.thumbnail,
    });

    TrengingSearchModel copyWith({
        String? text,
        String? thumbnail,
    }) => 
        TrengingSearchModel(
            text: text ?? this.text,
            thumbnail: thumbnail ?? this.thumbnail,
        );

    factory TrengingSearchModel.fromRawJson(String str) => TrengingSearchModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory TrengingSearchModel.fromJson(Map<String, dynamic> json) => TrengingSearchModel(
        text: json["text"],
        thumbnail: json["thumbnail"],
    );

    Map<String, dynamic> toJson() => {
        "text": text,
        "thumbnail": thumbnail,
    };
}
