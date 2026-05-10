import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'network_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';
import 'create_post_screen.dart';

void main() {
  runApp(const SkillinkApp());
}

class SkillinkApp extends StatelessWidget {
  const SkillinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SKILLINK',
      theme: ThemeData(
        primaryColor: const Color(0xFF0077B5),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),

      // CEK LOGIN DULU
      home: const CheckLogin(),
    );
  }
}

// CHECK LOGIN

class CheckLogin extends StatefulWidget {
  const CheckLogin({super.key});

  @override
  State<CheckLogin> createState() => _CheckLoginState();
}

class _CheckLoginState extends State<CheckLogin> {
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString('token');

    return token != null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isLoggedIn(),
      builder: (context, snapshot) {
        // Loading
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Kalau sudah login
        if (snapshot.data == true) {
          return const MainNavigation();
        }

        // Kalau belum login
        return const LoginScreen();
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // GlobalKey untuk akses fetchPosts() dari luar (dipakai FAB setelah buat postingan)
  final GlobalKey<SmartFeedScreenState> _feedKey = GlobalKey();

  List<Widget> get _widgetOptions => [
    SmartFeedScreen(key: _feedKey),
    const NetworkScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'SKILLINK',
          style: TextStyle(
            color: Color(0xFF0077B5),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          // Tombol logout
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.grey),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Logout Confirmation'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0077B5),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        child: const Text('Logout'),
                      ),
                    ],
                  );
                },
              );

              if (confirm == true) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                if (!mounted) return;

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Jaringan'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF0077B5),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
