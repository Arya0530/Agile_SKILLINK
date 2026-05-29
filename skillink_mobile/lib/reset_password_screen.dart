import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'dart:convert';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false;

  Future<void> sendResetLink() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email tidak boleh kosong'),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan alamat Gmail yang valid'),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/forgot-password'),

        body: {"email": email},
      );

      if (!mounted) return;

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message']),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Email tidak terdaftar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
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

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),

          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: SafeArea(
        child: Stack(
          children: [
            // BULATAN DEKORASI ATAS
            Positioned(
              top: -80,
              right: -60,

              child: Container(
                width: 220,
                height: 220,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0077B5).withOpacity(0.08),
                ),
              ),
            ),

            // BULATAN DEKORASI BAWAH
            Positioned(
              bottom: -100,
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

            LayoutBuilder(
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
                          alignment: const Alignment(0, -0.35),

                          child: Column(
                            mainAxisSize: MainAxisSize.min,

                            crossAxisAlignment: CrossAxisAlignment.stretch,

                            children: [
                              // ICON
                              Container(
                                height: 90,
                                width: 90,

                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF0077B5,
                                  ).withOpacity(0.1),

                                  shape: BoxShape.circle,
                                ),

                                child: const Icon(
                                  Icons.lock_reset,
                                  size: 45,
                                  color: Color(0xFF0077B5),
                                ),
                              ),

                              const SizedBox(height: 28),

                              const Text(
                                'Reset Password',
                                textAlign: TextAlign.center,

                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0077B5),
                                ),
                              ),

                              const SizedBox(height: 12),

                              const Text(
                                'Masukkan email untuk menerima link reset password',
                                textAlign: TextAlign.center,

                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15,
                                  height: 1.5,
                                ),
                              ),

                              const SizedBox(height: 40),

                              // CARD FORM
                              Container(
                                padding: const EdgeInsets.all(20),

                                decoration: BoxDecoration(
                                  color: Colors.white,

                                  borderRadius: BorderRadius.circular(20),

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

                                      keyboardType: TextInputType.emailAddress,

                                      decoration: InputDecoration(
                                        labelText: 'Email',

                                        hintText: 'Masukkan email',

                                        prefixIcon: const Icon(
                                          Icons.email_outlined,
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

                                    const SizedBox(height: 24),

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
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                        ),

                                        onPressed: _isLoading
                                            ? null
                                            : sendResetLink,

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
                                                'Kirim Link Reset',
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
          ],
        ),
      ),
    );
  }
}
