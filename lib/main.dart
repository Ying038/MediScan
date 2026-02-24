import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'auth_gate.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import this

late List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  cameras = await availableCameras();
  
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF8F9FE), // Soft Light Background
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF8A94FF), // Pastel Purple
        primary: const Color(0xFF8A94FF),
        secondary: const Color(0xFFFF8EAC), // Soft Pink
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(color: Color(0xFF2D3142), fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: IconThemeData(color: Color(0xFF2D3142)),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    ),
    home: AuthGate(cameras: cameras),
  ));
}