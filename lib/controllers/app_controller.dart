import 'dart:async';
import 'dart:collection';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/app_notification.dart';
import '../models/budget_status.dart';
import '../models/categories.dart';
import '../models/expense.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../utils/format.dart';

/// Pantallas de la app (equivalen al tipo "Screen" del prototipo).
enum AppScreen {
  splash,
  login,
  register,
  setup,
  dashboard,
  addExpense,
  today,
  history,
  detail,
  stats,
  budget,
  notifications,
  profile,
}

/// Pestanas de la barra inferior.
enum AppTab { home, expenses, add, stats, profile }

/// Total gastado en una categoria.
class CategoryTotal {
  const CategoryTotal(this.category, this.total);
  final ExpenseCategory category;
  final int total;
}

/// Controlador GetX con TODO el estado de la app.
///
/// - Las variables `Rx` (`.obs`) avisan a los `Obx` de las pantallas cuando cambian.
/// - Auth, Firestore y notificaciones llegan por servicios inyectados con `Get.find()`.
/// - Los gastos, el perfil y las notificaciones se escuchan en TIEMPO REAL (snapshots):
///   cualquier cambio en la nube actualiza la lista y la interfaz sin recargar.
class AppController extends GetxController {
  /// Acceso corto desde cualquier pantalla: `AppController.to`.
  static AppController get to => Get.find<AppController>();

  static const UserProfile _emptyProfile =
      UserProfile(name: '', email: '', avatar: '?', income: 0, budget: 0);

  // Servicios inyectados (ver AppBinding).
  final StorageService _storage = Get.find<StorageService>();
  final AuthService _auth = Get.find<AuthService>();
  final FirestoreService _fs = Get.find<FirestoreService>();
  final NotificationService _push = Get.find<NotificationService>();

  // ---------------------------------------------------------- estado reactivo
  final Rx<UserProfile> _profile = _emptyProfile.obs;
  final RxList<Expense> _expenses = <Expense>[].obs;
  final RxList<AppNotification> _notifications = <AppNotification>[].obs;
  final RxBool _alertsEnabled = true.obs;
  final RxBool _loggedIn = false.obs;
  final RxBool _setupDone = false.obs;
  final RxBool _busy = false.obs;
  final Rx<AppScreen> _screen = AppScreen.splash.obs;
  final Rx<AppTab> _tab = AppTab.home.obs;
  final RxnString _selectedExpenseId = RxnString();

  AppScreen _detailOrigin = AppScreen.history;

  // Estado interno (no necesita reactividad).
  String? _uid;
  bool _profileLoaded = false;
  bool _splashDone = false;
  bool _firstNotifSnapshot = true;
  final Set<String> _knownNotifIds = <String>{};
  StreamSubscription<User?>? _authSub;
  StreamSubscription<Map<String, dynamic>?>? _profileSub;
  StreamSubscription<List<Expense>>? _expSub;
  StreamSubscription<List<AppNotification>>? _notifSub;

  // ----------------------------------------------------------------- ciclo
  @override
  void onInit() {
    super.onInit();
    _trackMonth();
    _alertsEnabled.value = _storage.loadAlertsEnabled() ?? true;
    // Firebase Auth avisa cada vez que se inicia o cierra sesion (y al abrir la app).
    _authSub = _auth.authStateChanges().listen(_onAuthChanged);
  }

  @override
  void onClose() {
    _monthTimer?.cancel();
    _authSub?.cancel();
    _stopListeners();
    super.onClose();
  }

  // ---------------------------------------------------------------- lectura
  UserProfile get profile => _profile.value;
  List<Expense> get expenses => UnmodifiableListView<Expense>(List<Expense>.of(_expenses));
  List<AppNotification> get notifications =>
      UnmodifiableListView<AppNotification>(List<AppNotification>.of(_notifications));
  bool get alertsEnabled => _alertsEnabled.value;
  bool get isLoggedIn => _loggedIn.value;
  bool get busy => _busy.value;
  bool get storageAvailable => _storage.isPersistent;
  String? get uid => _uid;
  String? get lastEmail => _storage.loadLastEmail();

