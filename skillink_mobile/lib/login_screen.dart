import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_config.dart';
import 'main.dart';
import 'register_screen.dart';
import 'reset_password_screen.dart';
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
  bool _isLoading = false;

  Future<void> loginUser() async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('${ApiConfig.baseUrl}/login');

    try {
      final response = await http.post(
        url,

        headers: {'Accept': 'application/json'},

        body: {
          'email': _emailController.text,
          'password': _passwordController.text,
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();

        prefs.setString('user_token', data['token']);

        await prefs.setString('token', data['token']);

        await prefs.setString('user_name', data['data']['name']);

        await prefs.setString(
          'user_major',
          data['data']['jurusan']?.toString() ?? 'Jurusan Belum Diatur',
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigation()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Login gagal!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error login: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal nyambung ke server!'),
          backgroundColor: Colors.red,
        ),
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
      backgroundColor: const Color(0xFFF4F7FB),

      body: SafeArea(
        child: Stack(
          children: [
            // DEKORASI ATAS
            Positioned(
              top: -120,
              right: -80,

              child: Container(
                width: 260,
                height: 260,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  color: const Color(0xFF0077B5).withOpacity(0.08),
                ),
              ),
            ),

            // DEKORASI BAWAH
            Positioned(
              bottom: -100,
              left: -70,

              child: Container(
                width: 240,
                height: 240,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  color: const Color(0xFF0077B5).withOpacity(0.05),
                ),
              ),
            ),

            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),

                      child: IntrinsicHeight(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),

                          child: Align(
                            alignment: const Alignment(0, -0.15),

                            child: Column(
                              mainAxisSize: MainAxisSize.min,

                              crossAxisAlignment: CrossAxisAlignment.stretch,

                              children: [
                                // LOGO
                                Container(
                                  height: 100,
                                  width: 100,

                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,

                                    color: const Color(
                                      0xFF0077B5,
                                    ).withOpacity(0.1),
                                  ),

                                  child: const Icon(
                                    Icons.groups_rounded,
                                    size: 50,
                                    color: Color(0xFF0077B5),
                                  ),
                                ),

                                const SizedBox(height: 30),

                                const Text(
                                  'SKILLINK',
                                  textAlign: TextAlign.center,

                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0077B5),
                                    letterSpacing: 1,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                const Text(
                                  'Masuk untuk mulai kolaborasi dan bangun koneksi',
                                  textAlign: TextAlign.center,

                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey,
                                    height: 1.5,
                                  ),
                                ),

                                const SizedBox(height: 40),

                                // CARD LOGIN
                                Container(
                                  padding: const EdgeInsets.all(22),

                                  decoration: BoxDecoration(
                                    color: Colors.white,

                                    borderRadius: BorderRadius.circular(22),

                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),

                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),

                                  child: Column(
                                    children: [
                                      TextField(
                                        controller: _emailController,

                                        keyboardType:
                                            TextInputType.emailAddress,

                                        decoration: _buildInputDecor(
                                          'Email Mahasiswa / Pribadi',
                                          Icons.email_outlined,
                                        ),
                                      ),

                                      const SizedBox(height: 20),

                                      TextField(
                                        controller: _passwordController,

                                        obscureText: _isObscure,

                                        decoration: InputDecoration(
                                          labelText: 'Password',

                                          prefixIcon: const Icon(
                                            Icons.lock_outline,
                                          ),

                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _isObscure
                                                  ? Icons.visibility_off
                                                  : Icons.visibility,
                                            ),

                                            onPressed: () {
                                              setState(() {
                                                _isObscure = !_isObscure;
                                              });
                                            },
                                          ),

                                          filled: true,
                                          fillColor: const Color(0xFFF7F9FC),

                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),

                                            borderSide: BorderSide.none,
                                          ),

                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),

                                            borderSide: const BorderSide(
                                              color: Color(0xFF0077B5),
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 8),

                                      Align(
                                        alignment: Alignment.centerRight,

                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,

                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const ResetPasswordScreen(),
                                              ),
                                            );
                                          },

                                          child: const Text(
                                            'Lupa Password?',
                                            style: TextStyle(
                                              color: Color(0xFF0077B5),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 12),

                                      SizedBox(
                                        width: double.infinity,

                                        height: 54,

                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF0077B5,
                                            ),

                                            elevation: 2,

                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                          ),

                                          onPressed: _isLoading
                                              ? null
                                              : loginUser,

                                          child: _isLoading
                                              ? const SizedBox(
                                                  height: 24,
                                                  width: 24,

                                                  child:
                                                      CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 2.5,
                                                      ),
                                                )
                                              : const Text(
                                                  'LOGIN',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                        ),
                                      ),

                                      const SizedBox(height: 16),

                                      SizedBox(
                                        width: double.infinity,

                                        height: 54,

                                        child: OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(
                                              color: Color(0xFF0077B5),
                                              width: 2,
                                            ),

                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                          ),

                                          onPressed: () {
                                            Navigator.push(
                                              context,

                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const RegisterScreen(),
                                              ),
                                            );
                                          },

                                          child: const Text(
                                            'REGISTER',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF0077B5),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 18),

                                const Text(
                                  'SKILLINK © 2026',
                                  textAlign: TextAlign.center,

                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecor(String label, IconData icon) {
    return InputDecoration(
      labelText: label,

      prefixIcon: Icon(icon),

      filled: true,

      fillColor: const Color(0xFFF7F9FC),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),

        borderSide: BorderSide.none,
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),

        borderSide: const BorderSide(color: Color(0xFF0077B5), width: 2),
      ),
    );
  }
}
