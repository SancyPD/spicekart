import 'dart:convert';
import '../utils/string_extensions.dart';

Brands brandsFromJson(String str) => Brands.fromJson(json.decode(str));

String brandsToJson(Brands data) => json.encode(data.toJson());

class Brands {
  int status;
  List<Datum> data;
  String message;

  Brands({
    required this.status,
    required this.data,
    required this.message,
  });

  factory Brands.fromJson(Map<String, dynamic> json) => Brands(
    status: json["status"] ?? 0,
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    message: json["message"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "message": message,
  };
}

class Datum {
  int id;
  String brandName;
  String brandImage;
  int isActive;

  Datum({
    required this.id,
    required this.brandName,
    required this.brandImage,
    required this.isActive,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"] ?? 0,
    brandName: (json["brand_name"] as String? ?? "").toSentenceCase(),
    brandImage: json["brand_image"]??"",
    isActive: json["is_active"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "brand_name": brandName,
    "brand_image": brandImage,
    "is_active": isActive,
  };
}
