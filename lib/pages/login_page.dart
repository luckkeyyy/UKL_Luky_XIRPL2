import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'success_page.dart';
import 'add_song_page.dart'; // ✅ Import halaman AddSongPage

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = '';
  bool isLoading = false;

  Future<void> login() async {
    setState(() {
      errorMessage = '';
    });

    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      setState(() {
        errorMessage = 'Username and password must be filled.';
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    final res = await http.get(Uri.parse('https://dummyjson.com/users'));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final users = data['users'] as List;

      final user = users.firstWhere(
        (u) =>
            u['username'] == usernameController.text &&
            u['password'] == passwordController.text,
        orElse: () => null,
      );

      setState(() => isLoading = false);

      if (user != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessPage(user: user),
          ),
        );
      } else {
        setState(() => errorMessage = 'Username or password is incorrect.');
      }
    } else {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to fetch users.';
      });
    }
  }

  void goToAddSongPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddSongPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Tombol Login
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : OutlinedButton(
                    onPressed: login,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.amber, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 14),
                      foregroundColor: Colors.black,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('Login'),
                  ),

            // ❌ Error message
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),

            const SizedBox(height: 20),

            // ✅ Tombol Tambah Lagu
            ElevatedButton.icon(
              onPressed: goToAddSongPage,
              icon: const Icon(Icons.library_music),
              label: const Text('Tambah Lagu'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
