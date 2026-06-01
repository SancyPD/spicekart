import 'dart:convert';
import '../utils/string_extensions.dart';

SearchResponse searchResponseFromJson(String str) => SearchResponse.fromJson(json.decode(str));

String searchResponseToJson(SearchResponse data) => json.encode(data.toJson());

class SearchResponse {
  int status;
  List<Datum> data;
  Meta? meta;
  String message;

  SearchResponse({
    required this.status,
    required this.data,
    this.meta,
    required this.message,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) => SearchResponse(
    status: json["status"] ?? 0,
    data: json["data"] != null 
        ? List<Datum>.from(json["data"].map((x) => Datum.fromJson(x)))
        : [],
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

class Datum {
  int id;
  String slug;
  String productName;
  String productDescription;
  String productBarcode;
  int averageRating;
  int totalRatings;
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
  bool isFavourite;

  Datum({
    required this.id,
    required this.slug,
    required this.productName,
    required this.productDescription,
    required this.productBarcode,
    required this.averageRating,
    required this.totalRatings,
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
    required this.isFavourite,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"] ?? 0,
    slug: json["slug"] ?? "",
    productName: json["product_name"] ?? "",
    productDescription: json["product_description"] ?? "",
    productBarcode: json["product_barcode"] ?? "",
    averageRating: json["average_rating"] ?? 0,
    totalRatings: json["total_ratings"] ?? 0,
    categoryId: json["category_id"] ?? 0,
    categoryName: json["category_name"] ?? "",
    brandId: json["brand_id"] ?? 0,
    brandName: (json["brand_name"] as String? ?? "").toSentenceCase(),
    productImage: json["product_image"] ?? "",
    metaTitle: json["meta_title"] ?? "",
    metaDescription: json["meta_description"] ?? "",
    metaKeywords: json["meta_keywords"] ?? "",
    productTax: json["product_tax"] ?? "",
    productStatus: json["product_status"] ?? "",
    variants: json["variants"] != null 
        ? List<Variant>.from(json["variants"].map((x) => Variant.fromJson(x)))
        : [],
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
    "is_favourite": isFavourite,
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
    storePrice: json["store_price"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "product_id": productId,
    "varient_size": varientSize,
    "product_price": productPrice,
    "store_price": storePrice,
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