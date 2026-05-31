import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';
import 'edit_post_screen.dart';
import 'create_post_screen.dart';

class SmartFeedScreen extends StatefulWidget {
  const SmartFeedScreen({super.key});

  @override
  State<SmartFeedScreen> createState() => SmartFeedScreenState();
}

class SmartFeedScreenState extends State<SmartFeedScreen>
    with SingleTickerProviderStateMixin {
  // ===== FOR YOU TAB =====
  List _forYouPosts = [];
  bool _isLoadingForYou = true;

  // ===== MY POST TAB =====
  List _myPosts = [];
  bool _isLoadingMyPost = true;

  // ===== SHARED STATE =====
  String myName = '';
  String _searchQuery = '';
  Timer? _debounceTimer;
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final Set<int> _expandedPosts = {};

  // [BARU] Variabel untuk melacak post mana yang sedang loading saat di-apply
  final Set<int> _applyingPosts = {};

  // ===== FILTER STATE =====
  // Menyimpan jenis postingan yang dipilih untuk filter.
  // null = tidak ada filter aktif (tampilkan semua).
  String? _selectedFilterType;

  // Daftar jenis postingan sama persis dengan create_post_screen.dart
  final List<String> _postTypes = [
    'Kolaborasi Proyek',
    'Kolaborasi Lomba',
    'Kolaborasi Penelitian',
    'Kolaborasi Startup',
    'Kolaborasi Tugas',
  ];
  // ===== END FILTER STATE =====

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMyName();
    fetchPosts();
    _fetchMyPosts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildTags(String? tags) {
    if (tags == null || tags.isEmpty) return const SizedBox();

    final tagList = tags.split(' ');

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: tagList.map((tag) {
        if (!tag.startsWith('#')) tag = '#$tag';

        return GestureDetector(
          onTap: () {
            setState(() {
              _searchQuery = tag.replaceAll('#', '');
              _searchController.text = _searchQuery;
            });

            fetchPosts();
            _fetchMyPosts();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFE7F3FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              tag,
              style: const TextStyle(
                color: Color(0xFF0077B5),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── LOAD USER NAME ────────────────────────────────────────────────────────

  Future<void> _loadMyName() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => myName = prefs.getString('user_name') ?? '');
  }

  // ─── FETCH: FOR YOU ────────────────────────────────────────────────────────

  Future<void> fetchPosts() async {
    setState(() => _isLoadingForYou = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token');

    // Bangun query parameters: tag (dari search) + post_type (dari filter)
    final Map<String, String> queryParams = {};
    if (_searchQuery.isNotEmpty) queryParams['tag'] = _searchQuery;
    if (_selectedFilterType != null) queryParams['post_type'] = _selectedFilterType!;

    final uri = Uri.parse('${ApiConfig.baseUrl}/posts').replace(
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    try {
      final response = await http.get(uri, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      });

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _forYouPosts = data['data'];
          myName = prefs.getString('user_name') ?? myName;
          _isLoadingForYou = false;
        });
      } else {
        setState(() => _isLoadingForYou = false);
      }
    } catch (e) {
      debugPrint('Error narik For You: $e');
      if (!mounted) return;
      setState(() => _isLoadingForYou = false);
    }
  }

  // ─── FETCH: MY POST ────────────────────────────────────────────────────────

  Future<void> _fetchMyPosts() async {
    setState(() => _isLoadingMyPost = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token');

    setState(() {
      myName = prefs.getString('user_name') ?? myName;
    });

    // Bangun query parameters: tag (dari search) + post_type (dari filter)
    final Map<String, String> queryParams = {};
    if (_searchQuery.isNotEmpty) queryParams['tag'] = _searchQuery;
    if (_selectedFilterType != null) queryParams['post_type'] = _selectedFilterType!;

    final uri = Uri.parse('${ApiConfig.baseUrl}/my-posts').replace(
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    try {
      final response = await http.get(uri, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      });

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _myPosts = data['data'];
          _isLoadingMyPost = false;
        });
      } else {
        setState(() => _isLoadingMyPost = false);
      }
    } catch (e) {
      debugPrint('Error narik My Post: $e');
      if (!mounted) return;
      setState(() => _isLoadingMyPost = false);
    }
  }

  // ─── SEARCH ────────────────────────────────────────────────────────────────

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() => _searchQuery = value.trim());
      fetchPosts();
      _fetchMyPosts();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _searchQuery = '');
    fetchPosts();
    _fetchMyPosts();
  }

  // ─── SHOW FILTER BOTTOM SHEET ──────────────────────────────────────────────

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ──────────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Jenis Postingan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_selectedFilterType != null)
                        TextButton(
                          onPressed: () {
                            setState(() => _selectedFilterType = null);
                            Navigator.pop(ctx);
                            fetchPosts();
                            _fetchMyPosts();
                          },
                          child: const Text(
                            'Reset Filter',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Pilih satu jenis postingan untuk memfilter hasil.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),

                  // ── Pilihan Jenis Postingan ──────────────────────────────
                  ..._postTypes.map((type) {
                    final bool isSelected = _selectedFilterType == type;
                    return GestureDetector(
                      onTap: () {
                        setModalState(() {});
                        setState(() {
                          _selectedFilterType =
                              isSelected ? null : type;
                        });
                        Navigator.pop(ctx);
                        fetchPosts();
                        _fetchMyPosts();
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFE7F3FF)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF0077B5)
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _iconForPostType(type),
                              size: 18,
                              color: isSelected
                                  ? const Color(0xFF0077B5)
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              type,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? const Color(0xFF0077B5)
                                    : Colors.black87,
                              ),
                            ),
                            const Spacer(),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFF0077B5),
                                size: 18,
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ─── HELPER: ICON PER JENIS POSTINGAN ─────────────────────────────────────

  IconData _iconForPostType(String type) {
    switch (type) {
      case 'Kolaborasi Proyek':
        return Icons.work_outline;
      case 'Kolaborasi Lomba':
        return Icons.emoji_events_outlined;
      case 'Kolaborasi Penelitian':
        return Icons.science_outlined;
      case 'Kolaborasi Startup':
        return Icons.rocket_launch_outlined;
      case 'Kolaborasi Tugas':
        return Icons.assignment_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  // ─── ACTIONS ───────────────────────────────────────────────────────────────

  Future<void> _deletePost(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token');

    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/posts/$postId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (!mounted) return;
      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message']),
            backgroundColor: Colors.green,
          ),
        );
        fetchPosts();
        _fetchMyPosts();
      }
    } catch (e) {
      debugPrint('Gagal hapus: $e');
    }
  }

  Future<void> _applyJob(int postId) async {
    // 1. Cek apakah sedang proses apply. Jika iya, batalkan.
    if (_applyingPosts.contains(postId)) return;

    // 2. Tandai postingan ini sedang dalam proses apply
    setState(() {
      _applyingPosts.add(postId);
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mengirim lamaran...'),
        duration: Duration(seconds: 1),
      ),
    );

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/posts/$postId/apply'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (!mounted) return;
      final data = json.decode(response.body);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['message']),
          backgroundColor:
              response.statusCode == 200 ? Colors.green : Colors.red,
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          final index =
              _forYouPosts.indexWhere((post) => post['id'] == postId);

          if (index != -1) {
            _forYouPosts[index]['user_already_applied'] = true;
          }
        });
      }
    } catch (e) {
      debugPrint('Gagal Apply: $e');
    } finally {
      // 3. Pastikan menghapus status loading saat proses selesai
      if (mounted) {
        setState(() {
          _applyingPosts.remove(postId);
        });
      }
    }
  }

  // ─── TUTUP REKRUTMEN ───────────────────────────────────────────────────────

  Future<void> _closeRecruitment(int postId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tutup Rekrutmen?'),
        content: const Text(
          'Postingan akan hilang dari tab "For You" dan rekrutmen '
          'ditutup. Semua lamaran pending akan otomatis ditolak.\n\n'
          'Aksi ini tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Tutup Rekrutmen'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token');

    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/posts/$postId/close'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (!mounted) return;
      final data = json.decode(response.body);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['message']),
          backgroundColor:
              response.statusCode == 200 ? Colors.orange : Colors.red,
        ),
      );

      if (response.statusCode == 200) {
        fetchPosts();
        _fetchMyPosts();
      }
    } catch (e) {
      debugPrint('Gagal tutup rekrutmen: $e');
    }
  }

  // ─── PROYEK SELESAI ────────────────────────────────────────────────────────

  Future<void> _completeProject(int postId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tandai Proyek Selesai?'),
        content: const Text(
          'Proyek akan ditandai sebagai selesai.\n\n'
          'History proyek ini akan otomatis masuk ke portofolio '
          'semua anggota yang tergabung.\n\n'
          'Aksi ini tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Proyek Selesai'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token');

    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/posts/$postId/complete'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (!mounted) return;
      final data = json.decode(response.body);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['message']),
          backgroundColor:
              response.statusCode == 200 ? Colors.green : Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );

      if (response.statusCode == 200) {
        fetchPosts();
        _fetchMyPosts();
      }
    } catch (e) {
      debugPrint('Gagal complete project: $e');
    }
  }

  // ─── WIDGET HELPERS ────────────────────────────────────────────────────────

  Widget _buildMemberCounter(Map post) {
    final int maxAnggota = (post['max_anggota'] ?? 0) as int;
    if (maxAnggota == 0) return const SizedBox.shrink();

    final int acceptedCount = (post['accepted_count'] ?? 0) as int;
    final bool penuh = acceptedCount >= maxAnggota;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            penuh ? Icons.group_off : Icons.group,
            size: 16,
            color: penuh ? Colors.red : const Color(0xFF0077B5),
          ),
          const SizedBox(width: 4),
          Text(
            '$acceptedCount/$maxAnggota anggota',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: penuh ? Colors.red : const Color(0xFF0077B5),
            ),
          ),
          if (penuh) ...[
            const SizedBox(width: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.shade300),
              ),
              child: const Text(
                'Kuota Penuh',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPostCard(Map post, {bool isMyPost = false}) {
    final int maxAnggota = (post['max_anggota'] ?? 0) as int;
    final int acceptedCount = (post['accepted_count'] ?? 0) as int;
    final bool isApply =
        post['user_already_applied'] == 1 || post['user_already_applied'] == true;
    final bool isClosed =
        post['is_closed'] == 1 || post['is_closed'] == true;
    final bool isCompleted =
        post['is_completed'] == 1 || post['is_completed'] == true;
    final bool kuotaPenuh =
        maxAnggota > 0 && acceptedCount >= maxAnggota;
    final bool isOwn = post['author_name'] == myName;
    
    // [BARU] Mengecek apakah post ini sedang dalam proses apply
    final bool isApplying = _applyingPosts.contains(post['id']);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── HEADER ──────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF0077B5),
                child: Text(
                  (post['author_name'] ?? '?')[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['author_name'] ?? '-',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${post['author_major']} • ${post['post_type']}',
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Edit / Delete menu
              if (isOwn || isMyPost)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_horiz, color: Colors.grey),
                  onSelected: (value) async {
                    if (value == 'edit') {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditPostScreen(post: post),
                        ),
                      );
                      if (result == true) {
                        fetchPosts();
                        _fetchMyPosts();
                      }
                    } else if (value == 'hapus') {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Hapus Postingan?'),
                          content: const Text(
                            'Yakin mau hapus? Nggak bisa dibalikin lho.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _deletePost(post['id']);
                              },
                              child: const Text('Hapus',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                        value: 'edit', child: Text('Edit Postingan')),
                    const PopupMenuItem(
                        value: 'hapus', child: Text('Hapus')),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 12),

          // ── CONTENT ─────────────────────────────────────────────
          Builder(builder: (context) {
            final String content = post['content'] ?? '';
            final bool isExpanded =
                _expandedPosts.contains(post['id']);
            final bool isLongText = content.length > 150;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (isLongText && !isExpanded)
                      ? '${content.substring(0, 150)}...'
                      : content,
                  style: const TextStyle(
                      fontSize: 14, color: Colors.black87),
                ),
                _buildTags(post['tags']),
                if (isLongText)
                  GestureDetector(
                    onTap: () => setState(() {
                      if (isExpanded) {
                        _expandedPosts.remove(post['id']);
                      } else {
                        _expandedPosts.add(post['id']);
                      }
                    }),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        isExpanded
                            ? 'Tampilkan Lebih Sedikit'
                            : 'Lihat Selengkapnya',
                        style: const TextStyle(
                          color: Color(0xFF0077B5),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }),

          const SizedBox(height: 8),

          // ── MEMBER COUNTER ──────────────────────────────────────
          _buildMemberCounter(post),

          const Divider(height: 16),

          // ── FOOTER ROW: tanggal + status/apply ──────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time,
                      size: 18, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    post['created_at'] != null
                        ? post['created_at']
                            .toString()
                            .substring(0, 10)
                        : '-',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),

              if (isMyPost)
                _buildOwnerStatusBadge(post,
                    isClosed: isClosed,
                    isCompleted: isCompleted,
                    isApply: isApply)
              else if (!isOwn)
                ElevatedButton(
                  // [DIPERBARUI] Disable tombol jika apply sedang diproses
                  onPressed: (kuotaPenuh || isApply || isApplying)
                      ? null
                      : () => _applyJob(post['id']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (kuotaPenuh || isApply || isApplying)
                        ? Colors.grey.shade400
                        : const Color(0xFF0077B5),
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                  child: isApplying
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          kuotaPenuh
                              ? 'Kuota Penuh'
                              : (isApply ? 'sudah apply' : 'Apply'),
                          style: TextStyle(
                            color: (kuotaPenuh || isApply)
                                ? Colors.grey.shade600
                                : Colors.white,
                          ),
                        ),
                )
              else
                const Text('Postingan Sendiri',
                    style: TextStyle(color: Colors.grey)),
            ],
          ),

          // ── TOMBOL AKSI OWNER (hanya di My Post) ────────────────
          if (isMyPost && !isCompleted) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                if (!isClosed)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _closeRecruitment(post['id']),
                      icon: const Icon(Icons.lock_outline,
                          size: 16, color: Colors.orange),
                      label: const Text(
                        'Tutup Rekrutmen',
                        style: TextStyle(
                            color: Colors.orange, fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.orange),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),

                if (!isClosed) const SizedBox(width: 8),

                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _completeProject(post['id']),
                    icon: const Icon(Icons.check_circle_outline,
                        size: 16, color: Colors.green),
                    label: const Text(
                      'Proyek Selesai',
                      style: TextStyle(
                          color: Colors.green, fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.green),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Badge status di My Post
  Widget _buildOwnerStatusBadge(
    Map post, {
    required bool isClosed,
    required bool isCompleted,
    required bool isApply,
  }) {
    if (isCompleted) {
      return _statusBadge(
        icon: Icons.check_circle,
        label: 'Proyek Selesai',
        color: Colors.green,
        bgColor: Colors.green.shade50,
      );
    }

    if (isClosed) {
      return _statusBadge(
        icon: Icons.lock,
        label: 'Ditutup',
        color: Colors.red.shade600,
        bgColor: Colors.red.shade50,
      );
    }

    if (isApply) {
      return _statusBadge(
        icon: Icons.lock_open,
        label: 'Masih Buka',
        color: const Color(0xFF0077B5),
        bgColor: const Color(0xFFE8F4FD),
      );
    }

    return _statusBadge(
      icon: Icons.group_off,
      label: 'Kuota Penuh',
      color: Colors.grey.shade600,
      bgColor: Colors.grey.shade100,
    );
  }

  Widget _statusBadge({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostList(
    List posts,
    bool isLoading, {
    required bool isMyPost,
  }) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF0077B5)),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (isMyPost) {
          await _fetchMyPosts();
        } else {
          await fetchPosts();
        }
      },
      color: const Color(0xFF0077B5),
      child: posts.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.55,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isMyPost
                              ? Icons.article_outlined
                              : Icons.search_off,
                          size: 56,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isMyPost
                              ? (_searchQuery.isNotEmpty || _selectedFilterType != null
                                  ? 'Postinganmu tidak ditemukan\ndengan filter ini.'
                                  : 'Kamu belum punya postingan.\nYuk bikin yang pertama!')
                              : (_searchQuery.isNotEmpty || _selectedFilterType != null
                                  ? 'Nggak ada postingan dengan\nfilter yang kamu pilih.'
                                  : 'Belum ada postingan nih.'),
                          style:
                              TextStyle(color: Colors.grey[500], fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: posts.length,
              itemBuilder: (context, index) =>
                  _buildPostCard(posts[index], isMyPost: isMyPost),
            ),
    );
  }

  // ─── BUILD ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bool isFilterActive = _selectedFilterType != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // ── TAB BAR ─────────────────────────────────────────────
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF0077B5),
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(fontSize: 14),
              indicatorColor: const Color(0xFF0077B5),
              indicatorWeight: 2.5,
              tabs: const [
                Tab(text: 'For You'),
                Tab(text: 'My Post'),
              ],
            ),
          ),

          // ── SEARCH BAR + FILTER ICON ─────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Cari skill... contoh: #Flutter',
                      hintStyle:
                          const TextStyle(color: Colors.grey, fontSize: 14),
                      prefixIcon: const Icon(Icons.search,
                          color: Colors.grey, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close,
                                  color: Colors.grey, size: 20),
                              onPressed: _clearSearch,
                            )
                          : null,
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(
                            color: Color(0xFF0077B5), width: 1.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    GestureDetector(
                      onTap: _showFilterBottomSheet,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isFilterActive
                              ? const Color(0xFF0077B5)
                              : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.tune_rounded,
                          size: 22,
                          color: isFilterActive
                              ? Colors.white
                              : Colors.grey,
                        ),
                      ),
                    ),
                    if (isFilterActive)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Filter aktif badge indicator
          if (isFilterActive)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                children: [
                  Chip(
                    label: Text(
                      _selectedFilterType!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF0077B5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    avatar: const Icon(
                      Icons.filter_list,
                      size: 14,
                      color: Color(0xFF0077B5),
                    ),
                    deleteIcon: const Icon(
                      Icons.close,
                      size: 14,
                      color: Color(0xFF0077B5),
                    ),
                    onDeleted: () {
                      setState(() => _selectedFilterType = null);
                      fetchPosts();
                      _fetchMyPosts();
                    },
                    backgroundColor: const Color(0xFFE7F3FF),
                    side: const BorderSide(color: Color(0xFF0077B5)),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),

          // ── CONTENT ─────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPostList(
                  _forYouPosts,
                  _isLoadingForYou,
                  isMyPost: false,
                ),
                _buildPostList(
                  _myPosts,
                  _isLoadingMyPost,
                  isMyPost: true,
                ),
              ],
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const CreatePostScreen()),
          );
          if (result == true) {
            fetchPosts();
            _fetchMyPosts();
            _tabController.animateTo(1);
          }
        },
        backgroundColor: const Color(0xFF0077B5),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}