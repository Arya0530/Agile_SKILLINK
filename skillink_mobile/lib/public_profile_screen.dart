import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class PublicProfileScreen extends StatefulWidget {
  final int userId;
  const PublicProfileScreen({super.key, required this.userId});

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  // Fungsi fetch data
  Future<void> _fetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token');

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/users/${widget.userId}/profile'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (!mounted) return;
        setState(() {
          userData = data['data'];
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error ambil profil: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tampilan Loading di awal (First time load)
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white, 
        body: Center(child: CircularProgressIndicator(color: Color(0xFF0077B5)))
      );
    }
    
    // Tampilan jika data kosong
    if (userData == null) {
      return const Scaffold(body: Center(child: Text('Profil tidak ditemukan')));
    }

    final skills = userData!['skills'] as List;
    final projects = userData!['projects'] as List;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Profil ${userData!['name']}', style: const TextStyle(color: Colors.black, fontSize: 18)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      // --- MULAI REFRESH INDICATOR ---
      body: RefreshIndicator(
        onRefresh: _fetchProfile, // Tarik bawah buat panggil fungsi ini
        color: const Color(0xFF0077B5),
        child: SingleChildScrollView(
          // AlwaysScrollableScrollPhysics wajib ada biar layar pendek pun bisa ditarik
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Profil
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40, 
                      backgroundColor: Colors.purple, 
                      child: Text(
                        userData!['name'][0].toUpperCase(), 
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)
                      )
                    ),
                    const SizedBox(height: 12),
                    Text(userData!['name'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    Text(userData!['jurusan'] ?? 'Mahasiswa', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              
              // Bagian Keahlian (Skills)
              const Text('Keahlian', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              skills.isEmpty 
                ? const Text('Belum ada keahlian.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
                : Wrap(
                    spacing: 8,
                    children: skills.map((skill) => Chip(
                      label: Text(skill['name']),
                      backgroundColor: Colors.blue[50],
                      side: BorderSide.none,
                    )).toList(),
                  ),
              
              const SizedBox(height: 24),

              // Bagian Portofolio Proyek
              const Text('Portofolio Proyek', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              projects.isEmpty 
                ? const Text('Belum ada portofolio.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
                : Column(
                    children: projects.map((project) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), 
                        side: BorderSide(color: Colors.grey.shade300)
                      ),
                      child: ListTile(
                        title: Text(project['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(project['description'], maxLines: 2, overflow: TextOverflow.ellipsis),
                      ),
                    )).toList(),
                  ),
              
              // Tambahkan extra space di bawah biar scrolling terasa lega
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}