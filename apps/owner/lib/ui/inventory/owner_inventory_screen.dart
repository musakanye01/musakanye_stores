import 'package:flutter/material.dart';

const _primary = Color(0xFF2457C5);
const _muted = Color(0xFF737B8C);
const _lowStockColor = Color(0xFFB86A00);

const _categories = ['Clothing', 'Accessories', 'Footwear', 'Feeding'];

class OwnerProduct {
  const OwnerProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    this.lowStockThreshold = 5,
  });

  final int id;
  final String name;
  final String category;
  final double price;
  final int stock;
  final int lowStockThreshold;

  bool get isLowStock => stock <= lowStockThreshold;

  OwnerProduct copyWith({
    String? name,
    String? category,
    double? price,
    int? stock,
    int? lowStockThreshold,
  }) {
    return OwnerProduct(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
    );
  }
}

class OwnerInventoryScreen extends StatefulWidget {
  const OwnerInventoryScreen({super.key});

  @override
  State<OwnerInventoryScreen> createState() => _OwnerInventoryScreenState();
}

class _OwnerInventoryScreenState extends State<OwnerInventoryScreen> {
  final _searchController = TextEditingController();

  String _selectedCategory = 'All';
  bool _lowStockOnly = false;
  int _nextId = 9;

  final List<OwnerProduct> _products = [
    const OwnerProduct(
      id: 1,
      name: 'Baby Grow',
      category: 'Clothing',
      price: 12.50,
      stock: 24,
    ),
    const OwnerProduct(
      id: 2,
      name: 'Baby Vest',
      category: 'Clothing',
      price: 5.00,
      stock: 3,
    ),
    const OwnerProduct(
      id: 3,
      name: 'Baby Socks',
      category: 'Accessories',
      price: 3.00,
      stock: 4,
    ),
    const OwnerProduct(
      id: 4,
      name: 'Baby Blanket',
      category: 'Accessories',
      price: 15.00,
      stock: 12,
    ),
    const OwnerProduct(
      id: 5,
      name: 'Baby Hat',
      category: 'Accessories',
      price: 4.50,
      stock: 5,
    ),
    const OwnerProduct(
      id: 6,
      name: 'Cotton Romper',
      category: 'Clothing',
      price: 10.00,
      stock: 18,
    ),
    const OwnerProduct(
      id: 7,
      name: 'Baby Shoes',
      category: 'Footwear',
      price: 8.00,
      stock: 2,
    ),
    const OwnerProduct(
      id: 8,
      name: 'Feeding Bottle',
      category: 'Feeding',
      price: 6.50,
      stock: 14,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _money(double amount) => '\$${amount.toStringAsFixed(2)}';

  int get _lowStockCount =>
      _products.where((product) => product.isLowStock).length;

  int get _totalUnits =>
      _products.fold(0, (sum, product) => sum + product.stock);

  List<OwnerProduct> get _filteredProducts {
    final query = _searchController.text.trim().toLowerCase();

    return _products.where((product) {
      final matchesSearch =
          product.name.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query);

      final matchesCategory =
          _selectedCategory == 'All' || product.category == _selectedCategory;

      final matchesStock = !_lowStockOnly || product.isLowStock;

      return matchesSearch && matchesCategory && matchesStock;
    }).toList()..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  Widget build(BuildContext context) {
    final products = _filteredProducts;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addProduct,
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add product'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
        children: [
          const Text(
            'Products & stock',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Manage your products and monitor stock levels.',
            style: TextStyle(fontSize: 13, color: _muted),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _summaryCard(
                  title: 'Products',
                  value: '${_products.length}',
                  icon: Icons.inventory_2_outlined,
                  iconColor: _primary,
                  backgroundColor: const Color(0xFFE8EEFF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _summaryCard(
                  title: 'Low stock',
                  value: '$_lowStockCount',
                  icon: Icons.warning_amber_rounded,
                  iconColor: _lowStockColor,
                  backgroundColor: const Color(0xFFFFF0D9),
                  onTap: () {
                    setState(() {
                      _lowStockOnly = !_lowStockOnly;
                    });
                  },
                  active: _lowStockOnly,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.inventory_outlined, color: _muted),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Total units in stock',
                    style: TextStyle(color: _muted, fontSize: 13),
                  ),
                ),
                Text(
                  '$_totalUnits',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.close),
                    )
                  : null,
            ),
          ),

          const SizedBox(height: 16),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', ..._categories].map((category) {
                final selected = _selectedCategory == category;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: selected,
                    showCheckmark: false,
                    selectedColor: const Color(0xFFE0E9FF),
                    labelStyle: TextStyle(
                      color: selected ? _primary : _muted,
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    onSelected: (_) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Product list',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                '${products.length} items',
                style: const TextStyle(fontSize: 12, color: _muted),
              ),
            ],
          ),

