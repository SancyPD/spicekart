import 'dart:convert';

OrderHistoryResponse orderHistoryResponseFromJson(String str) => OrderHistoryResponse.fromJson(json.decode(str));

String orderHistoryResponseToJson(OrderHistoryResponse data) => json.encode(data.toJson());

class OrderHistoryResponse {
  int status;
  String message;
  Data data;

  OrderHistoryResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory OrderHistoryResponse.fromJson(Map<String, dynamic> json) => OrderHistoryResponse(
    status: json["status"] ?? 0,
    message: json["message"] ?? "",
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data.toJson(),
  };
}

class Data {
  int currentPage;
  List<Datum> data;
  String firstPageUrl;
  int from;
  int lastPage;
  String lastPageUrl;
  List<Link> links;
  String nextPageUrl;
  String path;
  int perPage;
  dynamic prevPageUrl;
  int to;
  int total;

  Data({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.links,
    required this.nextPageUrl,
    required this.path,
    required this.perPage,
    required this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    currentPage: json["current_page"] ?? 0,
    data: json["data"] != null 
        ? List<Datum>.from(json["data"].map((x) => Datum.fromJson(x)))
        : [],
    firstPageUrl: json["first_page_url"] ?? "",
    from: json["from"] ?? 0,
    lastPage: json["last_page"] ?? 0,
    lastPageUrl: json["last_page_url"] ?? "",
    links: json["links"] != null 
        ? List<Link>.from(json["links"].map((x) => Link.fromJson(x)))
        : [],
    nextPageUrl: json["next_page_url"] ?? "",
    path: json["path"] ?? "",
    perPage: json["per_page"] ?? 0,
    prevPageUrl: json["prev_page_url"],
    to: json["to"] ?? 0,
    total: json["total"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "first_page_url": firstPageUrl,
    "from": from,
    "last_page": lastPage,
    "last_page_url": lastPageUrl,
    "links": List<dynamic>.from(links.map((x) => x.toJson())),
    "next_page_url": nextPageUrl,
    "path": path,
    "per_page": perPage,
    "prev_page_url": prevPageUrl,
    "to": to,
    "total": total,
  };
}

class Datum {
  int id;
  String orderNumber;
  String subTotal;
  String taxAmount;
  String deliveryFee;
  String tipAmount;
  String couponDiscount;
  String walletUsed;
  String totalAmount;
  String paymentMethod;
  String paymentStatus;
  String orderStatus;
  DateTime placedAt;
  dynamic deliveryVerificationCode;
  dynamic deliveryVerifiedAt;
  Address address;
  DeliverySlot deliverySlot;
  List<ItemElement> items;

  Datum({
    required this.id,
    required this.orderNumber,
    required this.subTotal,
    required this.taxAmount,
    required this.deliveryFee,
    required this.tipAmount,
    required this.couponDiscount,
    required this.walletUsed,
    required this.totalAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderStatus,
    required this.placedAt,
    required this.deliveryVerificationCode,
    required this.deliveryVerifiedAt,
    required this.address,
    required this.deliverySlot,
    required this.items,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"] ?? 0,
    orderNumber: json["order_number"] ?? "",
    subTotal: json["sub_total"] ?? "",
    taxAmount: json["tax_amount"] ?? "",
    deliveryFee: json["delivery_fee"] ?? "",
    tipAmount: json["tip_amount"] ?? "",
    couponDiscount: json["coupon_discount"] ?? "",
    walletUsed: json["wallet_used"] ?? "",
    totalAmount: json["total_amount"] ?? "",
    paymentMethod:json["payment_method"] ?? "",
    paymentStatus:json["payment_status"] ?? "",
    orderStatus: json["order_status"] ?? "",
    placedAt: DateTime.parse(json["placed_at"]),
    deliveryVerificationCode: json["delivery_verification_code"],
    deliveryVerifiedAt: json["delivery_verified_at"],
    address: Address.fromJson(json["address"]),
    deliverySlot: DeliverySlot.fromJson(json["delivery_slot"]),
    items: json["items"] != null 
        ? List<ItemElement>.from(json["items"].map((x) => ItemElement.fromJson(x)))
        : [],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "order_number": orderNumber,
    "sub_total": subTotal,
    "tax_amount": taxAmount,
    "delivery_fee": deliveryFee,
    "tip_amount": tipAmount,
    "coupon_discount": couponDiscount,
    "wallet_used": walletUsed,
    "total_amount": totalAmount,
    "payment_method":paymentMethod,
    "payment_status": paymentStatus,
    "order_status": orderStatus,
    "placed_at": placedAt.toIso8601String(),
    "delivery_verification_code": deliveryVerificationCode,
    "delivery_verified_at": deliveryVerifiedAt,
    "address": address.toJson(),
    "delivery_slot": deliverySlot.toJson(),
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
  };
}

class Address {
  String firstName;
  String lastName;
  String addressLine1;
  String addressLine2;
  String landmark;
  String city;
  String state;
  String postalCode;
  String country;

  Address({
    required this.firstName,
    required this.lastName,
    required this.addressLine1,
    required this.addressLine2,
    required this.landmark,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
  });

  factory Address.fromJson(Map<String, dynamic>? json) => json == null ? Address(
    firstName: "",
    lastName: "",
    addressLine1: "",
    addressLine2: "",
    landmark: "",
    city: "",
    state: "",
    postalCode: "",
    country: "",
  ) : Address(
    firstName:json["first_name"] ?? "",
    lastName: json["last_name"] ?? "",
    addressLine1: json["address_line1"] ?? "",
    addressLine2: json["address_line2"] ?? "",
    landmark: json["landmark"] ?? "",
    city:json["city"] ?? "",
    state: json["state"] ?? "",
    postalCode: json["postal_code"] ?? "",
    country: json["country"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "first_name":firstName,
    "last_name": lastName,
    "address_line1":addressLine1,
    "address_line2": addressLine2,
    "landmark": landmark,
    "city": city,
    "state": state,
    "postal_code": postalCode,
    "country":country,
  };
}


class DeliverySlot {
  int id;
  String name;
  String startTime;
  String endTime;
  DateTime date;

  DeliverySlot({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.date,
  });

  factory DeliverySlot.fromJson(Map<String, dynamic> json) => DeliverySlot(
    id: json["id"] ?? 0,
    name: json["name"] ?? "",
    startTime: json["start_time"] ?? "",
    endTime: json["end_time"] ?? "",
    date: DateTime.parse(json["date"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "start_time": startTime,
    "end_time": endTime,
    "date": "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
  };
}



class ItemElement {
  int id;
  String itemName;
  String itemType;
  String unitPrice;
  int quantity;
  String totalPrice;
  ItemItem? item;
  Variant? variant;

  ItemElement({
    required this.id,
    required this.itemName,
    required this.itemType,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
    this.item,
    this.variant,
  });

  factory ItemElement.fromJson(Map<String, dynamic> json) => ItemElement(
    id: json["id"] ?? 0,
    itemName: json["item_name"] ?? "",
    itemType: json["item_type"] ?? "",
    unitPrice: json["unit_price"] ?? "",
    quantity: json["quantity"] ?? 0,
    totalPrice: json["total_price"] ?? "",
    item: json["item"] == null ? null : ItemItem.fromJson(json["item"]),
    variant: json["variant"] == null ? null : Variant.fromJson(json["variant"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "item_name": itemName,
    "item_type": itemType,
    "unit_price": unitPrice,
    "quantity": quantity,
    "total_price": totalPrice,
    "item": item?.toJson(),
    "variant": variant?.toJson(),
  };
}

class ItemItem {
  int id;
  String name;
  String description;
  String image;
  String price;
  bool isAvailable;
  FoodCategory? foodCategory;
  Restaurant? restaurant;
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
  List<ItemImage> images;
  bool isFavourite;

  ItemItem({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.price,
    required this.isAvailable,
    this.foodCategory,
    this.restaurant,
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

  factory ItemItem.fromJson(Map<String, dynamic> json) => ItemItem(
    id: json["id"] ?? 0,
    name: json["name"] ?? "",
    description: json["description"] ?? "",
    image: json["image"] ?? "",
    price: json["price"] ?? "",
    isAvailable: json["is_available"]??true,
    foodCategory: json["food_category"] != null ? FoodCategory.fromJson(json["food_category"]) : null,
    restaurant: json["restaurant"] != null ? Restaurant.fromJson(json["restaurant"]) : null,
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
    variants: json["variants"] != null
        ? List<Variant>.from(
      json["variants"].map((x) => Variant.fromJson(x)),
    )
        : [],
    regions: json["regions"] != null
        ? List<Region>.from(json["regions"].map((x) => Region.fromJson(x)))
        : [],
    ratings: json["ratings"] != null
        ? List<Rating>.from(json["ratings"].map((x) => Rating.fromJson(x)))
        : [],
    images: json["images"] != null
        ? List<ItemImage>.from(json["images"].map((x) => ItemImage.fromJson(x)))
        : [],
    isFavourite: json["is_favourite"] ?? false,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "image": image,
    "price": price,
    "is_available": isAvailable,
    "food_category": foodCategory?.toJson(),
    "restaurant": restaurant?.toJson(),
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

class FoodCategory {
  int id;
  String name;
  bool isActive;

  FoodCategory({
    required this.id,
    required this.name,
    required this.isActive,
  });

  factory FoodCategory.fromJson(Map<String, dynamic> json) => FoodCategory(
    id: json["id"] ?? 0,
    name: json["name"] ?? "",
    isActive: json["is_active"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "is_active": isActive,
  };
}

class ItemImage {
  int id;
  String productImage;

  ItemImage({
    required this.id,
    required this.productImage,
  });

  factory ItemImage.fromJson(Map<String, dynamic> json) => ItemImage(
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

class Restaurant {
  int id;
  String name;
  dynamic description;
  String image;
  String address;
  bool isActive;

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.address,
    required this.isActive,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
    id: json["id"] ?? 0,
    name: json["name"] ?? "",
    description: json["description"],
    image: json["image"] ?? "",
    address: json["address"] ?? "",
    isActive: json["is_active"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "image": image,
    "address": address,
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


class Link {
  String url;
  String label;
  int page;
  bool active;

  Link({
    required this.url,
    required this.label,
    required this.page,
    required this.active,
  });

  factory Link.fromJson(Map<String, dynamic> json) => Link(
    url: json["url"] ?? "",
    label: json["label"] ?? "",
    page: json["page"] ?? 0,
    active: json["active"],
  );

  Map<String, dynamic> toJson() => {
    "url": url,
    "label": label,
    "page": page,
    "active": active,
  };
}

