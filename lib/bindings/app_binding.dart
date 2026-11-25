import 'package:get/get.dart';

import '../controllers/app_controller.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

/// Inyeccion de dependencias de GetX: aqui se crean (una sola vez) los servicios y el
/// controlador. Despues cualquier pantalla los obtiene con Get.find() / AppController.to.
/// El orden importa: el controlador usa los servicios, asi que va al final.
class AppBinding extends Bindings {
  AppBinding(this.storage);

  final StorageService storage;

  @override
  void dependencies() {
    Get.put<StorageService>(storage, permanent: true);
    Get.put<AuthService>(AuthService(), permanent: true);
    Get.put<FirestoreService>(FirestoreService(), permanent: true);
    Get.put<NotificationService>(NotificationService(), permanent: true);
    Get.put<AppController>(AppController(), permanent: true);
  }
}
