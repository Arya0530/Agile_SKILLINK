import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  late TextEditingController _maxAnggotaController;
  late String _selectedPostType;

  final List<String> _postTypes = [
    'Kolaborasi Proyek',
    'Kolaborasi Lomba',
    'Kolaborasi Penelitian',
    'Kolaborasi Startup',
    'Kolaborasi Tugas'
  ];

  @override
  void initState() {
    super.initState();
    _contentController =
        TextEditingController(text: widget.post['content']);
    _tagsController = TextEditingController(text: widget.post['tags']);

    // Isi max_anggota dari data lama; tampilkan kosong kalau nilainya 0
    final existingMax = widget.post['max_anggota'];
    _maxAnggotaController = TextEditingController(
      text: (existingMax != null && existingMax != 0)
          ? existingMax.toString()
          : '',
    );

    _selectedPostType = _postTypes.contains(widget.post['post_type'])
        ? widget.post['post_type']
        : 'Kolaborasi Proyek';
  }

  Future<void> updatePost() async {
    final url =
        Uri.parse('${ApiConfig.baseUrl}/posts/${widget.post['id']}');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('user_token');

      final maxAnggotaText = _maxAnggotaController.text.trim();

      // Validasi: max anggota tidak boleh lebih dari 10
      if (maxAnggotaText.isNotEmpty) {
        final maxVal = int.tryParse(maxAnggotaText) ?? 0;
        if (maxVal < 1 || maxVal > 10) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Maksimal anggota harus antara 1–10 orang.'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
      }

      final maxAnggota =
          maxAnggotaText.isNotEmpty ? maxAnggotaText : '0';

      final response = await http.put(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
        body: {
          'post_type': _selectedPostType,
          'content': _contentController.text,
          'tags': _tagsController.text,
          'max_anggota': maxAnggota,
        },
      );

      final data = json.decode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Postingan diupdate!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: ${data['message']}'),
            backgroundColor: Colors.red,
          ),
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
        title: const Text(
          'Edit Postingan',
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
              onPressed: updatePost,
              child: const Text(
                'Simpan',
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

            const Text(
              'Deskripsi Proyek / Ajakan',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              maxLines: 6,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Keahlian yang Dicari (Tags)',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _tagsController,
              decoration: InputDecoration(
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
              maxLength: 2,
              decoration: InputDecoration(
                hintText: 'Contoh: 5',
                helperText: 'Maksimum 10 orang',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.group),
                suffixText: 'orang',
                counterText: '',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
