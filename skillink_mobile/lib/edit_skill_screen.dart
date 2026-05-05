import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart'; // Pastikan path import ini bener ya

class EditSkillScreen extends StatefulWidget {
  const EditSkillScreen({super.key});

  @override
  State<EditSkillScreen> createState() => _EditSkillScreenState();
}

class _EditSkillScreenState extends State<EditSkillScreen> {
  final TextEditingController _skillController = TextEditingController();
  final TextEditingController _projTitleController = TextEditingController();
  final TextEditingController _projRoleController = TextEditingController();
  final TextEditingController _projDescController = TextEditingController();

  bool _isLoading = false;

  // --- FUNGSI ASLI NEMBAK API DATABASE (SKILL) ---
Future<void> _saveSkill() async {
    if (_skillController.text.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('user_token');

      // 1. KITA PECAH TEKSNYA BERDASARKAN KOMA
      // Kalau lu ngetik "C++, HTML, CSS", bakal dipecah jadi 3 data
      List<String> inputSkills = _skillController.text.trim().split(RegExp(r'\s+'));
      bool isAllSuccess = true;

      // 2. KITA LOOPING (Kirim ke backend satu per satu secara kilat)
      for (String skill in inputSkills) {
        String cleanedSkill = skill.trim(); // Bersihin spasi sisa di kiri-kanan kata
        if (cleanedSkill.isEmpty) continue; // Kalau cuma spasi kosong, lewatin aja

        final response = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/profile/skills'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'name': cleanedSkill}),
        );

        if (response.statusCode != 200 && response.statusCode != 201) {
          isAllSuccess = false;
          debugPrint("Gagal nyimpen skill: $cleanedSkill - ${response.body}");
        }
      }

      // 3. KASIH NOTIFIKASI KALAU UDAH KELAR SEMUA
      if (isAllSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil menambah skill!'), backgroundColor: Colors.green)
        );
        _skillController.clear(); // Kosongin form
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ada skill yang gagal disimpan.'), backgroundColor: Colors.orange)
        );
      }
    } catch (e) {
      debugPrint("Error save skill: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --- FUNGSI ASLI NEMBAK API DATABASE (PROYEK) ---
Future<void> _saveProject() async {
  if (_projTitleController.text.isEmpty || _projRoleController.text.isEmpty) return;
  setState(() => _isLoading = true);

  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token');

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/profile/projects'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': _projTitleController.text.trim(),
        'role': _projRoleController.text.trim(),
        'description': _projDescController.text.trim(),
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil menambah proyek!'), backgroundColor: Colors.green));
      
      // <--- KOSONGIN FORM SETELAH BERHASIL SIMPAN
      _projTitleController.clear();
      _projRoleController.clear();
      _projDescController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: ${response.body}'), backgroundColor: Colors.red));
    }
  } catch (e) {
    debugPrint("Error save project: $e");
  } finally {
    setState(() => _isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Tambah Skill & Proyek", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0077B5))), elevation: 1, backgroundColor: Colors.white, foregroundColor: Colors.black),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF0077B5)))
        : ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('TAMBAH TECH STACK BARU', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          TextField(controller: _skillController, decoration: InputDecoration(hintText: 'Masukkan Skill', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0077B5), padding: const EdgeInsets.symmetric(vertical: 12)),
            onPressed: _saveSkill, // Panggil fungsi API
            child: const Text('SIMPAN SKILL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          
          const Divider(height: 50, thickness: 1),

          const Text('TAMBAH RIWAYAT PROYEK BARU', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          _buildProjField(_projTitleController, "Judul Proyek"),
          _buildProjField(_projRoleController, "Peran"),
          _buildProjField(_projDescController, "Deskripsi Singkat", max: 3),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0077B5), padding: const EdgeInsets.symmetric(vertical: 15)),
            onPressed: _saveProject, // Panggil fungsi API
            child: const Text('SIMPAN PROYEK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildProjField(TextEditingController ctrl, String hint, {int max = 1}) {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: TextField(controller: ctrl, maxLines: max, decoration: InputDecoration(hintText: hint, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))));
  }
}