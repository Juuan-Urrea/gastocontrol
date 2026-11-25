import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'app_shell.dart';
import 'bindings/app_binding.dart';
import 'firebase/firebase_options.dart';
import 'screens/firebase_setup_screen.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  final storage = await StorageService.init();

  // Firebase: si todavia no pegaste la configuracion, la app muestra una pantalla de ayuda
  // en lugar de cerrarse con un error.
  var firebaseReady = false;
  String? firebaseError;
  if (!DefaultFirebaseOptions.isConfigured) {
    firebaseError =
        'Falta pegar la configuración de Firebase en lib/firebase/firebase_options.dart.';
  } else {
    try {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
      if (!kIsWeb) {
        FirebaseMessaging.onBackgroundMessage(
            firebaseMessagingBackgroundHandler);
      }
      firebaseReady = true;
    } catch (e) {
      firebaseError = 'No se pudo iniciar Firebase: $e';
    }
  }

  runApp(GastoControlApp(
      storage: storage,
      firebaseReady: firebaseReady,
      firebaseError: firebaseError));
}

class GastoControlApp extends StatelessWidget {
  const GastoControlApp({
    super.key,
    required this.storage,
    required this.firebaseReady,
    this.firebaseError,
  });

  final StorageService storage;
  final bool firebaseReady;
  final String? firebaseError;

  @override
  Widget build(BuildContext context) {
    // GetMaterialApp reemplaza a MaterialApp: habilita Get.snackbar, Get.find, bindings, etc.
    return GetMaterialApp(
      title: 'GastoControl',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      initialBinding: firebaseReady ? AppBinding(storage) : null,
      home: firebaseReady
          ? const AppShell()
          : FirebaseSetupScreen(message: firebaseError),
    );
  }
}
