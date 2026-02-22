import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:confetti/confetti.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/med_service.dart';
import 'med_form_page.dart';
import 'package:intl/intl.dart';

class MedCalendarPage extends StatefulWidget {
  const MedCalendarPage({super.key});

  @override
  State<MedCalendarPage> createState() => _MedCalendarPageState();
}

class _MedCalendarPageState extends State<MedCalendarPage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  late ConfettiController _confettiController;
  final MedService _service = MedService();

  // Pastel Colors
  final Color primaryPurple = const Color(0xFF8A94FF);
  final Color accentPink = const Color(0xFFFF8EAC);
  final Color bgColor = const Color(0xFFF8F9FE);
  final Color textDark = const Color(0xFF2D3142);

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            title: Text("Medication Tracker", style: TextStyle(color: textDark, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: textDark),
            actions: [
              IconButton(
                icon: Icon(Icons.event_note, color: primaryPurple),
                onPressed: _showAddAppointment,
                tooltip: "Add Appointment",
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: accentPink,
            child: const Icon(Icons.add, color: Colors.white),
            onPressed: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (c) => const MedFormPage())
            ),
          ),
          body: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TableCalendar(
                  focusedDay: _focusedDay,
                  firstDay: DateTime(2025),
                  lastDay: DateTime(2030),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(color: textDark, fontWeight: FontWeight.bold),
                  ),
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  calendarStyle: CalendarStyle(
                    selectedDecoration: BoxDecoration(color: primaryPurple, shape: BoxShape.circle),
                    todayDecoration: BoxDecoration(color: primaryPurple.withOpacity(0.3), shape: BoxShape.circle),
                    defaultTextStyle: TextStyle(color: textDark),
                    weekendTextStyle: TextStyle(color: accentPink),
                  ),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: _service.getMedicineStream(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final meds = snapshot.data!.docs;
                            bool dayComplete = meds.isNotEmpty && meds.every((m) => 
                              _service.isTakenOnDate(m.data()['lastTaken'], day));

                            if (dayComplete) {
                              return Center(
                                child: Container(
                                  width: 35, height: 35,
                                  decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                                  child: const Icon(Icons.check, color: Colors.white, size: 20),
                                ),
                              );
                            }
                          }
                          return Center(child: Text('${day.day}', style: TextStyle(color: textDark)));
                        },
                      );
                    },
                    markerBuilder: (context, day, events) {
                      return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: _service.getAppointmentStream(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final appointments = snapshot.data!.docs;
                            bool hasAppointment = appointments.any((doc) => 
                              isSameDay(DateTime.parse(doc.data()['date']), day));

                            if (hasAppointment) {
                              return Positioned(
                                bottom: 1,
                                child: Container(
                                  width: 7, height: 7,
                                  decoration: BoxDecoration(color: primaryPurple, shape: BoxShape.circle),
                                ),
                              );
                            }
                          }
                          return const SizedBox();
                        },
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Daily Checklist", style: TextStyle(color: textDark, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              Expanded(child: _buildList()),
            ],
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: [primaryPurple, accentPink, Colors.green, Colors.yellow],
          ),
        ),
      ],
    );
  }

  void _showAddAppointment() {
    final nameController = TextEditingController();
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("New Appointment", style: TextStyle(color: textDark, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("For: ${DateFormat('d MMMM').format(_selectedDay)}", 
                style: TextStyle(color: primaryPurple, fontWeight: FontWeight.w600)),
            const SizedBox(height: 15),
            TextField(
              controller: nameController,
              decoration: _dialogInputDecoration("Doctor's Name"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: reasonController,
              decoration: _dialogInputDecoration("Reason"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                _service.addAppointment(
                  doctorName: nameController.text,
                  reason: reasonController.text,
                  date: _selectedDay,
                  time: "10:00 AM",
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Appointment saved!"), backgroundColor: Colors.green));
              }
            }, 
            style: ElevatedButton.styleFrom(backgroundColor: primaryPurple),
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  InputDecoration _dialogInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: primaryPurple)),
    );
  }

  Widget _buildList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _service.getMedicineStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data();
            final docId = docs[index].id;
            bool isTakenOnThisDay = _service.isTakenOnDate(data['lastTaken'], _selectedDay);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: ListTile(
                leading: IconButton(
                  icon: Icon(
                    isTakenOnThisDay ? Icons.check_circle : Icons.circle_outlined,
                    color: isTakenOnThisDay ? Colors.green : primaryPurple,
                    size: 30,
                  ),
                  onPressed: () {
                    if (isSameDay(_selectedDay, DateTime.now())) {
                      if (!isTakenOnThisDay) {
                        _service.markAsTaken(docId);
                        _confettiController.play();
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You can only mark meds for today!")));
                    }
                  },
                ),
                title: Text(data['name'], style: TextStyle(color: textDark, fontWeight: FontWeight.bold)),
                subtitle: Text("${data['portion']} • ${data['timeToEat']}", style: const TextStyle(color: Colors.grey)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () => _service.deleteMedicine(docId),
                ),
              ),
            );
          },
        );
      },
    );
  }
}