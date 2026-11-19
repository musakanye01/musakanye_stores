import 'package:flutter/material.dart';

class DashboardPrimaryAction extends StatelessWidget {
  const DashboardPrimaryAction({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 560;

        final content = Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: colors.onPrimaryContainer.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.point_of_sale_outlined,
                size: 28,
                color: colors.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ready to make a sale?',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Browse products, add items and complete checkout.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onPrimaryContainer.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

        final button = FilledButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.add),
          label: const Text('New Sale'),
          style: FilledButton.styleFrom(minimumSize: const Size(140, 48)),
        );

        return Card(
          color: colors.primaryContainer,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: isCompact
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        content,
                        const SizedBox(height: 20),
                        SizedBox(width: double.infinity, child: button),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(child: content),
                        const SizedBox(width: 20),
                        button,
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}
