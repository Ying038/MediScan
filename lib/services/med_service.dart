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
  Future<void> updateAppointment({
    required String docId,
    required String doctorName,
    required String reason,
    required DateTime date,
    required String time,
  }) async {
    if (userId == null) return;
    await _db.collection('users').doc(userId).collection('appointments').doc(docId).update({
      'doctor': doctorName,
      'reason': reason,
      'date': date.toIso8601String(),
      'time': time,
    });
  }

  // 3. Delete Appointment
  Future<void> deleteAppointment(String docId) async {
    if (userId == null) return;
    await _db.collection('users').doc(userId).collection('appointments').doc(docId).delete();
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
  // lib/services/med_service.dart

  // 1. Update addMedicine
  Future<void> addMedicine({
    required String name,
    required String portion,
    required String frequency,
    required List<String> times, // Change 'String timeToEat' to 'List<String> times'
  }) async {
    if (userId == null) return;
    int weekdayCreated = DateTime.now().weekday;

    await _db.collection('users').doc(userId).collection('medicines').add({
      'name': name,
      'portion': portion,
      'frequency': frequency,
      'times': times, // Store the list in Firestore
      'weekdayCreated': weekdayCreated,
      'createdAt': FieldValue.serverTimestamp(),
      'takenDoses': [],
    });
  }

  // 2. Update updateMedicine
  Future<void> updateMedicine({
    required String docId,
    required String name,
    required String portion,
    required String frequency,
    required List<String> times, // Change this to List<String>
  }) async {
    if (userId == null) return;
    await _db.collection('users').doc(userId).collection('medicines').doc(docId).update({
      'name': name,
      'portion': portion,
      'frequency': frequency,
      'times': times, // Update the list in Firestore
    });
  }

  // 3. Mark as "Taken Today": Updates the lastTaken timestamp
  Future<void> markAsTaken(String docId) async {
    if (userId == null) return;
    final now = DateTime.now().toIso8601String();
    
    await _db.collection('users').doc(userId).collection('medicines').doc(docId).update({
      // arrayUnion adds a new timestamp without deleting the old ones
      'takenDoses': FieldValue.arrayUnion([now]), 
      'lastTaken': now, // Keep this for compatibility with other logic
    });
  }
  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
          date1.month == date2.month &&
          date1.day == date2.day;
  }
  // Logic to count how many doses were taken on a specific day
  int getTakenCountForDate(List<dynamic>? takenDoses, DateTime date) {
    if (takenDoses == null) return 0;
    return takenDoses.where((d) {
      DateTime doseDate = DateTime.parse(d);
      return isSameDay(doseDate, date);
    }).length;
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