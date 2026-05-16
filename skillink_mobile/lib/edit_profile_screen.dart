import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {

  bool _obscurePassword = true;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _noWaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _selectedJurusan;
  bool _isLoading = false;
  bool _isLoadingData = true;

  // List of available jurusan
  final List<String> _jurusanList = [
    'D3 Teknik Informatika',
    'D3 Teknologi Multimedia Broadcasting (MMB)',
  ];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // Fetch data profil yang ada dari API
  Future<void> _loadProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('user_token');

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Token tidak ditemukan!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/profile'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          var jurusanFromDB = data['data']['jurusan'];
          
          // Normalize jurusan - jika tidak ada di list, map ke opsi terdekat
          if (jurusanFromDB != null && !_jurusanList.contains(jurusanFromDB)) {
            // "Multi media" → "D3 Teknologi Multimedia Broadcasting (MMB)"
            if (jurusanFromDB.toString().toLowerCase().contains('multimedia') || 
                jurusanFromDB.toString().toLowerCase().contains('multi media')) {
              jurusanFromDB = 'D3 Teknologi Multimedia Broadcasting (MMB)';
            }
          }
          
          setState(() {
            _nameController.text = data['data']['name'] ?? '';
            _emailController.text = data['data']['email'] ?? '';
            _noWaController.text = data['data']['no_wa'] ?? '';
            _selectedJurusan = jurusanFromDB;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    } finally {
      setState(() => _isLoadingData = false);
    }
  }

  // Update profil ke database
  Future<void> _updateProfile() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _noWaController.text.isEmpty ||
        _selectedJurusan == null ||
        _selectedJurusan!.isEmpty) {
          
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua field wajib diisi!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('user_token');

      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      // Buat request body
      final body = {
        'name': _nameController.text,
        'email': _emailController.text,
        'no_wa': _noWaController.text,
        'jurusan': _selectedJurusan,
      };

      // Jika password diisi, tambahkan ke body
      if (_passwordController.text.isNotEmpty) {
        body['password'] = _passwordController.text;
        body['password_confirmation'] = _passwordController.text;
      }

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/profile'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        // Update shared preferences
        await prefs.setString('user_name', _nameController.text);
        await prefs.setString('user_major', _selectedJurusan!);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );

        // Kembali ke halaman sebelumnya dengan result = true untuk trigger refresh
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? 'Gagal update profil!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal terhubung ke server!'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Edit Profil",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFF0077B5))),
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildField("Nama Lengkap", "Masukkan nama", _nameController),
                _buildField(
                    "Nomor WhatsApp", "0812...", _noWaController),
                _buildField("Email", "email@gmail.com", _emailController),
                _buildJurusanDropdown(),
                _buildField("Password Baru", "Isi jika ingin ganti",
                    _passwordController,
                    isPass: true),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0077B5),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onPressed: _isLoading ? null : _updateProfile,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text("SIMPAN PROFIL",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                ),
              ],
            ),
    );
  }

  Widget _buildJurusanDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Jurusan",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: _selectedJurusan,
              hint: const Padding(
                padding: EdgeInsets.only(left: 12),
                child: Text("Pilih Jurusan",
                    style: TextStyle(color: Colors.grey, fontSize: 14)),
              ),
              isExpanded: true,
              underline: const SizedBox(),
              items: _jurusanList.map((String jurusan) {
                return DropdownMenuItem<String>(
                  value: jurusan,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(jurusan),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedJurusan = newValue;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildField(
  String label,
  String hint,
  TextEditingController controller, {
  bool isPass = false,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,

          // ⭐ PASSWORD HIDE / SHOW
          obscureText: isPass ? _obscurePassword : false,

          decoration: InputDecoration(
            hintText: hint,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

            // ⭐ ICON MATA
            suffixIcon: isPass
                ? IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  )
                : null,

            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: Color(0xFF0077B5), width: 1.5),
            ),
          ),
        ),
      ],
    ),
  );
}

  @override
  void dispose() {
    _nameController.dispose();
    _noWaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}