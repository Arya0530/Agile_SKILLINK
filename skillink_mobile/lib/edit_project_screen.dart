import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class EditProjectScreen extends StatefulWidget {
  // Kalau projectId tidak null = mode EDIT, kalau null = mode TAMBAH BARU
  final int? projectId;
  final String? initialTitle;
  final String? initialRole;
  final String? initialDescription;

  const EditProjectScreen({
    super.key,
    this.projectId,
    this.initialTitle,
    this.initialRole,
    this.initialDescription,
  });

  @override
  State<EditProjectScreen> createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends State<EditProjectScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _roleController;
  late final TextEditingController _descController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _roleController  = TextEditingController(text: widget.initialRole ?? '');
    _descController  = TextEditingController(text: widget.initialDescription ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _roleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _saveProject() async {
    if (_titleController.text.trim().isEmpty || _roleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Judul dan Peran wajib diisi.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('user_token');

      final body = jsonEncode({
        'title':       _titleController.text.trim(),
        'role':        _roleController.text.trim(),
        'description': _descController.text.trim(),
      });

      final headers = {
        'Content-Type':  'application/json',
        'Accept':        'application/json',
        'Authorization': 'Bearer $token',
      };

      http.Response response;

      if (widget.projectId != null) {
        // Mode EDIT — pakai PUT
        response = await http.put(
          Uri.parse('${ApiConfig.baseUrl}/profile/projects/${widget.projectId}'),
          headers: headers,
          body: body,
        );
      } else {
        // Mode TAMBAH BARU — pakai POST
        response = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/profile/projects'),
          headers: headers,
          body: body,
        );
      }

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.projectId != null
                ? 'Proyek berhasil diperbarui!'
                : 'Proyek berhasil ditambahkan!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // true = ada perubahan, profil perlu di-refresh
      } else {
        final data = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: ${data['message'] ?? response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error save project: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.projectId != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          isEditMode ? 'Edit Proyek' : 'Tambah Proyek Baru',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF0077B5),
          ),
        ),
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0077B5)))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'DETAIL RIWAYAT PROYEK',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                _buildField(_titleController, 'Judul Proyek'),
                _buildField(_roleController, 'Peran Kamu di Proyek'),
                _buildField(_descController, 'Deskripsi Singkat', maxLines: 4),

                const SizedBox(height: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0077B5),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: _saveProject,
                  child: Text(
                    isEditMode ? 'SIMPAN PERUBAHAN' : 'SIMPAN PROYEK',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String hint, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}