import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
//rimport 'package:firebase_database/firebase_database.dart'; // Add this import
import 'package:provider/provider.dart';
import 'providers/theme_notifier.dart';
import 'screens/adminlogin.dart';
import 'screens/admin_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCRTFH65VPYOtUSCUscEICfytJ2zrLiit4",
      authDomain: "fir-smart-620b9.firebaseapp.com",
      databaseURL:
          "https://fir-smart-620b9-default-rtdb.firebaseio.com/", // Added trailing slash
      projectId: "fir-smart-620b9",
      storageBucket: "fir-smart-620b9.firebasestorage.app",
      messagingSenderId: "801645370724",
      appId: "1:801645370724:web:329ef0dc77fef2f8032e71",
    ),
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const AdminApp(),
    ),
  );
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        colorScheme: ColorScheme.light(
          primary: Colors.blue,
          secondary: const Color(0xFFfeada6),
        ),
        scaffoldBackgroundColor: const Color(0xFFf5efef),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(
          primary: Colors.blue,
          secondary: Colors.amber,
        ),
        scaffoldBackgroundColor: const Color(0xFF303030),
      ),
      themeMode: themeNotifier.themeMode,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          );
        }

        return snapshot.hasData ? const AdminDashboard() : AdminLogin();
      },
    );
  }
}
