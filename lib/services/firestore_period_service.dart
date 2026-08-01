import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService._();

  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _periodLogs(int userId) {
    return _firestore
        .collection("users")
        .doc(userId.toString())
        .collection("period_logs");
  }

  DateTime _normalize(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  String _docId(DateTime date) {
    final d = _normalize(date);

    return "${d.year}-"
        "${d.month.toString().padLeft(2, '0')}-"
        "${d.day.toString().padLeft(2, '0')}";
  }

  /// Save or overwrite a logged period day
  Future<void> savePeriod({
    required int userId,
    required DateTime date,
  }) async {
    final d = _normalize(date);

    await _periodLogs(userId).doc(_docId(d)).set({
      "date": Timestamp.fromDate(d),
      "logged": true,
      "created_at": FieldValue.serverTimestamp(),
      "updated_at": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Remove a logged period day
  Future<void> deletePeriod({
    required int userId,
    required DateTime date,
  }) async {
    await _periodLogs(userId).doc(_docId(date)).delete();
  }

  /// Returns true if the day has been logged
  Future<bool> isPeriodDay({
    required int userId,
    required DateTime date,
  }) async {
    final doc = await _periodLogs(userId).doc(_docId(date)).get();

    return doc.exists;
  }

  /// Get all logged period dates
  Future<List<DateTime>> getPeriodLogs(int userId) async {
    final snapshot =
        await _periodLogs(userId).orderBy("date").get();

    return snapshot.docs.map((doc) {
      return (doc.data()["date"] as Timestamp).toDate();
    }).toList();
  }

  /// Real-time updates
  Stream<List<DateTime>> periodLogsStream(int userId) {
    return _periodLogs(userId)
        .orderBy("date")
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return (doc.data()["date"] as Timestamp).toDate();
      }).toList();
    });
  }
}