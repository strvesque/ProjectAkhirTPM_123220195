import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/produk_model.dart';
import 'api_config.dart';

class ProdukService {
  final String baseUrl = '${ApiConfig.baseUrl}/produk';

  Future<List<ProdukModel>> getAllProduk() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List jsonData = jsonDecode(response.body);
      return jsonData.map((e) => ProdukModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil data produk');
    }
  }

  Future<bool> createProduk(ProdukModel produk) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(produk.toJson()),
    );

    return response.statusCode == 201 || response.statusCode == 200;
  }

  Future<bool> updateProduk(ProdukModel produk) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${produk.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(produk.toJson()),
    );

    return response.statusCode == 200;
  }

  Future<bool> deleteProduk(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    return response.statusCode == 200;
  }

  Future<ProdukModel> getProdukById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      return ProdukModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Produk tidak ditemukan');
    }
  }
}
