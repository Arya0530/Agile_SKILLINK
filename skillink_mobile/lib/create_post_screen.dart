import 'package:flutter/material.dart';
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
  String _selectedPostType = 'Kolaborasi Proyek'; // Default pilihan

  final List<String> _postTypes = ['Kolaborasi Proyek', 'Kolaborasi Lomba', 'Kolaborasi Projek'];
Future<void> submitPost() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/posts');

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 👇 KITA AMBIL TOKENNYA DARI DOMPET HP
      final token = prefs.getString('user_token'); 
      final namaUser = prefs.getString('user_name') ?? 'Mahasiswa Anonim'; 

      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          // 👇 TUNJUKIN KTP-NYA KE SATPAM LARAVEL DI SINI
          'Authorization': 'Bearer $token', 
        },
        body: {
          'author_name': namaUser,
          'post_type': _selectedPostType,
          'content': _contentController.text,
          'tags': _tagsController.text,
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil diposting!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: ${data['message'] ?? response.statusCode}'), backgroundColor: Colors.red),
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
        title: const Text('Buat Postingan', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () {
                submitPost();
                // TODO: Nanti kita isi fungsi nembak API nyimpen post ke Laravel di sini
              },
              child: const Text('Posting', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            const Text('Jenis Postingan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedPostType,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              items: _postTypes.map((String type) {
                return DropdownMenuItem<String>(value: type, child: Text(type));
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPostType = newValue!;
                });
              },
            ),
            const SizedBox(height: 20),

            // Kolom Isi Postingan
            const Text('Deskripsi Proyek / Ajakan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              maxLines: 6, // Biar kotaknya lumayan gede
              decoration: InputDecoration(
                hintText: 'Misal: Lagi butuh anak Frontend buat garap aplikasi e-commerce nih...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 20),

            // Kolom Tags
            const Text('Keahlian yang Dicari (Tags)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            TextField(
              controller: _tagsController,
              decoration: InputDecoration(
                hintText: 'Misal: #Flutter #UIUX #Laravel',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.tag),
              ),
            ),
          ],
        ),
      ),
    );
  }
}