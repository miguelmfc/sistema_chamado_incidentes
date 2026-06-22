import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class AuthService {
  final String baseUrl = 'http://localhost:5000/api';

  Future<User> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return User.fromJson(data['data']);
    }
    throw Exception(data['error'] ?? 'Erro ao fazer login');
  }

  Future<User> register(String name, String email,
      String password, String role) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      }),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return User.fromJson(data['data']);
    }
    throw Exception(data['error'] ?? 'Erro ao cadastrar');
  }
}