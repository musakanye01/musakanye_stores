import 'package:flutter/material.dart';
import 'package:owner/ui/operations/widgets/operations_colors.dart';

typedef DetailRow = (String label, String value);

void showActivityDetails(
  BuildContext context, {
  required String title,
  required String id,
  required List<DetailRow> rows,
}) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    builder: (_) => ActivityDetailsSheet(title: title, id: id, rows: rows),
  );
}

/// Bottom sheet listing label/value rows for one sale or shift.
class ActivityDetailsSheet extends StatelessWidget {
  const ActivityDetailsSheet({
    super.key,
    required this.title,
    required this.id,
    required this.rows,
  });

  final String title;
  final String id;
  final List<DetailRow> rows;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              id,
              style: const TextStyle(
                color: OperationsColors.muted,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 22),
            for (final (label, value) in rows) _Row(label, value),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: OperationsColors.muted,
                fontSize: 13,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
