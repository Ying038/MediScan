import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'auth_gate.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_analytics/firebase_analytics.dart'; 

late List<CameraDescription> cameras;

// 1. Create a global instance of Analytics
final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (e.toString().contains('duplicate-app')) {
      debugPrint('Firebase already initialized, skipping...');
    } else {
      rethrow;
    }
  }

  cameras = await availableCameras();
  
  runApp(const MyApp()); // 2. Refactored to a class for better organization
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // 3. Add the navigator observer to track page views automatically
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F9FE),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8A94FF),
          primary: const Color(0xFF8A94FF),
          secondary: const Color(0xFFFF8EAC),
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
    );
  }
}