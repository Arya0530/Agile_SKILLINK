import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Controller buat input Skill
  final TextEditingController _skillController = TextEditingController();

  // Controller buat input Project
  final TextEditingController _projTitleController = TextEditingController();
  final TextEditingController _projRoleController = TextEditingController();
  final TextEditingController _projDescController = TextEditingController();

  bool _isLoading = false;

Future<void> _addSkill() async {
  if (_skillController.text.isEmpty) return;

  setState(() => _isLoading = true);
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('user_token');

  debugPrint("Cek Token di HP: $token");

  try {
    List<String> inputSkills =
        _skillController.text.trim().split(RegExp(r'\s+'));

    bool allSuccess = true;

    for (String skill in inputSkills) {
      if (skill.isEmpty) continue;

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/profile/skills'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'name': skill}),
      );

      debugPrint("STATUS CODE LARAVEL: ${response.statusCode}");
      debugPrint("BALASAN LARAVEL: ${response.body}");

      if (!(response.statusCode == 200 || response.statusCode == 201)) {
        allSuccess = false;
      }
    }

    // ✅ notif cuma sekali
    if (allSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua skill berhasil ditambah!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ada skill yang gagal ditambahkan'),
          backgroundColor: Colors.orange,
        ),
      );
    }

    _skillController.clear();

  } catch (e) {
    debugPrint("WADUH ERROR FLUTTER: $e");
  } finally {
    setState(() => _isLoading = false);
  }
}
  // --- FUNGSI NAMBAH PROJECT ---
  Future<void> _addProject() async {
    if (_projTitleController.text.isEmpty || _projRoleController.text.isEmpty) return;

    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token');

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/profile/projects'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': _projTitleController.text,
          'role': _projRoleController.text,
          'description': _projDescController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project berhasil ditambah!'), backgroundColor: Colors.green),
        );
        _projTitleController.clear();
        _projRoleController.clear();
        _projDescController.clear();
      }
    } catch (e) {
      debugPrint("Error nambah project: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil Lengkap', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF0077B5)),
        elevation: 1,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // --- BAGIAN TAMBAH SKILL ---
                const Text('Tambah Tech Stack / Skill', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                TextField(
                  controller: _skillController,
                  decoration: InputDecoration(
                    labelText: 'Nama Skill (Contoh: Flutter)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.add_circle, color: Color(0xFF0077B5), size: 30),
                      onPressed: _addSkill, // Tombol eksekusi nambah skill
                    ),
                  ),
                ),
                
                const Divider(height: 50, thickness: 1),

                // --- BAGIAN TAMBAH PROJECT ---
                const Text('Tambah Riwayat Proyek', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                TextField(
                  controller: _projTitleController,
                  decoration: InputDecoration(labelText: 'Judul Proyek', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _projRoleController,
                  decoration: InputDecoration(labelText: 'Peran (Contoh: Backend Dev)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _projDescController,
                  maxLines: 3,
                  decoration: InputDecoration(labelText: 'Deskripsi Singkat Proyek', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0077B5),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _addProject, // Tombol eksekusi nambah project
                  child: const Text('SIMPAN PROYEK', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                )
              ],
            ),
    );
  }
}