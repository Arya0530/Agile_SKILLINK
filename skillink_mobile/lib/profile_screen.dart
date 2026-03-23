import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'edit_profile_screen.dart';
import 'login_screen.dart';
import 'api_config.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'Memuat...';
  String _major = 'Memuat...';
  
  // Variabel buat nampung data dari Laravel
  List<dynamic> _skills = [];
  List<dynamic> _projects = [];
  bool _isLoading = true;
  // 🛡️ ROMPI ANTI PELURU DEFUNCT ERROR
  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchProfileData(); // Tarik data dari Laravel pas halaman dibuka
  }

  // Tarik Nama & Jurusan dari memori HP
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
    setState(() {
      _name = prefs.getString('user_name') ?? 'Nama Belum Diatur';
      _major = prefs.getString('user_major') ?? 'Jurusan Belum Diatur';
    });
  }
  }

  // Tarik Data Skill & Project dari API Laravel
  Future<void> _fetchProfileData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('user_token');
      
      if (token == null) return;

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/profile'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (!mounted) return;
        if (data['success'] == true) {
          setState(() {
            _skills = data['data']['skills'] ?? [];
            _projects = data['data']['projects'] ?? [];
          });
        }
      }
    } catch (e) {
      debugPrint("Waduh, gagal narik profil: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }
Future<void> _deleteItem(String type, int id) async {
    debugPrint("TOMBOL DITEKAN! Mau hapus $type dengan ID: $id");
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token');
    
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/profile/$type/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      // 👇 INI CCTV BUAT NANGKEP ALASAN LARAVEL
      debugPrint("STATUS HAPUS: ${response.statusCode}");
      debugPrint("BALASAN HAPUS: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        _fetchProfileData(); // Refresh data di layar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil dihapus!'), backgroundColor: Colors.green)
        );
      } else {
        // Biar layar HP lu ngasih tau kalau gagal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal Hapus: ${response.statusCode}'), backgroundColor: Colors.orange)
        );
      }
    } catch (e) {
      debugPrint("Gagal ngehapus: $e");
    }
  }
  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading 
      ? const Center(child: CircularProgressIndicator(color: Color(0xFF0077B5)))
      : ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      children: [
        // --- Bagian Header Profil ---
        Center(
          child: Column(
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFF0077B5),
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(_name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(_major, style: const TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  // Tungguin user selesai di halaman edit
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                  );
                  // Kalau udah balik, panggil fungsi fetch lagi biar layarnya ke-refresh!
                  _fetchProfileData();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0077B5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Edit Profil', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
        const Divider(height: 40, thickness: 1),

        // --- Bagian Skill Badges ---
        const Text('Tech Stack & Skills', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          // Looping data skill dari Laravel
          children: _skills.isEmpty 
            ? [const Text('Belum ada skill ditambahkan.', style: TextStyle(color: Colors.grey))]
            : _skills.map((skill) => _buildSkillBadge(skill['id'], skill['name'])).toList(),
        ),
        const Divider(height: 40, thickness: 1),

        // --- Bagian Riwayat Proyek ---
        const Text('Riwayat Proyek', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        // Looping data project dari Laravel
        Column(
          children: _projects.isEmpty
            ? [const Text('Belum ada riwayat proyek.', style: TextStyle(color: Colors.grey))]
            : _projects.map((proj) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildProjectCard(
                  id: proj['id'],
                  title: proj['title'],
                  role: proj['role'],
                  description: proj['description'],
                ),
              )).toList(),
        ),
      ],
    );
  }

  Widget _buildSkillBadge(int id, String skill) {
    return GestureDetector(
      onLongPress: () => _deleteItem('skills', id), // Pelatuk hapus skill
      child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F3F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF0077B5)),
      ),
      child: Text(skill, style: const TextStyle(color: Color(0xFF0077B5), fontWeight: FontWeight.bold)),
      ),
    );
  }

    Widget _buildProjectCard({required int id, required String title, required String role, required String description}) {
    return GestureDetector(
      onLongPress: () => _deleteItem('projects', id), // Pelatuk hapus project
      child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 4, spreadRadius: 1)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(role, style: const TextStyle(fontSize: 14, color: Colors.orange, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(fontSize: 14, color: Colors.black87)),
        ],
      ),
       ),
    );
  }
}