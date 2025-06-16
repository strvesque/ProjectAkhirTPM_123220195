// File: lib/pages/pembelian/pembelian_form_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/produk_model.dart';
import '../../models/transaksi_model.dart';
import '../../services/transaksi_service.dart';
import '../../services/produk_service.dart';
import '../../utils/notification_helper.dart';
import 'package:google_fonts/google_fonts.dart';

class PembelianFormPage extends StatefulWidget {
  const PembelianFormPage({Key? key}) : super(key: key);

  @override
  State<PembelianFormPage> createState() => _PembelianFormPageState();
}

class _PembelianFormPageState extends State<PembelianFormPage> {
  final _formKey = GlobalKey<FormState>();
  final namaController = TextEditingController();
  final alamatController = TextEditingController();
  final noHpController = TextEditingController();

  List<ProdukModel> allProduk = [];
  List<Map<String, dynamic>> selectedProdukList = [];
  String selectedCurrency = 'IDR';

  Map<String, double> currencyRates = {
    'IDR': 1,
    'USD': 0.000066,
    'EUR': 0.000061,
    'JPY': 0.0104,
  };

  @override
  void initState() {
    super.initState();
    _loadProduk();
    _addProdukItem();
  }

  void _loadProduk() async {
    final data = await ProdukService().getAllProduk();
    if (mounted) {
      setState(() {
        allProduk = data;
      });
    }
  }

  void _addProdukItem() {
    setState(() {
      selectedProdukList.add({'id_produk': null, 'jumlah': ''});
    });
  }

  void _removeProdukItem(int index) {
    setState(() {
      selectedProdukList.removeAt(index);
    });
  }

  double _calculateTotal() {
    double total = 0;
    for (var item in selectedProdukList) {
      final produk = allProduk.firstWhere(
        (p) => p.id == item['id_produk'],
        orElse: () => ProdukModel(harga: 0),
      );
      final jumlah = int.tryParse(item['jumlah'] ?? '') ?? 0;
      total += jumlah * (produk.harga ?? 0);
    }
    return total;
  }

  double _calculateConvertedTotal() {
    double total = _calculateTotal();
    return total * (currencyRates[selectedCurrency] ?? 1);
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Pastikan tidak ada produk yang belum dipilih
    if (selectedProdukList.any((item) =>
        item['id_produk'] == null || (item['jumlah'] ?? '').isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Pastikan semua produk dan jumlah telah diisi.')),
      );
      return;
    }

    List<Map<String, dynamic>> items = selectedProdukList.map((item) {
      final produk = allProduk.firstWhere((p) => p.id == item['id_produk']);
      final jumlah = int.tryParse(item['jumlah'] ?? '') ?? 0;
      return {
        'id_produk': produk.id,
        'jumlah': jumlah,
        'harga_satuan': produk.harga,
      };
    }).toList();

    final success = await TransaksiService().createTransaksi(
      namaPembeli: namaController.text,
      alamatPembeli: alamatController.text,
      noHp: noHpController.text,
      tanggal: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      items: items,
    );

    if (mounted) {
      if (success) {
        await NotificationHelper.showNotification(
          title: 'Transaksi Berhasil',
          body: 'Terima kasih telah melakukan pembelian!',
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan transaksi')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Form Pembelian', style: textTheme.titleLarge),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: allProduk.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: namaController,
                      decoration:
                          const InputDecoration(labelText: 'Nama Pembeli'),
                      validator: (value) =>
                          value!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: alamatController,
                      decoration:
                          const InputDecoration(labelText: 'Alamat Pembeli'),
                      maxLines: 2,
                      validator: (value) =>
                          value!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: noHpController,
                      decoration: const InputDecoration(labelText: 'No. HP'),
                      keyboardType: TextInputType.phone,
                      validator: (value) =>
                          value!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Daftar Produk',
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...selectedProdukList.asMap().entries.map((entry) {
                      int index = entry.key;
                      var item = entry.value;
                      return Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  value: item['id_produk'],
                                  hint: const Text('Pilih Produk'),
                                  // --- PERBAIKAN 1: Tambahkan isExpanded ---
                                  // Membuat dropdown mengisi ruang yang tersedia secara horizontal.
                                  isExpanded: true,
                                  items: allProduk.map((p) {
                                    return DropdownMenuItem<int>(
                                      value: p.id,
                                      // --- PERBAIKAN 2: Atasi Teks Panjang ---
                                      // Mencegah nama produk yang panjang menyebabkan overflow.
                                      child: Text(
                                        p.nama ?? '',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      selectedProdukList[index]['id_produk'] =
                                          val;
                                    });
                                  },
                                  validator: (val) =>
                                      val == null ? 'Pilih produk' : null,
                                ),
                              ),
                              // IconButton tidak perlu diubah, posisinya sudah benar.
                              IconButton(
                                icon: const Icon(Icons.remove_circle,
                                    color: Colors.red),
                                onPressed: () => _removeProdukItem(index),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            // Gunakan controller untuk sinkronisasi nilai yang lebih baik
                            controller:
                                TextEditingController(text: item['jumlah']),
                            decoration:
                                const InputDecoration(labelText: 'Jumlah'),
                            keyboardType: TextInputType.number,
                            onChanged: (val) {
                              selectedProdukList[index]['jumlah'] = val;
                              // setState tidak diperlukan di sini jika hanya update data,
                              // tapi dibutuhkan untuk kalkulasi total.
                              setState(() {});
                            },
                            validator: (val) => (val == null || val.isEmpty)
                                ? 'Wajib diisi'
                                : null,
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    }).toList(),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _addProdukItem,
                        icon: const Icon(Icons.add),
                        label: const Text('Tambah Produk'),
                      ),
                    ),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Mata Uang:',
                            style: TextStyle(fontSize: 16)),
                        DropdownButton<String>(
                          value: selectedCurrency,
                          items: currencyRates.keys.map((code) {
                            return DropdownMenuItem(
                              value: code,
                              child: Text(code),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedCurrency = val!;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total: $selectedCurrency ${_calculateConvertedTotal().toStringAsFixed(2)}',
                      style: GoogleFonts.quicksand(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Submit',
                        style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
