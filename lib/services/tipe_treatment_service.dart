import 'dart:convert';
import 'package:http/http.dart' as http;
import './api_config.dart';
import '../models/tipe_treatment_model.dart';

class TipeTreatmentService {
  Future<List<TipeTreatmentModel>> getAllTipeTreatment() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/tipe_treatment');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> dataJson = jsonDecode(response.body);
      return dataJson
          .map((e) => TipeTreatmentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Gagal memuat tipe treatment: ${response.statusCode}');
    }
  }

  /// (Opsional) Mengambil satu tipe treatment berdasarkan id
  Future<TipeTreatmentModel> getTipeTreatmentById(int id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/tipe_treatment/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      return TipeTreatmentModel.fromJson(json);
    } else {
      throw Exception(
          'Gagal memuat tipe treatment dengan id $id: ${response.statusCode}');
    }
  }
}
