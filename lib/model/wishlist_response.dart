import 'dart:convert';
import 'package:spicekart/utils/string_extensions.dart';

FavouritesListResponse favouritesListResponseFromJson(String str) => FavouritesListResponse.fromJson(json.decode(str));

String favouritesListResponseToJson(FavouritesListResponse data) => json.encode(data.toJson());

class FavouritesListResponse {
  int status;
  String message;
  List<Datum> data;
  Meta? meta;

  FavouritesListResponse({
    required this.status,
    required this.message,
    required this.data,
    this.meta,
  });

  factory FavouritesListResponse.fromJson(Map<String, dynamic> json) => FavouritesListResponse(
    status: json["status"] ?? 0,
    message: json["message"] ?? "",
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    meta: json["meta"] != null ? Meta.fromJson(json["meta"]) : null,
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "meta": meta?.toJson(),
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
  User user;
  Product product;

  Datum({
    required this.user,
    required this.product,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    user: User.fromJson(json["user"]),
    product: Product.fromJson(json["product"]),
  );

  Map<String, dynamic> toJson() => {
    "user": user.toJson(),
    "product": product.toJson(),
  };
}

class Product {
  int id;
  String slug;
  String productName;
  String productDescription;
  String productBarcode;
  int categoryId;
  int brandId;
  String productImage;
  dynamic metaTitle;
  dynamic metaDescription;
  dynamic metaKeywords;
  String productTax;
  String productStatus;

  Product({
    required this.id,
    required this.slug,
    required this.productName,
    required this.productDescription,
    required this.productBarcode,
    required this.categoryId,
    required this.brandId,
    required this.productImage,
    required this.metaTitle,
    required this.metaDescription,
    required this.metaKeywords,
    required this.productTax,
    required this.productStatus,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json["id"] ?? 0,
    slug: json["slug"] ?? "",
    productName: json["product_name"] as String? ?? "",
    productDescription: json["product_description"] ?? "",
    productBarcode: json["product_barcode"] ?? "",
    categoryId: json["category_id"] ?? 0,
    brandId: json["brand_id"] ?? 0,
    productImage: json["product_image"] ?? "",
    metaTitle: json["meta_title"],
    metaDescription: json["meta_description"],
    metaKeywords: json["meta_keywords"],
    productTax: json["product_tax"] ?? "",
    productStatus: json["product_status"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "slug": slug,
    "product_name": productName,
    "product_description": productDescription,
    "product_barcode": productBarcode,
    "category_id": categoryId,
    "brand_id": brandId,
    "product_image": productImage,
    "meta_title": metaTitle,
    "meta_description": metaDescription,
    "meta_keywords": metaKeywords,
    "product_tax": productTax,
    "product_status": productStatus,
  };
}

class User {
  int id;
  dynamic firstName;
  dynamic lastName;
  String email;
  dynamic phone;
  int regionId;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.regionId,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"] ?? 0,
    firstName: json["first_name"],
    lastName: json["last_name"],
    email: json["email"] ?? "",
    phone: json["phone"],
    regionId: json["region_id"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "first_name": firstName,
    "last_name": lastName,
    "email": email,
    "phone": phone,
    "region_id": regionId,
  };
}
