import 'dart:convert';

UsualsResponse usualsResponseFromJson(String str) => UsualsResponse.fromJson(json.decode(str));

String usualsResponseToJson(UsualsResponse data) => json.encode(data.toJson());

class UsualsResponse {
  int status;
  String message;
  List<Datum> data;

  UsualsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory UsualsResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json["data"] as List<dynamic>?;
    return UsualsResponse(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      data: dataList != null
          ? dataList
              .where((x) => x != null && x["item"] != null)
              .map((x) => Datum.fromJson(x))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  int itemId;
  String itemType;
  int totalQuantity;
  int lineCount;
  Item item;

  Datum({
    required this.itemId,
    required this.itemType,
    required this.totalQuantity,
    required this.lineCount,
    required this.item,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    itemId: json["item_id"] ?? 0,
    itemType: json["item_type"] ?? "",
    totalQuantity: json["total_quantity"] ?? 0,
    lineCount: json["line_count"] ?? 0,
    item: Item.fromJson(json["item"]),
  );

  Map<String, dynamic> toJson() => {
    "item_id": itemId,
    "item_type": itemType,
    "total_quantity": totalQuantity,
    "line_count": lineCount,
    "item": item.toJson(),
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
  List<Variant> variants;
  List<Region> regions;
  List<Rating> ratings;
  List<Image> images;
  bool isFavourite;

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
    required this.variants,
    required this.regions,
    required this.ratings,
    required this.images,
    required this.isFavourite,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json["id"] ?? 0,
    slug: json["slug"] ?? "",
    productName: json["product_name"] ?? "",
    productDescription: json["product_description"] ?? "",
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
    variants: json["variants"] != null ? List<Variant>.from(json["variants"].map((x) => Variant.fromJson(x))) : [],
    regions: json["regions"] != null ? List<Region>.from(json["regions"].map((x) => Region.fromJson(x))) : [],
    ratings: json["ratings"] != null ? List<Rating>.from(json["ratings"].map((x) => Rating.fromJson(x))) : [],
    images: json["images"] != null ? List<Image>.from(json["images"].map((x) => Image.fromJson(x))) : [],
    isFavourite: json["is_favourite"] ?? false,
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
    "variants": List<dynamic>.from(variants.map((x) => x.toJson())),
    "regions": List<dynamic>.from(regions.map((x) => x.toJson())),
    "ratings": List<dynamic>.from(ratings.map((x) => x.toJson())),
    "images": List<dynamic>.from(images.map((x) => x.toJson())),
    "is_favourite": isFavourite,
  };
}

class Image {
  int id;
  String productImage;

  Image({
    required this.id,
    required this.productImage,
  });

  factory Image.fromJson(Map<String, dynamic> json) => Image(
    id: json["id"] ?? 0,
    productImage: json["product_image"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "product_image": productImage,
  };
}

class Rating {
  int ratingId;
  int rating;
  String reviewText;

  Rating({
    required this.ratingId,
    required this.rating,
    required this.reviewText,
  });

  factory Rating.fromJson(Map<String, dynamic> json) => Rating(
    ratingId: json["rating_id"] ?? 0,
    rating: json["rating"] ?? 0,
    reviewText: json["review_text"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "rating_id": ratingId,
    "rating": rating,
    "review_text": reviewText,
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
