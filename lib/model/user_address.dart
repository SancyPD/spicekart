class UserAddress {
  final int? addressId;
  final String addressLine1;
  final String? addressLine2;
  final String? landmark;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final String addressType;
  final bool isDefault;

  UserAddress({
    this.addressId,
    required this.addressLine1,
    this.addressLine2,
    this.landmark,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    required this.addressType,
    required this.isDefault,
  });

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      addressId: json['address_id'] ?? json['id'],
      addressLine1: json['address_line_1'] ?? '',
      addressLine2: json['address_line_2'],
      landmark: json['landmark'],
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      postalCode: json['postal_code']?.toString() ?? '',
      addressType: json['address_type'] ?? 'Home',
      isDefault: json['is_default'] == 1 || json['is_default'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'address_line_1': addressLine1,
      'city': city,
      'state': state,
      'country': country,
      'postal_code': postalCode,
      'address_type': addressType,
      'is_default': isDefault ? 1 : 0,
    };

    if (addressId != null) {
      data['address_id'] = addressId;
    }
    if (addressLine2 != null && addressLine2!.isNotEmpty) {
      data['address_line_2'] = addressLine2;
    }
    if (landmark != null && landmark!.isNotEmpty) {
      data['landmark'] = landmark;
    }

    return data;
  }
}
