import 'dart:convert';

BannersResponse bannersResponseFromJson(String str) => BannersResponse.fromJson(json.decode(str));

String bannersResponseToJson(BannersResponse data) => json.encode(data.toJson());

class BannersResponse {
  int status;
  List<Datum> data;
  String message;

  BannersResponse({
    required this.status,
    required this.data,
    required this.message,
  });

  factory BannersResponse.fromJson(Map<String, dynamic> json) => BannersResponse(
    status: json["status"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "message": message,
  };
}

class Datum {
  int id;
  String title;
  String bannerImageWeb;
  String bannerImageApp;
  DateTime startAt;
  DateTime endAt;
  int isActive;

  Datum({
    required this.id,
    required this.title,
    required this.bannerImageWeb,
    required this.bannerImageApp,
    required this.startAt,
    required this.endAt,
    required this.isActive,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    title: json["title"],
    bannerImageWeb: json["banner_image_web"],
    bannerImageApp: json["banner_image_app"],
    startAt: DateTime.parse(json["start_at"]),
    endAt: DateTime.parse(json["end_at"]),
    isActive: json["is_active"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "banner_image_web": bannerImageWeb,
    "banner_image_app": bannerImageApp,
    "start_at": startAt.toIso8601String(),
    "end_at": endAt.toIso8601String(),
    "is_active": isActive,
  };
}