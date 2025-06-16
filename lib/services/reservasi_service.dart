// File: lib/services/reservasi_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import './api_config.dart';
import '../models/reservasi_model.dart';

class ReservasiService {
  Future<bool> createReservasi(ReservasiModel reservasi) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/reservasi');
    final body = jsonEncode(reservasi.toJson());

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      print('Gagal simpan reservasi: ${response.statusCode} / ${response.body}');
      return false;
    }
  }

  Future<List<ReservasiModel>> getAllReservasi() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/reservasi');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> dataJson = jsonDecode(response.body);
      return dataJson
          .map((e) => ReservasiModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Gagal memuat reservasi: ${response.statusCode}');
    }
  }

  /// (Opsional) Mengambil reservasi milik pengguna tertentu (GET /reservasi?nama_pelanggan=...)
  Future<List<ReservasiModel>> getReservasiByNama(String nama) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/reservasi?nama_pelanggan=$nama');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> dataJson = jsonDecode(response.body);
      return dataJson
          .map((e) => ReservasiModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
          'Gagal memuat reservasi untuk $nama: ${response.statusCode}');
    }
  }
}
