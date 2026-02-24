import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/location_service.dart';
import '../services/med_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MedService _service = MedService();
  DateTime _selectedDay = DateTime.now();

  final Color primaryPurple = const Color(0xFF8A94FF);
  final Color accentPink = const Color(0xFFFF8EAC);
  final Color backgroundGray = const Color(0xFFF8F9FE);
  final Color textDark = const Color(0xFF2D3142);

  List<DateTime> _getCurrentWeek() {
    DateTime now = DateTime.now();
    int currentWeekday = now.weekday;
    DateTime startOfWeek = now.subtract(Duration(days: currentWeekday - 1));
    return List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: backgroundGray,
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _service.getMedicineStream(),
        builder: (context, medSnapshot) {
        int pendingMeds = 0;
        int totalMeds = 0;
        bool allTaken = true;

        if (medSnapshot.hasData) {
          final docs = medSnapshot.data!.docs;
          for (var doc in docs) {
            final data = doc.data();
            
            // A. Creation Date Check (Don't show meds before they were added)
            if (data['createdAt'] != null) {
              DateTime created = (data['createdAt'] as Timestamp).toDate();
              DateTime createdStart = DateTime(created.year, created.month, created.day);
              DateTime selectedStart = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
              if (selectedStart.isBefore(createdStart)) continue;
            }

            // B. Frequency Check (Sync with Firebase Weekly/Daily)
            final String freq = data['frequency'] ?? 'Once a day';
            if (freq == 'Weekly') {
              if (_selectedDay.weekday != data['weekdayCreated']) continue; // Skip if not the right day
            }

            // C. Count as a valid med for this day
            totalMeds++;

            // D. Check Doses (Twice = 2, Thrice = 3)
            int req = (freq == 'Thrice a day') ? 3 : (freq == 'Twice a day') ? 2 : 1;
            int taken = _service.getTakenCountForDate(data['takenDoses'], _selectedDay);
            
            if (taken < req) {
              pendingMeds++;
              allTaken = false;
            }
          }
        }

        // Final check for empty days
        if (totalMeds == 0) allTaken = true;

          return Column(
            children: [
              // 1. HEADER & WEEKLY CALENDAR
              Container(
                padding: const EdgeInsets.only(top: 60, left: 25, right: 25, bottom: 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(DateFormat('EEEE, d MMMM').format(_selectedDay), 
                              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                            Text("Hi, ${user?.email?.split('@')[0] ?? 'User'}!", 
                              style: TextStyle(color: textDark, fontSize: 28, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        CircleAvatar(radius: 25, backgroundColor: primaryPurple, child: const Icon(Icons.person, color: Colors.white)),
                      ],
                    ),
                    const SizedBox(height: 25),
                    _buildWeeklyCalendar(medSnapshot.data?.docs),
                  ],
                ),
              ),

              // 2. SCROLLABLE CONTENT
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  children: [
                    _buildPharmacyAction(),
                    const SizedBox(height: 25),
                    // APPOINTMENTS SECTION
                    _sectionHeader("Upcoming Appointments"),
                    _buildAppointmentList(),
                    
                    const SizedBox(height: 25),
                    _sectionHeader("Today's Medication Activity"),
                    _buildStatusCard(allTaken, pendingMeds, totalMeds),
                    const SizedBox(height: 25),
                    _buildMedicineHistory(medSnapshot.data?.docs),
                                        
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title, style: TextStyle(color: textDark, fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  // APPOINTMENT LIST FOR HOME PAGE
  Widget _buildAppointmentList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _service.getAppointmentStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        
        final now = DateTime.now();

        final upcomingAppointments = snapshot.data!.docs.where((doc) {
          final data = doc.data();
          DateTime apptDate = DateTime.parse(data['date']);
          
          // 1. Only show if it's the selected day
          if (!_service.isSameDay(apptDate, _selectedDay)) return false;

          // 2. If it's today, check if the time is already over
          if (_service.isSameDay(apptDate, now)) {
            try {
              // Use .trim() and try multiple formats to avoid FormatException
              String timeStr = data['time'].toString().trim();
              DateTime scheduledTime;
              
              try {
                scheduledTime = DateFormat.jm().parse(timeStr);
              } catch (e) {
                // Fallback for different spacing formats
                scheduledTime = DateFormat("h:mm a").parse(timeStr);
              }

              DateTime fullApptDateTime = DateTime(
                apptDate.year, 
                apptDate.month, 
                apptDate.day, 
                scheduledTime.hour, 
                scheduledTime.minute
              );
              
              // Only show if the current time is BEFORE the appointment time
              return fullApptDateTime.isAfter(now);
            } catch (e) {
              // If parsing fails, show it anyway so user doesn't miss it
              debugPrint("Time parsing error: $e");
              return true; 
            }
          }

          // 3. For future days, show everything
          return apptDate.isAfter(now);
        }).toList();

        if (upcomingAppointments.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text("No more appointments today.", style: TextStyle(color: Colors.grey)),
          );
        }

        return Column(
          children: upcomingAppointments.map((doc) {
            final data = doc.data();
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFFF8EAC).withOpacity(0.1), // accentPink
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFFFF8EAC).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Color(0xFFFF8EAC)),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data['doctor'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text("${data['time']} • ${data['reason']}", style: const TextStyle(color: Colors.black54)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildWeeklyCalendar(List<QueryDocumentSnapshot<Map<String, dynamic>>>? meds) {
    List<DateTime> week = _getCurrentWeek();
    return SizedBox(
      height: 85,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: week.length,
        itemBuilder: (context, index) {
          DateTime date = week[index];
          bool isSelected = _service.isSameDay(date, _selectedDay);
          bool dayComplete = false;
          if (meds != null && meds.isNotEmpty) {
            dayComplete = meds.every((m) {
              int req = (m.data()['frequency'] == 'Thrice a day') ? 3 : (m.data()['frequency'] == 'Twice a day') ? 2 : 1;
              return _service.getTakenCountForDate(m.data()['takenDoses'], date) >= req;
            });
          }
          return GestureDetector(
            onTap: () => setState(() => _selectedDay = date),
            child: Container(
              width: 55,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? primaryPurple : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? primaryPurple : Colors.grey.shade200),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DateFormat('E').format(date)[0], style: TextStyle(color: isSelected ? Colors.white70 : Colors.grey, fontSize: 12)),
                  const SizedBox(height: 4),
                  dayComplete 
                    ? Icon(Icons.check_circle, color: isSelected ? Colors.white : Colors.green, size: 20)
                    : Text(DateFormat('d').format(date), style: TextStyle(color: isSelected ? Colors.white : textDark, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- REST OF UI HELPER METHODS (Status Card, History, Pharmacy) ---
  // [Keep the _buildStatusCard, _buildMedicineHistory, and _buildPharmacyAction from previous version]
  
  Widget _buildStatusCard(bool allTaken, int pending, int totalMeds) {
  // If total is 0, show a neutral blue color or green
    Color statusColor = totalMeds == 0 ? primaryPurple : (allTaken ? Colors.green : accentPink);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1), 
        borderRadius: BorderRadius.circular(25), 
        border: Border.all(color: statusColor.withOpacity(0.2))
      ),
      child: Row(
        children: [
          Icon(
            totalMeds == 0 ? Icons.medication_outlined : (allTaken ? Icons.check_circle : Icons.pending_actions), 
            size: 50, 
            color: statusColor
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                Text(
                  totalMeds == 0 
                      ? "No Meds Scheduled" 
                      : (allTaken ? "All Complete!" : "$pending Meds Left"), 
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 20)
                ),
                Text(
                  totalMeds == 0 
                      ? "Enjoy your day!" 
                      : (allTaken ? "You're doing great!" : "Don't forget your doses today."), 
                  style: const TextStyle(color: Colors.black54, fontSize: 14)
                ),
              ]
            )
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineHistory(List<QueryDocumentSnapshot<Map<String, dynamic>>>? docs) {
    if (docs == null) return const SizedBox();
    List<Map<String, dynamic>> history = [];
    for (var doc in docs) {
      final List<dynamic> takenDoses = doc.data()['takenDoses'] ?? [];
      for (var dose in takenDoses) {
        DateTime doseTime = DateTime.parse(dose);
        if (_service.isSameDay(doseTime, _selectedDay)) {
          history.add({'name': doc.data()['name'], 'time': doseTime});
        }
      }
    }
    history.sort((a, b) => b['time'].compareTo(a['time']));
    if (history.isEmpty) return const Text("No doses taken yet.", style: TextStyle(color: Colors.grey));
    return Column(children: history.map((item) => Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Row(children: [
        const Icon(Icons.done_all, color: Colors.green, size: 20),
        const SizedBox(width: 15),
        Expanded(child: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold))),
        Text(DateFormat('hh:mm a').format(item['time']), style: const TextStyle(color: Colors.grey)),
      ]),
    )).toList());
  }

  Widget _buildPharmacyAction() {
    return GestureDetector(
      onTap: () => LocationService.searchPharmacy(), 
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: primaryPurple.withOpacity(0.1), borderRadius: BorderRadius.circular(15)), child: Icon(Icons.local_pharmacy, size: 30, color: primaryPurple)),
          const SizedBox(width: 20),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Nearby Pharmacy", style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 18)),
            const Text("Find open shops nearby", style: TextStyle(color: Colors.grey, fontSize: 14)),
          ])),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ]),
      ),
    );
  }
}