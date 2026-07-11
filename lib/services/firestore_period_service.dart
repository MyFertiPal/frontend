import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestorePeriodService {
  final _db = FirebaseFirestore.instance;

  String get uid => FirebaseAuth.instance.currentUser!.uid;

  CollectionReference get _collection =>
      _db.collection('users').doc(uid).collection('period_logs');

  String _dateId(DateTime day) {
    return "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
  }

  Future<void> savePeriodDay(DateTime day) async {
    final normalized = DateTime(day.year, day.month, day.day);

    await _collection.doc(_dateId(normalized)).set({
      "date": Timestamp.fromDate(normalized),
    });
  }


  // NEW: Save multiple period days
  Future<void> savePeriodDays(List<DateTime> days) async {
    final batch = _db.batch();

    for (final day in days) {
      final normalized = DateTime(day.year, day.month, day.day);

      final ref = _collection.doc(_dateId(normalized));

      batch.set(ref, {
        "date": Timestamp.fromDate(normalized),
      });
    }

    await batch.commit();
  }


  Future<void> deletePeriodDay(DateTime day) async {
    await _collection.doc(_dateId(day)).delete();
  }


  Future<List<DateTime>> loadPeriodDays() async {
    final snapshot = await _collection.get();

    return snapshot.docs
        .map((e) => (e["date"] as Timestamp).toDate())
        .toList();
  }


  Future<void> clearAll() async {
    final snapshot = await _collection.get();

    final batch = _db.batch();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}