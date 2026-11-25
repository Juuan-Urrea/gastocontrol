import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/budget_status.dart';

/// Paleta tomada de src/index.css del prototipo.
class AppColors {
  static const background = Color(0xFF09101F);
  static const foreground = Color(0xFFEEF2FF);
  static const card = Color(0xFF111827);
  static const primary = Color(0xFF7C6FEA);
  static const primaryDark = Color(0xFF5B4FCF);
  static const secondary = Color(0xFF1E2A42);
  static const muted = Color(0xFF1A2438);
  static const mutedForeground = Color(0xFF64748B);
  static const accent = Color(0xFF00D4A0);
  static const accentDark = Color(0xFF00B389);
  static const warn = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);
  static const dangerDark = Color(0xFFDC2626);

  // Blancos translucidos usados en tarjetas, bordes y pistas de progreso.
  static const white03 = Color(0x08FFFFFF);
  static const white04 = Color(0x0AFFFFFF);
  static const white06 = Color(0x0FFFFFFF);
  static const white07 = Color(0x12FFFFFF);
  static const white10 = Color(0x1AFFFFFF);

  static const navBackground = Color(0xF20A0E1A);
}

/// Degradados del prototipo (los angulos CSS se aproximan con Alignment).
class AppGradients {
  /// linear-gradient(160deg, #0d1629 -> #09101f): fondo de pantallas de acceso.
  static const screen = LinearGradient(
    begin: Alignment(-0.34, -0.94),
    end: Alignment(0.34, 0.94),
    colors: [Color(0xFF0D1629), Color(0xFF09101F)],
  );

  /// linear-gradient(135deg, #7c6fea -> #5b4fcf)
  static const primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.primaryDark],
  );

  static const danger = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.danger, AppColors.dangerDark],
  );

  /// Tarjeta principal del dashboard (135deg #1a1040 -> #0f1e35).
  static const budgetCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1040), Color(0xFF0F1E35)],
  );

  /// .gradient-card (160deg #1a2440 -> #111827)
  static const card = LinearGradient(
    begin: Alignment(-0.34, -0.94),
    end: Alignment(0.34, 0.94),
    colors: [Color(0xFF1A2440), Color(0xFF111827)],
  );
}

/// Resplandor (.glow-primary): box-shadow 0 0 24px rgba(124,111,234,0.35)
const List<BoxShadow> kGlowPrimary = [
  BoxShadow(color: Color(0x597C6FEA), blurRadius: 24),
];

const String kDisplayFont = 'Outfit';
const String kBodyFont = 'Inter';

/// Estilo de titulos/numeros (font-outfit).
TextStyle outfit(double size, {FontWeight weight = FontWeight.w400, Color color = AppColors.foreground, double? height}) {
  return TextStyle(fontFamily: kDisplayFont, fontSize: size, fontWeight: weight, color: color, height: height);
}

/// Estilo de texto de cuerpo (Inter).
TextStyle inter(double size, {FontWeight weight = FontWeight.w400, Color color = AppColors.foreground, double? height}) {
  return TextStyle(fontFamily: kBodyFont, fontSize: size, fontWeight: weight, color: color, height: height);
}

/// Color asociado a cada estado del presupuesto.
Color budgetStatusColor(BudgetStatus status) {
  switch (status) {
    case BudgetStatus.ok:
      return AppColors.accent;
    case BudgetStatus.warn:
      return AppColors.warn;
    case BudgetStatus.danger:
      return AppColors.danger;
  }
}

/// Relleno superior de los encabezados. En el prototipo es pt-12 (48 px);
/// en telefonos con notch se respeta el area segura.
double screenTopPadding(BuildContext context) {
  return math.max(48.0, MediaQuery.of(context).padding.top + 12);
}

/// Decoracion de tarjeta estandar (fondo 4 %, borde 7 %).
BoxDecoration cardDecoration({double radius = 24, Color? color, Color? borderColor}) {
  return BoxDecoration(
    color: color ?? AppColors.white04,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: borderColor ?? AppColors.white07),
  );
}

ThemeData buildAppTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  OutlineInputBorder border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color),
      );

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    canvasColor: AppColors.secondary,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.accent,
      onSecondary: AppColors.background,
      surface: AppColors.card,
      onSurface: AppColors.foreground,
      error: AppColors.danger,
    ),
    textTheme: base.textTheme.apply(
      fontFamily: kBodyFont,
      bodyColor: AppColors.foreground,
      displayColor: AppColors.foreground,
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.primary,
      selectionColor: AppColors.primary.withOpacity(0.3),
      selectionHandleColor: AppColors.primary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.secondary,
      isDense: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: inter(15, color: AppColors.mutedForeground),
      errorStyle: inter(12, color: AppColors.danger),
      border: border(AppColors.white07),
      enabledBorder: border(AppColors.white07),
      disabledBorder: border(AppColors.white07),
      focusedBorder: border(AppColors.primary),
      errorBorder: border(AppColors.danger),
      focusedErrorBorder: border(AppColors.danger),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.muted,
      contentTextStyle: inter(14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
