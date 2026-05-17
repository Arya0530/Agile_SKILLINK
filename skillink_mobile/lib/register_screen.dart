import 'package:flutter/material.dart';
import 'api_config.dart';
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

  final TextEditingController _noWaController = TextEditingController();

  String? _selectedJurusan;

  final List<String> _jurusanList = [
    'D3 Teknik Informatika',
    'D3 Teknologi Multimedia Broadcasting (MMB)',
  ];

  bool _isObscure = true;
  bool _isLoading = false;

  // REGISTER FUNCTION
  Future<void> registerUser() async {
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
          'no_wa': _noWaController.text,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pendaftaran Berhasil! Silakan Login.'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: ${data['message'] ?? 'Cek isian form lu!'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint("Waduh, error nembak API: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal nyambung ke server! Cek WiFi lu.'),
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

      body: Stack(
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
            bottom: -120,
            left: -80,

            child: Container(
              width: 260,
              height: 260,

              decoration: BoxDecoration(
                shape: BoxShape.circle,

                color: const Color(0xFF0077B5).withOpacity(0.05),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,

                children: [
                  Align(
                    alignment: Alignment.centerLeft,

                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },

                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ICON
                  Container(
                    height: 100,
                    width: 100,

                    decoration: BoxDecoration(
                      shape: BoxShape.circle,

                      color: const Color(0xFF0077B5).withOpacity(0.1),
                    ),

                    child: const Icon(
                      Icons.person_add_alt_1,
                      size: 50,
                      color: Color(0xFF0077B5),
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'Create Account',
                    textAlign: TextAlign.center,

                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0077B5),
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Gabung dan mulai bangun koneksi bersama SKILLINK',
                    textAlign: TextAlign.center,

                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 36),

                  // CARD
                  Container(
                    padding: const EdgeInsets.all(22),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.circular(24),

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
                        _buildInput(
                          controller: _nameController,

                          label: 'Nama Lengkap',

                          icon: Icons.person_outline,
                        ),

                        const SizedBox(height: 18),

                        DropdownButtonFormField<String>(
                          isExpanded: true,

                          value: _selectedJurusan,

                          decoration: InputDecoration(
                            labelText: 'Jurusan',

                            prefixIcon: const Icon(Icons.school),

                            filled: true,

                            fillColor: const Color(0xFFF7F9FC),

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),

                              borderSide: BorderSide.none,
                            ),

                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),

                              borderSide: const BorderSide(
                                color: Color(0xFF0077B5),
                                width: 2,
                              ),
                            ),
                          ),

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

                        const SizedBox(height: 18),

                        _buildInput(
                          controller: _noWaController,

                          label: 'Nomor WhatsApp',

                          icon: Icons.phone_android,

                          type: TextInputType.phone,
                        ),

                        const SizedBox(height: 18),

                        _buildInput(
                          controller: _emailController,

                          label: 'Email',

                          icon: Icons.email_outlined,

                          type: TextInputType.emailAddress,
                        ),

                        const SizedBox(height: 18),

                        TextField(
                          controller: _passwordController,

                          obscureText: _isObscure,

                          decoration: InputDecoration(
                            labelText: 'Password',

                            prefixIcon: const Icon(Icons.lock_outline),

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
                              borderRadius: BorderRadius.circular(14),

                              borderSide: BorderSide.none,
                            ),

                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),

                              borderSide: const BorderSide(
                                color: Color(0xFF0077B5),
                                width: 2,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        SizedBox(
                          width: double.infinity,

                          height: 54,

                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0077B5),

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),

                            onPressed: _isLoading ? null : registerUser,

                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,

                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    'REGISTER',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
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

                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType type = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: type,

      decoration: InputDecoration(
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
      ),
    );
  }
}
