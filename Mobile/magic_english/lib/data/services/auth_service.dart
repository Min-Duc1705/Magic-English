import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:magic_enlish/data/models/BackendResponse.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:magic_enlish/data/models/auth/ResponseLogin.dart';
import 'package:magic_enlish/data/models/auth/ResponseRegister.dart';

class AuthService {
  Future<BackendResponse<ResponseLogin>> login(
    String email,
    String password,
  ) async {
    final String url = dotenv.env['Backend_URL'] ?? '';
    final response = await http.post(
      Uri.parse('$url/api/v1/auth/login'),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final jsonData = jsonDecode(response.body);

    return BackendResponse<ResponseLogin>.fromJson(
      jsonData,
      (data) => ResponseLogin.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<BackendResponse<ResponseRegister>> register(
    String name,
    String email,
    String password,
  ) async {
    final String url = dotenv.env['Backend_URL'] ?? '';
    final response = await http.post(
      Uri.parse('$url/api/v1/auth/register'),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    final jsonData = jsonDecode(response.body);

    return BackendResponse<ResponseRegister>.fromJson(
      jsonData,
      (data) => ResponseRegister.fromJson(data as Map<String, dynamic>),
    );
  }
  Future<BackendResponse<void>> logout(String token) async {
    final String url = dotenv.env['Backend_URL'] ?? '';
    final response = await http.post(
      Uri.parse('$url/api/v1/auth/logout'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final jsonData = jsonDecode(response.body);

    return BackendResponse<void>.fromJson(
      jsonData,
      (data) {},
    );
  }
}
