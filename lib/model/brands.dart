import 'dart:convert';

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
    id: json["id"],
    brandName: json["brand_name"],
    brandImage: json["brand_image"]??"",
    isActive: json["is_active"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "brand_name": brandName,
    "brand_image": brandImage,
    "is_active": isActive,
  };
}
