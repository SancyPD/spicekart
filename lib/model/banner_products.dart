import 'dart:convert';

BannerProducts bannerProductsFromJson(String str) => BannerProducts.fromJson(json.decode(str));

String bannerProductsToJson(BannerProducts data) => json.encode(data.toJson());

class BannerProducts {
  int status;
  Data data;
  String message;

  BannerProducts({
    required this.status,
    required this.data,
    required this.message,
  });

  factory BannerProducts.fromJson(Map<String, dynamic> json) => BannerProducts(
    status: json["status"],
    data: Data.fromJson(json["data"]),
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": data.toJson(),
    "message": message,
  };
}

class Data {
  List<Product> product;

  Data({
    required this.product,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    product: List<Product>.from(json["product"].map((x) => Product.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "product": List<dynamic>.from(product.map((x) => x.toJson())),
  };
}

class Product {
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
  List<RegionElement> regions;
  List<Rating> ratings;
  bool isFavourite;

  Product({
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
    required this.isFavourite,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json["id"],
    slug: json["slug"],
    productName: json["product_name"],
    productDescription: json["product_description"],
    productBarcode: json["product_barcode"],
    averageRating: json["average_rating"],
    totalRatings: json["total_ratings"],
    categoryId: json["category_id"],
    brandId: json["brand_id"],
    productImage: json["product_image"],
    metaTitle: json["meta_title"],
    metaDescription: json["meta_description"],
    metaKeywords: json["meta_keywords"],
    productTax: json["product_tax"],
    productStatus: json["product_status"],
    variants: List<Variant>.from(json["variants"].map((x) => Variant.fromJson(x))),
    regions: List<RegionElement>.from(json["regions"].map((x) => RegionElement.fromJson(x))),
    ratings: List<Rating>.from(json["ratings"].map((x) => Rating.fromJson(x))),
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
    "is_favourite": isFavourite,
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
