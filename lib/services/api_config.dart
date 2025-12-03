class ApiConfig {
  // Ganti baseUrl dengan URL dari backend kamu
  static const String baseUrl = 'http://127.0.0.1:3000/api';

  // (Opsional) Endpoint spesifik
  static const String login = '$baseUrl/login';
  static const String register = '$baseUrl/register';
  static const String currentUser = '$baseUrl/user/me';

  // Endpoint untuk modul produk
  static const String produk = '$baseUrl/produk';

  // Endpoint untuk pembelian/transaksi
  static const String transaksi = '$baseUrl/transaksi';

  // Endpoint untuk reservasi
  static const String reservasi = '$baseUrl/reservasi';
  static const String tipeTreatment = '$baseUrl/treatment';
}
