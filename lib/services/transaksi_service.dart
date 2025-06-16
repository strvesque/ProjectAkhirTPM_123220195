// File: lib/services/transaksi_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaksi_model.dart';
import './api_config.dart'; // sesuaikan dengan path Anda

class TransaksiService {
  Future<List<TransaksiModel>> getTransaksiByUser(String namaPembeli) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/transaksi/user/$namaPembeli');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> dataJson = jsonDecode(response.body);
      return parseTransaksiList(dataJson); 
    } else {
      throw Exception(
          'Gagal mengambil transaksi pengguna: ${response.statusCode}');
    }
  }

  Future<bool> createTransaksi({
    required String namaPembeli,
    required String alamatPembeli,
    required String noHp,
    required String tanggal,
    required List<Map<String, dynamic>> items,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/transaksi');

    final body = jsonEncode({
      'nama_pembeli': namaPembeli,
      'alamat_pembeli': alamatPembeli,
      'no_hp': noHp,
      'tanggal': tanggal,
      'items': items,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('Gagal simpan transaksi: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error di createTransaksi: $e');
      return false;
    }
  }

  Future<List<TransaksiModel>> getAllTransaksi() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/transaksi');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> dataJson = jsonDecode(response.body);
      return dataJson
          .map((e) => TransaksiModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Gagal fetch transaksi: ${response.statusCode}');
    }
  }
}
