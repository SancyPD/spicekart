import 'dart:convert';

SavedItemsResponseFood savedItemsResponseFoodFromJson(String str) => SavedItemsResponseFood.fromJson(json.decode(str));

String savedItemsResponseFoodToJson(SavedItemsResponseFood data) => json.encode(data.toJson());

class SavedItemsResponseFood {
  int status;
  String message;
  List<Datum> data;

  SavedItemsResponseFood({
    required this.status,
    required this.message,
    required this.data,
  });

  factory SavedItemsResponseFood.fromJson(Map<String, dynamic> json) => SavedItemsResponseFood(
    status: json["status"] ?? 0,
    message: json["message"] ?? "",
    data: json["data"] != null 
        ? List<Datum>.from(json["data"].map((x) => Datum.fromJson(x)))
        : [],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  int id;
  int quantity;
  int isSavedForLater;
  String itemType;
  Item item;
  dynamic variant;

  Datum({
    required this.id,
    required this.quantity,
    required this.isSavedForLater,
    required this.itemType,
    required this.item,
    required this.variant,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"] ?? 0,
    quantity: json["quantity"] ?? 0,
    isSavedForLater: json["is_saved_for_later"] ?? 0,
    itemType: json["item_type"] ?? "",
    item: Item.fromJson(json["item"] ?? {}),
    variant: json["variant"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "quantity": quantity,
    "is_saved_for_later": isSavedForLater,
    "item_type": itemType,
    "item": item.toJson(),
    "variant": variant,
  };
}

class Item {
  int id;
  String name;
  String description;
  String image;
  String price;
  bool isAvailable;
  FoodCategory foodCategory;
  Restaurant restaurant;

  Item({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.price,
    required this.isAvailable,
    required this.foodCategory,
    required this.restaurant,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json["id"] ?? 0,
    name: json["name"] ?? "",
    description: json["description"] ?? "",
    image: json["image"] ?? "",
    price: json["price"] ?? "",
    isAvailable: json["is_available"] ?? true,
    foodCategory: FoodCategory.fromJson(json["food_category"] ?? {}),
    restaurant: Restaurant.fromJson(json["restaurant"] ?? {}),
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

  FoodCategory({
    required this.id,
    required this.name,
    required this.isActive,
  });

  factory FoodCategory.fromJson(Map<String, dynamic> json) => FoodCategory(
    id: json["id"] ?? 0,
    name: json["name"] ?? "",
    isActive: json["is_active"] ?? false,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "is_active": isActive,
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
    name: json["name"] ?? "",
    description: json["description"],
    image: json["image"] ?? "",
    address: json["address"] ?? "",
    isActive: json["is_active"] ?? false,
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