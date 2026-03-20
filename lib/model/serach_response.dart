import 'dart:convert';

SearchResponse searchResponseFromJson(String str) => SearchResponse.fromJson(json.decode(str));

String searchResponseToJson(SearchResponse data) => json.encode(data.toJson());

class SearchResponse {
  int status;
  List<Datum> data;
  String message;

  SearchResponse({
    required this.status,
    required this.data,
    required this.message,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) => SearchResponse(
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
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    slug: json["slug"],
    productName: json["product_name"],
    productDescription: json["product_description"]??"",
    productBarcode: json["product_barcode"]??"",
    categoryId: json["category_id"],
    categoryName: json["category_name"],
    brandId: json["brand_id"],
    brandName: json["brand_name"],
    productImage: json["product_image"],
    metaTitle: json["meta_title"],
    metaDescription: json["meta_description"],
    metaKeywords: json["meta_keywords"],
    productTax: json["product_tax"],
    productStatus: json["product_status"],
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
  };
}