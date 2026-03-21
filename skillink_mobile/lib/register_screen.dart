import 'package:flutter/material.dart';
import 'api_config.dart';
import 'login_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _selectedJurusan;

final List<String> _jurusanList = [
  'D3 Teknik Informatika',
  'D3 Teknologi Multimedia Broadcasting (MMB)'
];
  bool _isObscure = true;
  bool _isLoading = false; // Buat nampilin loading pas lagi ngirim data

// --- FUNGSI BUAT NEMBAK DATA KE LARAVEL ---
  Future<void> registerUser() async {

  // ✅ TARUH DI SINI (PALING ATAS)
  if (_selectedJurusan == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pilih jurusan dulu!'),
        backgroundColor: Colors.orange,
      ),
    );
    return;
  }

  setState(() {
    _isLoading = true;
  });

  final url = Uri.parse('${ApiConfig.baseUrl}/register');

    try {
  final response = await http.post(
    url,
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'name': _nameController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
      'jurusan': _selectedJurusan,
    }),
  );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Kalau sukses, kasih tau user pakai pop-up kecil di bawah
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pendaftaran Berhasil! Silakan Login.'), backgroundColor: Colors.green),
        );
        // Terus tendang balik ke layar Login
        Navigator.pop(context);
      } else {
        // Kalau gagal (misal email udah dipakai / password kurang panjang)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: ${data['message'] ?? 'Cek isian form lu!'}'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      // 👇 ERROR ASLINYA BAKAL MUNCUL DI DEBUG CONSOLE LU 👇
      debugPrint("Waduh, error nembak API: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal nyambung ke server! Cek WiFi lu.'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false; // Matiin loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0077B5)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Daftar Akun', textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0077B5))),
                const SizedBox(height: 10),
                const Text('Lengkapi data untuk bergabung di SKILLINK', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 40),

                TextField(controller: _nameController, decoration: _buildInputDecor('Nama Lengkap', Icons.person_outline)),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  isExpanded: true,
  decoration: InputDecoration(
    labelText: 'Jurusan',
    prefixIcon: const Icon(Icons.school),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  ),
  value: _selectedJurusan,
  items: _jurusanList.map((jurusan) {
    return DropdownMenuItem(
      value: jurusan,
      child: Text(jurusan),
    );
  }).toList(),
  onChanged: (value) {
    setState(() {
      _selectedJurusan = value;
    });
  },
),
                const SizedBox(height: 16),
                TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: _buildInputDecor('Email', Icons.email_outlined)),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: _isObscure,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 30),

                // Tombol Register
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0077B5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isLoading ? null : () {
                      // Pas dipencet, jalanin fungsi nembak ke Laravel
                      registerUser();
                    },
                    child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : const Text('DAFTAR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecor(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}