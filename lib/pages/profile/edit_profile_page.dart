import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';

class EditProfilePage extends StatefulWidget {
  final UserModel user;

  const EditProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _email;
  File? _imageFile;
  final picker = ImagePicker();
  bool _isSaving = false;
  bool _hasChanges = false;

  // Variabel untuk menyimpan data user terbaru, penting untuk dikirim kembali
  late UserModel _updatedUser;

  @override
  void initState() {
    super.initState();
    _name = widget.user.name ?? '';
    _email = widget.user.email ?? '';
    // Inisialisasi _updatedUser dengan data awal
    _updatedUser = widget.user;
  }

  Future<void> _pickImage() async {
    if (_isSaving) return; // Mencegah aksi saat menyimpan

    try {
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 80,
      );
      if (picked != null) {
        setState(() {
          _imageFile = File(picked.path);
          _hasChanges = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memilih gambar')),
        );
      }
    }
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  // == FUNGSI INI DIPERBAIKI SECARA KRUSIAL ==
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final userToUpdate = widget.user.copyWith(
        name: _name.trim(),
        email: _email.trim(),
      );

      final success =
          await AuthService.updateUser(userToUpdate, imageFile: _imageFile);

      if (!mounted) return;

      if (success) {
        final refreshedUser = await AuthService.getUserById(widget.user.id!);

        if (mounted) {
          _updatedUser = refreshedUser ?? userToUpdate;
          _hasChanges = false;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil berhasil diperbarui'),
              backgroundColor: Colors.green,
            ),
          );

          // FIX UTAMA: Beri jeda sesaat sebelum pop untuk menghindari konflik UI
          // yang menyebabkan Navigator terkunci.
          await Future.delayed(const Duration(milliseconds: 100));

          if (mounted) {
            Navigator.pop(context, _updatedUser);
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan perubahan'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  // == LOGIKA KEMBALI YANG BARU & AMAN ==
  Future<bool> _onWillPop() async {
    // 1. Cegah kembali jika sedang menyimpan
    if (_isSaving) return false;

    // 2. Jika ada perubahan, tampilkan dialog
    if (_hasChanges) {
      final shouldPop = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Perubahan Belum Disimpan'),
          content: const Text(
              'Apakah Anda yakin ingin keluar tanpa menyimpan perubahan?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Keluar'),
            ),
          ],
        ),
      );

      // Jika user memilih 'Keluar', pop secara manual dengan data yang benar lalu cegah pop default
      if (shouldPop == true) {
        Navigator.pop(context, _updatedUser);
        return false;
      }

      // Jika user memilih 'Batal' atau menutup dialog, cegah pop
      return false;
    }

    // 3. Jika tidak ada perubahan, lakukan pop secara manual dan cegah pop default
    Navigator.pop(context, _updatedUser);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    // WillPopScope sekarang menjadi satu-satunya sumber kebenaran untuk aksi kembali
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profil'),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            // Nonaktifkan saat menyimpan
            // Aksi onPressed hanya perlu memanggil pop(), WillPopScope akan menangani sisanya.
            onPressed: _isSaving ? null : () => Navigator.pop(context),
          ),
        ),
        body: _isSaving
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Menyimpan perubahan...'),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 6,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey.shade200,
                                backgroundImage: _imageFile != null
                                    ? FileImage(_imageFile!)
                                    : (widget.user.photo != null &&
                                            widget.user.photo!.isNotEmpty)
                                        ? NetworkImage(widget.user.photo!)
                                        : null,
                                child: _imageFile == null &&
                                        (widget.user.photo == null ||
                                            widget.user.photo!.isEmpty)
                                    ? const Icon(Icons.person,
                                        size: 50, color: Colors.grey)
                                    : null,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Tooltip(
                                message: 'Ubah foto',
                                child: InkWell(
                                  onTap: _pickImage,
                                  borderRadius: BorderRadius.circular(18),
                                  child: CircleAvatar(
                                    radius: 18,
                                    backgroundColor: primaryColor,
                                    child: const Icon(Icons.edit,
                                        color: Colors.white, size: 18),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        initialValue: _name,
                        decoration: InputDecoration(
                          labelText: 'Nama',
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        onChanged: (val) {
                          _name = val;
                          _onFieldChanged();
                        },
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Nama wajib diisi';
                          }
                          if (val.trim().length < 2) {
                            return 'Nama minimal 2 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: _email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.email_outlined),
                        ),
                        onChanged: (val) {
                          _email = val;
                          _onFieldChanged();
                        },
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Email wajib diisi';
                          } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                              .hasMatch(val.trim())) {
                            return 'Format email tidak valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text('Simpan Perubahan'),
                        onPressed:
                            _hasChanges && !_isSaving ? _saveProfile : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _hasChanges ? primaryColor : Colors.grey,
                          foregroundColor: Colors.white,
                          elevation: _hasChanges ? 2 : 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
                      if (_hasChanges) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Ada perubahan yang belum disimpan',
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
