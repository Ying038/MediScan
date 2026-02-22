import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MedService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // Getter for the current user's ID to ensure we always have the latest auth state
  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  // 1. Unified Stream: Listens to all medicines for the logged-in user
  Stream<QuerySnapshot<Map<String, dynamic>>> getMedicineStream() {
    if (userId == null) return const Stream.empty();
    
    return _db
        .collection('users')
        .doc(userId)
        .collection('medicines')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
  // 1. Add Appointment
  Future<void> addAppointment({
    required String doctorName,
    required String reason,
    required DateTime date,
    required String time,
  }) async {
    if (userId == null) return;
    await _db.collection('users').doc(userId).collection('appointments').add({
      'doctor': doctorName,
      'reason': reason,
      'date': date.toIso8601String(),
      'time': time,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 2. Stream for Appointments
  Stream<QuerySnapshot<Map<String, dynamic>>> getAppointmentStream() {
    if (userId == null) return const Stream.empty();
    return _db
        .collection('users')
        .doc(userId)
        .collection('appointments')
        .orderBy('date', descending: false)
        .snapshots();
  }
  // 2. Comprehensive Add: Used for both Manual and Scanner entries
  Future<void> addMedicine({
    required String name,
    required String portion,
    required String frequency,
    required String timeToEat,
  }) async {
    if (userId == null) return;
    
    await _db.collection('users').doc(userId).collection('medicines').add({
      'name': name,
      'portion': portion,
      'frequency': frequency,
      'timeToEat': timeToEat,
      'createdAt': FieldValue.serverTimestamp(),
      'lastTaken': null, 
    });
  }

  // 3. Mark as "Taken Today": Updates the lastTaken timestamp
  Future<void> markAsTaken(String docId) async {
    if (userId == null) return;

    await _db
        .collection('users')
        .doc(userId)
        .collection('medicines')
        .doc(docId)
        .update({
      'lastTaken': DateTime.now().toIso8601String(),
    });
  }

  // 4. Update/Edit existing entry
  Future<void> updateMedicine(String docId, Map<String, dynamic> updatedData) async {
    if (userId == null) return;
    await _db
        .collection('users')
        .doc(userId)
        .collection('medicines')
        .doc(docId)
        .update(updatedData);
  }

  // 5. Delete Entry
  Future<void> deleteMedicine(String docId) async {
    if (userId == null) return;
    await _db
        .collection('users')
        .doc(userId)
        .collection('medicines')
        .doc(docId)
        .delete();
  }

  // 6. Logic: Check if taken today
  bool isTakenToday(String? lastTakenIso) {
    if (lastTakenIso == null) return false;
    try {
      final lastTaken = DateTime.parse(lastTakenIso);
      final now = DateTime.now();
      return lastTaken.year == now.year && 
             lastTaken.month == now.month && 
             lastTaken.day == now.day;
    } catch (e) {
      return false;
    }
  }
  bool isTakenOnDate(String? lastTakenIso, DateTime selectedDate) {
    if (lastTakenIso == null) return false;
    final lastTaken = DateTime.parse(lastTakenIso);
    return lastTaken.year == selectedDate.year && 
          lastTaken.month == selectedDate.month && 
          lastTaken.day == selectedDate.day;
  }
}