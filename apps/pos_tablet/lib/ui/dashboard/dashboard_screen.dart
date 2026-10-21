import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_tablet/ui/shared/tablet_scaffold.dart';
import 'package:pos_tablet/ui/shifts/shift_view_model.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();

    // If the app was restarted mid-shift, the in-memory shift is gone,
    // so reload the open shift from Supabase.
    final shiftViewModel = context.read<ShiftViewModel>();
    if (shiftViewModel.currentShift == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) shiftViewModel.loadOpenShift.execute();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final shiftViewModel = context.watch<ShiftViewModel>();
    final shift = shiftViewModel.currentShift;
    final isLoadingShift = shiftViewModel.loadOpenShift.running;

    final String floatText;
    if (shift != null) {
      floatText = '\$${shift.openingFloat.toStringAsFixed(2)}';
    } else if (isLoadingShift) {
      floatText = 'Loading...';
    } else {
      floatText = '--';
    }

    return TabletScaffold(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Your shift is active. Here is your daily overview.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            // Active shift summary.
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Wrap(
                  spacing: 32,
                  runSpacing: 16,
                  children: [
                    _SummaryItem(
                      label: 'Shift status',
                      value: shift == null ? '--' : 'Active',
                      icon: Icons.check_circle_outline,
                    ),
                    _SummaryItem(
                      label: 'Opening float',
                      value: floatText,
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                    const _SummaryItem(
                      label: 'Sales today',
                      value: '0',
                      icon: Icons.point_of_sale_outlined,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            Text(
              'Quick actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Quick-action cards.
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 800 ? 2 : 1;
                final cardWidth =
                    (constraints.maxWidth - (columns - 1) * 16) / columns;

                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _QuickActionCard(
                      width: cardWidth,
                      title: 'New Sale',
                      description: 'Browse products and checkout',
                      icon: Icons.shopping_cart_outlined,
                      onTap: () => context.goNamed('sales'),
                    ),
                    _QuickActionCard(
                      width: cardWidth,
                      title: 'Stock Receiving',
                      description: 'Record incoming stock',
                      icon: Icons.inventory_2_outlined,
                      onTap: () => context.goNamed('stockReceiving'),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(value, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.width,
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  final double width;
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 32),
                const SizedBox(height: 16),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(description),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
