import 'dart:convert';

CartListProductResponse cartListProductResponseFromJson(String str) => CartListProductResponse.fromJson(json.decode(str));

String cartListProductResponseToJson(CartListProductResponse data) => json.encode(data.toJson());

class CartListProductResponse {
  int status;
  String message;
  List<Datum> data;

  CartListProductResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CartListProductResponse.fromJson(Map<String, dynamic> json) => CartListProductResponse(
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
  int quantity;
  int isSavedForLater;
  String itemType;
  Item item;
  Variant? variant;

  Datum({
    required this.id,
    required this.quantity,
    required this.isSavedForLater,
    required this.itemType,
    required this.item,
    this.variant,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"] ?? 0,
    quantity: json["quantity"] ?? 0,
    isSavedForLater: json["is_saved_for_later"] ?? 0,
    itemType: json["item_type"] ?? "",
    item: Item.fromJson(json["item"]),
    variant: json["variant"] == null ? null : Variant.fromJson(json["variant"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "quantity": quantity,
    "is_saved_for_later": isSavedForLater,
    "item_type": itemType,
    "item": item.toJson(),
    "variant": variant?.toJson(),
  };
}

class Item {
  int id;
  String slug;
  String productName;
  String productDescription;
  String productBarcode;
  int averageRating;
  int totalRatings;
  int categoryId;
  int brandId;
  String productImage;
  dynamic metaTitle;
  dynamic metaDescription;
  dynamic metaKeywords;
  String productTax;
  String productStatus;
  List<Region> regions;
  bool isFavourite;

  // Food fields
  String name;
  String description;
  String image;
  String price;
  bool isAvailable;
  FoodCategory? foodCategory;
  Restaurant? restaurant;

  Item({
    required this.id,
    required this.slug,
    required this.productName,
    required this.productDescription,
    required this.productBarcode,
    required this.averageRating,
    required this.totalRatings,
    required this.categoryId,
    required this.brandId,
    required this.productImage,
    required this.metaTitle,
    required this.metaDescription,
    required this.metaKeywords,
    required this.productTax,
    required this.productStatus,
    required this.regions,
    required this.isFavourite,
    this.name = "",
    this.description = "",
    this.image = "",
    this.price = "",
    this.isAvailable = false,
    this.foodCategory,
    this.restaurant,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json["id"] ?? 0,
    slug: json["slug"] ?? "",
    productName: json["product_name"] ?? "",
    productDescription: json["product_description"]??"",
    productBarcode: json["product_barcode"] ?? "",
    averageRating: json["average_rating"] ?? 0,
    totalRatings: json["total_ratings"] ?? 0,
    categoryId: json["category_id"] ?? 0,
    brandId: json["brand_id"] ?? 0,
    productImage: json["product_image"] ?? "",
    metaTitle: json["meta_title"],
    metaDescription: json["meta_description"],
    metaKeywords: json["meta_keywords"],
    productTax: json["product_tax"] ?? "",
    productStatus: json["product_status"] ?? "",
    regions: json["regions"] != null ? List<Region>.from(json["regions"].map((x) => Region.fromJson(x))) : [],
    isFavourite: json["is_favourite"] ?? false,
    name: json["name"] ?? "",
    description: json["description"] ?? "",
    image: json["image"] ?? "",
    price: json["price"] ?? "",
    isAvailable: json["is_available"] ?? false,
    foodCategory: json["food_category"] != null ? FoodCategory.fromJson(json["food_category"]) : null,
    restaurant: json["restaurant"] != null ? Restaurant.fromJson(json["restaurant"]) : null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "slug": slug,
    "product_name": productName,
    "product_description": productDescription,
    "product_barcode": productBarcode,
    "average_rating": averageRating,
    "total_ratings": totalRatings,
    "category_id": categoryId,
    "brand_id": brandId,
    "product_image": productImage,
    "meta_title": metaTitle,
    "meta_description": metaDescription,
    "meta_keywords": metaKeywords,
    "product_tax": productTax,
    "product_status": productStatus,
    "regions": List<dynamic>.from(regions.map((x) => x.toJson())),
    "is_favourite": isFavourite,
    "name": name,
    "description": description,
    "image": image,
    "price": price,
    "is_available": isAvailable,
    "food_category": foodCategory?.toJson(),
    "restaurant": restaurant?.toJson(),
  };
}

class Region {
  int id;
  int productId;
  int regionId;

  Region({
    required this.id,
    required this.productId,
    required this.regionId,
  });

  factory Region.fromJson(Map<String, dynamic> json) => Region(
    id: json["id"] ?? 0,
    productId: json["product_id"] ?? 0,
    regionId: json["region_id"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "product_id": productId,
    "region_id": regionId,
  };
}

class Variant {
  int id;
  int productId;
  String varientSize;
  String productPrice;
  dynamic storePrice;

  Variant({
    required this.id,
    required this.productId,
    required this.varientSize,
    required this.productPrice,
    required this.storePrice,
  });

  factory Variant.fromJson(Map<String, dynamic> json) => Variant(
    id: json["id"] ?? 0,
    productId: json["product_id"] ?? 0,
    varientSize: json["varient_size"] ?? "",
    productPrice: json["product_price"] ?? "",
    storePrice: json["store_price"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "product_id": productId,
    "varient_size": varientSize,
    "product_price": productPrice,
    "store_price": storePrice,
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