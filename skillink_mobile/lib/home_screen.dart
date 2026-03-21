import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_config.dart';

class SmartFeedScreen extends StatefulWidget {
  const SmartFeedScreen({super.key});

  @override
  State<SmartFeedScreen> createState() => _SmartFeedScreenState();
}

class _SmartFeedScreenState extends State<SmartFeedScreen> {
  List posts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPosts(); 
  }

  Future<void> fetchPosts() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/posts');
    
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          posts = data['data'];
          isLoading = false;
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
                children: [
                  CircleAvatar(backgroundColor: Colors.grey[300], child: const Icon(Icons.person, color: Colors.white)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post['author_name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('${post['author_major']} • ${post['post_type']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
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
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: post['is_apply'] == 1 ? const Color(0xFF0077B5) : Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: () {},
                    child: Text(post['is_apply'] == 1 ? 'Easy Apply' : 'Sewa Jasa', style: const TextStyle(color: Colors.white)),
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