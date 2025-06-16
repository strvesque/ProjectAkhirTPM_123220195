// File: lib/pages/reservasi/reservasi_form_page.dart

import 'package:flutter/material.dart';
import '../../models/tipe_treatment_model.dart';
import '../../models/reservasi_model.dart';
import '../../services/tipe_treatment_service.dart';
import '../../services/reservasi_service.dart';
import 'package:intl/intl.dart';
import '../../utils/notification_helper.dart';
import 'package:google_fonts/google_fonts.dart';

class ReservasiFormPage extends StatefulWidget {
  const ReservasiFormPage({Key? key}) : super(key: key);

  @override
  State<ReservasiFormPage> createState() => _ReservasiFormPageState();
}

class _ReservasiFormPageState extends State<ReservasiFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _noHpController = TextEditingController();
  final _catatanController = TextEditingController();

  List<TipeTreatmentModel> _allTipe = [];
  int? _selectedTipeId;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  // --- PERUBAHAN --- Tambahkan London sebagai opsi zona waktu
  String _selectedZona = 'WIB';

  bool _isLoadingTipe = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchTipeTreatment();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _noHpController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _fetchTipeTreatment() async {
    try {
      final data = await TipeTreatmentService().getAllTipeTreatment();
      setState(() {
        _allTipe = data;
        _isLoadingTipe = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingTipe = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat tipe treatment: $e')),
        );
      }
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: now,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Pilih Tanggal';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // --- PERUBAHAN ---
  // Memisahkan fungsi format untuk tampilan di tombol (lebih singkat)
  // dan untuk data yang dikirim (lebih lengkap)

  /// Format waktu untuk ditampilkan di UI (HH:mm)
  String _formatDisplayTime(TimeOfDay? time) {
    if (time == null) return 'Pilih Jam';
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('HH:mm').format(dt);
  }

  /// Konversi dan format waktu untuk dikirim ke server (HH:mm:ss)
  String _formatSubmitTime(TimeOfDay? time, String zona) {
    if (time == null) return '';

    int offset = 0; // Offset dari WIB
    if (zona == 'WITA') offset = 1;
    if (zona == 'WIT') offset = 2;
    // London (BST/UTC+1) 6 jam di belakang WIB (UTC+7)
    if (zona == 'London') offset = -6;

    final now = DateTime.now();
    // Buat waktu awal berdasarkan jam yang dipilih (dianggap sebagai WIB)
    final initialDateTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);
    // Terapkan offset untuk mendapatkan waktu yang dikonversi
    final adjustedDateTime = initialDateTime.add(Duration(hours: offset));

    return DateFormat('HH:mm:ss').format(adjustedDateTime);
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal reservasi belum dipilih')),
      );
      return;
    }
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jam reservasi belum dipilih')),
      );
      return;
    }
    if (_selectedTipeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tipe treatment belum dipilih')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final reservasi = ReservasiModel(
      namaPelanggan: _namaController.text.trim(),
      noHp: _noHpController.text.trim(),
      tanggal: _selectedDate!,
      jam: _formatSubmitTime(
          _selectedTime, _selectedZona), // Gunakan format lengkap untuk submit
      idTipeTreatment: _selectedTipeId!,
      catatan: _catatanController.text.trim().isEmpty
          ? null
          : _catatanController.text.trim(),
      status: 'menunggu',
    );

    final success = await ReservasiService().createReservasi(reservasi);

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      await NotificationHelper.showNotification(
        title: 'Reservasi Berhasil',
        body: 'Kami tunggu kedatangan anda!',
      );
      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Sukses'),
            content: const Text('Reservasi berhasil dibuat!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
            ],
          ),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal membuat reservasi')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Form Reservasi',
            style: Theme.of(context).textTheme.titleLarge),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoadingTipe
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _namaController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Pelanggan',
                      ),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                              ? 'Nama wajib diisi'
                              : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _noHpController,
                      decoration: const InputDecoration(
                        labelText: 'No. HP',
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nomor HP wajib diisi';
                        } else if (value.trim().length < 10) {
                          return 'Nomor HP tidak valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    // --- PERBAIKAN OVERFLOW ---
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _pickDate,
                            child: Text(_formatDate(_selectedDate)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _pickTime,
                            child: Text(_formatDisplayTime(_selectedTime)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // --- PERUBAHAN: TAMBAH LONDON ---
                    DropdownButtonFormField<String>(
                      value: _selectedZona,
                      decoration: const InputDecoration(
                        labelText: 'Zona Waktu Tujuan',
                      ),
                      items: ['WIB', 'WITA', 'WIT', 'London'].map((zona) {
                        // Tambah London di sini
                        return DropdownMenuItem<String>(
                          value: zona,
                          child: Text(zona),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedZona = val!;
                        });
                      },
                    ),
                    if (_selectedDate != null && _selectedTime != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tanggal: ${_formatDate(_selectedDate)}'),
                            // Tampilkan hasil konversi
                            Text(
                                'Waktu Terkonversi ($_selectedZona): ${_formatSubmitTime(_selectedTime, _selectedZona)}'),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: _selectedTipeId,
                      decoration: const InputDecoration(
                        labelText: 'Pilih Tipe Treatment',
                      ),
                      isExpanded: true,
                      items: _allTipe.map((t) {
                        return DropdownMenuItem<int>(
                          value: t.idTipeTreatment,
                          child: Text(
                            '${t.namaTipe} (Rp ${t.harga})',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedTipeId = val;
                        });
                      },
                      validator: (val) =>
                          val == null ? 'Pilih tipe treatment' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _catatanController,
                      decoration: const InputDecoration(
                        labelText: 'Catatan',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Reservasi Sekarang',
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
