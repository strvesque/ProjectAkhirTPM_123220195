import 'dart:convert';

class DetailTransaksiModel {
  final int idDetail;
  final int idTransaksi;
  final int idProduk;
  final int jumlah;
  final double hargaSatuan;
  final double totalHarga;

  DetailTransaksiModel({
    required this.idDetail,
    required this.idTransaksi,
    required this.idProduk,
    required this.jumlah,
    required this.hargaSatuan,
    required this.totalHarga,
  });

  factory DetailTransaksiModel.fromJson(Map<String, dynamic> json) {
    return DetailTransaksiModel(
      idDetail: json['id_detail'] as int,
      idTransaksi: json['id_transaksi'] as int,
      idProduk: json['id_produk'] as int,
      jumlah: json['jumlah'] as int,
      hargaSatuan: double.parse(json['harga_satuan'].toString()),
      totalHarga: double.parse(json['total_harga'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id_detail": idDetail,
      "id_transaksi": idTransaksi,
      "id_produk": idProduk,
      "jumlah": jumlah,
      "harga_satuan": hargaSatuan,
      // total_harga dihitung di DB, tapi bila diperlukan:
      "total_harga": totalHarga,
    };
  }
}

/// Model untuk representasi header transaksi
class TransaksiModel {
  final int idTransaksi; // id_transaksi (dari DB)
  final String namaPembeli; // nama_pembeli
  final String? alamatPembeli; // alamat_pembeli
  final String? noHp; // no_hp
  final String tanggal; // tanggal (format: "YYYY-MM-DD")
  final double?
      totalSemua; // total_semua (GENERATED dari DB, bisa null jika belum di‐generate)
  final List<DetailTransaksiModel> items; // list detail transaksi

  TransaksiModel({
    required this.idTransaksi,
    required this.namaPembeli,
    this.alamatPembeli,
    this.noHp,
    required this.tanggal,
    this.totalSemua,
    required this.items,
  });

  /// Parse dari JSON (dengan properti "items" yang berisi array objek detail_transaksi)
  factory TransaksiModel.fromJson(Map<String, dynamic> json) {
    var itemsJson = json['items'] as List<dynamic>? ?? [];
    List<DetailTransaksiModel> listItems = itemsJson
        .map((e) => DetailTransaksiModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return TransaksiModel(
      idTransaksi: json['id_transaksi'] as int,
      namaPembeli: json['nama_pembeli'] as String,
      alamatPembeli: json['alamat_pembeli'] as String?,
      noHp: json['no_hp'] as String?,
      tanggal: json['tanggal'] as String,
      totalSemua: json['total_semua'] != null
          ? (json['total_semua'] as num).toDouble()
          : null,
      items: listItems,
    );
  }

  /// Men‐generate JSON untuk dikirim ke server (tanpa `id_transaksi` dan `total_semua`):
  Map<String, dynamic> toJson() {
    return {
      "nama_pembeli": namaPembeli,
      "alamat_pembeli": alamatPembeli,
      "no_hp": noHp,
      "tanggal": tanggal,
      "items": items.map((dt) {
        return {
          "id_produk": dt.idProduk,
          "jumlah": dt.jumlah,
          "harga_satuan": dt.hargaSatuan
        };
      }).toList(),
    };
  }

  /// Utility untuk memudahkan menampilkan total harga (jika ingin menghitung di sisi aplikasi)
  double get totalCalculated {
    return items.fold<double>(
      0.0,
      (prev, dt) => prev + (dt.jumlah * dt.hargaSatuan),
    );
  }
}

List<TransaksiModel> parseTransaksiList(List<dynamic> jsonList) {
  final Map<int, TransaksiModel> transaksiMap = {};

  for (var item in jsonList) {
    final int idTransaksi = item['id_transaksi'];

    if (!transaksiMap.containsKey(idTransaksi)) {
      transaksiMap[idTransaksi] = TransaksiModel(
        idTransaksi: idTransaksi,
        namaPembeli: item['nama_pembeli'],
        alamatPembeli: item['alamat_pembeli'],
        noHp: item['no_hp'],
        tanggal: item['tanggal'],
        totalSemua: item['total_semua'] != null
            ? double.tryParse(item['total_semua'].toString()) ?? 0.0
            : null,
        items: [],
      );
    }

    if (item['id_detail'] != null &&
        item['id_produk'] != null &&
        item['jumlah'] != null &&
        item['harga_satuan'] != null) {
      transaksiMap[idTransaksi]?.items.add(
            DetailTransaksiModel(
              idDetail: item['id_detail'],
              idTransaksi: idTransaksi,
              idProduk: item['id_produk'],
              jumlah: item['jumlah'],
              hargaSatuan: double.parse(item['harga_satuan'].toString()),
              totalHarga: item['total_harga'] != null
                  ? double.parse(item['total_harga'].toString())
                  : (item['jumlah'] *
                      double.parse(item['harga_satuan'].toString())),
            ),
          );
    }
  }

  return transaksiMap.values.toList();
}
