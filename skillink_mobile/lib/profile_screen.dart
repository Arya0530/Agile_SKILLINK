import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'edit_profile_screen.dart';
import 'api_config.dart';
import 'edit_skill_screen.dart';
import 'edit_project_screen.dart';

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

  // [BARU] Daftar portofolio otomatis dari proyek yang selesai
  List<dynamic> _projectHistories = [];

  bool _isLoading = true;

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
            _name = data['data']['name'] ?? _name;
            _major = data['data']['jurusan'] ?? _major;

            _skills = data['data']['skills'] ?? [];
            _projects = data['data']['projects'] ?? [];
            _projectHistories = data['data']['project_histories'] ?? [];
          });
        }
      }
    } catch (e) {
      debugPrint('Waduh, gagal narik profil: $e');
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
          const SnackBar(
              content: Text('Berhasil dihapus!'),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      debugPrint('Gagal ngehapus: $e');
    }
  }

  // ─── HELPER: format tanggal "YYYY-MM-DD" → "MMM YYYY" ──────────────────────

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final dt = DateTime.parse(dateStr);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
      ];
      return '${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return dateStr.substring(0, 7); // fallback: "YYYY-MM"
    }
  }

  // ─── BUILD ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(color: Color(0xFF0077B5)))
        : RefreshIndicator(
            color: const Color(0xFF0077B5),
            onRefresh: _fetchProfileData,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.all(16.0),
              children: [
                // ── Header Profil ──────────────────────────────────────────
                Center(
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Color(0xFF0077B5),
                        child:
                            Icon(Icons.person, size: 50, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Text(_name,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(_major,
                          style: const TextStyle(
                              fontSize: 16, color: Colors.grey)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const EditProfileScreen(),
                                  ),
                                );

                                if (result == true) {
                                  await _loadUserData();
                                  await _fetchProfileData();
                                }
                              },
                              style: _blueButtonStyle(),
                              child: const Text('EDIT PROFIL',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const EditSkillScreen()),
                                );
                                _fetchProfileData();
                              },
                              style: _blueButtonStyle(),
                              child: const Text('EDIT SKILL',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Divider(height: 40, thickness: 1),

                // ── Tech Stack & Skills ────────────────────────────────────
                const Text('Tech Stack & Skills',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _skills.isEmpty
                      ? [
                          const Text('Belum ada skill ditambahkan.',
                              style: TextStyle(color: Colors.grey))
                        ]
                      : _skills
                          .map((skill) =>
                              _buildSkillBadge(skill['id'], skill['name']))
                          .toList(),
                ),

                const Divider(height: 40, thickness: 1),

                // ── Riwayat Proyek (manual entry) ──────────────────────────
                const Text('Riwayat Proyek Diluar Platform',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Column(
                  children: _projects.isEmpty
                      ? [
                          const Text('Belum ada riwayat proyek.',
                              style: TextStyle(color: Colors.grey))
                        ]
                      : _projects
                          .map((proj) => Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 12.0),
                                child: _buildProjectCard(
                                  id: proj['id'],
                                  title: proj['title'],
                                  role: proj['role'],
                                  description: proj['description'],
                                ),
                              ))
                          .toList(),
                ),

                const Divider(height: 40, thickness: 1),

                // ── [BARU] History Kolaborasi Proyek (portofolio otomatis) ────────────
                Row(
                  children: [
                    const Text(
                      'History Kolaborasi Proyek',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0077B5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_projectHistories.length}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Portofolio dari proyek yang telah selesai',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                Column(
                  children: _projectHistories.isEmpty
                      ? [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Colors.grey.shade200),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.history_edu,
                                    size: 40, color: Colors.grey.shade300),
                                const SizedBox(height: 8),
                                const Text(
                                  'Belum ada proyek yang selesai.\n'
                                  'History akan muncul otomatis saat pemilik proyek\n'
                                  'menekan tombol "Proyek Selesai".',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 13),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        ]
                      : _projectHistories
                          .map((h) => Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 12.0),
                                child: _buildHistoryCard(h),
                              ))
                          .toList(),
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
  }

  // ─── WIDGET BUILDERS ───────────────────────────────────────────────────────

  ButtonStyle _blueButtonStyle() {
    return ButtonStyle(
      elevation: MaterialStateProperty.all(0),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      side: MaterialStateProperty.all(
        const BorderSide(color: Color(0xFF0077B5), width: 1.5),
      ),
      backgroundColor: MaterialStateProperty.resolveWith<Color>(
        (states) => states.contains(MaterialState.hovered)
            ? Colors.white
            : const Color(0xFF0077B5),
      ),
      foregroundColor: MaterialStateProperty.resolveWith<Color>(
        (states) => states.contains(MaterialState.hovered)
            ? const Color(0xFF0077B5)
            : Colors.white,
      ),
    );
  }

  Widget _buildSkillBadge(int id, String skill) {
    return GestureDetector(
      onLongPress: () => _deleteItem('skills', id),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F3F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF0077B5)),
        ),
        child: Text(skill,
            style: const TextStyle(
                color: Color(0xFF0077B5),
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildProjectCard({
    required int id,
    required String title,
    required String role,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              spreadRadius: 1)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ),
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                onSelected: (value) async {
                  if (value == 'edit') {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProjectScreen(
                          projectId:          id,
                          initialTitle:       title,
                          initialRole:        role,
                          initialDescription: description,
                        ),
                      ),
                    );
                    if (result == true) _fetchProfileData();
                  } else if (value == 'delete') {
                    _deleteItem('projects', id);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                      value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(
                      value: 'delete',
                      child: Text('Hapus',
                          style: TextStyle(color: Colors.red))),
                ],
              ),
            ],
          ),
          Text(role,
              style: const TextStyle(
                  fontSize: 14,
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(description,
              style: const TextStyle(
                  fontSize: 14, color: Colors.black87)),
        ],
      ),
    );
  }

  // ─── [BARU] Kartu History Proyek ───────────────────────────────────────────

  Widget _buildHistoryCard(Map<String, dynamic> history) {
    final String title = history['project_title'] ?? '-';
    final String leader = history['leader_name'] ?? '-';
    final String start = _formatDate(history['start_date']?.toString());
    final String end = _formatDate(history['end_date']?.toString());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF0077B5).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 4,
              spreadRadius: 1)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Judul Proyek ──────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2.0),
                child: Icon(Icons.folder_special,
                    size: 18, color: Color(0xFF0077B5)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ── Ketua Proyek ──────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.person_pin,
                  size: 15, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                'Ketua: ',
                style: TextStyle(
                    fontSize: 13, color: Colors.grey.shade600),
              ),
              Text(
                leader,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // ── Periode Proyek ────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.date_range,
                  size: 15, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                'Periode: ',
                style: TextStyle(
                    fontSize: 13, color: Colors.grey.shade600),
              ),
              Text(
                '$start – $end',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ── Badge "Selesai" ───────────────────────────────────
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle,
                      size: 12, color: Colors.green),
                  SizedBox(width: 4),
                  Text(
                    'Selesai',
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.green,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}