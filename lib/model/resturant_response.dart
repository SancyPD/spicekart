import 'dart:convert';

RestaurantsResponse restaurantsResponseFromJson(String str) => RestaurantsResponse.fromJson(json.decode(str));

String restaurantsResponseToJson(RestaurantsResponse data) => json.encode(data.toJson());

class RestaurantsResponse {
  int status;
  String message;
  List<Datum> data;

  RestaurantsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory RestaurantsResponse.fromJson(Map<String, dynamic> json) => RestaurantsResponse(
    status: json["status"] ?? 0,
    message: json["message"] ?? "",
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  int id;
  String name;
  dynamic description;
  String image;
  String address;
  bool isActive;

  Datum({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.address,
    required this.isActive,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"] ?? 0,
    name: json["name"] ?? "",
    description: json["description"],
    image: json["image"] ?? "",
    address: json["address"] ?? "",
    isActive: json["is_active"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "image": image,
    "address": address,
    "is_active": isActive,
  };
}