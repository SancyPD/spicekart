import 'dart:convert';

PaymentMethodsResponse paymentMethodsResponseFromJson(String str) =>
    PaymentMethodsResponse.fromJson(json.decode(str) as Map<String, dynamic>);

String paymentMethodsResponseToJson(PaymentMethodsResponse data) =>
    json.encode(data.toJson());

class PaymentMethodsResponse {
  int status;
  String message;
  Data data;
  dynamic meta;

  PaymentMethodsResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.meta,
  });

  factory PaymentMethodsResponse.fromJson(Map<String, dynamic> json) =>
      PaymentMethodsResponse(
        status: _asInt(json['status']),
        message: json['message']?.toString() ?? '',
        data: json['data'] is Map<String, dynamic>
            ? Data.fromJson(json['data'] as Map<String, dynamic>)
            : Data.empty(),
        meta: json['meta'],
      );

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'data': data.toJson(),
        'meta': meta,
      };
}

class Data {
  String object;
  List<Datum> data;
  bool hasMore;
  String url;

  Data({
    required this.object,
    required this.data,
    required this.hasMore,
    required this.url,
  });

  factory Data.empty() => Data(
        object: 'list',
        data: [],
        hasMore: false,
        url: '',
      );

  factory Data.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'];
    final list = <Datum>[];
    if (rawList is List) {
      for (final item in rawList) {
        if (item is Map<String, dynamic>) {
          try {
            list.add(Datum.fromJson(item));
          } catch (_) {
            // Skip malformed entries
          }
        }
      }
    }
    return Data(
      object: json['object']?.toString() ?? 'list',
      data: list,
      hasMore: json['has_more'] == true || json['has_more'] == 1,
      url: json['url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'object': object,
        'data': List<dynamic>.from(data.map((x) => x.toJson())),
        'has_more': hasMore,
        'url': url,
      };
}

class Datum {
  String id;
  String object;
  String allowRedisplay;
  BillingDetails billingDetails;
  Card? card;
  int created;
  String customer;
  dynamic customerAccount;
  bool livemode;
  List<dynamic> metadata;
  dynamic sharedPaymentGrantedToken;
  String type;

  Datum({
    required this.id,
    required this.object,
    required this.allowRedisplay,
    required this.billingDetails,
    required this.card,
    required this.created,
    required this.customer,
    required this.customerAccount,
    required this.livemode,
    required this.metadata,
    required this.sharedPaymentGrantedToken,
    required this.type,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json['id']?.toString() ?? '',
        object: json['object']?.toString() ?? '',
        allowRedisplay: json['allow_redisplay']?.toString() ?? '',
        billingDetails: json['billing_details'] is Map<String, dynamic>
            ? BillingDetails.fromJson(
                json['billing_details'] as Map<String, dynamic>,
              )
            : BillingDetails.empty(),
        card: json['card'] is Map<String, dynamic>
            ? Card.fromJson(json['card'] as Map<String, dynamic>)
            : null,
        created: _asInt(json['created']),
        customer: json['customer']?.toString() ?? '',
        customerAccount: json['customer_account'],
        livemode: json['livemode'] == true || json['livemode'] == 1,
        metadata: json['metadata'] is List
            ? List<dynamic>.from(json['metadata'] as List)
            : const [],
        sharedPaymentGrantedToken: json['shared_payment_granted_token'],
        type: json['type']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'object': object,
        'allow_redisplay': allowRedisplay,
        'billing_details': billingDetails.toJson(),
        if (card != null) 'card': card!.toJson(),
        'created': created,
        'customer': customer,
        'customer_account': customerAccount,
        'livemode': livemode,
        'metadata': List<dynamic>.from(metadata.map((x) => x)),
        'shared_payment_granted_token': sharedPaymentGrantedToken,
        'type': type,
      };
}

class BillingDetails {
  Address address;
  dynamic email;
  dynamic name;
  dynamic phone;
  dynamic taxId;

  BillingDetails({
    required this.address,
    required this.email,
    required this.name,
    required this.phone,
    required this.taxId,
  });

  factory BillingDetails.empty() => BillingDetails(
        address: Address.empty(),
        email: null,
        name: null,
        phone: null,
        taxId: null,
      );

  factory BillingDetails.fromJson(Map<String, dynamic> json) =>
      BillingDetails(
        address: json['address'] is Map<String, dynamic>
            ? Address.fromJson(json['address'] as Map<String, dynamic>)
            : Address.empty(),
        email: json['email'],
        name: json['name'],
        phone: json['phone'],
        taxId: json['tax_id'],
      );

  Map<String, dynamic> toJson() => {
        'address': address.toJson(),
        'email': email,
        'name': name,
        'phone': phone,
        'tax_id': taxId,
      };
}

class Address {
  dynamic city;
  String country;
  dynamic line1;
  dynamic line2;
  dynamic postalCode;
  dynamic state;

