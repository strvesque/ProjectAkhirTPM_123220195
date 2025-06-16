class ProdukModel {
  final int? id;
  final String? nama;
  final String? jenis;
  final double? harga;
  final String? deskripsi;
  final String? gambar;

  ProdukModel({
    this.id,
    this.nama,
    this.jenis,
    this.harga,
    this.deskripsi,
    this.gambar,
  });

  factory ProdukModel.fromJson(Map<String, dynamic> json) {
    return ProdukModel(
      id: json['id'],
      nama: json['nama'],
      jenis: json['jenis'],
      harga: json['harga'] != null ? double.tryParse(json['harga'].toString()) : null,
      deskripsi: json['deskripsi'],
      gambar: json['gambar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'jenis': jenis,
      'harga': harga,
      'deskripsi': deskripsi,
      'gambar': gambar,
    };
  }
}