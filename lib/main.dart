import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/produk_model.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/profile/kesan_pesan_page.dart';
import 'pages/transaksi/transaksi_form_page.dart';
import 'pages/transaksi/riwayat_transaksi_page.dart';
import 'pages/profile/profile_page.dart';
import 'pages/register_page.dart';
import 'pages/reservasi/reservasi_form_page.dart';
import 'pages/reservasi/riwayat_reservasi_page.dart';
import 'pages/produk/produk_page.dart';
import 'pages/produk/detail_produk_page.dart';
import 'utils/notification_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationHelper.init();
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  await initializeDateFormatting('id_ID', null);
  runApp(KlinikApp(isLoggedIn: isLoggedIn));
}

class KlinikApp extends StatelessWidget {
  final bool isLoggedIn;

  const KlinikApp({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color softPink = const Color(0xFFFFC1CC); // pink muda pastel
    final Color lightBackground = const Color(0xFFFFF1F3); // latar belakang lembut

    return MaterialApp(
      title: 'Klinik Kecantikan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: lightBackground,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.pink,
          backgroundColor: lightBackground,
          brightness: Brightness.light,
        ).copyWith(
          primary: softPink,
          secondary: Colors.pinkAccent.shade100,
        ),
        textTheme: GoogleFonts.quicksandTextTheme().copyWith(
          bodyLarge: const TextStyle(color: Colors.black87),
          bodyMedium: const TextStyle(color: Colors.black87),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: softPink,
          foregroundColor: Colors.white,
          titleTextStyle: GoogleFonts.quicksand(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: softPink,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          hintStyle: const TextStyle(color: Colors.black38),
        ),
      ),
      home: isLoggedIn ? const HomePage() : const LoginPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/profile': (context) => const ProfilePage(),
        '/produk': (context) => ProdukPage(),
        '/pembelian': (context) => const PembelianFormPage(),
        '/pembelian/riwayat': (context) => const RiwayatTransaksiPage(),
        '/reservasi': (context) => const ReservasiFormPage(),
        '/reservasi/riwayat': (context) => const RiwayatReservasiPage(),
        '/kesan-pesan': (context) => KesanPesanPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/produk/detail') {
          final args = settings.arguments as ProdukModel;
          return MaterialPageRoute(
            builder: (context) => DetailProdukPage(produk: args),
          );
        }

        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(child: Text('Route tidak ditemukan')),
          ),
        );
      },
    );
  }
}