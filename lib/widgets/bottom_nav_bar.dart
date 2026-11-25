import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../theme/app_theme.dart';

/// Barra de navegacion inferior del prototipo: Inicio, Gastos, [+] elevado, Estadisticas y Perfil.
class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key, required this.tab, required this.onChanged});

  final AppTab tab;
  final ValueChanged<AppTab> onChanged;

  static const double _itemHeight = 41;
  // El boton [+] sobresale unos 12 px por encima de la barra.
  static const double _protrusion = 12;

  @override
  Widget build(BuildContext context) {
    final bottomInset = math.max(16.0, MediaQuery.of(context).padding.bottom);
    // 1 px del borde superior + 8 px de relleno + alto del item + margen inferior.
    final barHeight = 1 + 8 + _itemHeight + bottomInset;

    return SizedBox(
      height: barHeight + _protrusion,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: barHeight,
            child: Container(
              padding: EdgeInsets.fromLTRB(8, 8, 8, bottomInset),
              decoration: const BoxDecoration(
                color: AppColors.navBackground,
                border: Border(top: BorderSide(color: AppColors.white07)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _NavItem(
                      label: 'Inicio',
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home_rounded,
                      selected: tab == AppTab.home,
                      onTap: () => onChanged(AppTab.home),
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      label: 'Gastos',
                      icon: Icons.list_alt_outlined,
                      activeIcon: Icons.list_alt_rounded,
                      selected: tab == AppTab.expenses,
                      onTap: () => onChanged(AppTab.expenses),
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                  Expanded(
                    child: _NavItem(
                      label: 'Estadísticas',
                      icon: Icons.show_chart_rounded,
                      activeIcon: Icons.show_chart_rounded,
                      selected: tab == AppTab.stats,
                      onTap: () => onChanged(AppTab.stats),
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      label: 'Perfil',
                      icon: Icons.person_outline_rounded,
                      activeIcon: Icons.person_rounded,
                      selected: tab == AppTab.profile,
                      onTap: () => onChanged(AppTab.profile),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(child: _AddButton(onTap: () => onChanged(AppTab.add))),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.mutedForeground;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          height: BottomNavBar._itemHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(selected ? activeIcon : icon, size: 22, color: color),
              const SizedBox(height: 4),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: inter(10, weight: selected ? FontWeight.w600 : FontWeight.w400, color: color, height: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Registrar gasto',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: AppGradients.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: kGlowPrimary,
          ),
          child: const Icon(Icons.add_rounded, size: 28, color: Colors.white),
        ),
      ),
    );
  }
}
