import 'package:cloud_firestore/cloud_firestore.dart';

class FirestorePeriodService {
  FirestorePeriodService({
    required this.userId,
  });

  final int userId;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection => _db
      .collection('users')
      .doc(userId.toString())
      .collection('period_logs');

  String _dateId(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);

    return "${normalized.year}-"
        "${normalized.month.toString().padLeft(2, '0')}-"
        "${normalized.day.toString().padLeft(2, '0')}";
  }

  Future<void> savePeriodDay(DateTime day) async {
    final normalized = DateTime(day.year, day.month, day.day);

    await _collection.doc(_dateId(normalized)).set({
      "date": Timestamp.fromDate(normalized),
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Future<void> savePeriodDays(List<DateTime> days) async {
    final batch = _db.batch();

    for (final day in days) {
      final normalized = DateTime(day.year, day.month, day.day);

      batch.set(
        _collection.doc(_dateId(normalized)),
        {
          "date": Timestamp.fromDate(normalized),
          "createdAt": FieldValue.serverTimestamp(),
        },
      );
    }

    await batch.commit();
  }

  Future<void> deletePeriodDay(DateTime day) async {
    await _collection.doc(_dateId(day)).delete();
  }

  Future<List<DateTime>> loadPeriodDays() async {
    final snapshot = await _collection.get();

    return snapshot.docs
        .map((doc) => (doc.data()['date'] as Timestamp).toDate())
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