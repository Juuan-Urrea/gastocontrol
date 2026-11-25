import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../firebase/firebase_options.dart';
import 'firestore_service.dart';
import 'web_notifier.dart';

/// Handler de mensajes push en segundo plano (Android/iOS). Debe ser una funcion de nivel superior.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // El sistema operativo muestra la notificacion; aqui no hace falta logica extra.
}

/// Notificaciones:
///  1) Firebase Cloud Messaging (FCM): pide permiso, obtiene el token del dispositivo, lo guarda
///     en Firestore y muestra un aviso cuando llega un push con la app abierta.
///  2) Notificacion del sistema en web (API Notification) para los avisos generados por la app.
class NotificationService extends GetxService {
  bool _listening = false;
  bool _refreshListening = false;

  /// Texto con el estado del registro push (se muestra en Perfil para diagnosticar).
  final RxString status = 'Sin registrar. Pulsa "Activar notificaciones".'.obs;

  /// Token FCM de este navegador/dispositivo (null si aun no se obtuvo).
  final RxnString token = RxnString();

  /// Pide permisos. Llamar desde un gesto del usuario (por ejemplo, al pulsar "Iniciar sesion").
  Future<void> requestPermission() async {
    try {
      await FirebaseMessaging.instance.requestPermission();
    } catch (e) {
      debugPrint('FCM requestPermission: $e');
    }
    await requestSystemPermission();
  }

  /// Pide permiso, obtiene el token FCM y lo guarda en usuarios/{uid}.fcmToken.
  /// Deja en [status] el resultado o el motivo exacto del fallo.
  Future<void> registerToken(String uid, FirestoreService fs) async {
    status.value = 'Registrando notificaciones...';
    try {
      if (kIsWeb && !DefaultFirebaseOptions.hasVapidKey) {
        status.value = 'Falta la clave VAPID en lib/firebase/firebase_options.dart.';
        return;
      }

      // En web hay que tener permiso ANTES de pedir el token.
      final settings = await FirebaseMessaging.instance.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        status.value =
            'Permiso bloqueado. En el navegador: candado de la barra de direcciones → Notificaciones → Permitir, y pulsa de nuevo.';
        return;
      }
      if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
        status.value = 'Aún no diste permiso. Pulsa "Activar notificaciones" y acepta el aviso del navegador.';
        return;
      }

      final t = await FirebaseMessaging.instance.getToken(
        vapidKey: kIsWeb ? DefaultFirebaseOptions.vapidKey : null,
      );
      if (t == null || t.isEmpty) {
        status.value = 'Firebase no devolvió ningún token.';
        return;
      }

      token.value = t;
      await fs.updateProfile(uid, {'fcmToken': t});
      status.value = 'Listo: token guardado en tu perfil de Firestore.';

      if (!_refreshListening) {
        _refreshListening = true;
        FirebaseMessaging.instance.onTokenRefresh.listen((nuevo) {
          token.value = nuevo;
          fs.updateProfile(uid, {'fcmToken': nuevo});
        });
      }
      _listenForeground();
    } catch (e) {
      // Aqui cae, por ejemplo, un service worker que no se pudo registrar en FlutLab.
      debugPrint('FCM registerToken: $e');
      status.value = 'Error: $e';
    }
  }

  void _listenForeground() {
    if (_listening) return;
    _listening = true;
    FirebaseMessaging.onMessage.listen((message) {
      final n = message.notification;
      if (n == null) return;
      Get.snackbar(
        n.title ?? 'GastoControl',
        n.body ?? '',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
    });
  }

  /// Notificacion del sistema (web) para un aviso generado dentro de la app.
  void showSystem(String title, String body) => showSystemNotification(title, body);
}