  /// Estado del registro de notificaciones push (texto) y token FCM del dispositivo.
  RxString get pushStatus => _push.status;
  RxnString get pushToken => _push.token;

  /// Pide permiso de notificaciones y obtiene/guarda el token FCM (llamar desde un boton).
  Future<void> enablePush() async {
    final uid = _uid;
    if (uid == null) return;
    await _push.registerToken(uid, _fs);
  }

  AppScreen get screen => _screen.value;
  AppTab get tab => _tab.value;

  Expense? get selectedExpense {
    final id = _selectedExpenseId.value;
    if (id == null) return null;
    for (final e in _expenses) {
      if (e.id == id) return e;
    }
    return null;
  }

  int get unreadCount => _notifications.where((n) => !n.read).length;

  final _month = dateToStr(DateTime.now()).substring(0, 7).obs;
  Timer? _monthTimer;

  void _trackMonth() {
    final now = DateTime.now();
    _month.value = dateToStr(now).substring(0, 7);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    _monthTimer = Timer(tomorrow.difference(now), _trackMonth);
  }

  String get monthLabel => formatMonth(DateTime.parse('${_month.value}-01'));

  bool _inCurrentMonth(Expense expense) => expense.date.startsWith(_month.value);

  Iterable<Expense> get monthlyExpenses => _expenses.where(_inCurrentMonth);
  int get totalSpent => _sum(monthlyExpenses);
  final _deposited = 0.obs;
  int get deposited => _deposited.value;
  int get accountBalance => deposited - _sum(_expenses);

  Future<bool> deposit(int amount) async {
    final uid = _uid;
    if (uid == null || amount <= 0) return false;
    try {
      await _fs.deposit(uid, amount);
      return true;
    } catch (e) {
      _toast('Depósito', 'No se pudo registrar el depósito. Revisa tu conexión.');
      return false;
    }
  }
  int get available => _profile.value.budget - totalSpent;

  /// Porcentaje del presupuesto usado (0 si no hay presupuesto).
  int get budgetPct {
    final budget = _profile.value.budget;
    if (budget <= 0) return 0;
    return totalSpent * 100 ~/ budget;
  }

  BudgetStatus get budgetStatus {
    final pct = budgetPct;
    if (pct >= 100) return BudgetStatus.danger;
    if (pct >= 80) return BudgetStatus.warn;
    return BudgetStatus.ok;
  }

  List<Expense> expensesForDate(String date) => _expenses.where((e) => e.date == date).toList();

  List<Expense> get todayExpenses => expensesForDate(todayStr());
  int get todaySpent => _sum(todayExpenses);

  /// Gastos filtrados por categoria ("all" devuelve todos).
  List<Expense> expensesForCategory(String categoryId) => categoryId == 'all'
      ? List<Expense>.of(_expenses)
      : _expenses.where((e) => e.category == categoryId).toList();

  int spentInCategory(String categoryId) =>
      _sum(monthlyExpenses.where((e) => categoryById(e.category).id == categoryId));

  /// Categorias con gasto > 0, de mayor a menor.
  List<CategoryTotal> categoryTotals() {
    final result = <CategoryTotal>[];
    for (final c in kCategories) {
      final total = spentInCategory(c.id);
      if (total > 0) result.add(CategoryTotal(c, total));
    }
    result.sort((a, b) => b.total.compareTo(a.total));
    return result;
  }

  static int _sum(Iterable<Expense> items) => items.fold<int>(0, (sum, e) => sum + e.amount);

  static String newId() => DateTime.now().microsecondsSinceEpoch.toString();

  // ------------------------------------------------------------- navegacion
  static AppTab? _tabFor(AppScreen s) {
    switch (s) {
      case AppScreen.dashboard:
        return AppTab.home;
      case AppScreen.today:
      case AppScreen.history:
        return AppTab.expenses;
      case AppScreen.stats:
        return AppTab.stats;
      case AppScreen.profile:
        return AppTab.profile;
      default:
        return null;
    }
  }

