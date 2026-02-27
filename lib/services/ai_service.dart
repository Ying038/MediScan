import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIService {
  static final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  
  final model = GenerativeModel(
    model: 'gemini-2.5-flash',
    apiKey: _apiKey,
    systemInstruction: Content.system(
      "You are a medical assistant for the elderly. Be extremely concise. "
      "You MUST respond in this EXACT format for the app to work: "
      "Medicine Name | Portion | Frequency | Brief Instructions "
      "Example: Panadol | 2 Tablets | Twice a day | Take after meals for pain. "
      "Do not use greetings, do not say 'Hello', do not use bold or bullet points. Say Twice a day, not 2 times a day. "
      "Just the single line of data. Inclue the purpose of the medicine. Speak slowly and clearly."
      "Use simple, loud-and-clear language. End with: 'Please confirm with your doctor.'"
    ),
  );

  Future<String> identifyMedicine(Uint8List imageBytes) async {
    final content = [
      Content.multi([
        TextPart("What is this medicine? Provide instructions for an elderly person."),
        DataPart('image/jpeg', imageBytes),
      ])
    ];

    try {
      final response = await model.generateContent(content);
      return response.text ?? "I'm sorry, I couldn't identify this. Please ask a caregiver.";
    } catch (e) {
      return "Connection error. Please try again.";
    }
  }
}