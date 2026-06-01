import 'dart:convert';
import 'delivery_slots.dart';

CheckoutPreviewProductResponse checkoutPreviewProductResponseFromJson(String str) => CheckoutPreviewProductResponse.fromJson(json.decode(str));

String checkoutPreviewProductResponseToJson(CheckoutPreviewProductResponse data) => json.encode(data.toJson());

class CheckoutPreviewProductResponse {
  int status;
  String message;
  Data data;

  CheckoutPreviewProductResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CheckoutPreviewProductResponse.fromJson(Map<String, dynamic> json) => CheckoutPreviewProductResponse(
    status: json["status"] ?? 0,
    message: json["message"] ?? "",
    data: json["data"] is Map<String, dynamic> ? Data.fromJson(json["data"]) : Data(
      issues: Issues(deliverySlotAvailability: ""),
      cart: Cart(id: 0, userId: 0, checkoutPhone: "", checkoutEmail: "", checkoutPhoneVerifiedAt: "", coupon: null, discountAmount: "", address: Address(userId: 0, firstName: "", lastName: "", addressLine1: "", addressLine2: null, landmark: "", city: "", state: "", postalCode: "", country: "", addressType: "", isDefault: 0), propertyType: PropertyType(id: 0, name: ""), deliverySlot: null, deliveryDate: null, cartItems: [], createdAt: DateTime.now(), updatedAt: DateTime.now()),
      deliveryInstruction: DeliveryInstruction(propertyTypeId: 0, gateCode: "", deliveryNotes: "", dropOffLocation: "", source: ""),
      totalAmountSummary: TotalAmountSummary(subtotal: 0, discount: 0, deliveryFee: 0, tax: 0, walletBalance: 0, walletUsed: 0, tipPercent: 0, tipAmount: 0, cashback: 0, total: 0),
      cartType: "",
    ),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data.toJson(),
  };
}

class Data {
  Issues issues;
  Cart cart;
  DeliveryInstruction deliveryInstruction;
  TotalAmountSummary totalAmountSummary;
  String cartType;

