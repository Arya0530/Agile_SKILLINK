import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';
import 'edit_post_screen.dart';

class SmartFeedScreen extends StatefulWidget {
  const SmartFeedScreen({super.key});

  @override
  State<SmartFeedScreen> createState() => SmartFeedScreenState();
}

class SmartFeedScreenState extends State<SmartFeedScreen> {
  List posts = [];
  bool isLoading = true;
  String myName = '';
  String _searchQuery = ''; // teks yang lagi diketik user
  Timer? _debounceTimer; // timer biar tidak spam request tiap ketik

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchPosts() async {
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token');

    // Kalau ada teks pencarian, kirim sebagai query parameter ?tag=
    final uri = Uri.parse('${ApiConfig.baseUrl}/posts').replace(
      queryParameters: _searchQuery.isNotEmpty ? {'tag': _searchQuery} : {},
    );

    try {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          posts = data['data'];
          isLoading = false;
          myName = prefs.getString('user_name') ?? '';
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Error narik data: $e");
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  // Dipanggil setiap user mengetik — pakai debounce 500ms biar tidak spam request
  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() => _searchQuery = value.trim());
      fetchPosts();
    });
  }

  // Reset pencarian
  void _clearSearch() {
    _searchController.clear();
    setState(() => _searchQuery = '');
    fetchPosts();
  }

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
      }
    } catch (e) {
      debugPrint("Gagal hapus: $e");
    }
  }

  Future<void> _applyJob(int postId) async {
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

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message']),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message']), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      debugPrint("Gagal Apply: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --- SEARCH BAR ---
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Cari skill... contoh: #Flutter',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              prefixIcon: const Icon(
                Icons.search,
                color: Colors.grey,
                size: 20,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.grey,
                        size: 20,
                      ),
                      onPressed: _clearSearch,
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 16,
              ),
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
                  color: Color(0xFF0077B5),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),

        // --- LIST POSTINGAN ---
        Expanded(
child: isLoading
? const Center(
child: CircularProgressIndicator(color: Color(0xFF0077B5)),
)
: RefreshIndicator(
onRefresh: fetchPosts,
color: const Color(0xFF0077B5),
child: posts.isEmpty
? ListView(
physics: const AlwaysScrollableScrollPhysics(),
children: [
SizedBox(
height: MediaQuery.of(context).size.height * 0.6,
child: Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
const Icon(
Icons.search_off,
size: 48,
color: Colors.grey,
),
const SizedBox(height: 12),
Text(
_searchQuery.isNotEmpty
? 'Nggak ada postingan dengan tag "$_searchQuery"'
: 'Belum ada postingan nih.',
style: const TextStyle(color: Colors.grey),
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
itemBuilder: (context, index) {
final post = posts[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // HEADER
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey[300],
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post['author_name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '${post['author_major']} • ${post['post_type']}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          if (post['author_name'] == myName)
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
                                  if (result == true) fetchPosts();
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
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Batal'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _deletePost(post['id']);
                                          },
                                          child: const Text(
                                            'Hapus',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit Postingan'),
                                ),
                                const PopupMenuItem(
                                  value: 'hapus',
                                  child: Text('Hapus'),
                                ),
                              ],
                            ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // CONTENT
                      Text(post['content']),
                      const SizedBox(height: 8),

                      // TAG
                      Text(
                        post['tags'],
                        style: const TextStyle(
                          color: Color(0xFF0077B5),
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const Divider(height: 30),

                      // FOOTER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 18, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                post['created_at'] != null
                                    ? post['created_at'].toString().substring(0, 10)
                                    : '-',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          post['author_name'] != myName
                              ? 
                            ElevatedButton(
                              onPressed: () => _applyJob(post['id']),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: post['is_apply'] == 1
                                    ? const Color(0xFF0077B5)
                                    : const Color(0xFF0077B5), // kalau mau sama semua warna
                              ),
                              child: Text(
                                post['is_apply'] == 1
                                    ? 'Easy Apply'
                                    : 'Apply',
                                style: const TextStyle(color: Colors.white),
                              ),
                            )
                              : const Text(
                                  'Postingan Sendiri',
                                  style: TextStyle(color: Colors.grey),
                                ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    ),
)
      ],
    );
  }
}
