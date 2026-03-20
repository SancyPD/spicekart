// To parse this JSON data, do
//
//     final checkoutPreviewResponse = checkoutPreviewResponseFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

CheckoutPreviewResponse checkoutPreviewResponseFromJson(String str) => CheckoutPreviewResponse.fromJson(json.decode(str));

String checkoutPreviewResponseToJson(CheckoutPreviewResponse data) => json.encode(data.toJson());

class CheckoutPreviewResponse {
  int status;
  String message;
  Data data;

  CheckoutPreviewResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CheckoutPreviewResponse.fromJson(Map<String, dynamic> json) => CheckoutPreviewResponse(
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
  Issues issues;
  Cart cart;
  TotalAmountSummary totalAmountSummary;

  Data({
    required this.issues,
    required this.cart,
    required this.totalAmountSummary,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    issues: Issues.fromJson(json["issues"]),
    cart: Cart.fromJson(json["cart"]),
    totalAmountSummary: TotalAmountSummary.fromJson(json["total_amount_summary"]),
  );

  Map<String, dynamic> toJson() => {
    "issues": issues.toJson(),
    "cart": cart.toJson(),
    "total_amount_summary": totalAmountSummary.toJson(),
  };
}

class Cart {
  int id;
  int userId;
  String checkoutPhone;
  String checkoutEmail;
  DateTime checkoutPhoneVerifiedAt;
  dynamic coupon;
  String discountAmount;
  Address address;
  PropertyType propertyType;
  dynamic deliverySlot;
  dynamic deliveryDate;
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
    id: json["id"],
    userId: json["user_id"],
    checkoutPhone: json["checkout_phone"],
    checkoutEmail: json["checkout_email"],
    checkoutPhoneVerifiedAt: DateTime.parse(json["checkout_phone_verified_at"]),
    coupon: json["coupon"],
    discountAmount: json["discount_amount"],
    address: Address.fromJson(json["address"]),
    propertyType: PropertyType.fromJson(json["property_type"]),
    deliverySlot: json["delivery_slot"],
    deliveryDate: json["delivery_date"],
    cartItems: List<CartItem>.from(json["cart_items"].map((x) => CartItem.fromJson(x))),
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "checkout_phone": checkoutPhone,
    "checkout_email": checkoutEmail,
    "checkout_phone_verified_at": checkoutPhoneVerifiedAt.toIso8601String(),
    "coupon": coupon,
    "discount_amount": discountAmount,
    "address": address.toJson(),
    "property_type": propertyType.toJson(),
    "delivery_slot": deliverySlot,
    "delivery_date": deliveryDate,
    "cart_items": List<dynamic>.from(cartItems.map((x) => x.toJson())),
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}

class Address {
  int userId;
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

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    userId: json["user_id"],
    addressLine1: json["address_line1"],
    addressLine2: json["address_line2"],
    landmark: json["landmark"],
    city: json["city"],
    state: json["state"],
    postalCode: json["postal_code"],
    country: json["country"],
    addressType: json["address_type"],
    isDefault: json["is_default"],
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
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

  CartItem({
    required this.id,
    required this.quantity,
    required this.isSavedForLater,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    id: json["id"],
    quantity: json["quantity"],
    isSavedForLater: json["is_saved_for_later"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "quantity": quantity,
    "is_saved_for_later": isSavedForLater,
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
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}

class Issues {
  String deliverySlotAvailability;
  String phoneNumberNotFound;

  Issues({
    required this.deliverySlotAvailability,
    required this.phoneNumberNotFound,
  });

  factory Issues.fromJson(Map<String, dynamic> json) => Issues(
    deliverySlotAvailability: json["delivery_slot_availability"],
    phoneNumberNotFound: json["phone_number_not_found"],
  );

  Map<String, dynamic> toJson() => {
    "delivery_slot_availability": deliverySlotAvailability,
    "phone_number_not_found": phoneNumberNotFound,
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
  int tipAmount;
  int cashback;
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
    required this.cashback,
    required this.total,
  });

  factory TotalAmountSummary.fromJson(Map<String, dynamic> json) => TotalAmountSummary(
    subtotal: json["subtotal"].toDouble(),
    discount: json["discount"],
    deliveryFee: json["delivery_fee"],
    tax: json["tax"].toDouble(),
    walletBalance: json["wallet_balance"],
    walletUsed: json["wallet_used"],
    tipPercent: json["tip_percent"],
    tipAmount: json["tip_amount"],
    cashback: json["cashback"],
    total: json["total"].toDouble(),
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
    "cashback": cashback,
    "total": total,
  };
}