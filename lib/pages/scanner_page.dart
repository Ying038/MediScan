import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/ai_service.dart';
import '../services/med_service.dart';
import 'med_form_page.dart';

class ScannerPage extends StatefulWidget {
  final List<CameraDescription> cameras;
  const ScannerPage({super.key, required this.cameras});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final AIService _ai = AIService();
  final FlutterTts _tts = FlutterTts();
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.cameras.first, ResolutionPreset.high);
    _initializeControllerFuture = _controller.initialize();
  }

  Future<void> _handleScan() async {
    setState(() => _isBusy = true);
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      final bytes = await image.readAsBytes();

      // 1. Get structured string: Name | Portion | Frequency | Instructions
      final String rawResult = await _ai.identifyMedicine(bytes);
      
      // 2. TTS: Speak slowly and clearly for the elderly
      await _tts.setSpeechRate(0.3); 
      await _tts.speak(rawResult.replaceAll("|", ".")); //

      // 3. Robust Parsing
      List<String> parts = rawResult.split("|");
      String name = parts.isNotEmpty ? parts[0].trim() : "Unknown Medicine";
      String portion = parts.length > 1 ? parts[1].trim() : "1 Tablet";
      String frequency = parts.length > 2 ? parts[2].trim() : "Once a day";
      String fullAnalysis = parts.length > 3 ? parts[3].trim() : rawResult;

      if (mounted) {
        Navigator.push(context, MaterialPageRoute(
          builder: (c) => MedFormPage(initialData: {
            'name': name,
            'portion': portion,
            'frequency': frequency, // Now explicitly passed
            'fullInfo': fullAnalysis,
          }),
        ));
      }
    } finally {
      setState(() => _isBusy = false);
    }
  }
  void _showResult(String text) {
    showModalBottomSheet(
      context: context,
      builder: (c) => Container(padding: const EdgeInsets.all(20), child: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Center(child: CameraPreview(_controller));
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
          // Viewfinder Border Removed
          const Positioned(
            top: 60, left: 0, right: 0,
            child: Center(child: Text("Focus on Medicine Label", style: TextStyle(color: Colors.white))),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: FloatingActionButton.large(
                onPressed: _handleScan,
                backgroundColor: const Color(0xFF8A94FF),
                child: _isBusy ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.camera_alt, color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}