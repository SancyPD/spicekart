import 'dart:convert';

ProfileResponse profileResponseFromJson(String str) => ProfileResponse.fromJson(json.decode(str));

String profileResponseToJson(ProfileResponse data) => json.encode(data.toJson());

class ProfileResponse {
    int status;
    String message;
    Data? data;

    ProfileResponse({
        required this.status,
        required this.message,
        this.data,
    });

    factory ProfileResponse.fromJson(Map<String, dynamic> json) => ProfileResponse(
        status: json["status"] ?? 0,
        message: json["message"] ?? "",
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
    };
}

class Data {
    int id;
    String firstName;
    String lastName;
    String email;
    String phone;
    int? regionId;

    Data({
        required this.id,
        required this.firstName,
        required this.lastName,
        required this.email,
        required this.phone,
        this.regionId,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"] ?? 0,
        firstName: json["first_name"] ?? "",
        lastName: json["last_name"] ?? "",
        email: json["email"] ?? "",
        phone: json["phone"] ?? "",
        regionId: json["region_id"] is int ? json["region_id"] : int.tryParse(json["region_id"]?.toString() ?? ""),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "phone": phone,
        "region_id": regionId,
    };
}
