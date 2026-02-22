import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'pages/auth_page.dart';
import 'pages/main_navigation_hub.dart';

class AuthGate extends StatelessWidget {
  final List<CameraDescription> cameras;
  const AuthGate({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (!snapshot.hasData) return const AuthPage();
        return MainNavigationHub(cameras: cameras);
      },
    );
  }
}