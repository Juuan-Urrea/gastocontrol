import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.screen),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(gradient: AppGradients.primary, borderRadius: BorderRadius.circular(26)),
                  child: const Icon(Icons.account_balance_wallet_outlined, size: 44, color: Colors.white),
                ),
                const SizedBox(height: 22),
                Text('GastoControl', style: outfit(32, weight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text('Controla tus gastos. Decide mejor.', textAlign: TextAlign.center, style: inter(15, color: AppColors.mutedForeground)),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: () => AppController.to.finishSplash(),
                    style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                    child: const Text('Continuar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
