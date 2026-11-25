import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferencias locales (SharedPreferences). Los datos de la cuenta viven en Firebase;
/// aqui solo se guarda lo que conviene tener a mano en el dispositivo:
///  - el ultimo correo usado (para rellenar el login)
///  - la preferencia de alertas (se usa mientras llega el perfil desde Firestore)
class StorageService extends GetxService {
  StorageService._(this._prefs);

  final SharedPreferences? _prefs;

  static const _kLastEmail = 'gastocontrol.lastEmail';
  static const _kAlerts = 'gastocontrol.alertsEnabled';

  bool get isPersistent => _prefs != null;

  static Future<StorageService> init() async {
    try {
      return StorageService._(await SharedPreferences.getInstance());
    } catch (e) {
      debugPrint('SharedPreferences no disponible: $e');
      return StorageService._(null);
    }
  }

  String? loadLastEmail() => _prefs?.getString(_kLastEmail);

  Future<void> saveLastEmail(String email) async {
    try {
      await _prefs?.setString(_kLastEmail, email);
    } catch (e) {
      debugPrint('No se pudo guardar el correo: $e');
    }
  }

  bool? loadAlertsEnabled() => _prefs?.getBool(_kAlerts);

  Future<void> saveAlertsEnabled(bool value) async {
    try {
      await _prefs?.setBool(_kAlerts, value);
    } catch (e) {
      debugPrint('No se pudo guardar la preferencia de alertas: $e');
    }
  }
}