  void go(AppScreen screen, {AppTab? tab}) {
    if (screen == AppScreen.addExpense && _screen.value != AppScreen.detail) {
      _selectedExpenseId.value = null;
    }
    _screen.value = screen;
    _tab.value = tab ?? _tabFor(screen) ?? _tab.value;
  }

  /// Toque en la barra inferior (misma logica que navigate() del prototipo).
  void navigateTab(AppTab t) {
    switch (t) {
      case AppTab.home:
        go(AppScreen.dashboard);
        break;
      case AppTab.expenses:
        go(AppScreen.today);
        break;
      case AppTab.add:
        _selectedExpenseId.value = null;
        go(AppScreen.addExpense);
        break;
      case AppTab.stats:
        go(AppScreen.stats);
        break;
      case AppTab.profile:
        go(AppScreen.profile);
        break;
    }
  }

  void openDetail(Expense expense) {
    _detailOrigin = _screen.value == AppScreen.detail ? _detailOrigin : _screen.value;
    _selectedExpenseId.value = expense.id;
    go(AppScreen.detail);
  }

  /// true si el boton "atras" del sistema debe manejarse dentro de la app.
  bool get canHandleBack {
    switch (_screen.value) {
      case AppScreen.splash:
      case AppScreen.login:
      case AppScreen.setup:
      case AppScreen.dashboard:
        return false;
      default:
        return true;
    }
  }

  void back() {
    switch (_screen.value) {
      case AppScreen.register:
        go(AppScreen.login);
        break;
      case AppScreen.addExpense:
      case AppScreen.notifications:
      case AppScreen.budget:
        go(AppScreen.dashboard);
        break;
      case AppScreen.detail:
        go(_detailOrigin);
        break;
      case AppScreen.history:
        go(AppScreen.today);
        break;
      case AppScreen.today:
      case AppScreen.stats:
      case AppScreen.profile:
        go(AppScreen.dashboard);
        break;
      default:
        break;
    }
  }

  /// Fin del splash: abre login, configuracion pendiente o dashboard segun la sesion de Firebase.
  void finishSplash() {
    if (_screen.value != AppScreen.splash) return;
    _splashDone = true;
    if (_uid == null) {
      go(AppScreen.login);
    } else if (_profileLoaded) {
      go(_setupDone.value ? AppScreen.dashboard : AppScreen.setup);
    }
    // Si hay sesion pero el perfil aun no llega, _onProfile() hace la navegacion al recibirlo.
  }

  // ------------------------------------------------- sesion (Firebase Auth)

  void _onAuthChanged(User? user) {
    if (user == null) {
      _stopListeners();
      _uid = null;
      _profileLoaded = false;
      _loggedIn.value = false;
      _setupDone.value = false;
      _profile.value = _emptyProfile;
      _deposited.value = 0;
      _expenses.clear();
      _notifications.clear();
      final s = _screen.value;
      if (s != AppScreen.splash && s != AppScreen.login && s != AppScreen.register) {
        go(AppScreen.login);
      }
      return;
    }
    if (_uid == user.uid) return;
    _uid = user.uid;
    _loggedIn.value = true;
    _startListeners(user.uid);
    _push.registerToken(user.uid, _fs);
  }

  /// Inicia sesion con Firebase Auth. Devuelve un mensaje de error o null si salio bien.
  /// La navegacion la hace _onProfile() cuando llega el perfil desde Firestore.
  Future<String?> login(String email, String password) async {
    if (_busy.value) return null;
    _busy.value = true;
    _push.requestPermission(); // dentro del gesto del usuario (clic en "Iniciar sesion")
    try {
      final cleanEmail = email.trim();
      final user = await _auth.signIn(cleanEmail, password);
      await _fs.ensureProfile(
        user.uid,
        name: user.displayName ?? cleanEmail.split('@').first,
        email: user.email ?? cleanEmail,
        avatar: initialsOf(user.displayName ?? cleanEmail),
      );
      await _storage.saveLastEmail(cleanEmail);
      return null;
    } on FirebaseAuthException catch (e) {
      return AuthService.messageFor(e);
    } catch (e) {
      debugPrint('login: $e');
      return 'No se pudo iniciar sesión. Revisa tu conexión e inténtalo de nuevo.';
    } finally {
      _busy.value = false;
    }
  }

