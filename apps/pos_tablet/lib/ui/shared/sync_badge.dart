import 'package:flutter/material.dart';
import 'package:shared_core/domain/model/sync_status.dart';

/// Shows nothing for synced sales, so only the ones needing attention stand out.
class SyncBadge extends StatelessWidget {
  const SyncBadge(this.status, {super.key});

  final SyncStatus status;

  @override
  Widget build(BuildContext context) {
    if (status == SyncStatus.synced) return const SizedBox.shrink();

    final failed = status == SyncStatus.failed;
    final color = failed ? Theme.of(context).colorScheme.error : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        failed ? 'Sync failed' : 'Pending sync',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
