import 'package:flutter/material.dart';
import 'package:owner/ui/stock/inventory_view_model.dart';
import 'package:owner/ui/stock/model/inventory_sort_option.dart';
import 'package:owner/ui/stock/model/inventory_stock_filter.dart';
import 'package:shared_core/theme/app_colors.dart';

class InventoryFilterSheet extends StatefulWidget {
  const InventoryFilterSheet({super.key, required this.viewModel});

  final InventoryViewModel viewModel;

  @override
  State<InventoryFilterSheet> createState() => _InventoryFilterSheetState();
}

class _InventoryFilterSheetState extends State<InventoryFilterSheet> {
  late InventoryStockFilter _stockFilter;
  late String? _categoryId;
  late InventorySortOption _sortOption;

  @override
  void initState() {
    super.initState();

    _stockFilter = widget.viewModel.stockFilter;
    _categoryId = widget.viewModel.selectedCategoryId;
    _sortOption = widget.viewModel.sortOption;
  }

  void _reset() {
    setState(() {
      _stockFilter = InventoryStockFilter.all;
      _categoryId = null;
      _sortOption = InventorySortOption.nameAscending;
    });
  }

  void _apply() {
    widget.viewModel.applyFilters(
      stockFilter: _stockFilter,
      categoryId: _categoryId,
      sortOption: _sortOption,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = widget.viewModel.categories;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          22,
          8,
          22,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Filter products',
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  TextButton(onPressed: _reset, child: const Text('Reset')),
                ],
              ),
              const SizedBox(height: 18),

              _sectionTitle(context, 'Stock status'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _stockChip('All', InventoryStockFilter.all),
                  _stockChip('Low stock', InventoryStockFilter.lowStock),
                  _stockChip('Out of stock', InventoryStockFilter.outOfStock),
                ],
              ),

              const SizedBox(height: 22),
              _sectionTitle(context, 'Category'),
              const SizedBox(height: 10),
              DropdownButtonFormField<String?>(
                initialValue: _categoryId,
                isExpanded: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.outline),
                  ),
                ),
                hint: const Text('All categories'),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All categories'),
                  ),
                  ...categories.map(
                    (category) => DropdownMenuItem<String?>(
                      value: category['id'] as String,
                      child: Text(category['name'] as String),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _categoryId = value);
                },
              ),

              const SizedBox(height: 22),
              _sectionTitle(context, 'Sort by'),
              const SizedBox(height: 8),
              ...InventorySortOption.values.map(
                (option) => RadioListTile<InventorySortOption>(
                  value: option,
                  groupValue: _sortOption,
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _sortOption = value);
                  },
                  title: Text(option.label, style: theme.textTheme.bodyMedium),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  activeColor: AppColors.primary,
                ),
              ),

              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _apply,
                  child: const Text('Apply filters'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall
          ?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  Widget _stockChip(String label, InventoryStockFilter filter) {
    final selected = _stockFilter == filter;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) {
        setState(() => _stockFilter = filter);
      },
      selectedColor: AppColors.primaryContainer,
      backgroundColor: Theme.of(context).colorScheme.surface,
      side: BorderSide(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.25)
            : AppColors.outline,
      ),
      labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: selected ? AppColors.onPrimaryContainer : AppColors.muted,
      ),
    );
  }
}
