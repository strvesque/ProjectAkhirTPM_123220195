import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    setState(() => _isLoading = true);
    try {
      final user = await AuthService.getCurrentUser();
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      await AuthService.logout();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  Future<void> _onLogout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    child: const Text('Login'),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Profil Card
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey.shade300,
                                backgroundImage: _user!.photo != null &&
                                        _user!.photo!.isNotEmpty
                                    ? NetworkImage(_user!.photo!)
                                    : null,
                                child: _user!.photo == null ||
                                        _user!.photo!.isEmpty
                                    ? Icon(Icons.person,
                                        size: 50,
                                        color: Colors.grey.shade700)
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _user!.name ?? '-',
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _user!.email ?? '-',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 12),
                              TextButton.icon(
                                onPressed: () async {
                                  final isUpdated = await Navigator.push<bool>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          EditProfilePage(user: _user!),
                                    ),
                                  );
                                  if (isUpdated == true && mounted) {
                                    _loadCurrentUser();
                                  }
                                },
                                icon: const Icon(Icons.edit),
                                label: const Text("Edit Profil"),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Tombol Navigasi Fitur
                      _buildFeatureButton(
                        icon: Icons.shopping_cart,
                        label: 'Riwayat Pembelian',
                        onTap: () =>
                            Navigator.pushNamed(context, '/pembelian/riwayat'),
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureButton(
                        icon: Icons.event_note,
                        label: 'Riwayat Reservasi',
                        onTap: () =>
                            Navigator.pushNamed(context, '/reservasi/riwayat'),
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureButton(
                        icon: Icons.message,
                        label: 'Kesan dan Pesan',
                        onTap: () =>
                            Navigator.pushNamed(context, '/kesan-pesan'),
                      ),

                      const Spacer(),

                      // Logout
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.logout, color: Colors.red),
                          label: const Text(
                            'Logout',
                            style: TextStyle(color: Colors.red),
                          ),
                          onPressed: _onLogout,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildFeatureButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(label),
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}