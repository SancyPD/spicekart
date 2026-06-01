
import 'dart:convert';
import '../utils/string_extensions.dart';

ProductsListResponse productsListResponseFromJson(String str) => ProductsListResponse.fromJson(json.decode(str));

String productsListResponseToJson(ProductsListResponse data) => json.encode(data.toJson());

class ProductsListResponse {
  int status;
  List<Datum> data;
  Meta? meta;
  String message;

  ProductsListResponse({
    required this.status,
    required this.data,
    this.meta,
    required this.message,
  });

  factory ProductsListResponse.fromJson(Map<String, dynamic> json) => ProductsListResponse(
    status: json["status"] ?? 0,
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    meta: json["meta"] != null ? Meta.fromJson(json["meta"]) : null,
    message: json["message"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "meta": meta?.toJson(),
    "message": message,
  };
}

class Meta {
  int currentPage;
  int perPage;
  int total;
  int lastPage;

  Meta({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
    currentPage: json["current_page"] ?? 1,
    perPage: json["per_page"] ?? 20,
    total: json["total"] ?? 0,
    lastPage: json["last_page"] ?? 1,
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "per_page": perPage,
    "total": total,
    "last_page": lastPage,
  };
}

class Datum {
  int id;
  String slug;
  String productName;
  String productDescription;
  String productBarcode;
  int categoryId;
  String categoryName;
  int brandId;
  String brandName;
  String productImage;
  dynamic metaTitle;
  dynamic metaDescription;
  dynamic metaKeywords;
  String productTax;
  String productStatus;
  List<Variant> variants;
  List<RegionElement> regions;
  List<Rating> ratings;

  Datum({
    required this.id,
    required this.slug,
    required this.productName,
    required this.productDescription,
    required this.productBarcode,
    required this.categoryId,
    required this.categoryName,
    required this.brandId,
    required this.brandName,
    required this.productImage,
    required this.metaTitle,
    required this.metaDescription,
    required this.metaKeywords,
    required this.productTax,
    required this.productStatus,
    required this.variants,
    required this.regions,
    required this.ratings,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"] ?? 0,
    slug: json["slug"] ?? "",
    productName: json["product_name"] as String? ?? "",
    productDescription: json["product_description"]??"",
    productBarcode: json["product_barcode"]??"",
    categoryId: json["category_id"] ?? 0,
    categoryName: json["category_name"] ?? "",
    brandId: json["brand_id"] ?? 0,
    brandName: (json["brand_name"] as String? ?? "").toSentenceCase(),
    productImage: json["product_image"]??"",
    metaTitle: json["meta_title"],
    metaDescription: json["meta_description"],
    metaKeywords: json["meta_keywords"],
    productTax: json["product_tax"] ?? "",
    productStatus: json["product_status"] ?? "",
    variants: List<Variant>.from(json["variants"].map((x) => Variant.fromJson(x))),
    regions: List<RegionElement>.from(json["regions"].map((x) => RegionElement.fromJson(x))),
    ratings: List<Rating>.from(json["ratings"].map((x) => Rating.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "slug": slug,
    "product_name": productName,
    "product_description": productDescription,
    "product_barcode": productBarcode,
    "category_id": categoryId,
    "category_name": categoryName,
    "brand_id": brandId,
    "brand_name": brandName,
    "product_image": productImage,
    "meta_title": metaTitle,
    "meta_description": metaDescription,
    "meta_keywords": metaKeywords,
    "product_tax": productTax,
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
    ratingId: json["rating_id"] ?? 0,
    user: json["user"]??"",
    rating: json["rating"] ?? 0,
    reviewText: json["review_text"] ?? "",
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
    id: json["id"] ?? 0,
    productId: json["product_id"] ?? 0,
    regionId: json["region_id"] ?? 0,
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
  String regionImage;
  int isActive;

  RegionRegion({
    required this.id,
    required this.title,
    required this.regionImage,
    required this.isActive,
  });

  factory RegionRegion.fromJson(Map<String, dynamic> json) => RegionRegion(
    id: json["id"] ?? 0,
    title: json["title"] ?? "",
    regionImage: json["region_image"] ?? "",
    isActive: json["is_active"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "region_image": regionImage,
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