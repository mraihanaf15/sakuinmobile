import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/core.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  IconData _icon(String type) {
    switch (type) {
      case 'budget_exceeded':
        return Icons.warning_amber_rounded;
      case 'budget_warning':
        return Icons.error_outline;
      case 'goal_achieved':
        return Icons.emoji_events_outlined;
      case 'broadcast':
        return Icons.campaign_outlined;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  Color _color(String type) {
    if (type == 'budget_exceeded') return SC.red;
    if (type == 'budget_warning') return SC.amber;
    return SC.green;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifikasi')),
      body: ref
          .watch(notificationsProvider)
          .when(
            loading: () =>
                const Center(child: CircularProgressIndicator(color: SC.green)),
            error: (e, _) => Center(child: Text(apiError(e))),
            data: (items) => items.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada notifikasi.',
                      style: TextStyle(color: SC.mute),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: SC.line),
                    itemBuilder: (_, i) {
                      final n = items[i];
                      final type = '${n['type']}';
                      final unread = n['read_at'] == null;
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 4),
                        leading: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: _color(type).withOpacity(.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _icon(type),
                            color: _color(type),
                            size: 20,
                          ),
                        ),
                        title: Text(
                          '${n['title']}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: unread
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          '${n['body']}',
                          style: const TextStyle(fontSize: 11),
                        ),
                        trailing: unread
                            ? Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: SC.green,
                                  shape: BoxShape.circle,
                                ),
                              )
                            : null,
                        onTap: () async {
                          await ref
                              .read(repoProvider)
                              .markRead(toNum(n['id']).toInt());
                          ref.invalidate(notificationsProvider);
                        },
                      );
                    },
                  ),
          ),
    );
  }
}
