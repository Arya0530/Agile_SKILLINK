import 'edit_post_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SmartFeedScreen extends StatefulWidget {
  const SmartFeedScreen({super.key});

  @override
  State<SmartFeedScreen> createState() => _SmartFeedScreenState();
}

class _SmartFeedScreenState extends State<SmartFeedScreen> {
  List posts = [];
  bool isLoading = true;
  String myName = '';

  @override
  void initState() {
    super.initState();
    fetchPosts(); 
  }

  Future<void> fetchPosts() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/posts');
    final prefs = await SharedPreferences.getInstance();
    
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          posts = data['data'];
          isLoading = false;
          myName = prefs.getString('user_name') ?? '';
        });
      }
    } catch (e) {
      print("Error narik data: $e");
      if (!mounted) return;
      setState(() {
        isLoading = false; 
      });
    }
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

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message']), backgroundColor: Colors.green),
        );
        fetchPosts(); // Refresh layar biar postingannya langsung ilang
      }
    } catch (e) {
      debugPrint("Gagal hapus: $e");
    }
  }
  // Fungsi nembak API Easy Apply
  Future<void> _applyJob(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token');

    // Nampilin pop-up loading kecil
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mengirim lamaran...'), duration: Duration(seconds: 1)),
    );

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/posts/$postId/apply'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        // Kalau sukses (dapet balasan 200 dari Laravel)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message']), backgroundColor: Colors.green),
        );
      } else {
        // Kalau gagal (misal: spam apply atau apply project sendiri)
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
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF0077B5)));
    }
    if (posts.isEmpty) {
      return const Center(child: Text("Belum ada postingan nih."));
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
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
              Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.grey[300],
          child: const Icon(Icons.person, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post['author_name'],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('${post['author_major']} • ${post['post_type']}',
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ],
    ),
    // 👇 MUNCULIN TITIK TIGA KALAU NAMA PEMBUAT = NAMA LU
                  if (post['author_name'] == myName)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_horiz, color: Colors.grey), // Icon titik tiga horizontal
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onSelected: (value) async  {
                      if (value == 'edit') {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditPostScreen(post: post),
                          ),
                        );

                        if (result == true) {
                          fetchPosts();
                         }
                        } else if (value == 'hapus') {
                          // Pop-up Konfirmasi Hapus (Sama kayak tadi)
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: Colors.white,
                              title: const Text('Hapus Postingan?'),
                              content: const Text('Yakin mau hapus postingan ini? Nggak bisa dibalikin lho.'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Tutup pop-up
                                    _deletePost(post['id']); // Tembak API hapus
                                  }, 
                                  child: const Text('Hapus', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                                ),
                              ],
                            )
                          );
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, color: Color(0xFF0077B5), size: 20),
                              SizedBox(width: 12),
                              Text('Edit Postingan'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'hapus',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, color: Colors.red, size: 20),
                              SizedBox(width: 12),
                              Text('Hapus', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                           ],
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              Text(post['content']),
              const SizedBox(height: 8),
              Text(post['tags'], style: const TextStyle(color: Color(0xFF0077B5), fontWeight: FontWeight.bold)),
              const Divider(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.thumb_up_alt_outlined, color: Colors.grey[600], size: 20),
                      const SizedBox(width: 4),
                      Text('Suka', style: TextStyle(color: Colors.grey[600])),
                      const SizedBox(width: 16),
                      Icon(Icons.chat_bubble_outline, color: Colors.grey[600], size: 20),
                      const SizedBox(width: 4),
                      Text('Komen', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                  post['author_name'] != myName
    ? ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: post['is_apply'] == 1
              ? const Color(0xFF0077B5)
              : Colors.green,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
        ),
        onPressed: () {
          _applyJob(post['id']);
        },
        child: Text(
          post['is_apply'] == 1 ? 'Easy Apply' : 'Sewa Jasa',
          style: const TextStyle(color: Colors.white),
        ),
      )
    : const Text(
        'Postingan Sendiri',
        style: TextStyle(
          color: Colors.grey,
          fontStyle: FontStyle.italic,
        ),
      )
                ],
              )
            ],
          ),
        );
      },
    );
  }
}