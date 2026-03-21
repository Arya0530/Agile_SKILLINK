import 'package:flutter/material.dart';

class NetworkScreen extends StatelessWidget {
  const NetworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text('Jaringan Koneksi', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.black), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- BAGIAN 1: UNDANGAN MASUK ---
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: Text('Undangan Kolaborasi (1)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0077B5))),
            ),
            _buildInviteCard(
              name: 'Siti Aminah',
              major: 'Desain Komunikasi Visual',
              message: 'Mengajak koneksi dari postingan "Bikin E-Commerce"',
              avatarColor: Colors.purple,
            ),
            
            const Divider(thickness: 6, color: Color(0xFFF3F2EF)), // Garis pembatas tebal ala LinkedIn

            // --- BAGIAN 2: REKOMENDASI PARTNER ---
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: Text('Rekomendasi Partner buat Lu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0077B5))),
            ),
            _buildRecommendationCard(name: 'Budi Santoso', major: 'MMB - Video Editor', avatarColor: Colors.orange),
            _buildRecommendationCard(name: 'Clara', major: 'Sistem Informasi - System Analyst', avatarColor: Colors.teal),
            _buildRecommendationCard(name: 'Dono', major: 'D3 Teknik Informatika - magang', avatarColor: Colors.redAccent),
          ],
        ),
      ),
    );
  }

  // WIDGET KECIL BUAT KOTAK UNDANGAN (Biar kodingan rapi)
  Widget _buildInviteCard({required String name, required String major, required String message, required Color avatarColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 28, backgroundColor: avatarColor, child: Text(name[0], style: const TextStyle(color: Colors.white, fontSize: 24))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(major, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 4),
                Text(message, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.grey, side: const BorderSide(color: Colors.grey)),
                        onPressed: () {},
                        child: const Text('Abaikan'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0077B5)),
                        onPressed: () {},
                        child: const Text('Terima', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // WIDGET KECIL BUAT DAFTAR REKOMENDASI
  Widget _buildRecommendationCard({required String name, required String major, required Color avatarColor}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(radius: 24, backgroundColor: avatarColor, child: Text(name[0], style: const TextStyle(color: Colors.white))),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(major, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      trailing: IconButton(
        icon: const Icon(Icons.person_add_alt_1, color: Color(0xFF0077B5)),
        onPressed: () {},
      ),
    );
  }
}