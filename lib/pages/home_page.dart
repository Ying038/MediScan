import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../services/location_service.dart';
import '../services/med_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final MedService _service = MedService();
    
    // Define the UI Colors here so they are available in this scope
    const Color primaryPurple = Color(0xFF8A94FF);
    const Color accentPink = Color(0xFFFF8EAC);
    const Color backgroundGray = Color(0xFFF8F9FE); // Renamed to avoid confusion
    const Color textDark = Color(0xFF2D3142);

    return Scaffold(
      backgroundColor: backgroundGray,
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _service.getMedicineStream(),
        builder: (context, snapshot) {
          bool allTaken = true;
          int totalMeds = 0;
          int takenCount = 0;

          if (snapshot.hasData) {
            final docs = snapshot.data!.docs;
            totalMeds = docs.length;
            for (var doc in docs) {
              if (_service.isTakenToday(doc.data()['lastTaken'])) {
                takenCount++;
              } else {
                allTaken = false;
              }
            }
          }
          if (totalMeds == 0) allTaken = true;

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 60, left: 25, right: 25, bottom: 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
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
                            Text(DateFormat('EEEE, d MMMM').format(DateTime.now()), 
                              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                            Text("Hi, ${user?.email?.split('@')[0] ?? 'User'}!", 
                              style: const TextStyle(color: textDark, fontSize: 28, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const CircleAvatar(
                          radius: 25, 
                          backgroundColor: primaryPurple, 
                          child: Icon(Icons.person, color: Colors.white)
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    // Pass both colors to the helper
                    _buildHorizontalCalendar(primaryPurple, backgroundGray),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  children: [
                    _buildStatusCard(allTaken, totalMeds, takenCount, primaryPurple, accentPink),
                    const SizedBox(height: 25),
                    const Text("Quick Actions", 
                      style: TextStyle(color: textDark, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    GestureDetector(
                      onTap: () => LocationService.searchPharmacy(), 
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: primaryPurple.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
                              child: const Icon(Icons.local_pharmacy, size: 30, color: primaryPurple),
                            ),
                            const SizedBox(width: 20),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Nearby Pharmacy", 
                                    style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 18)),
                                  Text("Find open shops in Malaysia", 
                                    style: TextStyle(color: Colors.grey, fontSize: 14)),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Updated helper to accept both colors
  Widget _buildHorizontalCalendar(Color primary, Color background) {
    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          DateTime date = DateTime.now().add(Duration(days: index - 3));
          bool isToday = index == 3;
          return Container(
            width: 55,
            margin: const EdgeInsets.only(right: 15),
            decoration: BoxDecoration(
              color: isToday ? primary : background, // Using the passed background color
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(DateFormat('d').format(date), 
                  style: TextStyle(color: isToday ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)),
                Text(DateFormat('E').format(date), 
                  style: TextStyle(color: isToday ? Colors.white70 : Colors.grey, fontSize: 12)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(bool allTaken, int total, int taken, Color purple, Color pink) {
    Color statusColor = allTaken ? Colors.green : pink;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: statusColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(allTaken ? Icons.check_circle : Icons.error_outline, size: 50, color: statusColor),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  total == 0 ? "No Meds Yet" : (allTaken ? "All Done!" : "Incomplete"),
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 20),
                ),
                Text(
                  total == 0 ? "Scan medicine to start." : "You've taken $taken of $total medications today.",
                  style: const TextStyle(color: Colors.black54, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}