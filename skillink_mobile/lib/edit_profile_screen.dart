import 'package:flutter/material.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Edit Profil", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0077B5))), 
        foregroundColor: Colors.black, 
        backgroundColor: Colors.white, 
        elevation: 1
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildField("Nama Lengkap", "Masukkan nama"),
          _buildField("Nomor WhatsApp", "0812..."),
          _buildField("Email", "email@gmail.com"),
          _buildField("Jurusan", "Contoh: Teknik Informatika"),
          _buildField("Password Baru", "Isi jika ingin ganti", isPass: true),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0077B5), 
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
            ),
            onPressed: () { 
              // TODO: Backend handle save profile
            },
            child: const Text("SIMPAN PROFIL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, String hint, {bool isPass = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            obscureText: isPass,
            decoration: InputDecoration(
              hintText: hint, 
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF0077B5), width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}