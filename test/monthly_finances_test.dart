import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gastocontrol/controllers/app_controller.dart';
import 'package:gastocontrol/models/app_notification.dart';
import 'package:gastocontrol/models/expense.dart';
import 'package:gastocontrol/services/auth_service.dart';
import 'package:gastocontrol/services/firestore_service.dart';
import 'package:gastocontrol/services/notification_service.dart';
import 'package:gastocontrol/services/storage_service.dart';
import 'package:gastocontrol/utils/format.dart';

class _User extends Fake implements User {
  @override
  String get uid => 'prueba';
}

class _Auth extends AuthService {
  @override
  Stream<User?> authStateChanges() => Stream.value(_User());
}

class _Notifications extends NotificationService {
  @override
  Future<void> registerToken(String uid, FirestoreService fs) async {}
}

class _Store extends FirestoreService {
  int added = 0;

  @override
  Future<void> deposit(String uid, int amount) async { added += amount; }

  @override
  Stream<Map<String, dynamic>?> watchProfile(String uid) =>
      Stream.value({'budget': 100000, 'deposited': 50000});

  @override
  Stream<List<AppNotification>> watchNotifications(String uid) =>
      Stream.value([]);

  @override
  Stream<List<Expense>> watchExpenses(String uid) {
    final now = DateTime.now();
    Expense item(String id, int amount, DateTime date) => Expense(
      id: id, amount: amount, date: dateToStr(date), category: 'food',
      description: id, method: 'Efectivo',
    );
    return Stream.value([
      item('mes actual', 15000, now),
      item('mes anterior', 10000, DateTime(now.year, now.month - 1, 1)),
      item('año anterior', 2000, DateTime(now.year - 1, now.month, 1)),
    ]);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('presupuesto mensual y saldo histórico usan períodos distintos', () async {
    SharedPreferences.setMockInitialValues({});
    Get.put<StorageService>(await StorageService.init());
    Get.put<AuthService>(_Auth());
    final store = _Store();
    Get.put<FirestoreService>(store);
    Get.put<NotificationService>(_Notifications());
    final controller = Get.put(AppController());
    addTearDown(() => Get.reset());
    await Future<void>.delayed(Duration.zero);

    expect(controller.totalSpent, 15000);
    expect(controller.available, 85000);
    expect(controller.budgetPct, 15);
    expect(controller.categoryTotals().single.total, 15000);
    expect(controller.accountBalance, 23000);
    expect(await controller.deposit(0), isFalse);
    expect(await controller.deposit(1000), isTrue);
    expect(store.added, 1000);
  });
}

