import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class EditPostScreen extends StatefulWidget {
  final Map post; // Nerima data postingan lama
  const EditPostScreen({super.key, required this.post});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  late TextEditingController _contentController;
  late TextEditingController _tagsController;
  late String _selectedPostType;

  final List<String> _postTypes = ['Kolaborasi Proyek', 'Lomba', 'Open Commission'];

  @override
  void initState() {
    super.initState();
    // Isi otomatis form-nya pakai data lama
    _contentController = TextEditingController(text: widget.post['content']);
    _tagsController = TextEditingController(text: widget.post['tags']);
    
    // Pastiin tipenya valid, kalau nggak default ke Kolaborasi
    _selectedPostType = _postTypes.contains(widget.post['post_type']) 
        ? widget.post['post_type'] 
        : 'Kolaborasi Proyek';
  }

  Future<void> updatePost() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/posts/${widget.post['id']}');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('user_token');

      final response = await http.put(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {
          'post_type': _selectedPostType,
          'content': _contentController.text,
          'tags': _tagsController.text,
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Postingan diupdate!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); // Tutup dan kasih sinyal sukses
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: ${data['message']}'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      debugPrint("Error nembak API Edit: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text('Edit Postingan', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
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
              onPressed: () => updatePost(),
              child: const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const Text('Deskripsi Proyek / Ajakan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              maxLines: 6,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Keahlian yang Dicari (Tags)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            TextField(
              controller: _tagsController,
              decoration: InputDecoration(
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