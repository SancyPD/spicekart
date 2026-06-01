import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('https://spicekart1.mockupz.in/api/getProfile');
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer 506|6uJVbn6g5jjXA2R1WmIzn334gYsjdi2NqAK0Lsrm6a95cd08',
    },
  );
  print('Status: ${response.statusCode}');
  print('Body: ${response.body}');
}
