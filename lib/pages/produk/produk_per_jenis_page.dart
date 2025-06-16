import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/produk_model.dart';
import 'detail_produk_page.dart';

class ProdukPerJenisPage extends StatelessWidget {
  final String jenis;
  final List<ProdukModel> produkList;

  const ProdukPerJenisPage({
    super.key,
    required this.jenis,
    required this.produkList,
  });

  String _formatHarga(double? harga) {
    if (harga == null) return "Rp 0";
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(harga);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jenis: $jenis'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: produkList.length,
        itemBuilder: (context, index) {
          final produk = produkList[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 3,
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  produk.gambar ?? '',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                ),
              ),
              title: Text(
                produk.nama ?? '-',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(_formatHarga(produk.harga)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailProdukPage(produk: produk),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}