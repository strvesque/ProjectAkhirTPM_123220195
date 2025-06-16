import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/transaksi_model.dart';
import '../../services/transaksi_service.dart';

class RiwayatTransaksiPage extends StatefulWidget {
  const RiwayatTransaksiPage({Key? key}) : super(key: key);

  @override
  State<RiwayatTransaksiPage> createState() => _RiwayatTransaksiPageState();
}

class _RiwayatTransaksiPageState extends State<RiwayatTransaksiPage> {
  late Future<List<TransaksiModel>> _futureTransaksi;

  final Color _cardColor = Colors.white;
  final Color _textColor = Colors.black87;
  final Color _highlightColor = Color(0xFFFFC1CC); // Soft pink

  @override
  void initState() {
    super.initState();
    _futureTransaksi = getUserTransaksi();
  }

  Future<List<TransaksiModel>> getUserTransaksi() async {
    final prefs = await SharedPreferences.getInstance();
    final namaPembeli = prefs.getString('username') ?? '';
    if (namaPembeli.isEmpty) throw Exception('Nama pembeli tidak ditemukan');

    return await TransaksiService().getTransaksiByUser(namaPembeli);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        backgroundColor: _highlightColor,
      ),
      body: FutureBuilder<List<TransaksiModel>>(
        future: _futureTransaksi,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: GoogleFonts.quicksand(color: _textColor),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'Belum ada transaksi.',
                style: GoogleFonts.quicksand(fontSize: 16, color: _textColor),
              ),
            );
          }

          final transaksiList = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            itemCount: transaksiList.length,
            itemBuilder: (context, index) {
              final transaksi = transaksiList[index];
              final total = transaksi.totalSemua ?? transaksi.totalCalculated;

              return Card(
                color: _cardColor,
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(
                    'Tanggal: ${DateFormat("d MMMM y", "id_ID").format(DateTime.parse(transaksi.tanggal))}',
                    style: GoogleFonts.quicksand(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: _highlightColor,
                    ),
                  ),
                  subtitle: Text(
                    'Nama: ${transaksi.namaPembeli} • Total: Rp ${NumberFormat("#,##0", "id_ID").format(total)}',
                    style: GoogleFonts.quicksand(color: _textColor),
                  ),
                  children: [
                    const Divider(),
                    ...transaksi.items.map((detail) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Produk ID: ${detail.idProduk} × ${detail.jumlah}',
                                style: GoogleFonts.quicksand(fontSize: 14, color: _textColor),
                              ),
                              Text(
                                'Harga satuan: Rp ${detail.hargaSatuan.toStringAsFixed(0)}\nSubtotal: Rp ${detail.totalHarga.toStringAsFixed(0)}',
                                style: GoogleFonts.quicksand(fontSize: 13, color: _textColor),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}