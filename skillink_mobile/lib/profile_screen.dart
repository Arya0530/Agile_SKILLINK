import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'edit_profile_screen.dart';
import 'login_screen.dart';
import 'api_config.dart';
import 'edit_skill_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'Memuat...';
  String _major = 'Memuat...';
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
    _fetchProfileData(); 
  }

Future<void> _loadUserData() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    _name = prefs.getString('user_name') ?? 'Nama Belum Diatur';
    _major = prefs.getString('user_major') ?? 'Jurusan Belum Diatur';
  });
}

  Future<void> _fetchProfileData() async {
    // Kita tidak pakai _isLoading = true di sini agar saat pull-to-refresh
    // indikator bawaan RefreshIndicator yang jalan, bukan Full Screen Loader.
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('user_token');
      
      if (token == null) return;

      final response = await http.get(
        
        Uri.parse('${ApiConfig.baseUrl}/profile'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
      );
debugPrint(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
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
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token');
    
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/profile/$type/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _fetchProfileData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil dihapus!'), backgroundColor: Colors.green)
        );
      }
    } catch (e) {
      debugPrint("Gagal ngehapus: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading 
      ? const Center(child: CircularProgressIndicator(color: Color(0xFF0077B5)))
      : RefreshIndicator(
          color: const Color(0xFF0077B5),
          onRefresh: _fetchProfileData, // Fungsi yang dipanggil saat ditarik
          child: ListView(
            // physics ini WAJIB AlwaysScrollable agar biarpun konten sedikit, tetap bisa ditarik
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.all(16.0),
            children: [
              // --- Bagian Header Profil ---
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

Row(
  children: [
    // --- TOMBOL 1: EDIT PROFIL (Normal Biru, Hover Putih) ---
    Expanded(
      child: ElevatedButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditProfileScreen()),
          );
          _fetchProfileData();
        },
        style: ButtonStyle(
          elevation: MaterialStateProperty.all(0), 
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
          ),
          side: MaterialStateProperty.all(
            const BorderSide(color: Color(0xFF0077B5), width: 1.5) 
          ),
          // Background: Normal = Biru, Hover = Putih
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.hovered)) {
                return Colors.white; 
              }
              return const Color(0xFF0077B5); 
            },
          ),
          // Teks: Normal = Putih, Hover = Biru
          foregroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.hovered)) {
                return const Color(0xFF0077B5); 
              }
              return Colors.white; 
            },
          ),
        ),
        child: const Text(
          'EDIT PROFIL', 
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)
        ),
      ),
    ),
    
    const SizedBox(width: 10),
    
    // --- TOMBOL 2: EDIT SKILL (Normal Biru, Hover Putih) ---
    Expanded(
      child: ElevatedButton(
onPressed: () async {
  // Tunggu user ngedit-ngedit di halaman Edit Skill
  await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const EditSkillScreen()),
  );
  // Pas user mencet tombol Back, otomatis tarik data terbaru dari Laragon
  _fetchProfileData();
},
        style: ButtonStyle(
          elevation: MaterialStateProperty.all(0), 
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
          ),
          side: MaterialStateProperty.all(
            const BorderSide(color: Color(0xFF0077B5), width: 1.5)
          ),
          // Background: Normal = Biru, Hover = Putih
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.hovered)) {
                return Colors.white; 
              }
              return const Color(0xFF0077B5); 
            },
          ),
          // Teks: Normal = Putih, Hover = Biru
          foregroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.hovered)) {
                return const Color(0xFF0077B5); 
              }
              return Colors.white; 
            },
          ),
        ),
        child: const Text(
          'EDIT SKILL',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    ),
  ],
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
                children: _skills.isEmpty 
                  ? [const Text('Belum ada skill ditambahkan.', style: TextStyle(color: Colors.grey))]
                  : _skills.map((skill) => _buildSkillBadge(skill['id'], skill['name'])).toList(),
              ),
              const Divider(height: 40, thickness: 1),

              // --- Bagian Riwayat Proyek ---
              const Text('Riwayat Proyek', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
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
          ),
        );
  }

  Widget _buildSkillBadge(int id, String skill) {
    return GestureDetector(
      onLongPress: () => _deleteItem('skills', id),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10), // Bikin sudut melengkung
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4, spreadRadius: 1)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              // --- INI DIA TOMBOL TITIK 3 NYA ---
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                onSelected: (value) {
                    if (value == 'edit') {
                      // Arahin ke halaman Edit Profil
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => const EditSkillScreen())
                      );
                    } else if (value == 'delete') {
                      _deleteItem('projects', id);
                    }
                  },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'delete', child: Text('Hapus', style: TextStyle(color: Colors.red))),
                ],
              ),
            ],
          ),
          // const SizedBox(height: 2), <-- Diubah dikit biar teks role lebih rapi
          Text(role, style: const TextStyle(fontSize: 14, color: Colors.blueAccent, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(fontSize: 14, color: Colors.black87)),
        ],
      ),
    );
  }
}
