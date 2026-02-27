import 'package:flutter/material.dart';
import '../services/med_service.dart';
import 'package:intl/intl.dart';

class MedFormPage extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  const MedFormPage({super.key, this.initialData});

  @override
  State<MedFormPage> createState() => _MedFormPageState();
}

class _MedFormPageState extends State<MedFormPage> {
  final MedService _service = MedService();
  final _nameController = TextEditingController();
  final _portionController = TextEditingController();
  
  String _frequency = 'Once a day';
  // List to handle multiple dose times
  List<TimeOfDay> _selectedTimes = [const TimeOfDay(hour: 8, minute: 0)];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _nameController.text = widget.initialData!['name'] ?? "";
      _portionController.text = widget.initialData!['portion'] ?? "";
      
      final String incomingFreq = widget.initialData!['frequency'] ?? 'Once a day';
      if (["Once a day", "Twice a day", "Thrice a day", "Weekly"].contains(incomingFreq)) {
        _frequency = incomingFreq;
      }
      
      // Load existing times if editing, otherwise set defaults
      _updateTimeFields(_frequency);
    }
  }

  // Helper to adjust number of time pickers based on frequency
  void _updateTimeFields(String freq) {
    setState(() {
      if (freq == 'Once a day' || freq == 'Weekly') {
        _selectedTimes = [const TimeOfDay(hour: 8, minute: 0)];
      } else if (freq == 'Twice a day') {
        _selectedTimes = [
          const TimeOfDay(hour: 8, minute: 0),
          const TimeOfDay(hour: 20, minute: 0)
        ];
      } else if (freq == 'Thrice a day') {
        _selectedTimes = [
          const TimeOfDay(hour: 8, minute: 0),
          const TimeOfDay(hour: 14, minute: 0),
          const TimeOfDay(hour: 20, minute: 0)
        ];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryPurple = Color(0xFF8A94FF);
    const Color accentPink = Color(0xFFFF8EAC);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text("Confirm Schedule", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 1. AI Analysis Header
          if (widget.initialData?['fullInfo'] != null)
            Container(
              padding: const EdgeInsets.all(15),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: primaryPurple.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("AI Analysis:", style: TextStyle(fontWeight: FontWeight.bold, color: primaryPurple)),
                  const SizedBox(height: 5),
                  Text(
                    widget.initialData!['fullInfo'],
                    style: const TextStyle(color: Color(0xFF4A4A4A), fontSize: 13, fontStyle: FontStyle.italic),
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

          // 2. Frequency Dropdown
          DropdownButtonFormField<String>(
            value: _frequency,
            items: ["Once a day", "Twice a day", "Thrice a day", "Weekly"]
                .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                .toList(),
            onChanged: (val) {
              _frequency = val!;
              _updateTimeFields(val);
            },
            decoration: InputDecoration(
              labelText: "Frequency",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          
          const SizedBox(height: 25),
          const Text("Schedule Times", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          // 3. Dynamic Time Pickers List
          ...List.generate(_selectedTimes.length, (index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
              ),
              child: ListTile(
                leading: const Icon(Icons.access_time, color: primaryPurple),
                title: Text("Dose ${index + 1} Time"),
                trailing: Text(
                  _selectedTimes[index].format(context),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: primaryPurple, fontSize: 16),
                ),
                onTap: () async {
                  TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: _selectedTimes[index],
                  );
                  if (picked != null) {
                    setState(() => _selectedTimes[index] = picked);
                  }
                },
              ),
            );
          }),

          const SizedBox(height: 30),
          
          // 4. Submit Button
          ElevatedButton(
            onPressed: () async {
              // FIX: Instead of t.format(context), use a custom formatter to force 12hr AM/PM
              List<String> formattedTimes = _selectedTimes.map((t) {
                final now = DateTime.now();
                final dt = DateTime(now.year, now.month, now.day, t.hour, t.minute);
                return DateFormat("h:mm a").format(dt); // This forces "8:30 PM" even on 24hr phones
              }).toList();

              if (widget.initialData?['docId'] != null) {
                await _service.updateMedicine(
                  docId: widget.initialData!['docId'],
                  name: _nameController.text,
                  portion: _portionController.text,
                  frequency: _frequency,
                  times: formattedTimes, 
                );
              } else {
                await _service.addMedicine(
                  name: _nameController.text,
                  portion: _portionController.text,
                  frequency: _frequency,
                  times: formattedTimes, 
                );
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accentPink,
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 0,
            ),
            child: Text(
              widget.initialData?['docId'] != null ? "UPDATE SCHEDULE" : "ADD TO SCHEDULE",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
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
        labelStyle: const TextStyle(color: Colors.grey),
      ),
    );
  }
}