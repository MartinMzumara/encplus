import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../components/custom_nav.dart';
import 'decrypt_page.dart';
import 'encrypt_page.dart';
import 'homepage.dart';
import 'login_page.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isSetting1Enabled = true;
  String _selectedValue = 'Value 1';
  List<String> _values = ['Value 1', 'Value 2', 'Value 3'];
  bool _isDarkModeEnabled = false;
  String _username = '';
  User? _user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    if (_user != null) {
      _username = _user!.displayName ?? '';
    }
  }

  void _toggleDarkMode(bool? value) {
    setState(() {
      _isDarkModeEnabled = value!;
    });
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Username',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(_username),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/account-details');
              },
              child: const Text('Account Details'),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Dark Mode',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Radio(
                  value: false,
                  groupValue: _isDarkModeEnabled,
                  onChanged: _toggleDarkMode,
                ),
                const Text('Light'),
              ],
            ),
            Row(
              children: [
                Radio(
                  value: true,
                  groupValue: _isDarkModeEnabled,
                  onChanged: _toggleDarkMode,
                ),
                const Text('Dark'),
              ],
            ),
            const SizedBox(height: 16.0),
            TextButton(
              onPressed: _logout,
              child: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lock),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lock_open),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings')
        ],
        currentIndex: 3,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EncryptionPage(),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DecryptionPage(),
              ),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SettingsPage(),
              ),
            );
          }
        },
      ),
    );
  }
}
