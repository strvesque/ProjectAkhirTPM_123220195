import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/reservasi_model.dart';
import '../../models/tipe_treatment_model.dart';
import '../../services/reservasi_service.dart';
import '../../services/tipe_treatment_service.dart';

class RiwayatReservasiPage extends StatefulWidget {
  const RiwayatReservasiPage({Key? key}) : super(key: key);

  @override
  State<RiwayatReservasiPage> createState() => _RiwayatReservasiPageState();
}

class _RiwayatReservasiPageState extends State<RiwayatReservasiPage> {
  bool _isLoading = true;
  List<ReservasiModel> _allReservasi = [];
  List<TipeTreatmentModel> _allTipe = [];
  String? _errorMessage;

  final Color _cardColor = Colors.white;
  final Color _textColor = Colors.black87;
  final Color _highlightColor = Color(0xFFFFC1CC); // Soft pink

  @override
  void initState() {
    super.initState();
    _fetchDataReserva();
  }

  Future<void> _fetchDataReserva() async {
    try {
      final tipeList = await TipeTreatmentService().getAllTipeTreatment();
      final reservasiList = await ReservasiService().getAllReservasi();

      setState(() {
        _allTipe = tipeList;
        _allReservasi = reservasiList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data: $e';
        _isLoading = false;
      });
    }
  }

  String _namaTipeById(int id) {
    try {
      return _allTipe.firstWhere((t) => t.idTipeTreatment == id).namaTipe;
    } catch (_) {
      return '-';
    }
  }

  String _formatDate(DateTime date) {
    final yyyy = date.year.toString().padLeft(4, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '$yyyy-$mm-$dd';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Reservasi'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text(
                    _errorMessage!,
                    style: GoogleFonts.quicksand(color: _textColor),
                  ),
                )
              : _allReservasi.isEmpty
                  ? Center(
                      child: Text(
                        'Belum ada reservasi.',
                        style: GoogleFonts.quicksand(
                          fontSize: 16,
                          color: _textColor,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      itemCount: _allReservasi.length,
                      itemBuilder: (context, index) {
                        final reservasi = _allReservasi[index];

                        return Card(
                          color: _cardColor,
                          elevation: 3,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  reservasi.namaPelanggan,
                                  style: GoogleFonts.quicksand(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: _highlightColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _infoText('Tanggal', _formatDate(reservasi.tanggal)),
                                _infoText('Jam', reservasi.jam),
                                _infoText('Tipe', _namaTipeById(reservasi.idTipeTreatment)),
                                _infoText('Status', reservasi.status ?? '-'),
                                if (reservasi.catatan != null && reservasi.catatan!.isNotEmpty)
                                  _infoText('Catatan', reservasi.catatan!),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }

  Widget _infoText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        '$label: $value',
        style: GoogleFonts.quicksand(
          fontSize: 14,
          color: _textColor,
        ),
      ),
    );
  }
}