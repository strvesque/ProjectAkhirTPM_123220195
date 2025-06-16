import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KesanPesanPage extends StatelessWidget {
  const KesanPesanPage({Key? key}) : super(key: key);

  final Color _highlightColor = const Color(0xFFFFC1CC);
  final Color _textColor = Colors.black87;
  final Color _cardColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kesan dan Pesan',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            color: _textColor,
          ),
        ),
        backgroundColor: _highlightColor,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 100,
              color: _highlightColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Kesan & Pesan Selama Perkuliahan',
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _textColor,
              ),
            ),
            const SizedBox(height: 24),
            Card(
              color: _cardColor,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kesan:',
                      style: GoogleFonts.quicksand(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _highlightColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Selama mengikuti mata kuliah Teknologi dan Pemrograman Mobile, saya merasa sangat tertantang namun juga sangat antusias. '
                      'Materi yang diajarkan sangat relevan dengan kebutuhan industri saat ini, terutama dalam pengembangan aplikasi mobile menggunakan Flutter.',
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                        color: _textColor,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Pesan:',
                      style: GoogleFonts.quicksand(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _highlightColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Semoga ke depannya materi yang diberikan bisa terus ditingkatkan dengan studi kasus yang lebih kompleks dan nyata. '
                      'Selain itu, saya berharap pembelajaran tetap menyenangkan dan interaktif seperti selama ini.',
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                        color: _textColor,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}