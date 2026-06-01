import 'dart:convert';

DeliverySlots deliverySlotsFromJson(String str) =>
    DeliverySlots.fromJson(json.decode(str));

String deliverySlotsToJson(DeliverySlots data) => json.encode(data.toJson());

class DeliverySlots {
  int status;
  String message;
  List<DeliverySlot> data;

  DeliverySlots({
    required this.status,
    required this.message,
    required this.data,
  });

  factory DeliverySlots.fromJson(Map<String, dynamic> json) => DeliverySlots(
    status: json["status"] is int ? json["status"] : int.tryParse(json["status"]?.toString() ?? "") ?? 0,
    message: json["message"]?.toString() ?? "",
    data: json["data"] is List
        ? List<DeliverySlot>.from(json["data"].map((x) => DeliverySlot.fromJson(x)))
        : [],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class DeliverySlot {
  DateTime deliveryDate;
  List<Slot> slots;

  DeliverySlot({required this.deliveryDate, required this.slots});

  factory DeliverySlot.fromJson(Map<String, dynamic> json) => DeliverySlot(
    deliveryDate: json["delivery_date"] != null 
        ? DateTime.parse(json["delivery_date"]) 
        : DateTime.now(),
    slots: json["slots"] is List 
        ? List<Slot>.from(json["slots"].map((x) => Slot.fromJson(x))) 
        : [],
  );

  Map<String, dynamic> toJson() => {
    "delivery_date":
        "${deliveryDate.year.toString().padLeft(4, '0')}-${deliveryDate.month.toString().padLeft(2, '0')}-${deliveryDate.day.toString().padLeft(2, '0')}",
    "slots": List<dynamic>.from(slots.map((x) => x.toJson())),
  };
}

class Slot {
  int id;
  String startTime;
  String endTime;
  int isActive;

  Slot({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.isActive,
  });

  factory Slot.fromJson(Map<String, dynamic> json) => Slot(
    id: json["id"] is int ? json["id"] : int.tryParse(json["id"]?.toString() ?? "") ?? 0,
    startTime: json["start_time"]?.toString() ?? "",
    endTime: json["end_time"]?.toString() ?? "",
    isActive: json["is_active"] is int ? json["is_active"] : int.tryParse(json["is_active"]?.toString() ?? "") ?? 1,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "start_time": startTime,
    "end_time": endTime,
    "is_active": isActive,
  };
}