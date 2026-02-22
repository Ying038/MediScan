import 'package:flutter/material.dart';
import '../services/med_service.dart';

class MedFormPage extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  const MedFormPage({super.key, this.initialData});

  @override
  State<MedFormPage> createState() => _MedFormPageState();
}

class _MedFormPageState extends State<MedFormPage> {
  final _nameController = TextEditingController();
  final _portionController = TextEditingController();
  String _frequency = 'Once a day';
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      // These now come directly from the AI scan logic above
      _nameController.text = widget.initialData!['name'] ?? "";
      _portionController.text = widget.initialData!['portion'] ?? "";
      
      // Ensure the dropdown matches the frequency string exactly
      final String incomingFreq = widget.initialData!['frequency'] ?? 'Once a day';
      if (["Once a day", "Twice a day", "Weekly"].contains(incomingFreq)) {
        _frequency = incomingFreq;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE), // Pastel Background
      appBar: AppBar(
        title: const Text("Confirm Schedule"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // AI Analysis Pop-up Section
          if (widget.initialData?['fullInfo'] != null)
            Container(
              padding: const EdgeInsets.all(15),
              margin: const EdgeInsets.only(bottom: 20), // FIXED
              decoration: BoxDecoration(
                color: const Color(0xFF8A94FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFF8A94FF).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("AI Analysis:", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8A94FF))),
                  const SizedBox(height: 5),
                  Text(
                    widget.initialData!['fullInfo'],
                    style: const TextStyle(
                      color: Color(0xFF4A4A4A), 
                      fontSize: 14, 
                      fontStyle: FontStyle.italic, // FIXED
                    ),
                  ),
                ],
              ),
            ),

          const Text("Medicine Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          
          _customField("Medicine Title", _nameController),
          const SizedBox(height: 15),
          
          _customField("Portion", _portionController),
          const SizedBox(height: 15),

          DropdownButtonFormField<String>(
            value: _frequency,
            items: ["Once a day", "Twice a day", "Weekly"].map((f) => 
              DropdownMenuItem(value: f, child: Text(f))).toList(),
            onChanged: (val) => setState(() => _frequency = val!),
            decoration: const InputDecoration(labelText: "Frequency"),
          ),
          
          const SizedBox(height: 30),
          
          ElevatedButton(
            onPressed: () async {
              await MedService().addMedicine(
                name: _nameController.text,
                portion: _portionController.text,
                frequency: _frequency,
                timeToEat: _selectedTime.format(context),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8EAC), // Pastel Pink
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text("ADD TO SCHEDULE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _customField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}