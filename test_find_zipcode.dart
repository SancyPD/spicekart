import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('https://spicekart1.mockupz.in/api/findValidZipCode');
  final response = await http.post(
    url,
    body: jsonEncode({'zip_code': '77477'}),
    headers: {'Content-Type': 'application/json'},
  );
  print(response.statusCode);
  print(response.body);

  final responseInvalid = await http.post(
    url,
    body: jsonEncode({'zip_code': '00000'}),
    headers: {'Content-Type': 'application/json'},
  );
  print(responseInvalid.statusCode);
  print(responseInvalid.body);
}
