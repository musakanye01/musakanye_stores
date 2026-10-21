import 'package:flutter/material.dart';
import 'package:owner/ui/stock/widgets/inventory_colors.dart';

class InventorySearchField extends StatelessWidget {
  const InventorySearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search products...',
        prefixIcon: const Icon(Icons.search, color: InventoryColors.muted),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(onPressed: onClear, icon: const Icon(Icons.close))
            : null,
      ),
    );
  }
}
