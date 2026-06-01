import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('https://spicekart1.mockupz.in/api/listAllZipcodesWithZones');
  final response = await http.post(url);
  print(response.statusCode);
  print(response.body.substring(0, 200));
}
