import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:confetti/confetti.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/med_service.dart';
import 'med_form_page.dart';
import 'package:intl/intl.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

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
            title: Text("Daily Schedule", style: TextStyle(color: textDark, fontWeight: FontWeight.bold)),
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
                    // We use the same helper for all day types to ensure consistency
                    defaultBuilder: (context, day, focusedDay) => _buildCalendarDay(day),
                    todayBuilder: (context, day, focusedDay) => _buildCalendarDay(day, isToday: true),
                    selectedBuilder: (context, day, focusedDay) => _buildCalendarDay(day, isSelected: true),
                    
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
              const SizedBox(height: 15),
              Expanded(
                child: ListView(
                  children: [
                    _sectionHeader("Appointments"),
                    _buildFilteredAppointmentList(),
                    _sectionHeader("Medications"),
                    _buildFilteredMedList(),
                  ],
                ),
              ),
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

  Widget _buildCalendarDay(DateTime day, {bool isToday = false, bool isSelected = false}) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _service.getMedicineStream(),
      builder: (context, snapshot) {
        bool dayComplete = false;

        if (snapshot.hasData) {
          final meds = snapshot.data!.docs;

          final medsValidForDay = meds.where((m) {
            final data = m.data();
            
            // 1. Check if it was created yet
            if (data['createdAt'] != null) {
              DateTime created = (data['createdAt'] as Timestamp).toDate();
              DateTime createdDateOnly = DateTime(created.year, created.month, created.day);
              DateTime dayDateOnly = DateTime(day.year, day.month, day.day);
              if (dayDateOnly.isBefore(createdDateOnly)) return false;
            }

            // 2. Weekly frequency check (Missing in your original code)
            if (data['frequency'] == 'Weekly') {
              return day.weekday == data['weekdayCreated'];
            }
            
            return true;
          }).toList();

          // Check if all valid meds for THIS specific day are done
          dayComplete = medsValidForDay.isNotEmpty && 
              medsValidForDay.every((m) {
                final data = m.data();
                int req = (data['frequency'] == 'Thrice a day') ? 3 : 
                          (data['frequency'] == 'Twice a day') ? 2 : 1;
                return _service.getTakenCountForDate(data['takenDoses'] ?? [], day) >= req;
              });
        }

        if (dayComplete) {
          return Center(
            child: Container(
              width: 35, height: 35,
              decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
              child: const Icon(Icons.check, color: Colors.white, size: 20),
            ),
          );
        }

        return Center(
          child: Container(
            width: 35, height: 35,
            decoration: BoxDecoration(
              color: isSelected ? primaryPurple : (isToday ? primaryPurple.withOpacity(0.3) : Colors.transparent),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${day.day}',
                style: TextStyle(
                  color: isSelected ? Colors.white : textDark,
                  fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Text(title, style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Widget _buildFilteredAppointmentList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _service.getAppointmentStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final appointments = snapshot.data!.docs.where((doc) => isSameDay(DateTime.parse(doc.data()['date']), _selectedDay)).toList();

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final data = appointments[index].data();
            final docId = appointments[index].id;
            return _listItemCard(
              title: data['doctor'],
              subtitle: "${data['time']} • ${data['reason']}",
              icon: Icons.alarm,
              iconColor: accentPink,
              onTap: () => _showAddAppointment(existingData: data, docId: docId),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => _service.deleteAppointment(docId),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilteredMedList() {
  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    stream: _service.getMedicineStream(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
      
      final allDocs = snapshot.data!.docs;
      
      final filteredDocs = allDocs.where((doc) {
        final data = doc.data();
        if (data['createdAt'] != null) {
          DateTime created = (data['createdAt'] as Timestamp).toDate();
          DateTime createdStart = DateTime(created.year, created.month, created.day);
          DateTime selectedStart = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
          if (selectedStart.isBefore(createdStart)) return false;
        }

        if (data['frequency'] == 'Weekly') {
          return _selectedDay.weekday == data['weekdayCreated'];
        }
        return true;
      }).toList();

      return Column(
        children: [
          _buildIncompleteWarning(filteredDocs),
          
          if (filteredDocs.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No medicines for this day.", style: TextStyle(color: Colors.grey)))),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredDocs.length,
            itemBuilder: (context, index) {
              final data = filteredDocs[index].data();
              final docId = filteredDocs[index].id;
              
              return Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: ExpansionTile(
                    leading: Icon(Icons.medication_outlined, color: primaryPurple, size: 30),
                    title: Text(data['name'], style: TextStyle(color: textDark, fontWeight: FontWeight.bold)),
                    subtitle: Text("${data['portion']} • ${data['frequency']}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Colors.grey, size: 20),
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => MedFormPage(initialData: {...data, 'docId': docId}))),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                          onPressed: () => _service.deleteMedicine(docId),
                        ),
                      ],
                    ),
                    children: [
                      const Divider(height: 1),
                      Builder(builder: (context) {
                        final List<dynamic> scheduledTimes = data['times'] ?? [];
                        final List<dynamic> takenDoses = data['takenDoses'] ?? [];
                        int takenTodayCount = _service.getTakenCountForDate(takenDoses, _selectedDay);

                        return Column(
                          children: List.generate(scheduledTimes.length, (idx) {
                            String timeStr = scheduledTimes[idx];
                            bool doseAlreadyTaken = idx < takenTodayCount;
                            
                            // --- TIME VALIDATION LOGIC (+- 1hr) ---
                            bool isWithinTimeRange = true; 
                            String statusText = "Scheduled at $timeStr";

                            if (isSameDay(_selectedDay, DateTime.now())) {
                              DateTime now = DateTime.now();
                              // Parse the saved time string (e.g. "8:00 AM")
                              DateTime scheduled;
                              try {
                                // .trim() removes any accidental leading/trailing spaces
                                scheduled = DateFormat.jm().parse(timeStr.trim());
                              } catch (e) {
                                // Fallback if the format is slightly different
                                scheduled = DateFormat("h:mm a").parse(timeStr.trim());
                              }
                              DateTime doseTimeToday = DateTime(now.year, now.month, now.day, scheduled.hour, scheduled.minute);
                              int scheduledMinutes = scheduled.hour * 60 + scheduled.minute;
                              int currentMinutes = now.hour * 60 + now.minute;
                              int diffInMinutes = (currentMinutes - scheduledMinutes).abs();
                              isWithinTimeRange = diffInMinutes <= 60; 
                              if (!isWithinTimeRange && currentMinutes < scheduledMinutes) {
                                statusText = "Too early. Available at $timeStr";
                              } else if (!isWithinTimeRange && currentMinutes > scheduledMinutes) {
                                statusText = "Missed time. Was due at $timeStr";
                              }
                            }

                            return ListTile(
                              dense: true,
                              leading: Icon(
                                doseAlreadyTaken ? Icons.check_circle : Icons.circle_outlined,
                                color: doseAlreadyTaken 
                                    ? Colors.green 
                                    : (isWithinTimeRange ? primaryPurple : Colors.grey.withOpacity(0.5)),
                              ),
                              title: Text("Dose ${idx + 1} • $timeStr"),
                              subtitle: Text(doseAlreadyTaken ? "Taken successfully" : statusText, 
                                  style: TextStyle(color: isWithinTimeRange || doseAlreadyTaken ? Colors.grey : Colors.orange)),
                              trailing: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: doseAlreadyTaken ? Colors.green : primaryPurple,
                                  disabledBackgroundColor: Colors.grey.shade300,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  elevation: 0,
                                ),
                                onPressed: (isWithinTimeRange && !doseAlreadyTaken && isSameDay(_selectedDay, DateTime.now()))
                                  ? () async {
                                      _service.markAsTaken(docId);
                                      _confettiController.play();
                                      
                                      // --- ANALYTICS TRACKING ---
                                      await FirebaseAnalytics.instance.logEvent(
                                        name: 'medication_taken',
                                        parameters: {
                                          'medicine_name': data['name'],
                                          'dose_time': timeStr,
                                          'day_of_week': DateFormat('EEEE').format(DateTime.now()),
                                        },
                                      );
                                    }
                                  : null,
                                child: Text(doseAlreadyTaken ? "Done" : "Tick", style: const TextStyle(color: Colors.white)),
                              ),
                            );
                          }),
                        );
                      }),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      );
    },
  );
}

  Widget _buildIncompleteWarning(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    if (!_selectedDay.isBefore(today)) return const SizedBox();

    bool incomplete = docs.any((m) {
      final data = m.data();
      int req = (data['frequency'] == 'Thrice a day') ? 3 : (data['frequency'] == 'Twice a day') ? 2 : 1;
      return _service.getTakenCountForDate(data['takenDoses'], _selectedDay) < req;
    });

    if (!incomplete) return const SizedBox();
    if (incomplete) {
      // Log that a day was missed when the user views it
      FirebaseAnalytics.instance.logEvent(
        name: 'missed_dose_warning_viewed',
        parameters: {'date': _selectedDay.toIso8601String()},
      );
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.orange.withOpacity(0.3))),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange),
          SizedBox(width: 10),
          Expanded(child: Text("Warning: You missed doses on this day!", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _listItemCard({required String title, required String subtitle, required IconData icon, required Color iconColor, VoidCallback? onTap, Widget? trailing}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
      child: ListTile(onTap: onTap, leading: Icon(icon, color: iconColor, size: 30), title: Text(title, style: TextStyle(color: textDark, fontWeight: FontWeight.bold)), subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)), trailing: trailing),
    );
  }

  void _showAddAppointment({Map<String, dynamic>? existingData, String? docId}) {
    final nameController = TextEditingController(text: existingData?['doctor']);
    final reasonController = TextEditingController(text: existingData?['reason']);
    bool isEditing = existingData != null;
    
    // Default time is 10:00 AM or the existing time if editing
    TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);
    if (isEditing && existingData?['time'] != null) {
      // Basic parsing logic if you store time as "10:00 AM"
      final timeParts = existingData!['time'].split(':');
      selectedTime = TimeOfDay(hour: int.parse(timeParts[0]), minute: 0); 
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder( // Added StatefulBuilder here
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(isEditing ? "Edit Appointment" : "New Appointment"),
            content: Column(
              mainAxisSize: MainAxisSize.min, 
              children: [
                TextField(controller: nameController, decoration: _dialogInputDecoration("Doctor Name")),
                const SizedBox(height: 10),
                TextField(controller: reasonController, decoration: _dialogInputDecoration("Reason")),
                const SizedBox(height: 15),
                
                // --- TIME PICKER TRIGGER ---
                ListTile(
                  title: const Text("Select Time", style: TextStyle(fontSize: 14)),
                  subtitle: Text(selectedTime.format(context), 
                    style: TextStyle(color: primaryPurple, fontWeight: FontWeight.bold, fontSize: 18)),
                  trailing: Icon(Icons.access_time, color: primaryPurple),
                  onTap: () async {
                    TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (picked != null) {
                      setDialogState(() => selectedTime = picked); // Update dialog UI
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: primaryPurple),
                onPressed: () {
                  FirebaseAnalytics.instance.logEvent(
                    name: 'appointment_added',
                    parameters: {'doctor': nameController.text},
                  );
                  if (isEditing) {
                    _service.updateAppointment(
                      docId: docId!, 
                      doctorName: nameController.text, 
                      reason: reasonController.text, 
                      date: _selectedDay, 
                      time: selectedTime.format(context) // Save the picked time
                    );
                  } else {
                    _service.addAppointment(
                      doctorName: nameController.text, 
                      reason: reasonController.text, 
                      date: _selectedDay, 
                      time: selectedTime.format(context) // Save the picked time
                    );
                  }
                  Navigator.pop(context);
                },
                child: Text(isEditing ? "Update" : "Save", style: const TextStyle(color: Colors.white)),
              ),
            ],
          );
        }
      ),
    );
  }

  InputDecoration _dialogInputDecoration(String label) {
    return InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.grey), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: primaryPurple)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: primaryPurple, width: 2)));
  }
}