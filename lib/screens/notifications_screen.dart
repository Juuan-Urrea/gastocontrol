import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/app_controller.dart';
import '../models/app_notification.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';

/// Lista de notificaciones en tiempo real (Firestore). Al tocar una se marca como leida.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  Color _color(NotificationType t) {
    switch (t) {
      case NotificationType.danger:
        return AppColors.danger;
      case NotificationType.warn:
        return AppColors.warn;
      case NotificationType.info:
        return AppColors.accent;
    }
  }

  @override
  Widget build(BuildContext context) => Obx(() => _content(context, AppController.to));

  Widget _content(BuildContext context, AppController state) {
    final items = state.notifications;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, screenTopPadding(context), 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(onPressed: state.back, icon: const Icon(Icons.arrow_back)),
              const SizedBox(width: 6),
              Expanded(child: Text('Notificaciones', style: outfit(24, weight: FontWeight.w700))),
              if (state.unreadCount > 0)
                TextButton(onPressed: state.markAllRead, child: const Text('Marcar todas')),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Text(
                      'Aún no tienes notificaciones.\nRegistra un gasto y aparecerá aquí al instante.',
                      textAlign: TextAlign.center,
                      style: inter(14, color: AppColors.mutedForeground, height: 1.5),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 9),
                    itemBuilder: (_, i) {
                      final n = items[i];
                      final color = _color(n.type);
                      final when = n.createdAt > 0 ? timeAgo(n.createdAt) : n.time;
                      return Material(
                        color: n.read ? AppColors.white03 : color.withOpacity(0.10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: n.read ? AppColors.white06 : color.withOpacity(0.35)),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => state.markRead(n.id),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: Text(n.title, style: inter(14, weight: FontWeight.w600))),
                                    if (!n.read)
                                      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(n.message, style: inter(13, color: AppColors.mutedForeground, height: 1.4)),
                                const SizedBox(height: 6),
                                Text(when, style: inter(11, color: AppColors.mutedForeground)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
