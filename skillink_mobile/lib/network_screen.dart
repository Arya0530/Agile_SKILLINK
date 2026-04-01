import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'public_profile_screen.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart'; // Pastiin file api_config lu ke-import
import 'package:url_launcher/url_launcher.dart';

class NetworkScreen extends StatefulWidget {
  const NetworkScreen({super.key});

  @override
  State<NetworkScreen> createState() => _NetworkScreenState();
}

class _NetworkScreenState extends State<NetworkScreen> {
  List<dynamic> _applicants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchApplicants();
  }

  // Tarik data siapa aja yang ngelamar project lu
 Future<void> _fetchApplicants() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('user_token');

  try {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/my-applicants'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    debugPrint("STATUS JARINGAN: ${response.statusCode}");
    debugPrint("BALASAN JARINGAN: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (!mounted) return;
      setState(() {
        _applicants = data['data'];
      });
    }
  } catch (e) {
    debugPrint("Gagal narik data pelamar: $e");
  } finally {
    // 🔥 WAJIB ADA DI SINI
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F2EF),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0077B5)))
          : _applicants.isEmpty
              ? const Center(child: Text('Belum ada undangan kolaborasi nih.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: _applicants.length,
                  itemBuilder: (context, index) {
                    final app = _applicants[index];
                    return Card(
                      color: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.purple,
                              child: Text(
                                app['applicant_name'][0].toUpperCase(), 
                                style: const TextStyle(color: Colors.white, fontSize: 20)
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(app['applicant_name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text(app['applicant_major'] ?? 'Mahasiswa', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                  const SizedBox(height: 4),
                                  Text('Mengajak koneksi dari postingan "${app['post_title']}"', style: const TextStyle(fontSize: 13)),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            // 1. Tarik nomor WA dari database
                                            String noWa = app['applicant_no_wa'] ?? "";
                                            
                                            // 2. Format nomornya. Kalau depannya '0', ganti jadi '62'
                                            if (noWa.startsWith('0')) {
                                              noWa = '62${noWa.substring(1)}';
                                            }

                                            // 3. Bikin pesan sapaan dinamis
                                            final Uri waUrl = Uri.parse("https://wa.me/$noWa");
                                            
                                            // 5. Lempar ke WhatsApp
                                            try {
                                              await launchUrl(waUrl, mode: LaunchMode.externalApplication);
                                            } catch (e) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Gagal buka WhatsApp nih bro')),
                                              );
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                          ),
                                          child: const Text(
                                            'Terima & WA',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton(
                                         onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => PublicProfileScreen(
                                                userId: app['applicant_id'],
                                              ),
                                            ),
                                          );
                                        },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF0077B5),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                                          ),
                                          child: const Text('Liat Profil', style: TextStyle(color: Colors.white)),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}