// To parse this JSON data, do
//
//     final productDetailResponse = productDetailResponseFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

ProductDetailResponse productDetailResponseFromJson(String str) => ProductDetailResponse.fromJson(json.decode(str));

String productDetailResponseToJson(ProductDetailResponse data) => json.encode(data.toJson());

class ProductDetailResponse {
  int status;
  String message;
  Data data;

  ProductDetailResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ProductDetailResponse.fromJson(Map<String, dynamic> json) => ProductDetailResponse(
    status: json["status"],
    message: json["message"],
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data.toJson(),
  };
}

class Data {
  int id;
  String slug;
  String productName;
  String productDescription;
  String productBarcode;
  double averageRating;
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
  List<RegionElement> regions;
  List<Rating> ratings;
  List<Image> images;
  bool isFavourite;

  Data({
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
    required this.regions,
    required this.ratings,
    required this.images,
    required this.isFavourite,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    slug: json["slug"],
    productName: json["product_name"],
    productDescription: json["product_description"],
    productBarcode: json["product_barcode"],
    averageRating: json["average_rating"].toDouble()??0.0,
    totalRatings: json["total_ratings"],
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
    variants: List<Variant>.from(json["variants"].map((x) => Variant.fromJson(x))),
    regions: List<RegionElement>.from(json["regions"].map((x) => RegionElement.fromJson(x))),
    ratings: List<Rating>.from(json["ratings"].map((x) => Rating.fromJson(x))),
    images: List<Image>.from(json["images"].map((x) => Image.fromJson(x))),
    isFavourite: json["is_favourite"],
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
    id: json["id"],
    productImage: json["product_image"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "product_image": productImage,
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
  String regionImage;
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