  /// Crea la cuenta en Firebase Auth y su perfil en Firestore. Devuelve un error o null.
  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (_busy.value) return null;
    _busy.value = true;
    _push.requestPermission();
    try {
      final cleanName = name.trim();
      final cleanEmail = email.trim();
      final user = await _auth.signUp(cleanName, cleanEmail, password);
      await _fs.createProfile(
        user.uid,
        name: cleanName,
        email: cleanEmail,
        avatar: initialsOf(cleanName),
      );
      await _storage.saveLastEmail(cleanEmail);
      return null;
    } on FirebaseAuthException catch (e) {
      return AuthService.messageFor(e);
    } catch (e) {
      debugPrint('register: $e');
      return 'No se pudo crear la cuenta. Revisa tu conexión e inténtalo de nuevo.';
    } finally {
      _busy.value = false;
    }
  }

  /// Cierra la sesion. _onAuthChanged(null) limpia los datos y vuelve al login.
  Future<void> logout() async {
    await _auth.signOut();
  }

  // ------------------------------------------- escucha en tiempo real (Firestore)

  void _startListeners(String uid) {
    _stopListeners();
    _profileLoaded = false;
    _firstNotifSnapshot = true;
    _knownNotifIds.clear();

    _profileSub = _fs.watchProfile(uid).listen(_onProfile, onError: _onStreamError);
    _expSub = _fs.watchExpenses(uid).listen((list) {
      list.sort((a, b) {
        final byDate = b.date.compareTo(a.date);
        return byDate != 0 ? byDate : b.id.compareTo(a.id);
      });
      _expenses.assignAll(list);
    }, onError: _onStreamError);
    _notifSub = _fs.watchNotifications(uid).listen(_onNotifications, onError: _onStreamError);
  }

  void _stopListeners() {
    _profileSub?.cancel();
    _expSub?.cancel();
    _notifSub?.cancel();
    _profileSub = null;
    _expSub = null;
    _notifSub = null;
  }

  void _onStreamError(Object error) {
    debugPrint('Firestore: $error');
    _toast('Firestore', 'No se pudieron leer los datos. Revisa las reglas de seguridad y tu conexión.');
  }

  void _onProfile(Map<String, dynamic>? data) {
    if (data == null) return; // el perfil aun no existe (registro en curso)
    _deposited.value = (data['deposited'] as num?)?.toInt() ?? 0;
    _profile.value = UserProfile(
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      avatar: data['avatar'] as String? ?? '?',
      income: (data['income'] as num?)?.toInt() ?? 0,
      budget: (data['budget'] as num?)?.toInt() ?? 0,
    );
    _setupDone.value = data['setupDone'] as bool? ?? false;
    final alerts = data['alertsEnabled'] as bool? ?? true;
    if (alerts != _alertsEnabled.value) {
      _alertsEnabled.value = alerts;
      _storage.saveAlertsEnabled(alerts);
    }

    final first = !_profileLoaded;
    _profileLoaded = true;
    if (!first) return;

    // Primera carga del perfil tras iniciar sesion: decidir a donde ir.
    final s = _screen.value;
    final canRoute = s == AppScreen.login ||
        s == AppScreen.register ||
        (s == AppScreen.splash && _splashDone);
    if (canRoute) go(_setupDone.value ? AppScreen.dashboard : AppScreen.setup);
  }

  void _onNotifications(List<AppNotification> list) {
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (!_firstNotifSnapshot) {
      // Notificaciones nuevas llegadas en tiempo real (de este u otro dispositivo).
      for (final n in list) {
        if (!_knownNotifIds.contains(n.id) && !n.read) _announce(n);
      }
    }
    _knownNotifIds
      ..clear()
      ..addAll(list.map((n) => n.id));
    _firstNotifSnapshot = false;
    _notifications.assignAll(list);
  }

  /// Aviso visible: snackbar de GetX dentro de la app + notificacion del sistema (web).
  void _announce(AppNotification n) {
    _toast(n.title, n.message);
    _push.showSystem(n.title, n.message);
  }

  void _toast(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 4),
      backgroundColor: const Color(0xFF1E2A42),
      colorText: const Color(0xFFEEF2FF),
    );
  }

  /// Ejecuta una operacion de red y avisa si falla. Devuelve true si salio bien.
  Future<bool> _try(Future<void> Function() action, String errorMessage) async {
    try {
      await action().timeout(const Duration(seconds: 15));
      return true;
    } catch (e) {
      debugPrint('$errorMessage -> $e');
      _toast('Error', errorMessage);
      return false;
    }
  }

  // ----------------------------------------------------------------- gastos

  Future<void> addExpense(Expense expense) async {
    final uid = _uid;
    if (uid == null) return;
    final budget = _profile.value.budget;
    final prevTotal = totalSpent;

    final ok = await _try(
      () => _fs.saveExpense(uid, expense),
      'No se pudo guardar el gasto. Revisa tu conexión.',
    );
    if (!ok) return;
    go(AppScreen.dashboard, tab: AppTab.home);

    if (!_alertsEnabled.value) return;

    // 1) Aviso de gasto registrado (es la "push" del requerimiento).
    final cat = categoryById(expense.category);
    await _pushNotification(
      title: '✅ Gasto registrado',
      message: '${cat.icon} ${expense.description} por ${formatCOP(expense.amount)} (${cat.label}).',
      type: NotificationType.info,
    );

    if (_inCurrentMonth(expense)) {
      await _budgetAlert(prevTotal, prevTotal + expense.amount, budget);
    }
  }

  Future<void> _budgetAlert(int prevTotal, int newTotal, int budget) async {
    if (budget > 0 && _alertsEnabled.value) {
      final prevPct = prevTotal / budget * 100;
      final newPct = newTotal / budget * 100;
      if (newPct >= 100 && prevPct < 100) {
        await _pushNotification(
          title: '🚨 Presupuesto excedido',
          message: 'Has superado tu presupuesto mensual. Llevas ${formatCOP(newTotal)} gastados.',
          type: NotificationType.danger,
        );
      } else if (newPct >= 80 && prevPct < 80) {
        await _pushNotification(
          title: '⚠️ Presupuesto al 80%',
          message: 'Has usado el 80% de tu presupuesto. Quedan ${formatCOP(budget - newTotal)}.',
          type: NotificationType.warn,
        );
      }
    }
  }

  Future<void> updateExpense(Expense updated) async {
    final uid = _uid;
    if (uid == null) return;
    final previous = _expenses.firstWhereOrNull((e) => e.id == updated.id);
    final prevTotal = totalSpent;
    final budget = profile.budget;
    final previousAmount = previous != null && _inCurrentMonth(previous) ? previous.amount : 0;
    final updatedAmount = _inCurrentMonth(updated) ? updated.amount : 0;
    final ok = await _try(
      () => _fs.saveExpense(uid, updated),
      'No se pudo actualizar el gasto. Revisa tu conexión.',
    );
    if (ok) await _budgetAlert(prevTotal, prevTotal - previousAmount + updatedAmount, budget);
  }

  /// Elimina un gasto; si se estaba viendo su detalle, vuelve a la pantalla de origen.
  Future<void> deleteExpense(String id) async {
    final uid = _uid;
    if (uid == null) return;
    final ok = await _try(
      () => _fs.deleteExpense(uid, id),
      'No se pudo eliminar el gasto. Revisa tu conexión.',
    );
    if (!ok) return;
    if (_screen.value == AppScreen.detail && _selectedExpenseId.value == id) {
      _selectedExpenseId.value = null;
      _screen.value = _detailOrigin;
      _tab.value = _tabFor(_detailOrigin) ?? _tab.value;
    }
  }

  // ---------------------------------------------------------- notificaciones

  Future<void> _pushNotification({
    required String title,
    required String message,
    required NotificationType type,
  }) async {
    final uid = _uid;
    if (uid == null) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final n = AppNotification(
      id: newId(),
      title: title,
      message: message,
      time: 'Ahora',
      read: false,
      type: type,
      createdAt: now,
    );
    // Al escribirla en Firestore, el listener _onNotifications la recibe en tiempo real
    // y dispara el aviso (snackbar + notificacion del sistema).
    await _try(() => _fs.saveNotification(uid, n), 'No se pudo guardar la notificación.');
  }

  Future<void> markRead(String id) async {
    final uid = _uid;
    if (uid == null) return;
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index < 0 || _notifications[index].read) return;
    await _try(() => _fs.markNotificationsRead(uid, [id]), 'No se pudo actualizar la notificación.');
  }

  Future<void> markAllRead() async {
    final uid = _uid;
    if (uid == null) return;
    final ids = _notifications.where((n) => !n.read).map((n) => n.id).toList();
    if (ids.isEmpty) return;
    await _try(() => _fs.markNotificationsRead(uid, ids), 'No se pudieron actualizar las notificaciones.');
  }

  // ----------------------------------------------------------------- perfil

  Future<void> completeSetup({required int income, required int budget}) async {
    final uid = _uid;
    if (uid == null) return;
    final ok = await _try(
      () => _fs.updateProfile(uid, {'income': income, 'budget': budget, 'setupDone': true}),
      'No se pudo guardar la configuración. Revisa tu conexión.',
    );
    if (ok) go(AppScreen.dashboard);
  }

  Future<bool> updateProfile({
    required String name,
    required int income,
    required int budget,
  }) async {
    final uid = _uid;
    if (uid == null) return false;
    return _try(
      () => _fs.updateProfile(uid, {
        'name': name.trim(),
        'avatar': initialsOf(name),
        'income': income,
        'budget': budget,
      }),
      'No se pudo guardar el perfil. Revisa tu conexión.',
    );
  }

  Future<void> setAlertsEnabled(bool value) async {
    final uid = _uid;
    _alertsEnabled.value = value;
    await _storage.saveAlertsEnabled(value);
    if (uid != null) {
      await _try(() => _fs.updateProfile(uid, {'alertsEnabled': value}), 'No se pudo guardar la preferencia.');
    }
  }

  // ------------------------------------------------------ datos de prueba

  /// Agrega gastos de prueba con la fecha de HOY. Usa ids fijos por dia: no duplica.
  /// Devuelve cuantos gastos agrego.
  Future<int> addTodayTestExpenses() async {
    final uid = _uid;
    if (uid == null) return 0;
    final today = todayStr();
    final stamp = today.replaceAll('-', '');
    final samples = <Expense>[
      Expense(id: 'test_${stamp}_1', amount: 15000, category: 'food', description: 'Almuerzo corriente (prueba)', date: today, method: 'Efectivo', isDemo: true),
      Expense(id: 'test_${stamp}_2', amount: 5000, category: 'transport', description: 'Bus universitario (prueba)', date: today, method: 'Tarjeta débito', isDemo: true),
      Expense(id: 'test_${stamp}_3', amount: 6000, category: 'food', description: 'Café y empanada (prueba)', date: today, method: 'Nequi/Daviplata', isDemo: true),
    ];
    final existingIds = _expenses.map((e) => e.id).toSet();
    final toAdd = samples.where((e) => !existingIds.contains(e.id)).toList();
    if (toAdd.isEmpty) return 0;
    final ok = await _try(() => _fs.saveExpenses(uid, toAdd), 'No se pudieron cargar los gastos de prueba.');
    return ok ? toAdd.length : 0;
  }

  /// Quita los gastos marcados como ejemplo/prueba y deja solo los del usuario.
  Future<int> removeDemoExpenses() async {
    final uid = _uid;
    if (uid == null) return 0;
    final ids = _expenses.where((e) => e.isDemo).map((e) => e.id).toList();
    if (ids.isEmpty) return 0;
    final ok = await _try(() => _fs.deleteExpenses(uid, ids), 'No se pudieron quitar los gastos de prueba.');
    return ok ? ids.length : 0;
  }
}
