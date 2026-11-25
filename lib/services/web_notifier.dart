// Selecciona la implementacion segun la plataforma:
//  - Web  -> web_notifier_web.dart (usa la API Notification del navegador)
//  - Resto -> web_notifier_stub.dart (no hace nada)
export 'web_notifier_stub.dart' if (dart.library.html) 'web_notifier_web.dart';
