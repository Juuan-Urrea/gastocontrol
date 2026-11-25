import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyBzExHpw576PqI_PuDpFKERl9kG9KY5rmA",
    appId: "1:942983192460:web:4e101bbe1aa1a2d2d780a9",
    messagingSenderId: "942983192460",
    projectId: "gastocontrol-eaac4",
    authDomain: "gastocontrol-eaac4.firebaseapp.com",
    storageBucket: "gastocontrol-eaac4.firebasestorage.app",
  );

  static const String vapidKey =
      'BGyVVhVn8MJrcQnNuu22hLiNN7Qgmwd-ag0J3R7YCJCR5uWq_n4I5aiqRAn40lWEneP8otADRAY3x98ekGjzQlE';

  static bool get isConfigured =>
      !web.apiKey.startsWith('PEGAR') &&
      !web.appId.startsWith('PEGAR') &&
      !web.projectId.startsWith('PEGAR');

  static bool get hasVapidKey => !vapidKey.startsWith('PEGAR');

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    throw UnsupportedError(
      'Solo esta configurada la plataforma web (FlutLab). Para Android/iOS ejecuta '
      '"flutterfire configure" o agrega google-services.json / GoogleService-Info.plist.',
    );
  }
}
