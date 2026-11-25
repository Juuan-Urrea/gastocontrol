import 'package:flutter/material.dart';

import 'screens/add_expense_screen.dart';
import 'screens/budget_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/detail_screen.dart';
import 'screens/history_screen.dart';
import 'screens/login_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/register_screen.dart';
import 'screens/setup_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/today_screen.dart';
import 'controllers/app_controller.dart';
import 'theme/app_theme.dart';
import 'package:get/get.dart';
import 'widgets/bottom_nav_bar.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  // Pantallas sin barra inferior (flujo de acceso).
  static const _withoutNav = <AppScreen>{
    AppScreen.splash,
    AppScreen.login,
    AppScreen.register,
    AppScreen.setup,
  };

  Widget _buildScreen(AppScreen screen, AppController state) {
    switch (screen) {
      case AppScreen.splash:
        return const SplashScreen();
      case AppScreen.login:
        return const LoginScreen();
      case AppScreen.register:
        return const RegisterScreen();
      case AppScreen.setup:
        return const SetupScreen();
      case AppScreen.dashboard:
        return const DashboardScreen();
      case AppScreen.addExpense:
        return AddExpenseScreen(expense: state.selectedExpense);
      case AppScreen.today:
        return const TodayScreen();
      case AppScreen.history:
        return const HistoryScreen();
      case AppScreen.detail:
        return const DetailScreen();
      case AppScreen.stats:
        return const StatsScreen();
      case AppScreen.budget:
        return const BudgetScreen();
      case AppScreen.notifications:
        return const NotificationsScreen();
      case AppScreen.profile:
        return const ProfileScreen();
    }
  }

  @override
  Widget build(BuildContext context) => Obx(() => _content(context, AppController.to));

  Widget _content(BuildContext context, AppController state) {
    final hasNavScreen = !_withoutNav.contains(state.screen);
    // Con el teclado abierto se oculta la barra para no aplastar los formularios.
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final showNav = hasNavScreen && !keyboardOpen;

    return PopScope(
      // El boton "atras" del sistema navega dentro de la app; en el dashboard cierra la app.
      canPop: !state.canHandleBack,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) state.back();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          top: false,
          bottom: !hasNavScreen,
          child: Column(
            children: [
              Expanded(
                child: MediaQuery.removePadding(
                  context: context,
                  removeBottom: hasNavScreen,
                  child: KeyedSubtree(
                    key: ValueKey<AppScreen>(state.screen),
                    child: _buildScreen(state.screen, state),
                  ),
                ),
              ),
              if (showNav)
                BottomNavBar(tab: state.tab, onChanged: state.navigateTab),
            ],
          ),
        ),
      ),
    );
  }
}
