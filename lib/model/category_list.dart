import 'dart:convert';

CategoryList categoryListFromJson(String str) => CategoryList.fromJson(json.decode(str));

String categoryListToJson(CategoryList data) => json.encode(data.toJson());

class CategoryList {
  int status;
  List<Category> data;
  String message;

  CategoryList({
    required this.status,
    required this.data,
    required this.message,
  });

  factory CategoryList.fromJson(Map<String, dynamic> json) => CategoryList(
    status: json["status"] ?? 0,
    data: List<Category>.from(json["data"].map((x) => Category.fromJson(x))),
    message: json["message"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "message": message,
  };
}

class Category {
  int id;
  String categoryName;
  dynamic categorySlug;
  int position;
  int isActive;
  dynamic categoryImage;
  dynamic metaTitle;
  dynamic metaDescription;
  dynamic metaKeywords;

  Category({
    required this.id,
    required this.categoryName,
    required this.categorySlug,
    required this.position,
    required this.isActive,
    required this.categoryImage,
    required this.metaTitle,
    required this.metaDescription,
    required this.metaKeywords,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json["id"] ?? 0,
    categoryName: json["category_name"] ?? "",
    categorySlug: json["category_slug"],
    position: json["position"] ?? 0,
    isActive: json["is_active"] ?? 0,
    categoryImage: json["category_image"],
    metaTitle: json["meta_title"],
    metaDescription: json["meta_description"],
    metaKeywords: json["meta_keywords"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "category_name": categoryName,
    "category_slug": categorySlug,
    "position": position,
    "is_active": isActive,
    "category_image": categoryImage,
    "meta_title": metaTitle,
    "meta_description": metaDescription,
    "meta_keywords": metaKeywords,
  };
}