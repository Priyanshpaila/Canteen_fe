import 'dart:convert';
import 'package:canteen_fe/core/constants/api_endpoints.dart';
import 'package:http/http.dart' as http;


class AuthService {
  Future<Map<String, dynamic>> login(String phone, String pin) async {
    final response = await http.post(
      Uri.parse(loginUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phoneNumber': phone, 'pin': pin}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Login failed');
    }
  }

  Future<Map<String, dynamic>> signup({
    required String phoneNumber,
    required String pin,
    required String empid,
    required String fullName,
    required String division,
    required String department,
    required String designation,
  }) async {
    final response = await http.post(
      Uri.parse(signupUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phoneNumber': phoneNumber,
        'pin': pin,
        'empid': empid,
        'fullName': fullName,
        'division': division,
        'department': department,
        'designation': designation,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Signup failed');
    }
  }
}
