import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'public_profile_screen.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';
import 'package:url_launcher/url_launcher.dart';

class NetworkScreen extends StatefulWidget {
  const NetworkScreen({super.key});

  @override
  State<NetworkScreen> createState() => _NetworkScreenState();
}

class _NetworkScreenState extends State<NetworkScreen> {
  // ===== TAB 1: PERMINTAAN (untuk pemilik post) =====
  List<dynamic> _applicants = [];
  bool _isLoading = true;
  Set<int> expandedIndex = {};

  // ===== TAB 2: RIWAYAT (untuk pelamar) =====
  List<dynamic> _history = [];
  bool _isLoadingHistory = true;

  // ===== TAB 2: RIWAYAT KEPUTUSAN (untuk pemilik post) =====
  List<dynamic> _decisionHistory = [];
  bool _isLoadingDecision = true;

  @override
  void initState() {
    super.initState();
    _fetchApplicants();
    _fetchHistory();
    _fetchDecisionHistory();
  }

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

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (!mounted) return;
        setState(() => _applicants = data['data']);
      }
    } catch (e) {
      debugPrint("Gagal narik data pelamar: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token');

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/my-application-history'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (!mounted) return;
        setState(() => _history = data['data']);
      }
    } catch (e) {
      debugPrint("Gagal narik history: $e");
    } finally {
      if (mounted) setState(() => _isLoadingHistory = false);
    }
  }

  Future<void> _fetchDecisionHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token');

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/my-decision-history'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (!mounted) return;
        setState(() => _decisionHistory = data['data']);
      }
    } catch (e) {
      debugPrint("Gagal narik decision history: $e");
    } finally {
      if (mounted) setState(() => _isLoadingDecision = false);
    }
  }

  Future<void> _updateApplicationStatus({
    required int applicationId,
    required String status,
    required int index,
    String? noWa,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token');

    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/applications/$applicationId/status'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          _applicants.removeAt(index);
          expandedIndex.clear();
        });

        // Refresh kedua history sekaligus supaya rejected_auto langsung muncul
        _fetchHistory();
        _fetchDecisionHistory();
        // Refresh tab permintaan juga biar sisa pelamar ter-update
        _fetchApplicants();

        if (status == 'accepted' && noWa != null && noWa.isNotEmpty) {
          String formattedWa = noWa;
          if (formattedWa.startsWith('0')) {
            formattedWa = '62${formattedWa.substring(1)}';
          }
          final Uri waUrl = Uri.parse("https://wa.me/$formattedWa");
          try {
            await launchUrl(waUrl, mode: LaunchMode.externalApplication);
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text('Lamaran diterima, tapi gagal buka WhatsApp')),
              );
            }
          }
        } else {
          if (mounted) {
            final msg =
                status == 'accepted' ? 'Lamaran diterima!' : 'Lamaran ditolak.';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(msg),
                backgroundColor:
                    status == 'accepted' ? Colors.green : Colors.red,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('Gagal memperbarui status lamaran, coba lagi.')),
          );
        }
      }
    } catch (e) {
      debugPrint("Gagal update status: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Koneksi bermasalah, coba lagi.')),
        );
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
          toolbarHeight: 0,
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
            child: _applicants.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada yang melamar.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _applicants.length,
                    itemBuilder: (context, index) {
                      final app = _applicants[index];
                      final title = app['post_title'] ?? '';
                      final applicationId = app['application_id'] as int;

                      // ===== [BARU] Data kuota dari API =====
                      final int maxAnggota =
                          (app['max_anggota'] ?? 0) as int;
                      final int acceptedCount =
                          (app['accepted_count'] ?? 0) as int;
                      final bool adaKuota = maxAnggota > 0;

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
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          app['applicant_name'],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                        Text(
                                          app['applicant_major'] ?? 'Mahasiswa',
                                          style: const TextStyle(
                                              color: Colors.grey, fontSize: 13),
                                        ),
                                        const SizedBox(height: 4),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              expandedIndex.contains(index)
                                                  ? title
                                                  : (title.length > 50
                                                      ? '${title.substring(0, 50)}...'
                                                      : title),
                                              style:
                                                  const TextStyle(fontSize: 13),
                                            ),
                                            if (title.length > 50)
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    if (expandedIndex
                                                        .contains(index)) {
                                                      expandedIndex
                                                          .remove(index);
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
                                        // ===== [BARU] Counter kuota di kartu pelamar =====
                                        if (adaKuota) ...[
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.group,
                                                size: 14,
                                                color: Colors.orange.shade700,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Slot terisi: $acceptedCount/$maxAnggota',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.orange.shade700,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // ===== TOMBOL AKSI =====
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PublicProfileScreen(
                                          userId: app['applicant_id'],
                                          applicationId: applicationId,
                                          applicantName:
                                              app['applicant_name'] ?? '',
                                          noWa: app['applicant_no_wa'],
                                          onAccept: () {
                                            _updateApplicationStatus(
                                              applicationId: applicationId,
                                              status: 'accepted',
                                              index: index,
                                              noWa: app['applicant_no_wa'],
                                            );
                                          },
                                          onReject: () {
                                            _updateApplicationStatus(
                                              applicationId: applicationId,
                                              status: 'rejected',
                                              index: index,
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.person, size: 16),
                                  label: const Text('Lihat Profil'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0077B5),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
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

  // ================= TAB 2: RIWAYAT =================
  Widget _buildRiwayatTab() {
    final isLoading = _isLoadingHistory || _isLoadingDecision;

    return isLoading
        ? const Center(
            child: CircularProgressIndicator(color: Color(0xFF0077B5)),
          )
        : RefreshIndicator(
            onRefresh: () async {
              await Future.wait([_fetchHistory(), _fetchDecisionHistory()]);
            },
            color: const Color(0xFF0077B5),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              children: [
                // -------- SEKSI 1: LAMARAN SAYA (sebagai pelamar) --------
                _buildSectionHeader('📨 Lamaran Saya'),
                const SizedBox(height: 8),
                if (_history.isEmpty)
                  _buildEmptyState(
                      'Belum ada riwayat lamaran yang kamu kirim.')
                else
                  ..._history.map((item) {
                    final status = item['status'] as String;
                    // Pakai status_label dari API yang sudah disiapkan backend
                    final statusLabel =
                        item['status_label'] as String? ?? status;

                    return Card(
                      color: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor:
                              _statusAvatarBg(status),
                          child: Icon(
                            _statusIcon(status),
                            color: _statusColor(status),
                          ),
                        ),
                        title: Text(
                          item['post_title'] ?? '-',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'Oleh: ${item['post_owner_name'] ?? '-'} · ${item['post_owner_major'] ?? ''}',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                            Text(
                              'Diperbarui: ${item['updated_at'] ?? '-'}',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        // ===== [DIUPDATE] Badge pakai status string =====
                        trailing: _buildStatusBadgeByStatus(status, statusLabel),
                      ),
                    );
                  }),

                const SizedBox(height: 20),

                // -------- SEKSI 2: KEPUTUSAN SAYA (sebagai pemilik post) --------
                _buildSectionHeader('📋 Keputusan Saya'),
                const SizedBox(height: 8),
                if (_decisionHistory.isEmpty)
                  _buildEmptyState('Belum ada lamaran yang kamu tindak.')
                else
                  ..._decisionHistory.map((item) {
                    final status = item['status'] as String;
                    final statusLabel =
                        item['status_label'] as String? ?? status;
                    final isDiterima = status == 'accepted';
                    final noWa = item['applicant_no_wa'] as String?;

                    return Card(
                      color: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: _statusAvatarBg(status),
                              child: Text(
                                (item['applicant_name'] ?? '?')[0]
                                    .toUpperCase(),
                                style: TextStyle(
                                  color: _statusColor(status),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['applicant_name'] ?? '-',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  ),
                                  Text(
                                    item['applicant_major'] ?? '-',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item['post_title'] ?? '-',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Ditindak: ${item['decided_at'] ?? '-'}',
                                    style: const TextStyle(
                                        fontSize: 11, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      _buildStatusBadgeByStatus(
                                          status, statusLabel),
                                      const SizedBox(width: 8),
                                      if (isDiterima &&
                                          noWa != null &&
                                          noWa.isNotEmpty)
                                        GestureDetector(
                                          onTap: () async {
                                            String formattedWa = noWa;
                                            if (formattedWa.startsWith('0')) {
                                              formattedWa =
                                                  '62${formattedWa.substring(1)}';
                                            }
                                            final Uri waUrl = Uri.parse(
                                                "https://wa.me/$formattedWa");
                                            try {
                                              await launchUrl(waUrl,
                                                  mode: LaunchMode
                                                      .externalApplication);
                                            } catch (e) {
                                              if (mounted) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                      content: Text(
                                                          'Gagal buka WhatsApp')),
                                                );
                                              }
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                  color: Colors.green,
                                                  width: 1),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: const [
                                                Icon(Icons.chat,
                                                    size: 14,
                                                    color: Colors.green),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Hubungi WA',
                                                  style: TextStyle(
                                                    color: Colors.green,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
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
                      ),
                    );
                  }),
              ],
            ),
          );
  }

  // ---- Helper: tentukan warna, ikon, bg berdasarkan status string ----

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'rejected_auto':
        return Colors.orange.shade700;
      default: // 'rejected'
        return Colors.red;
    }
  }

  Color _statusAvatarBg(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green.shade100;
      case 'rejected_auto':
        return Colors.orange.shade100;
      default:
        return Colors.red.shade100;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'accepted':
        return Icons.check_circle;
      case 'rejected_auto':
        return Icons.block;
      default:
        return Icons.cancel;
    }
  }

  // ===== [DIUPDATE] Badge sekarang pakai string status + label =====
  Widget _buildStatusBadgeByStatus(String status, String label) {
    Color bgColor;
    Color borderColor;
    Color textColor;

    switch (status) {
      case 'accepted':
        bgColor = Colors.green.shade50;
        borderColor = Colors.green;
        textColor = Colors.green;
        break;
      case 'rejected_auto':
        bgColor = Colors.orange.shade50;
        borderColor = Colors.orange.shade700;
        textColor = Colors.orange.shade700;
        break;
      default: // 'rejected'
        bgColor = Colors.red.shade50;
        borderColor = Colors.red;
        textColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // Tetap ada untuk backward-compat kalau ada yang masih pakai
  Widget _buildStatusBadge(bool isDiterima) {
    return _buildStatusBadgeByStatus(
      isDiterima ? 'accepted' : 'rejected',
      isDiterima ? 'Diterima' : 'Ditolak',
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Color(0xFF333333),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        message,
        style: const TextStyle(color: Colors.grey, fontSize: 13),
      ),
    );
  }
}
