// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Pide permiso al navegador para mostrar notificaciones del sistema.
Future<void> requestSystemPermission() async {
  try {
    if (html.Notification.supported && html.Notification.permission == 'default') {
      await html.Notification.requestPermission();
    }
  } catch (_) {
    // Algunos navegadores bloquean la solicitud; la app sigue funcionando.
  }
}

/// Muestra una notificacion del sistema (la bandeja del navegador/escritorio).
void showSystemNotification(String title, String body) {
  try {
    if (html.Notification.supported && html.Notification.permission == 'granted') {
      html.Notification(title, body: body);
    }
  } catch (_) {
    // En algunos navegadores moviles el constructor no esta permitido; se ignora.
  }
}
