import 'package:flutter/material.dart';
import 'package:owner/ui/inventory/owner_inventory_screen.dart';
import 'package:owner/ui/operations/owner_operations_screen.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  int _selectedIndex = 0;

  static const Color _primary = Color(0xFF2457C5);
  static const Color _muted = Color(0xFF737B8C);

  final List<Map<String, dynamic>> _lowStockProducts = [
    {'name': 'Baby Socks', 'category': 'Accessories', 'stock': 4},
    {'name': 'Baby Vest', 'category': 'Clothing', 'stock': 3},
    {'name': 'Baby Hat', 'category': 'Accessories', 'stock': 5},
  ];

  String get _pageTitle {
    switch (_selectedIndex) {
      case 1:
        return 'Inventory';
      case 2:
        return 'Operations';
      default:
        return 'Dashboard';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _pageTitle,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Baby clothing & accessories',
              style: TextStyle(
                fontSize: 12,
                color: _muted,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 19,
              backgroundColor: const Color(0xFFE6EEFF),
              child: Icon(Icons.person_outline, color: _primary),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHome(),
            const OwnerInventoryScreen(),
            const OwnerOperationsScreen(),
            //_buildOperations(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2_rounded),
            label: 'Inventory',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Operations',
          ),
        ],
      ),
    );
  }

  Widget _buildHome() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        const Text(
          'Welcome back!',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Here is how your store is doing today.',
          style: TextStyle(color: _muted, fontSize: 14),
        ),
        const SizedBox(height: 24),

        _buildSalesCard(),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Transactions',
                value: '18',
                subtitle: 'Today',
                icon: Icons.receipt_long_outlined,
                iconColor: const Color(0xFF2457C5),
                backgroundColor: const Color(0xFFE8EEFF),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'Low Stock',
                value: '${_lowStockProducts.length}',
                subtitle: 'Needs attention',
                icon: Icons.warning_amber_rounded,
                iconColor: const Color(0xFFB86A00),
                backgroundColor: const Color(0xFFFFF0D9),
              ),
            ),
          ],
        ),

        const SizedBox(height: 26),

        _sectionHeading(
          title: 'Stock alerts',
          actionLabel: 'View inventory',
          onAction: () => setState(() => _selectedIndex = 1),
        ),
        const SizedBox(height: 12),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: _lowStockProducts
                  .map(
                    (product) => _buildStockRow(
                      name: product['name'] as String,
                      category: product['category'] as String,
                      quantity: product['stock'] as int,
                    ),
                  )
                  .toList(),
            ),
          ),
        ),

        const SizedBox(height: 26),

        _sectionHeading(title: 'Store operations'),
        const SizedBox(height: 12),

        Card(
          child: Column(
            children: [
              _buildActionRow(
                icon: Icons.point_of_sale_outlined,
                title: 'Cashier shift',
                subtitle: 'Check the current shift status',
                trailing: _statusChip('Open', const Color(0xFF218653)),
                onTap: () => setState(() => _selectedIndex = 2),
              ),
              const Divider(height: 1, indent: 58, endIndent: 16),
              _buildActionRow(
                icon: Icons.payments_outlined,
                title: 'Cash movements',
                subtitle: 'Review cash in and cash out',
                onTap: () => setState(() => _selectedIndex = 2),
              ),
              const Divider(height: 1, indent: 58, endIndent: 16),
              _buildActionRow(
                icon: Icons.inventory_outlined,
                title: 'Stock receiving',
                subtitle: 'Review incoming stock',
                onTap: () => setState(() => _selectedIndex = 2),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        const Text(
          'Demo data only · Not connected to live sales or inventory.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: _muted),
        ),
      ],
    );
  }

  Widget _buildSalesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _primary,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Today's sales",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            '\$428.50',
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Sample sales figure for the demo',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 21),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 3),
            Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: _muted)),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeading({
    required String title,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ),
        if (actionLabel != null)
          TextButton(onPressed: onAction, child: Text(actionLabel)),
      ],
    );
  }

  Widget _buildStockRow({
    required String name,
    required String category,
    required int quantity,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F2F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.inventory_2_outlined, color: _muted),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category,
                  style: const TextStyle(color: _muted, fontSize: 12),
                ),
              ],
            ),
          ),
          _statusChip('$quantity left', const Color(0xFFB86A00)),
        ],
      ),
    );
  }

  Widget _buildActionRow({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFE8EEFF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: _primary, size: 21),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: _muted),
        ),
      ),
      trailing:
          trailing ?? const Icon(Icons.chevron_right_rounded, color: _muted),
    );
  }

  Widget _statusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInventory() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Inventory overview',
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'A quick view of products that need attention.',
          style: TextStyle(color: _muted),
        ),
        const SizedBox(height: 20),
        _buildMetricCard(
          title: 'Low-stock products',
          value: '${_lowStockProducts.length}',
          subtitle: 'Sample inventory data',
          icon: Icons.warning_amber_rounded,
          iconColor: const Color(0xFFB86A00),
          backgroundColor: const Color(0xFFFFF0D9),
        ),
        const SizedBox(height: 20),
        ..._lowStockProducts.map(
          (product) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.inventory_2_outlined),
                ),
                title: Text(product['name'] as String),
                subtitle: Text(product['category'] as String),
                trailing: Text(
                  '${product['stock']} left',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB86A00),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Product editing and full inventory management will be added next.',
          style: TextStyle(color: _muted, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildOperations() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Store operations',
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Monitor cashier activity and store movements.',
          style: TextStyle(color: _muted),
        ),
        const SizedBox(height: 20),
        Card(
          child: Column(
            children: [
              _buildActionRow(
                icon: Icons.point_of_sale_outlined,
                title: 'Cashier shifts',
                subtitle: 'View shift status and reconciliation',
              ),
              const Divider(height: 1, indent: 70),
              _buildActionRow(
                icon: Icons.payments_outlined,
                title: 'Cash movements',
                subtitle: 'Review recorded cash in and cash out',
              ),
              const Divider(height: 1, indent: 70),
              _buildActionRow(
                icon: Icons.inventory_outlined,
                title: 'Stock receipts',
                subtitle: 'Review incoming stock records',
              ),
              const Divider(height: 1, indent: 70),
              _buildActionRow(
                icon: Icons.receipt_long_outlined,
                title: 'Transactions',
                subtitle: 'Browse sales and payment details',
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'These are navigation placeholders. Live records and detail screens '
          'will be implemented in later steps.',
          style: TextStyle(color: _muted, fontSize: 12),
        ),
      ],
    );
  }
}
