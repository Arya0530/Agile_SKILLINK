import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_config.dart';
import 'main.dart'; 
import 'register_screen.dart'; 
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscure = true;
  bool _isLoading = false; // Status buat animasi muter pas tombol diklik

  // --- FUNGSI BUAT NGECEK LOGIN KE LARAVEL ---
  Future<void> loginUser() async {
    setState(() {
      _isLoading = true;
    });

    // PENTING: IP WiFi lu!
    final url = Uri.parse('${ApiConfig.baseUrl}/login');

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json', // Wajib biar ga miskom lagi
        },
        body: {
          'email': _emailController.text,
          'password': _passwordController.text,
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Kalau sukses cocok, tendang masuk ke halaman Home (MainNavigation)
      if (response.statusCode == 200 && data['success'] == true) {
        // 1. Panggil memori HP-nya
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('user_token', data['token']);
        // 2. Simpen Tiket (Token) dan Nama lu ke dalam memori
        await prefs.setString('token', data['token']);
        await prefs.setString('user_name', data['data']['name']);
        await prefs.setString('user_major', data['data']['jurusan']?.toString() ?? 'Jurusan Belum Diatur');
        
        // (Boleh tambahin email atau ID kalau nanti butuh)
        // await prefs.setString('user_email', data['data']['email']);

        // 3. Baru deh tendang masuk ke halaman Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigation()),
        );
      }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigation()),
        );
      } else {
        // Kalau email/password salah
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Login gagal!'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      debugPrint("Waduh, error login: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal nyambung ke server!'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('SKILLINK', textAlign: TextAlign.center, style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFF0077B5))),
                const SizedBox(height: 10),
                const Text('Masuk untuk mulai kolaborasi', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 50),

                TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: _buildInputDecor('Email Mahasiswa / Pribadi', Icons.email_outlined)),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: _isObscure,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() { _isObscure = !_isObscure; });
                      },
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 10),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(onPressed: () {}, child: const Text('Lupa Password?', style: TextStyle(color: Color(0xFF0077B5)))),
                ),
                const SizedBox(height: 20),

                // TOMBOL LOGIN UDAH PAKAI API
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0077B5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isLoading ? null : () {
                      // Panggil fungsi cek ke Laravel
                      loginUser();
                    },
                    child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : const Text('LOGIN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                
                const SizedBox(height: 16),

                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF0077B5), width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                  },
                  child: const Text('REGISTER', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0077B5))),
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