  Address({
    required this.city,
    required this.country,
    required this.line1,
    required this.line2,
    required this.postalCode,
    required this.state,
  });

  factory Address.empty() => Address(
        city: null,
        country: '',
        line1: null,
        line2: null,
        postalCode: null,
        state: null,
      );

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        city: json['city'],
        country: json['country']?.toString() ?? '',
        line1: json['line1'],
        line2: json['line2'],
        postalCode: json['postal_code'],
        state: json['state'],
      );

  Map<String, dynamic> toJson() => {
        'city': city,
        'country': country,
        'line1': line1,
        'line2': line2,
        'postal_code': postalCode,
        'state': state,
      };
}

class Card {
  String brand;
  Checks checks;
  String country;
  String displayBrand;
  int expMonth;
  int expYear;
  String fingerprint;
  String funding;
  dynamic generatedFrom;
  String last4;
  Networks networks;
  String regulatedStatus;
  ThreeDSecureUsage threeDSecureUsage;
  dynamic wallet;

  Card({
    required this.brand,
    required this.checks,
    required this.country,
    required this.displayBrand,
    required this.expMonth,
    required this.expYear,
    required this.fingerprint,
    required this.funding,
    required this.generatedFrom,
    required this.last4,
    required this.networks,
    required this.regulatedStatus,
    required this.threeDSecureUsage,
    required this.wallet,
  });

  factory Card.fromJson(Map<String, dynamic> json) => Card(
        brand: json['brand']?.toString() ?? '',
        checks: json['checks'] is Map<String, dynamic>
            ? Checks.fromJson(json['checks'] as Map<String, dynamic>)
            : Checks.empty(),
        country: json['country']?.toString() ?? '',
        displayBrand: json['display_brand']?.toString() ?? '',
        expMonth: _asInt(json['exp_month']),
        expYear: _asInt(json['exp_year']),
        fingerprint: json['fingerprint']?.toString() ?? '',
        funding: json['funding']?.toString() ?? '',
        generatedFrom: json['generated_from'],
        last4: json['last4']?.toString() ?? '',
        networks: json['networks'] is Map<String, dynamic>
            ? Networks.fromJson(json['networks'] as Map<String, dynamic>)
            : Networks.empty(),
        regulatedStatus: json['regulated_status']?.toString() ?? '',
        threeDSecureUsage: json['three_d_secure_usage'] is Map<String, dynamic>
            ? ThreeDSecureUsage.fromJson(
                json['three_d_secure_usage'] as Map<String, dynamic>,
              )
            : ThreeDSecureUsage(supported: false),
        wallet: json['wallet'],
      );

  Map<String, dynamic> toJson() => {
        'brand': brand,
        'checks': checks.toJson(),
        'country': country,
        'display_brand': displayBrand,
        'exp_month': expMonth,
        'exp_year': expYear,
        'fingerprint': fingerprint,
        'funding': funding,
        'generated_from': generatedFrom,
        'last4': last4,
        'networks': networks.toJson(),
        'regulated_status': regulatedStatus,
        'three_d_secure_usage': threeDSecureUsage.toJson(),
        'wallet': wallet,
      };
}

class Checks {
  dynamic addressLine1Check;
  dynamic addressPostalCodeCheck;
  String cvcCheck;

  Checks({
    required this.addressLine1Check,
    required this.addressPostalCodeCheck,
    required this.cvcCheck,
  });

  factory Checks.empty() => Checks(
        addressLine1Check: null,
        addressPostalCodeCheck: null,
        cvcCheck: '',
      );

  factory Checks.fromJson(Map<String, dynamic> json) => Checks(
        addressLine1Check: json['address_line1_check'],
        addressPostalCodeCheck: json['address_postal_code_check'],
        cvcCheck: json['cvc_check']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'address_line1_check': addressLine1Check,
        'address_postal_code_check': addressPostalCodeCheck,
        'cvc_check': cvcCheck,
      };
}

class Networks {
  List<String> available;
  dynamic preferred;

  Networks({
    required this.available,
    required this.preferred,
  });

  factory Networks.empty() => Networks(available: [], preferred: null);

  factory Networks.fromJson(Map<String, dynamic> json) {
    final raw = json['available'];
    return Networks(
      available: raw is List
          ? List<String>.from(raw.map((x) => x.toString()))
          : const [],
      preferred: json['preferred'],
    );
  }

  Map<String, dynamic> toJson() => {
        'available': List<dynamic>.from(available.map((x) => x)),
        'preferred': preferred,
      };
}

class ThreeDSecureUsage {
  bool supported;

  ThreeDSecureUsage({
    required this.supported,
  });

  factory ThreeDSecureUsage.fromJson(Map<String, dynamic> json) =>
      ThreeDSecureUsage(
        supported: json['supported'] == true || json['supported'] == 1,
      );

  Map<String, dynamic> toJson() => {
        'supported': supported,
      };
}

int _asInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is double) return v.round();
  return int.tryParse(v.toString()) ?? 0;
}
