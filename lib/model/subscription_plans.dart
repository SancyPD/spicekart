
import 'dart:convert';

SubscriptionPlans subscriptionPlansFromJson(String str) => SubscriptionPlans.fromJson(json.decode(str));

String subscriptionPlansToJson(SubscriptionPlans data) => json.encode(data.toJson());

class SubscriptionPlans {
  int status;
  String message;
  List<Datum> data;

  SubscriptionPlans({
    required this.status,
    required this.message,
    required this.data,
  });

  factory SubscriptionPlans.fromJson(Map<String, dynamic> json) => SubscriptionPlans(
    status: json["status"] ?? 0,
    message: json["message"] ?? "",
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
  String name;
  String code;
  String price;
  String currency;
  String minOrderForFreeDelivery;
  String deliveryFeeUnderMin;
  String cashbackPer100;
  int trialDays;
  String stripePriceId;
  int isActive;
  dynamic createdAt;
  dynamic updatedAt;

  Datum({
    required this.id,
    required this.name,
    required this.code,
    required this.price,
    required this.currency,
    required this.minOrderForFreeDelivery,
    required this.deliveryFeeUnderMin,
    required this.cashbackPer100,
    required this.trialDays,
    required this.stripePriceId,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"] ?? 0,
    name: json["name"]??"",
    code: json["code"]??"",
    price: json["price"]??"",
    currency: json["currency"]??"",
    minOrderForFreeDelivery: json["min_order_for_free_delivery"]??"",
    deliveryFeeUnderMin: json["delivery_fee_under_min"]??"",
    cashbackPer100: json["cashback_per_100"]??"",
    trialDays: json["trial_days"]??0,
    stripePriceId: json["stripe_price_id"]??"",
    isActive: json["is_active"]??0,
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "code": code,
    "price": price,
    "currency": currency,
    "min_order_for_free_delivery": minOrderForFreeDelivery,
    "delivery_fee_under_min": deliveryFeeUnderMin,
    "cashback_per_100": cashbackPer100,
    "trial_days": trialDays,
    "stripe_price_id": stripePriceId,
    "is_active": isActive,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}