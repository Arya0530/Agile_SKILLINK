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
  Set<int> expandedIndex = {};
 

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
  return DefaultTabController(
    length: 2,
    child: Scaffold(
      backgroundColor: const Color(0xFFF3F2EF),

        appBar: AppBar(
          toolbarHeight: 0, // 🔥 hilangin bagian atas
          bottom: const TabBar(
            labelColor: Color(0xFF0077B5),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF0077B5),
            tabs: [
              Tab(text: "Permintaan"),
              Tab(text: "Riwayat"),
            ],
          ),
        ),

      body: TabBarView(
        children: [
          _buildPermintaanTab(),
          _buildRiwayatTab(),
        ],
      ),
    ),
  );
}

// ================= TAB 1: PERMINTAAN =================
Widget _buildPermintaanTab() {
  return _isLoading
      ? const Center(
          child: CircularProgressIndicator(color: Color(0xFF0077B5)),
        )
      : RefreshIndicator(
          onRefresh: _fetchApplicants,
          color: const Color(0xFF0077B5),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8.0),
            itemCount: _applicants.length,
            itemBuilder: (context, index) {
              final app = _applicants[index];
              final title = app['post_title'] ?? '';

              return Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.purple,
                            child: Text(
                              app['applicant_name'][0].toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  app['applicant_name'],
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Text(
                                  app['applicant_major'] ?? 'Mahasiswa',
                                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                                ),
                                const SizedBox(height: 4),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      expandedIndex.contains(index)
                                          ? title
                                          : (title.length > 50
                                              ? title.substring(0, 50) + "..."
                                              : title),
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    if (title.length > 50)
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            if (expandedIndex.contains(index)) {
                                              expandedIndex.remove(index);
                                            } else {
                                              expandedIndex.add(index);
                                            }
                                          });
                                        },
                                        child: Text(
                                          expandedIndex.contains(index)
                                              ? "Lihat lebih sedikit"
                                              : "Lihat Selengkapnya",
                                          style: const TextStyle(
                                            color: Color(0xFF0077B5),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                String noWa = app['applicant_no_wa'] ?? "";
                                if (noWa.startsWith('0')) {
                                  noWa = '62${noWa.substring(1)}';
                                }

                                final Uri waUrl = Uri.parse("https://wa.me/$noWa");

                                try {
                                  await launchUrl(waUrl, mode: LaunchMode.externalApplication);
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Gagal buka WhatsApp')),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Terima & WA'),
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
                                foregroundColor: Colors.white, 
                              ),
                              child: const Text('Lihat Profil'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
}

// ================= TAB 2: RIWAYAT =================
Widget _buildRiwayatTab() {
  return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: 5,
    itemBuilder: (context, index) {
      return Card(
        child: ListTile(
          leading: const CircleAvatar(child: Text("B")),
          title: const Text("bbb"),
          subtitle: const Text("Riwayat lamaran"),
          trailing: Text(
            index % 2 == 0 ? "Diterima" : "Ditolak",
            style: TextStyle(
              color: index % 2 == 0 ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    },
  );
}
}