import 'dart:convert';

RestaurantMenuResponse restaurantMenuResponseFromJson(String str) => RestaurantMenuResponse.fromJson(json.decode(str));

String restaurantMenuResponseToJson(RestaurantMenuResponse data) => json.encode(data.toJson());

class RestaurantMenuResponse {
  int status;
  String message;
  List<Datum> data;

  RestaurantMenuResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory RestaurantMenuResponse.fromJson(Map<String, dynamic> json) => RestaurantMenuResponse(
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
  String description;
  String image;
  String price;
  bool isAvailable;
  FoodCategory foodCategory;
  Restaurant restaurant;

  Datum({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.price,
    required this.isAvailable,
    required this.foodCategory,
    required this.restaurant,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"] ?? 0,
    name: json["name"] ?? "",
    description: json["description"]??"",
    image: json["image"]??"",
    price: json["price"]??"",
    isAvailable: json["is_available"],
    foodCategory: FoodCategory.fromJson(json["food_category"]),
    restaurant: Restaurant.fromJson(json["restaurant"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "image": image,
    "price": price,
    "is_available": isAvailable,
    "food_category": foodCategory.toJson(),
    "restaurant": restaurant.toJson(),
  };
}

class FoodCategory {
  int id;
  String name;
  bool isActive;
  Restaurant restaurant;

  FoodCategory({
    required this.id,
    required this.name,
    required this.isActive,
    required this.restaurant,
  });

  factory FoodCategory.fromJson(Map<String, dynamic> json) => FoodCategory(
    id: json["id"] ?? 0,
    name: json["name"]??"",
    isActive: json["is_active"],
    restaurant: Restaurant.fromJson(json["restaurant"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "is_active": isActive,
    "restaurant": restaurant.toJson(),
  };
}

class Restaurant {
  int id;
  String name;
  dynamic description;
  String image;
  String address;
  bool isActive;

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.address,
    required this.isActive,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
    id: json["id"] ?? 0,
    name: json["name"]??"",
    description: json["description"]??"",
    image:json["image"]??"",
    address: json["address"]??"",
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

