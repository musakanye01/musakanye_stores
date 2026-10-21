import 'package:flutter/material.dart';
import 'package:owner/ui/operations/widgets/operations_colors.dart';

class OperationsEmptyState extends StatelessWidget {
  const OperationsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.filter_list_off_rounded,
            size: 38,
            color: OperationsColors.muted,
          ),
          SizedBox(height: 12),
          Text(
            'No activity found',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 6),
          Text(
            'Try selecting another category.',
            textAlign: TextAlign.center,
            style: TextStyle(color: OperationsColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