          if (_lowStockOnly) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  setState(() => _lowStockOnly = false);
                },
                icon: const Icon(Icons.filter_alt_off, size: 17),
                label: const Text('Clear low-stock filter'),
              ),
            ),
          ],

          const SizedBox(height: 10),

          if (products.isEmpty)
            _emptyState()
          else
            ...products.map(
              (product) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _productCard(product),
              ),
            ),

          const SizedBox(height: 12),

          const Text(
            'Demo data only. Changes remain in memory and are not saved '
            'to Supabase.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: _muted),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    VoidCallback? onTap,
    bool active = false,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: active ? Border.all(color: iconColor, width: 1.5) : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: iconColor, size: 21),
              ),
              const SizedBox(height: 14),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(title, style: const TextStyle(color: _muted, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _productCard(OwnerProduct product) {
    final lowStock = product.isLowStock;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => _showProductDetails(product),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F2F7),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  _categoryIcon(product.category),
                  size: 25,
                  color: _primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      product.category,
                      style: const TextStyle(fontSize: 12, color: _muted),
                    ),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        Text(
                          '${product.stock} in stock',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: lowStock ? _lowStockColor : _muted,
                          ),
                        ),
                        if (lowStock) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.warning_amber_rounded,
                            size: 15,
                            color: _lowStockColor,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _money(product.price),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: _muted,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Icon(Icons.search_off_rounded, size: 40, color: _muted),
          SizedBox(height: 12),
          Text(
            'No products found',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 6),
          Text(
            'Try another search or category.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _muted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Clothing':
        return Icons.checkroom_outlined;
      case 'Accessories':
        return Icons.child_care_outlined;
      case 'Footwear':
        return Icons.roller_shades_closed_sharp;
      case 'Feeding':
        return Icons.baby_changing_station_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  String _xbb(double amount) => '\$${amount.toStringAsFixed(2)}';

  void _showProductDetails(OwnerProduct product) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
            decoration: const BoxDecoration(
              color: Color(0xFFF7F8FC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(product.category, style: const TextStyle(color: _muted)),
                const SizedBox(height: 24),
                _detailRow('Selling price', _xbb(product.price)),
                _detailRow('Quantity in stock', '${product.stock} units'),
                _detailRow(
                  'Low-stock threshold',
                  '${product.lowStockThreshold} units',
                ),
                _detailRow(
                  'Stock status',
                  product.isLowStock ? 'Low stock' : 'In stock',
                  valueColor: product.isLowStock
                      ? _lowStockColor
                      : Colors.green,
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _editProduct(product);
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit product'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: _muted)),
          ),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w600, color: valueColor),
          ),
        ],
      ),
    );
  }

  Future<void> _addProduct() async {
    final product = await showModalBottomSheet<OwnerProduct>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      builder: (_) => const _ProductFormSheet(),
    );

    if (product == null || !mounted) return;

    setState(() {
      _products.add(
        OwnerProduct(
          id: _nextId++,
          name: product.name,
          category: product.category,
          price: product.price,
          stock: product.stock,
          lowStockThreshold: product.lowStockThreshold,
        ),
      );
    });

    _showMessage('${product.name} added to demo inventory.');
  }

  Future<void> _editProduct(OwnerProduct original) async {
    final updated = await showModalBottomSheet<OwnerProduct>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      builder: (_) => _ProductFormSheet(product: original),
    );

    if (updated == null || !mounted) return;

    setState(() {
      final index = _products.indexWhere((p) => p.id == original.id);
      if (index != -1) {
        _products[index] = updated;
      }
    });

    _showMessage('${updated.name} updated in demo inventory.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ProductFormSheet extends StatefulWidget {
  const _ProductFormSheet({this.product});

  final OwnerProduct? product;

  @override
  State<_ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends State<_ProductFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _thresholdController;

  late String _category;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();

    final product = widget.product;

    _nameController = TextEditingController(text: product?.name ?? '');
    _priceController = TextEditingController(
      text: product?.price.toStringAsFixed(2) ?? '',
    );
    _stockController = TextEditingController(
      text: product?.stock.toString() ?? '0',
    );
    _thresholdController = TextEditingController(
      text: product?.lowStockThreshold.toString() ?? '5',
    );

    _category = product?.category ?? _categories.first;
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
    final price = double.tryParse(value ?? '');
    if (price == null || price <= 0) {
      return 'Enter a price greater than zero';
    }
    if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(value!.trim())) {
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

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final existing = widget.product;

    Navigator.pop(
      context,
      OwnerProduct(
        id: existing?.id ?? 0,
        name: _nameController.text.trim(),
        category: _category,
        price: double.parse(_priceController.text.trim()),
        stock: int.parse(_stockController.text.trim()),
        lowStockThreshold: int.parse(_thresholdController.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
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
                  style: TextStyle(color: _muted),
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
                  initialValue: _category,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: _categories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _category = value);
                    }
                  },
                ),
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
                    onPressed: _save,
                    child: Text(_isEditing ? 'Save changes' : 'Add product'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
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
