
import 'dart:convert';

NotificationsResponse notificationsResponseFromJson(String str) => NotificationsResponse.fromJson(json.decode(str));

String notificationsResponseToJson(NotificationsResponse data) => json.encode(data.toJson());

class NotificationsResponse {
  int status;
  String message;
  List<Datum> data;
  dynamic meta;

  NotificationsResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.meta,
  });

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) => NotificationsResponse(
    status: json["status"] ?? 0,
    message: json["message"] ?? "",
    data: json["data"] != null ? List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))) : [],
    meta: json["meta"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "meta": meta,
  };
}

class Datum {
  int id;
  String title;
  String message;
  String type;
  int isRead;

  Datum({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"] ?? 0,
    title: json["title"] ?? "",
    message: json["message"] ?? "",
    type: json["type"] ?? "",
    isRead: json["is_read"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "message": message,
    "type": type,
    "is_read": isRead,
  };
}
