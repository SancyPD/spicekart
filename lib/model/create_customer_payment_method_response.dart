import 'dart:convert';

CreateCustomerPaymentMethodResponse
    createCustomerPaymentMethodResponseFromJson(String str) =>
        CreateCustomerPaymentMethodResponse.fromJson(
          json.decode(str) as Map<String, dynamic>,
        );

/// Response from [ApiService.createCustomerPaymentMethod] — contains a Stripe
/// [SetupIntent](https://stripe.com/docs/api/setup_intents/object) used to collect
/// and attach a card to the customer.
class CreateCustomerPaymentMethodResponse {
  final int status;
  final String message;
  final SetupIntentData? data;
  final dynamic meta;

  CreateCustomerPaymentMethodResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.meta,
  });

  factory CreateCustomerPaymentMethodResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final raw = json['data'];
    return CreateCustomerPaymentMethodResponse(
      status: _asInt(json['status']),
      message: json['message']?.toString() ?? '',
      data: raw is Map<String, dynamic> ? SetupIntentData.fromJson(raw) : null,
      meta: json['meta'],
    );
  }

  String? get setupIntentClientSecret => data?.clientSecret;

  String? get customerId {
    final c = data?.customer;
    if (c == null || c.isEmpty) return null;
    return c;
  }

  /// If the backend returns an ephemeral key for the customer, pass it to Payment Sheet.
  String? get ephemeralKeySecret => data?.ephemeralKeySecret;
}

class SetupIntentData {
  final String id;
  final String object;
  final String? clientSecret;
  final String? customer;
  final String? status;
  final dynamic metadata;
  final String? ephemeralKeySecret;

  SetupIntentData({
    required this.id,
    required this.object,
    required this.clientSecret,
    required this.customer,
    required this.status,
    required this.metadata,
    required this.ephemeralKeySecret,
  });

  factory SetupIntentData.fromJson(Map<String, dynamic> json) {
    final ek = json['ephemeral_key'] ??
        json['ephemeralKey'] ??
        json['customer_ephemeral_key_secret'];
    return SetupIntentData(
      id: json['id']?.toString() ?? '',
      object: json['object']?.toString() ?? '',
      clientSecret: json['client_secret']?.toString(),
      customer: json['customer']?.toString(),
      status: json['status']?.toString(),
      metadata: json['metadata'],
      ephemeralKeySecret: ek?.toString(),
    );
  }
}

int _asInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is double) return v.round();
  return int.tryParse(v.toString()) ?? 0;
}
