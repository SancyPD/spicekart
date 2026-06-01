class Address {
  String a;
  Address({required this.a});
  factory Address.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Address(a: "null");
    return Address(a: json["a"]);
  }
}

void main() {
  Map<String, dynamic> json = {};
  Address add = Address.fromJson(json["address"]);
  print(add.a);
}
