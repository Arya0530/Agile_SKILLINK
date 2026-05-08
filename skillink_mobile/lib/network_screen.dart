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

  // ----------------------------------------------------------------
  // Tarik data siapa aja yang ngelamar project lu (hanya status pending)
  // ----------------------------------------------------------------
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ----------------------------------------------------------------
  // Tarik history lamaran milik user yang login (accepted / rejected)
  // ----------------------------------------------------------------
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

      debugPrint("STATUS HISTORY: ${response.statusCode}");
      debugPrint("BALASAN HISTORY: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (!mounted) return;
        setState(() {
          _history = data['data'];
        });
      }
    } catch (e) {
      debugPrint("Gagal narik history: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoadingHistory = false);
      }
    }
  }

  // ----------------------------------------------------------------
  // Tarik history keputusan pemilik post (acc/reject yang sudah dilakukan)
  // ----------------------------------------------------------------
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

      debugPrint("STATUS DECISION HISTORY: ${response.statusCode}");
      debugPrint("BALASAN DECISION HISTORY: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (!mounted) return;
        setState(() {
          _decisionHistory = data['data'];
        });
      }
    } catch (e) {
      debugPrint("Gagal narik decision history: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoadingDecision = false);
      }
    }
  }

  // ---------------------------------------------------------------- lalu hapus dari list Permintaan
  // ----------------------------------------------------------------
  Future<void> _updateApplicationStatus({
    required int applicationId,
    required String status, // 'accepted' atau 'rejected'
    required int index,
    String? noWa, // hanya dipakai saat accept
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

      debugPrint("STATUS UPDATE: ${response.statusCode}");
      debugPrint("BALASAN UPDATE: ${response.body}");

      if (response.statusCode == 200) {
        // Hapus dari list Permintaan supaya langsung hilang di UI
        if (!mounted) return;
        setState(() {
          _applicants.removeAt(index);
          // Reset expanded index supaya tidak kacak setelah item dihapus
          expandedIndex.clear();
        });

        // Refresh history supaya langsung muncul di tab Riwayat
        _fetchHistory();
        _fetchDecisionHistory();

        // Kalau accept, buka WhatsApp setelah API berhasil
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
                const SnackBar(content: Text('Lamaran diterima, tapi gagal buka WhatsApp')),
              );
            }
          }
        } else {
          // Tampilkan snackbar konfirmasi
          if (mounted) {
            final msg = status == 'accepted'
                ? 'Lamaran diterima!'
                : 'Lamaran ditolak.';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(msg),
                backgroundColor: status == 'accepted' ? Colors.green : Colors.red,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal memperbarui status lamaran, coba lagi.')),
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
                                              style: const TextStyle(
                                                  fontSize: 13),
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
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // ===== TOMBOL AKSI =====
                              Row(
                                children: [
                                  // [DIUPDATE] Tombol Terima — panggil API accept dulu, baru buka WA
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        _updateApplicationStatus(
                                          applicationId: applicationId,
                                          status: 'accepted',
                                          index: index,
                                          noWa: app['applicant_no_wa'],
                                        );
                                      },
                                      icon: const Icon(Icons.check, size: 16),
                                      label: const Text('Terima & WA'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // [BARU] Tombol Tolak — panggil API reject
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text('Tolak Lamaran'),
                                            content: Text(
                                              'Yakin mau nolak lamaran dari ${app['applicant_name']}?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx),
                                                child: const Text('Batal'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(ctx);
                                                  _updateApplicationStatus(
                                                    applicationId: applicationId,
                                                    status: 'rejected',
                                                    index: index,
                                                  );
                                                },
                                                child: const Text(
                                                  'Ya, Tolak',
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.close, size: 16),
                                      label: const Text('Tolak'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red.shade400,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Tombol Lihat Profil
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PublicProfileScreen(
                                            userId: app['applicant_id'],
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0077B5),
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Profil'),
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
  // Seksi 1: Lamaran Saya (sebagai pelamar)
  // Seksi 2: Keputusan Saya (sebagai pemilik post, ada tombol WA kalau accepted)
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
                  _buildEmptyState('Belum ada riwayat lamaran yang kamu kirim.')
                else
                  ..._history.map((item) {
                    final status = item['status'] as String;
                    final isDiterima = status == 'accepted';
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
                          backgroundColor: isDiterima
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                          child: Icon(
                            isDiterima ? Icons.check_circle : Icons.cancel,
                            color: isDiterima ? Colors.green : Colors.red,
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
                        trailing: _buildStatusBadge(isDiterima),
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
                              backgroundColor: isDiterima
                                  ? Colors.green.shade100
                                  : Colors.red.shade100,
                              child: Text(
                                (item['applicant_name'] ?? '?')[0]
                                    .toUpperCase(),
                                style: TextStyle(
                                  color: isDiterima
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
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
                                      _buildStatusBadge(isDiterima),
                                      const SizedBox(width: 8),
                                      // Tombol WA hanya muncul kalau status accepted
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

  // ---- Helper widgets ----
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

  Widget _buildStatusBadge(bool isDiterima) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDiterima ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDiterima ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Text(
        isDiterima ? 'Diterima' : 'Ditolak',
        style: TextStyle(
          color: isDiterima ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
