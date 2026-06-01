import 'dart:convert';

PropertyTypes propertyTypesFromJson(String str) => PropertyTypes.fromJson(json.decode(str));

String propertyTypesToJson(PropertyTypes data) => json.encode(data.toJson());

class PropertyTypes {
  int status;
  String message;
  List<Datum> data;

  PropertyTypes({
    required this.status,
    required this.message,
    required this.data,
  });

  factory PropertyTypes.fromJson(Map<String, dynamic> json) => PropertyTypes(
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
  String typeName;

  Datum({
    required this.id,
    required this.typeName,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"] ?? 0,
    typeName: json["type_name"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "type_name": typeName,
  };
}
