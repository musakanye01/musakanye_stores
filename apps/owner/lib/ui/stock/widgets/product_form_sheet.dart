import 'package:flutter/material.dart';
import 'package:owner/ui/stock/inventory_view_model.dart';
import 'package:owner/ui/stock/widgets/inventory_colors.dart';
import 'package:provider/provider.dart';
import 'package:shared_core/domain/model/catalogue_item.dart';

class ProductFormSheet extends StatefulWidget {
  const ProductFormSheet({super.key, this.product, required this.categories});

  final CatalogueItem? product;
  final List<Map<String, dynamic>> categories;

  @override
  State<ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends State<ProductFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _thresholdController;

  String? _categoryId;
  bool _categoryChanged = false;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();

    final product = widget.product;

    _nameController = TextEditingController(text: product?.productName ?? '');
    _priceController = TextEditingController(
      text: product?.price.toStringAsFixed(2) ?? '',
    );
    _stockController = TextEditingController(
      text: product?.stockOnHand.toString() ?? '0',
    );
    _thresholdController = TextEditingController(text: '5');

    _categoryId = product?.categoryId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter a product name';
    }
    return null;
  }

  String? _validatePrice(String? value) {
    final text = value?.trim() ?? '';
    final price = double.tryParse(text);

    if (price == null || price <= 0) {
      return 'Enter a price greater than zero';
    }
    if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(text)) {
      return 'Use up to 2 decimal places';
    }
    return null;
  }

  String? _validateWholeNumber(String? value, String label) {
    final number = int.tryParse(value ?? '');
    if (number == null || number < 0) {
      return 'Enter a valid $label';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<InventoryViewModel>();
    final product = widget.product;
    final priceCents = (double.parse(_priceController.text.trim()) * 100)
        .round();

    final categoryId = _categoryChanged
        ? _categoryId
        : (product?.categoryId ?? _categoryId);

    final bool saved;

    if (product == null) {
      saved = await viewModel.createProduct(
        name: _nameController.text.trim(),
        categoryId: categoryId,
        priceCents: priceCents,
        initialStock: int.parse(_stockController.text.trim()),
      );
    } else {
      saved = await viewModel.updateProduct(
        productId: product.productId,
        variantId: product.variantId,
        name: _nameController.text.trim(),
        categoryId: categoryId,
        // These fields are not editable in the original UI, so preserve
        // their existing values instead of accidentally clearing them.
        description: product.description,
        sku: product.sku,
        size: product.size,
        colour: product.colour,
        priceCents: priceCents,
      );
    }

    if (!mounted) return;

    if (saved) {
      Navigator.pop(context, true);
    } else {
      final message = viewModel.errorMessage ?? 'Could not save the product.';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<InventoryViewModel>();
    final isSaving = _isEditing
        ? viewModel.isUpdatingProduct
        : viewModel.isCreatingProduct;

    final selectedCategoryExists = widget.categories.any(
      (category) => category['id'] == _categoryId,
    );

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  _isEditing ? 'Edit product' : 'Add product',
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Enter the product details below.',
                  style: TextStyle(color: InventoryColors.muted),
                ),
                const SizedBox(height: 22),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Product name',
                    prefixIcon: Icon(Icons.inventory_2_outlined),
                  ),
                  validator: _validateName,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategoryExists ? _categoryId : null,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Uncategorised'),
                    ),
                    ...widget.categories.map(
                      (category) => DropdownMenuItem<String>(
                        value: category['id'] as String,
                        child: Text(category['name'] as String),
                      ),
                    ),
                  ],
                  onChanged: isSaving
                      ? null
                      : (value) {
                          setState(() {
                            _categoryId = value;
                            _categoryChanged = true;
                          });
                        },
                ),
                if (viewModel.categoryErrorMessage != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Could not load categories: '
                    '${viewModel.categoryErrorMessage}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Selling price (USD)',
                    prefixText: '\$ ',
                  ),
                  validator: _validatePrice,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _stockController,
                        readOnly: _isEditing,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Stock quantity',
                        ),
                        validator: (value) =>
                            _validateWholeNumber(value, 'quantity'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _thresholdController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Low-stock alert at',
                        ),
                        validator: (value) =>
                            _validateWholeNumber(value, 'threshold'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: isSaving ? null : _save,
                    child: isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_isEditing ? 'Save changes' : 'Add product'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: isSaving ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
