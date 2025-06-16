// File: lib/models/tipe_treatment_model.dart

class TipeTreatmentModel {
  final int idTipeTreatment;    // id_tipe_treatment
  final String? kodeTreatment;  // kode_treatment
  final String namaTipe;        // nama_tipe
  final int harga;              // harga
  final String? deskripsi;      // deskripsi

  TipeTreatmentModel({
    required this.idTipeTreatment,
    this.kodeTreatment,
    required this.namaTipe,
    required this.harga,
    this.deskripsi,
  });

  factory TipeTreatmentModel.fromJson(Map<String, dynamic> json) {
    return TipeTreatmentModel(
      idTipeTreatment: json['id_tipe_treatment'] as int,
      kodeTreatment:
          json.containsKey('kode_treatment') ? json['kode_treatment'] as String : null,
      namaTipe: json['nama_tipe'] as String,
      harga: json['harga'] as int,
      deskripsi: json.containsKey('deskripsi') ? json['deskripsi'] as String : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_tipe_treatment': idTipeTreatment,
      'kode_treatment': kodeTreatment,
      'nama_tipe': namaTipe,
      'harga': harga,
      'deskripsi': deskripsi,
    };
  }
}
