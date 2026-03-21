import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'network_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';
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
      home: const LoginScreen(),
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
  Key _homeRefreshKey = UniqueKey();

  List<Widget> get _widgetOptions => [
    SmartFeedScreen(key: _homeRefreshKey), // Kuncinya dipasang di sini!
    const NetworkScreen(),   
    const ProfileScreen(),   
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text('SKILLINK', style: TextStyle(color: Color(0xFF0077B5), fontWeight: FontWeight.bold, fontSize: 22)),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.grey), onPressed: () {}),
          IconButton(icon: const Icon(Icons.notifications_none, color: Colors.grey), onPressed: () {}),
        ],
      ),
      body: IndexedStack(
      index: _selectedIndex,
      children: _widgetOptions,
),
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
      // Tombol Plus (+) melayang di kanan bawah
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0077B5),
        onPressed: () async { 
          // Nungguin layar Create Post ditutup
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePostScreen()),
          );

          // Kalau balikan sinyalnya true (sukses posting)
          if (result == true) {
            setState(() {
              // Ganti kuncinya, paksa SmartFeedScreen buat narik data ulang
              _homeRefreshKey = UniqueKey(); 
            });
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}