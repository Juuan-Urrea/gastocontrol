import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../models/app_notification.dart';
import '../models/expense.dart';

/// Acceso a Cloud Firestore. Estructura de datos:
///
///   usuarios/{uid}                      -> perfil (name, email, avatar, income, budget, setupDone, alertsEnabled, fcmToken)
///   usuarios/{uid}/gastos/{id}          -> un documento por gasto
///   usuarios/{uid}/notificaciones/{id}  -> un documento por notificacion
///
/// Los metodos watch* devuelven Streams (snapshots): son la parte de "tiempo real".
class FirestoreService extends GetxService {
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _user(String uid) => _db.collection('usuarios').doc(uid);
  CollectionReference<Map<String, dynamic>> _expenses(String uid) => _user(uid).collection('gastos');
  CollectionReference<Map<String, dynamic>> _notifs(String uid) => _user(uid).collection('notificaciones');

  // ------------------------------------------------------------ tiempo real

  /// Perfil del usuario; emite null mientras el documento aun no existe.
  Stream<Map<String, dynamic>?> watchProfile(String uid) =>
      _user(uid).snapshots().map((s) => s.exists ? s.data() : null);

  Stream<List<Expense>> watchExpenses(String uid) => _expenses(uid).snapshots().map(
        (q) => q.docs.map((d) => Expense.fromJson({...d.data(), 'id': d.id})).toList(),
      );

  Stream<List<AppNotification>> watchNotifications(String uid) => _notifs(uid).snapshots().map(
        (q) => q.docs.map((d) => AppNotification.fromJson({...d.data(), 'id': d.id})).toList(),
      );

  // ------------------------------------------------------------------ perfil

  Future<void> createProfile(
    String uid, {
    required String name,
    required String email,
    required String avatar,
  }) {
    return _user(uid).set({
      'name': name,
      'email': email,
      'avatar': avatar,
      'income': 0,
      'budget': 0,
      'setupDone': false,
      'alertsEnabled': true,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Si la cuenta existe en Auth pero no tiene perfil en Firestore, lo crea.
  Future<void> ensureProfile(
    String uid, {
    required String name,
    required String email,
    required String avatar,
  }) async {
    final snap = await _user(uid).get();
    if (!snap.exists) {
      await createProfile(uid, name: name, email: email, avatar: avatar);
    }
  }

  Future<void> deposit(String uid, int amount) =>
      _user(uid).update({'deposited': FieldValue.increment(amount)});

  Future<void> updateProfile(String uid, Map<String, dynamic> data) =>
      _user(uid).set(data, SetOptions(merge: true));

  // ------------------------------------------------------------------ gastos

  Future<void> saveExpense(String uid, Expense e) {
    final data = e.toJson()..remove('id');
    return _expenses(uid).doc(e.id).set(data);
  }

  Future<void> deleteExpense(String uid, String id) => _expenses(uid).doc(id).delete();

  Future<void> saveExpenses(String uid, List<Expense> items) async {
    final batch = _db.batch();
    for (final e in items) {
      batch.set(_expenses(uid).doc(e.id), e.toJson()..remove('id'));
    }
    await batch.commit();
  }

  Future<void> deleteExpenses(String uid, List<String> ids) async {
    final batch = _db.batch();
    for (final id in ids) {
      batch.delete(_expenses(uid).doc(id));
    }
    await batch.commit();
  }

  // ---------------------------------------------------------- notificaciones

  Future<void> saveNotification(String uid, AppNotification n) {
    final data = n.toJson()..remove('id');
    return _notifs(uid).doc(n.id).set(data);
  }

  Future<void> markNotificationsRead(String uid, List<String> ids) async {
    final batch = _db.batch();
    for (final id in ids) {
      batch.update(_notifs(uid).doc(id), {'read': true});
    }
    await batch.commit();
  }
}
