import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:pos_tablet/data/sync/sync_coordinator.dart';

class DashboardSyncStatus extends StatelessWidget {
  const DashboardSyncStatus({super.key});

  @override
  Widget build(BuildContext context) {
    final coordinator = context.watch<SyncCoordinatorImp>();
    final status = coordinator.status;
    final lastSuccessfulSync = coordinator.lastSuccessfulSync;

    final (label, description, icon, color) = switch (status) {
      SyncStatus.idle => (
        'Ready to sync',
        'Sync service is standing by.',
        Icons.cloud_outlined,
        Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      SyncStatus.syncing => (
        'Syncing',
        'Uploading pending changes.',
        Icons.sync,
        Theme.of(context).colorScheme.primary,
      ),
      SyncStatus.waitingForNetwork => (
        'Offline',
        'Changes will sync when the connection returns.',
        Icons.cloud_off_outlined,
        Theme.of(context).colorScheme.error,
      ),
      SyncStatus.success => (
        'Synced',
        'Your latest changes have been synchronized.',
        Icons.cloud_done_outlined,
        const Color(0xFF16834A),
      ),
      SyncStatus.syncFailed => (
        'Sync issue',
        'Some changes could not be synchronized. They will be retried.',
        Icons.warning_amber_outlined,
        Theme.of(context).colorScheme.error,
      ),
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (lastSuccessfulSync != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Last successful sync: ${_formatTime(lastSuccessfulSync)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (status == SyncStatus.syncing)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }
}
