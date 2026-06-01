import 'dart:convert';

ZipCodeListResponse zipCodeListResponseFromJson(String str) => ZipCodeListResponse.fromJson(json.decode(str));

String zipCodeListResponseToJson(ZipCodeListResponse data) => json.encode(data.toJson());

class ZipCodeListResponse {
  int status;
  String message;
  List<Datum> data;
  dynamic meta;

  ZipCodeListResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.meta,
  });

  factory ZipCodeListResponse.fromJson(Map<String, dynamic> json) => ZipCodeListResponse(
    status: json["status"],
    message: json["message"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    meta: json["meta"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "meta": meta,
  };
}

class Datum {
  int id;
  int zoneId;
  String cityName;
  String zipCode;
  DateTime createdAt;
  DateTime updatedAt;
  int isActive;
  Zone zone;

  Datum({
    required this.id,
    required this.zoneId,
    required this.cityName,
    required this.zipCode,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    required this.zone,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    zoneId: json["zone_id"],
    cityName: json["city_name"],
    zipCode: json["zip_code"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    isActive: json["is_active"],
    zone: Zone.fromJson(json["zone"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "zone_id": zoneId,
    "city_name": cityName,
    "zip_code": zipCode,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "is_active": isActive,
    "zone": zone.toJson(),
  };
}

class Zone {
  int id;
  String name;
  DateTime createdAt;
  DateTime updatedAt;
  int isActive;

  Zone({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  factory Zone.fromJson(Map<String, dynamic> json) => Zone(
    id: json["id"],
    name:json["name"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    isActive: json["is_active"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "is_active": isActive,
  };
}