  Data({
    required this.issues,
    required this.cart,
    required this.deliveryInstruction,
    required this.totalAmountSummary,
    required this.cartType,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    issues: json["issues"] is Map<String, dynamic> 
        ? Issues.fromJson(json["issues"]) 
        : Issues(deliverySlotAvailability: ""),
    cart: json["cart"] is Map<String, dynamic> ? Cart.fromJson(json["cart"]) : Cart(id: 0, userId: 0, checkoutPhone: "", checkoutEmail: "", checkoutPhoneVerifiedAt: "", coupon: null, discountAmount: "", address: Address(userId: 0, firstName: "", lastName: "", addressLine1: "", addressLine2: null, landmark: "", city: "", state: "", postalCode: "", country: "", addressType: "", isDefault: 0), propertyType: PropertyType(id: 0, name: ""), deliverySlot: null, deliveryDate: null, cartItems: [], createdAt: DateTime.now(), updatedAt: DateTime.now()),
    deliveryInstruction: json["delivery_instruction"] is Map<String, dynamic>
        ? DeliveryInstruction.fromJson(json["delivery_instruction"])
        : DeliveryInstruction(propertyTypeId: 0, gateCode: "", deliveryNotes: "", dropOffLocation: "", source: ""),
    totalAmountSummary: json["total_amount_summary"] is Map<String, dynamic>
        ? TotalAmountSummary.fromJson(json["total_amount_summary"])
        : TotalAmountSummary(subtotal: 0, discount: 0, deliveryFee: 0, tax: 0, walletBalance: 0, walletUsed: 0, tipPercent: 0, tipAmount: 0, cashback: 0, total: 0),
    cartType: json["cart_type"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "issues": issues.toJson(),
    "cart": cart.toJson(),
    "delivery_instruction": deliveryInstruction.toJson(),
    "total_amount_summary": totalAmountSummary.toJson(),
    "cart_type": cartType,
  };
}

class Cart {
  int id;
  int userId;
  String checkoutPhone;
  String checkoutEmail;
  String checkoutPhoneVerifiedAt;
  dynamic coupon;
  String discountAmount;
  Address address;
  PropertyType propertyType;
  Slot? deliverySlot;
  DateTime? deliveryDate;
  List<CartItem> cartItems;
  DateTime createdAt;
  DateTime updatedAt;

  Cart({
    required this.id,
    required this.userId,
    required this.checkoutPhone,
    required this.checkoutEmail,
    required this.checkoutPhoneVerifiedAt,
    required this.coupon,
    required this.discountAmount,
    required this.address,
    required this.propertyType,
    required this.deliverySlot,
    required this.deliveryDate,
    required this.cartItems,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Cart.fromJson(Map<String, dynamic> json) => Cart(
    id: json["id"] ?? 0,
    userId: json["user_id"] ?? 0,
    checkoutPhone: json["checkout_phone"] ?? "",
    checkoutEmail: json["checkout_email"] ?? "",
    checkoutPhoneVerifiedAt: json["checkout_phone_verified_at"] ?? "",
    coupon: json["coupon"],
    discountAmount: json["discount_amount"] ?? "",
    address: Address.fromJson(json["address"]),
    propertyType: json["property_type"] is Map<String, dynamic>
        ? PropertyType.fromJson(json["property_type"])
        : PropertyType(id: 0, name: ""),
    deliverySlot: json["delivery_slot"] == null ? null : Slot.fromJson(json["delivery_slot"]),
    deliveryDate: json["delivery_date"] == null ? null : DateTime.tryParse(json["delivery_date"]),
    cartItems: json["cart_items"] != null ? List<CartItem>.from(json["cart_items"].map((x) => CartItem.fromJson(x))) : [],
    createdAt: json["created_at"] != null ? DateTime.parse(json["created_at"]) : DateTime.now(),
    updatedAt: json["updated_at"] != null ? DateTime.parse(json["updated_at"]) : DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "checkout_phone": checkoutPhone,
    "checkout_email": checkoutEmail,
    "checkout_phone_verified_at": checkoutPhoneVerifiedAt,
    "coupon": coupon,
    "discount_amount": discountAmount,
    "address": address.toJson(),
    "property_type": propertyType.toJson(),
    "delivery_slot": deliverySlot?.toJson(),
    "delivery_date": deliveryDate?.toIso8601String(),
    "cart_items": List<dynamic>.from(cartItems.map((x) => x.toJson())),
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}

class Address {
  int userId;
  String firstName;
  String lastName;
  String addressLine1;
  dynamic addressLine2;
  String landmark;
  String city;
  String state;
  String postalCode;
  String country;
  String addressType;
  int isDefault;

  Address({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.addressLine1,
    required this.addressLine2,
    required this.landmark,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.addressType,
    required this.isDefault,
  });

  factory Address.fromJson(Map<String, dynamic>? json) => json == null ? Address(
    userId: 0,
    firstName: "",
    lastName: "",
    addressLine1: "",
    addressLine2: null,
    landmark: "",
    city: "",
    state: "",
    postalCode: "",
    country: "",
    addressType: "",
    isDefault: 0,
  ) : Address(
    userId: json["user_id"] ?? 0,
    firstName: json["first_name"] ?? "",
    lastName: json["last_name"] ?? "",
    addressLine1: json["address_line1"] ?? "",
    addressLine2: json["address_line2"],
    landmark: json["landmark"] ?? "",
    city: json["city"] ?? "",
    state: json["state"] ?? "",
    postalCode: json["postal_code"] ?? "",
    country: json["country"] ?? "",
    addressType: json["address_type"] ?? "",
    isDefault: json["is_default"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "first_name": firstName,
    "last_name": lastName,
    "address_line1": addressLine1,
    "address_line2": addressLine2,
    "landmark": landmark,
    "city": city,
    "state": state,
    "postal_code": postalCode,
    "country": country,
    "address_type": addressType,
    "is_default": isDefault,
  };
}

class CartItem {
  int id;
  int quantity;
  int isSavedForLater;
  String itemType;
  Item item;
  Variant? variant;

  CartItem({
    required this.id,
    required this.quantity,
    required this.isSavedForLater,
    required this.itemType,
    required this.item,
    this.variant,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    id: json["id"] ?? 0,
    quantity: json["quantity"] ?? 0,
    isSavedForLater: json["is_saved_for_later"] ?? 0,
    itemType: json["item_type"] ?? "",
    item: json["item"] is Map<String, dynamic> ? Item.fromJson(json["item"]) : Item(id: 0, slug: "", productName: "", productDescription: "", productBarcode: "", averageRating: 0, totalRatings: 0, categoryId: 0, brandId: 0, productImage: "", metaTitle: null, metaDescription: null, metaKeywords: null, productTax: "", productStatus: "", regions: [], isFavourite: false),
    variant: json["variant"] == null ? null : Variant.fromJson(json["variant"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "quantity": quantity,
    "is_saved_for_later": isSavedForLater,
    "item_type": itemType,
    "item": item.toJson(),
    "variant": variant?.toJson(),
  };
}

class Item {
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
  List<Region> regions;
  bool isFavourite;

  // Food fields
  String name;
  String description;
  String image;
  String price;
  bool isAvailable;
  FoodCategory? foodCategory;
  Restaurant? restaurant;

  Item({
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
    required this.regions,
    required this.isFavourite,
    this.name = "",
    this.description = "",
    this.image = "",
    this.price = "",
    this.isAvailable = false,
    this.foodCategory,
    this.restaurant,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json["id"] ?? 0,
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
    regions: json["regions"] != null ? List<Region>.from(json["regions"].map((x) => Region.fromJson(x))) : [],
    isFavourite: json["is_favourite"] ?? false,
    name: json["name"] ?? "",
    description: json["description"] ?? "",
    image: json["image"] ?? "",
    price: json["price"] ?? "",
    isAvailable: json["is_available"] ?? false,
    foodCategory: json["food_category"] != null ? FoodCategory.fromJson(json["food_category"]) : null,
    restaurant: json["restaurant"] != null ? Restaurant.fromJson(json["restaurant"]) : null,
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
    "regions": List<dynamic>.from(regions.map((x) => x.toJson())),
    "is_favourite": isFavourite,
    "name": name,
    "description": description,
    "image": image,
    "price": price,
    "is_available": isAvailable,
    "food_category": foodCategory?.toJson(),
    "restaurant": restaurant?.toJson(),
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
    isActive: json["is_active"] ?? false,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "is_active": isActive,
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
    isActive: json["is_active"] ?? false,
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

class PropertyType {
  int id;
  String name;

  PropertyType({
    required this.id,
    required this.name,
  });

  factory PropertyType.fromJson(Map<String, dynamic> json) => PropertyType(
    id: json["id"] ?? 0,
    name: json["name"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}

class DeliveryInstruction {
  int propertyTypeId;
  String gateCode;
  String deliveryNotes;
  String dropOffLocation;
  String source;

  DeliveryInstruction({
    required this.propertyTypeId,
    required this.gateCode,
    required this.deliveryNotes,
    required this.dropOffLocation,
    required this.source,
  });

  factory DeliveryInstruction.fromJson(Map<String, dynamic> json) => DeliveryInstruction(
    propertyTypeId: json["property_type_id"] ?? 0,
    gateCode: json["gate_code"] ?? "",
    deliveryNotes: json["delivery_notes"] ?? "",
    dropOffLocation: json["drop_off_location"] ?? "",
    source: json["source"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "property_type_id": propertyTypeId,
    "gate_code": gateCode,
    "delivery_notes": deliveryNotes,
    "drop_off_location": dropOffLocation,
    "source": source,
  };
}

class Issues {
  String deliverySlotAvailability;

  Issues({
    required this.deliverySlotAvailability,
  });

  factory Issues.fromJson(Map<String, dynamic> json) => Issues(
    deliverySlotAvailability: json["delivery_slot_availability"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "delivery_slot_availability": deliverySlotAvailability,
  };
}

class TotalAmountSummary {
  double subtotal;
  int discount;
  int deliveryFee;
  double tax;
  int walletBalance;
  int walletUsed;
  int tipPercent;
  double tipAmount;
  /// API: `percent` | `custom` when provided.
  String? tipType;
  double? customTipAmount;
  double cashback;
  double total;

  TotalAmountSummary({
    required this.subtotal,
    required this.discount,
    required this.deliveryFee,
    required this.tax,
    required this.walletBalance,
    required this.walletUsed,
    required this.tipPercent,
    required this.tipAmount,
    this.tipType,
    this.customTipAmount,
    required this.cashback,
    required this.total,
  });

  factory TotalAmountSummary.fromJson(Map<String, dynamic> json) => TotalAmountSummary(
    subtotal: (json["subtotal"] ?? 0).toDouble(),
    discount: (json["discount"] ?? 0).toInt(),
    deliveryFee: (json["delivery_fee"] ?? 0).toInt(),
    tax: (json["tax"] ?? 0).toDouble(),
    walletBalance: (json["wallet_balance"] ?? 0).toInt(),
    walletUsed: (json["wallet_used"] ?? 0).toInt(),
    tipPercent: (json["tip_percent"] ?? 0).toInt(),
    tipAmount: _parseAmount(json["tip_amount"]),
    tipType: json["tip_type"]?.toString(),
    customTipAmount: json["custom_tip_amount"] != null
        ? _parseAmount(json["custom_tip_amount"])
        : null,
    cashback: (json["cashback"] ?? 0).toDouble(),
    total: (json["total"] ?? 0).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "subtotal": subtotal,
    "discount": discount,
    "delivery_fee": deliveryFee,
    "tax": tax,
    "wallet_balance": walletBalance,
    "wallet_used": walletUsed,
    "tip_percent": tipPercent,
    "tip_amount": tipAmount,
    if (tipType != null) "tip_type": tipType,
    if (customTipAmount != null) "custom_tip_amount": customTipAmount,
    "cashback": cashback,
    "total": total,
  };
}

double _parseAmount(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}