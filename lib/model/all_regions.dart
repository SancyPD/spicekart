import 'dart:convert';

AllRegions allRegionsFromJson(String str) => AllRegions.fromJson(json.decode(str));

String allRegionsToJson(AllRegions data) => json.encode(data.toJson());

class AllRegions {
  int status;
  List<Region> data;
  String message;

  AllRegions({
    required this.status,
    required this.data,
    required this.message,
  });

  factory AllRegions.fromJson(Map<String, dynamic> json) => AllRegions(
    status: json["status"] ?? 0,
    data: List<Region>.from(json["data"].map((x) => Region.fromJson(x))),
    message: json["message"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "message": message,
  };
}

class Region {
  int id;
  String title;
  dynamic regionImage;
  int isActive;

  Region({
    required this.id,
    required this.title,
    required this.regionImage,
    required this.isActive,
  });

  factory Region.fromJson(Map<String, dynamic> json) => Region(
    id: json["id"] ?? 0,
    title: json["title"] ?? "",
    regionImage: json["region_image"],
    isActive: json["is_active"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "region_image": regionImage,
    "is_active": isActive,
  };
}