import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/produk_model.dart';
import '../services/produk_service.dart';
import 'produk/detail_produk_page.dart';
import 'transaksi/transaksi_form_page.dart';
import 'produk/produk_per_jenis_page.dart';
import 'reservasi/reservasi_form_page.dart';
import 'profile/profile_page.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late Future<List<ProdukModel>> _produkFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchKeyword = '';
  Timer? _debounce;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  @override
  void initState() {
    super.initState();
    _produkFuture = ProdukService().getAllProduk();
    _initializeAccelerometer();
  }

  void _initializeAccelerometer() {
    _accelerometerSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
      const double shakeThreshold = 15.0;
      double magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      if (magnitude > shakeThreshold && _searchKeyword.isNotEmpty) {
        _resetSearch();
      }
    });
  }

  void _resetSearch() {
    if (mounted) {
      _searchController.clear();
      setState(() {
        _searchKeyword = '';
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          _searchKeyword = value.toLowerCase();
        });
      }
    });
  }

  void refreshProduk() {
    if (mounted) {
      setState(() {
        _produkFuture = ProdukService().getAllProduk();
      });
    }
  }

  Future<void> _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      // Handle error jika diperlukan
      debugPrint('Error during logout: $e');
    }
  }

  Widget _buildHomeTab() {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        SharedPreferences.getInstance(),
        _produkFuture,
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Terjadi kesalahan saat memuat data.",
              style: GoogleFonts.quicksand(),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Center(
            child: Text(
              "Data tidak tersedia.",
              style: GoogleFonts.quicksand(),
            ),
          );
        }

        final produkList = snapshot.data![1] as List<ProdukModel>;

        if (produkList.isEmpty) {
          return Center(
            child: Text(
              "Data produk kosong.",
              style: GoogleFonts.quicksand(),
            ),
          );
        }

        final grouped = <String, List<ProdukModel>>{};
        for (var produk in produkList) {
          final jenis = produk.jenis ?? 'Lainnya';
          grouped.putIfAbsent(jenis, () => []).add(produk);
        }

        final filteredGrouped = <String, List<ProdukModel>>{};
        grouped.forEach((jenis, list) {
          final filtered = list
              .where((produk) => 
                  (produk.nama ?? '').toLowerCase().contains(_searchKeyword))
              .toList();
          if (filtered.isNotEmpty) {
            filteredGrouped[jenis] = filtered;
          }
        });

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                hintStyle: GoogleFonts.quicksand(),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: _searchKeyword.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          if (mounted) {
                            setState(() {
                              _searchKeyword = '';
                            });
                          }
                        },
                      )
                    : null,
              ),
              onChanged: _onSearchChanged,
            ),
            const SizedBox(height: 16),
            if (filteredGrouped.isEmpty)
              Center(
                child: Text(
                  "Produk tidak ditemukan.",
                  style: GoogleFonts.quicksand(),
                ),
              )
            else
              ...filteredGrouped.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            entry.key,
                            style: GoogleFonts.quicksand(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProdukPerJenisPage(
                                  jenis: entry.key,
                                  produkList: entry.value,
                                ),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            "Lihat Selengkapnya",
                            style: GoogleFonts.quicksand(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 160,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        itemCount: entry.value.length,
                        itemBuilder: (context, index) {
                          final produk = entry.value[index];
                          return Container(
                            width: 100,
                            margin: const EdgeInsets.only(right: 12),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailProdukPage(produk: produk),
                                  ),
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          produk.gambar ?? '',
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => 
                                              const Icon(Icons.broken_image),
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return const Center(
                                              child: CircularProgressIndicator(),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    produk.nama ?? '-',
                                    style: GoogleFonts.quicksand(fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              }),
          ],
        );
      },
    );
  }

  Widget _buildPembelianTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PembelianFormPage(),
                  ),
                );
              },
              child: Text('Transaksi', style: GoogleFonts.quicksand()),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReservasiFormPage(),
                  ),
                );
              },
              child: Text('Reservasi', style: GoogleFonts.quicksand()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    return const ProfilePage();
  }

  List<Widget> get _tabs => [
        _buildHomeTab(),
        _buildPembelianTab(),
        _buildProfileTab(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("L Clinic", style: GoogleFonts.quicksand()),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _tabs[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (mounted) {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
        selectedLabelStyle: GoogleFonts.quicksand(),
        unselectedLabelStyle: GoogleFonts.quicksand(),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Pembelian',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}