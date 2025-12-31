import 'package:magic_enlish/data/models/auth/ResponseLogin.dart';
import 'package:magic_enlish/data/models/auth/ResponseRegister.dart';
import 'package:magic_enlish/data/services/auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository({AuthService? authService})
    : _authService = authService ?? AuthService();

  /// Login user with email and password
  /// Returns ResponseLogin with user data and token
  /// Throws Exception if login fails
  Future<ResponseLogin> login(String email, String password) async {
    try {
      final response = await _authService.login(email, password);

      if (response.statusCode == 200 && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Login error: ${e.toString()}');
    }
  }

  /// Register new user
  /// Returns ResponseRegister with user data
  /// Throws Exception if registration fails
  Future<ResponseRegister> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await _authService.register(name, email, password);

      if (response.statusCode == 201 && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Registration error: ${e.toString()}');
    }
  }

  /// Logout user
  /// Throws Exception if logout fails
  Future<void> logout(String token) async {
    try {
      final response = await _authService.logout(token);

      if (response.statusCode != 200) {
        throw Exception(response.message ?? 'Logout failed');
      }
    } catch (e) {
      throw Exception('Logout error: ${e.toString()}');
    }
  }
}
