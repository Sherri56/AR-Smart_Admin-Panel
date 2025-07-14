import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/theme_notifier.dart';

class AdminLogin extends StatelessWidget {
  final TextEditingController _emailController =
      TextEditingController(text: "sherriqasim91@gmail.com");
  final TextEditingController _passwordController = TextEditingController();

  AdminLogin({super.key});

  Future<void> _login(BuildContext context) async {
    try {
      UserCredential user =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      final doc = await FirebaseFirestore.instance
          .collection('admins')
          .doc(user.user!.uid)
          .get();

      if (!doc.exists) {
        await FirebaseAuth.instance.signOut();
        throw 'Access Denied: Not an admin';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkMode = themeNotifier.isDarkMode;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF424242),
                    Color(0xFF303030),
                  ],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFfeada6),
                    Color(0xFFf5efef),
                  ],
                ),
        ),
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      height: 120,
                      width: 120,
                      color: isDarkMode ? Colors.white : null,
                    ),
                    const SizedBox(height: 40),
                    _buildLoginCard(context, isDarkMode),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 40,
              child: IconButton(
                icon: Icon(
                  isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  size: 30,
                  color: isDarkMode ? Colors.amber : Colors.black54,
                ),
                onPressed: () {
                  themeNotifier.toggleTheme(!isDarkMode);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context, bool isDarkMode) {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.grey[800]!.withOpacity(0.9)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black54 : Colors.black12,
            blurRadius: 16,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        children: [
          Text(
            'Admin Login',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          _buildEmailField(isDarkMode),
          const SizedBox(height: 16),
          _buildPasswordField(isDarkMode),
          const SizedBox(height: 24),
          _buildLoginButton(context, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildEmailField(bool isDarkMode) {
    return TextField(
      controller: _emailController,
      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: 'Email',
        labelStyle:
            TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
        prefixIcon: Icon(Icons.email,
            color: isDarkMode ? Colors.white70 : Colors.black54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: isDarkMode ? Colors.grey : Colors.black54),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildPasswordField(bool isDarkMode) {
    return TextField(
      controller: _passwordController,
      obscureText: true,
      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: 'Password',
        labelStyle:
            TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
        prefixIcon: Icon(Icons.lock,
            color: isDarkMode ? Colors.white70 : Colors.black54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: isDarkMode ? Colors.grey : Colors.black54),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context, bool isDarkMode) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isDarkMode ? const Color(0xFFBB86FC) : const Color(0xFFfeada6),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () => _login(context),
        child: Text(
          'Login',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }
  // ... rest of your _buildLoginCard, _buildEmailField,
  // _buildPasswordField, and _buildLoginButton methods remain the same ...
}
