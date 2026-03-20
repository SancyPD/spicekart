import 'user_address.dart';
import 'dart:convert';

AddressListResponse addressListResponseFromJson(String str) =>
    AddressListResponse.fromJson(json.decode(str));

String addressListResponseToJson(AddressListResponse data) =>
    json.encode(data.toJson());

class AddressListResponse {
  final int status;
  final String message;
  final List<UserAddress>? data;

  AddressListResponse({required this.status, required this.message, this.data});

  factory AddressListResponse.fromJson(Map<String, dynamic> json) {
    return AddressListResponse(
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? List<UserAddress>.from(
              (json['data'] as List).map((x) => UserAddress.fromJson(x)),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}
