import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:magic_enlish/data/models/BackendResponse.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:magic_enlish/data/models/user/ResponseUpdateUser.dart';

class UserService {

  Future<BackendResponse<ResponseUpdateUser>> updateUser(String token, int id,String name,String email,String? avatarUrl) async {
    final String url = dotenv.env['Backend_URL'] ?? '';
    final response = await http.put(
      Uri.parse('$url/api/v1/users'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'id': id,
        'name': name,
        'email': email,
        'avatarUrl': avatarUrl,
      }),
    );

    final jsonData = jsonDecode(response.body);

    return BackendResponse<ResponseUpdateUser>.fromJson(jsonData, (data) => ResponseUpdateUser.fromJson(data as Map<String, dynamic>));
  }
}
