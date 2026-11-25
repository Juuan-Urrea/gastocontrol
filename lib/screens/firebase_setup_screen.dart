import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Se muestra solo si Firebase aun no esta configurado (o fallo al iniciar).
class FirebaseSetupScreen extends StatelessWidget {
  const FirebaseSetupScreen({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final muted = inter(13, color: AppColors.mutedForeground, height: 1.55);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(gradient: AppGradients.primary, borderRadius: BorderRadius.circular(20)),
                  child: const Icon(Icons.cloud_off_outlined, size: 32, color: Colors.white),
                ),
                const SizedBox(height: 18),
                Text('Falta conectar Firebase', style: outfit(24, weight: FontWeight.w700)),
                const SizedBox(height: 8),
                if (message != null) Text(message!, style: inter(13, color: AppColors.warn, height: 1.5)),
                const SizedBox(height: 16),
                Text('1. Pide a tu compañero los datos de la app Web de Firebase.', style: muted),
                Text('2. Abre lib/firebase/firebase_options.dart.', style: muted),
                Text('3. Reemplaza cada "PEGAR_..." por el valor real.', style: muted),
                Text('4. Vuelve a ejecutar la app.', style: muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
