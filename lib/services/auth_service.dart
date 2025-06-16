import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl =
      'https://backend-project-akhir-102601587611.asia-southeast2.run.app';
  // static const String baseUrl = 'http://172.20.10.4:8080';
  static Future<UserModel?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final prefs = await SharedPreferences.getInstance();
      prefs.setInt('user_id', data['id']);
      prefs.setString('token', data['token']);
      prefs.setInt('user_id', data['id']);
      print('Saved user_id: ${data['id']}');

      return UserModel.fromJson(data);
    } else {
      return null;
    }
  }

  static Future<bool> register(UserModel user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toRegisterJson()),
    );

    return response.statusCode == 201;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('user_id');

    print('Retrieved user_id from SharedPreferences: $id');
    if (id != null) {
      return await getUserById(id);
    } else {
      return null;
    }
  }

  static Future<List<UserModel>> getAllUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/api/users'));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => UserModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil data user');
    }
  }

  static Future<UserModel?> getUserById(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$baseUrl/api/users/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  }

  static Future<bool> updateUser(UserModel user, {File? imageFile}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final uri = Uri.parse('$baseUrl/api/users/${user.id}');
    final request = http.MultipartRequest('PUT', uri)
      ..fields['name'] = user.name ?? ''
      ..fields['email'] = user.email ?? ''
      ..headers['Authorization'] =
          'Bearer $token'; // 🟢 Tambahkan token di header

    // Kirim password jika tidak kosong
    if (user.password != null && user.password!.isNotEmpty) {
      request.fields['password'] = user.password!;
    }

    // Kirim file jika ada
    if (imageFile != null) {
      request.files
          .add(await http.MultipartFile.fromPath('photo', imageFile.path));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print('Status Code: ${response.statusCode}');
    print('Body: ${response.body}');

    return response.statusCode == 200;
  }

  static Future<bool> deleteUser(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/api/users/$id'));

    return response.statusCode == 200;
  }
}
