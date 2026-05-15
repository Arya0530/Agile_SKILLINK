import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_config.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final TextEditingController _maxAnggotaController = TextEditingController();
  String _selectedPostType = 'Kolaborasi Proyek';

  final List<String> _postTypes = [
    'Kolaborasi Proyek',
    'Kolaborasi Lomba',
    'Kolaborasi Penelitian',
    'Kolaborasi Startup',
    'Kolaborasi Tugas'
  ];

  Future<void> submitPost() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/posts');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('user_token');
      final namaUser = prefs.getString('user_name') ?? 'Mahasiswa Anonim';

      // Ambil nilai max_anggota — kalau kosong kirim '0' (tidak dibatasi)
      final maxAnggotaText = _maxAnggotaController.text.trim();
      final maxAnggota =
          maxAnggotaText.isNotEmpty ? maxAnggotaText : '0';

      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
        body: {
          'author_name': namaUser,
          'post_type': _selectedPostType,
          'content': _contentController.text,
          'tags': _tagsController.text,
          'max_anggota': maxAnggota,
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Berhasil diposting!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: ${data['message'] ?? response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error nembak API Post: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Buat Postingan',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0077B5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: submitPost,
              child: const Text(
                'Posting',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pilihan Jenis Postingan
            const Text(
              'Jenis Postingan',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedPostType,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: _postTypes.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPostType = newValue!;
                });
              },
            ),
            const SizedBox(height: 20),

            // Kolom Isi Postingan
            const Text(
              'Deskripsi Proyek / Ajakan',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText:
                    'Misal: Lagi butuh anak Frontend buat garap aplikasi e-commerce nih...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Kolom Tags
            const Text(
              'Keahlian yang Dicari (Tags)',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _tagsController,
              decoration: InputDecoration(
                hintText: 'Misal: #Flutter #UIUX #Laravel',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.tag),
              ),
            ),
            const SizedBox(height: 20),

            // ===== [BARU] Kolom Maksimal Anggota =====
            const Text(
              'Maksimal Anggota yang Direkrut',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            const Text(
              'Kosongkan jika tidak ingin membatasi jumlah anggota.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _maxAnggotaController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: 'Contoh: 5',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.group),
                suffixText: 'orang',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
