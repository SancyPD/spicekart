import 'dart:convert';

WeeklyDeals weeklyDealsFromJson(String str) => WeeklyDeals.fromJson(json.decode(str));

String weeklyDealsToJson(WeeklyDeals data) => json.encode(data.toJson());

class WeeklyDeals {
  int status;
  List<Datum> data;
  String message;

  WeeklyDeals({
    required this.status,
    required this.data,
    required this.message,
  });

  factory WeeklyDeals.fromJson(Map<String, dynamic> json) => WeeklyDeals(
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
  int dealId;
  int productId;
  WeekDeals weekDeals;
  Products products;

  Datum({
    required this.id,
    required this.dealId,
    required this.productId,
    required this.weekDeals,
    required this.products,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    dealId: json["deal_id"],
    productId: json["product_id"],
    weekDeals: WeekDeals.fromJson(json["week_deals"]),
    products: Products.fromJson(json["products"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "deal_id": dealId,
    "product_id": productId,
    "week_deals": weekDeals.toJson(),
    "products": products.toJson(),
  };
}

class Products {
  int id;
  String slug;
  String productName;
  String productDescription;
  int categoryId;
  int brandId;
  dynamic productImage;
  dynamic metaTitle;
  dynamic metaDescription;
  dynamic metaKeywords;
  String productStatus;
  List<Variant> variants;
  List<RegionElement> regions;
  List<Rating> ratings;

  Products({
    required this.id,
    required this.slug,
    required this.productName,
    required this.productDescription,
    required this.categoryId,
    required this.brandId,
    required this.productImage,
    required this.metaTitle,
    required this.metaDescription,
    required this.metaKeywords,
    required this.productStatus,
    required this.variants,
    required this.regions,
    required this.ratings,
  });

  factory Products.fromJson(Map<String, dynamic> json) => Products(
    id: json["id"],
    slug: json["slug"],
    productName: json["product_name"],
    productDescription: json["product_description"],
    categoryId: json["category_id"],
    brandId: json["brand_id"],
    productImage: json["product_image"],
    metaTitle: json["meta_title"],
    metaDescription: json["meta_description"],
    metaKeywords: json["meta_keywords"],
    productStatus: json["product_status"],
    variants: List<Variant>.from(json["variants"].map((x) => Variant.fromJson(x))),
    regions: List<RegionElement>.from(json["regions"].map((x) => RegionElement.fromJson(x))),
    ratings: List<Rating>.from(json["ratings"].map((x) => Rating.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "slug": slug,
    "product_name": productName,
    "product_description": productDescription,
    "category_id": categoryId,
    "brand_id": brandId,
    "product_image": productImage,
    "meta_title": metaTitle,
    "meta_description": metaDescription,
    "meta_keywords": metaKeywords,
    "product_status": productStatus,
    "variants": List<dynamic>.from(variants.map((x) => x.toJson())),
    "regions": List<dynamic>.from(regions.map((x) => x.toJson())),
    "ratings": List<dynamic>.from(ratings.map((x) => x.toJson())),
  };
}

class Rating {
  int ratingId;
  String user;

  int rating;
  String reviewText;

  Rating({
    required this.ratingId,
    required this.user,
    required this.rating,
    required this.reviewText,
  });

  factory Rating.fromJson(Map<String, dynamic> json) => Rating(
    ratingId: json["rating_id"],
    user: json["user"],
    rating: json["rating"],
    reviewText: json["review_text"],
  );

  Map<String, dynamic> toJson() => {
    "rating_id": ratingId,
    "user": user,
    "rating": rating,
    "review_text": reviewText,
  };
}

class RegionElement {
  int id;
  int productId;
  int regionId;
  RegionRegion region;

  RegionElement({
    required this.id,
    required this.productId,
    required this.regionId,
    required this.region,
  });

  factory RegionElement.fromJson(Map<String, dynamic> json) => RegionElement(
    id: json["id"],
    productId: json["product_id"],
    regionId: json["region_id"],
    region: RegionRegion.fromJson(json["region"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "product_id": productId,
    "region_id": regionId,
    "region": region.toJson(),
  };
}

class RegionRegion {
  int id;
  String title;
  dynamic regionImage;
  int isActive;

  RegionRegion({
    required this.id,
    required this.title,
    required this.regionImage,
    required this.isActive,
  });

  factory RegionRegion.fromJson(Map<String, dynamic> json) => RegionRegion(
    id: json["id"],
    title: json["title"],
    regionImage: json["region_image"],
    isActive: json["is_active"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "region_image": regionImage,
    "is_active": isActive,
  };
}

class WeekDeals {
  int id;
  String title;
  DateTime startAt;
  dynamic endAt;
  int isActive;

  WeekDeals({
    required this.id,
    required this.title,
    required this.startAt,
    required this.endAt,
    required this.isActive,
  });

  factory WeekDeals.fromJson(Map<String, dynamic> json) => WeekDeals(
    id: json["id"],
    title: json["title"],
    startAt: DateTime.parse(json["start_at"]),
    endAt: json["end_at"],
    isActive: json["is_active"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "start_at": startAt.toIso8601String(),
    "end_at": endAt,
    "is_active": isActive,
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
    id: json["id"],
    productId: json["product_id"],
    varientSize: json["varient_size"],
    productPrice: json["product_price"],
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