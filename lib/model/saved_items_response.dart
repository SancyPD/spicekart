import 'dart:convert';

SavedItemsResponse savedItemsResponseFromJson(String str) => SavedItemsResponse.fromJson(json.decode(str));

String savedItemsResponseToJson(SavedItemsResponse data) => json.encode(data.toJson());

class SavedItemsResponse {
  int status;
  String message;
  List<Datum> data;

  SavedItemsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory SavedItemsResponse.fromJson(Map<String, dynamic> json) => SavedItemsResponse(
    status: json["status"],
    message: json["message"],
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
  Product product;
  Variant variant;

  Datum({
    required this.id,
    required this.quantity,
    required this.isSavedForLater,
    required this.product,
    required this.variant,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    quantity: json["quantity"],
    isSavedForLater: json["is_saved_for_later"],
    product: Product.fromJson(json["product"]),
    variant: Variant.fromJson(json["variant"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "quantity": quantity,
    "is_saved_for_later": isSavedForLater,
    "product": product.toJson(),
    "variant": variant.toJson(),
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
