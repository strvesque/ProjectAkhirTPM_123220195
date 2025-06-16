// File: lib/models/reservasi_model.dart

class ReservasiModel {
  final int? idReservasi;       // id_reservasi (nullable saat membuat baru)
  final String namaPelanggan;   // nama_pelanggan
  final String? noHp;           // no_hp
  final DateTime tanggal;       // tanggal_reservasi
  final String jam;             // jam_reservasi (format "HH:mm:ss" atau "HH:mm")
  final int idTipeTreatment;    // id_tipe_treatment (FK)
  final String? catatan;        // catatan
  final String? status;         // status, misal "menunggu", "dikonfirmasi", dst.

  ReservasiModel({
    this.idReservasi,
    required this.namaPelanggan,
    this.noHp,
    required this.tanggal,
    required this.jam,
    required this.idTipeTreatment,
    this.catatan,
    this.status,
  });

  factory ReservasiModel.fromJson(Map<String, dynamic> json) {
    return ReservasiModel(
      idReservasi: json['id_reservasi'] as int?,
      namaPelanggan: json['nama_pelanggan'] as String,
      noHp: json.containsKey('no_hp') ? json['no_hp'] as String : null,
      tanggal: DateTime.parse(json['tanggal_reservasi'] as String),
      jam: json['jam_reservasi'] as String,
      idTipeTreatment: json['id_tipe_treatment'] as int,
      catatan: json.containsKey('catatan') ? json['catatan'] as String : null,
      status: json.containsKey('status') ? json['status'] as String : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idReservasi != null) 'id_reservasi': idReservasi,
      'nama_pelanggan': namaPelanggan,
      'no_hp': noHp,
      'tanggal_reservasi': tanggal.toIso8601String().split('T')[0],
      'jam_reservasi': jam,
      'id_tipe_treatment': idTipeTreatment,
      'catatan': catatan,
      'status': status,
    };
  }
}
