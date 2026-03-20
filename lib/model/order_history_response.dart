import 'dart:convert';

OrderHistoryResponse orderHistoryResponseFromJson(String str) => OrderHistoryResponse.fromJson(json.decode(str));

String orderHistoryResponseToJson(OrderHistoryResponse data) => json.encode(data.toJson());

class OrderHistoryResponse {
  int status;
  String message;
  List<Order> data;

  OrderHistoryResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory OrderHistoryResponse.fromJson(Map<String, dynamic> json) => OrderHistoryResponse(
    status: json["status"] ?? 0,
    message: json["message"] ?? "",
    data: json["data"] != null ? List<Order>.from(json["data"].map((x) => Order.fromJson(x))) : [],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Order {
  int id;
  String orderNumber;
  String orderDate;
  String totalAmount;
  String status;
  int itemCount;
  String? deliveryBoyName;
  String? deliveryBoyImage;
  List<OrderItem> items;

  Order({
    required this.id,
    required this.orderNumber,
    required this.orderDate,
    required this.totalAmount,
    required this.status,
    required this.itemCount,
    this.deliveryBoyName,
    this.deliveryBoyImage,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json["id"] ?? 0,
    orderNumber: json["order_number"] ?? "",
    orderDate: json["order_date"] ?? "",
    totalAmount: json["total_amount"] ?? "0.00",
    status: json["status"] ?? "",
    itemCount: json["item_count"] ?? 0,
    deliveryBoyName: json["delivery_boy_name"],
    deliveryBoyImage: json["delivery_boy_image"],
    items: json["items"] != null ? List<OrderItem>.from(json["items"].map((x) => OrderItem.fromJson(x))) : [],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "order_number": orderNumber,
    "order_date": orderDate,
    "total_amount": totalAmount,
    "status": status,
    "item_count": itemCount,
    "delivery_boy_name": deliveryBoyName,
    "delivery_boy_image": deliveryBoyImage,
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
  };
}

class OrderItem {
  int id;
  int productId;
  String productName;
  String productImage;
  String varientSize;
  String productPrice;
  int quantity;

  OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.varientSize,
    required this.productPrice,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    id: json["id"] ?? 0,
    productId: json["product_id"] ?? 0,
    productName: json["product_name"] ?? "",
    productImage: json["product_image"] ?? "",
    varientSize: json["varient_size"] ?? "",
    productPrice: json["product_price"] ?? "0.00",
    quantity: json["quantity"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "product_id": productId,
    "product_name": productName,
    "product_image": productImage,
    "varient_size": varientSize,
    "product_price": productPrice,
    "quantity": quantity,
  };
}
