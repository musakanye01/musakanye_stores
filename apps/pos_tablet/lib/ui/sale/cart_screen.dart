import 'package:flutter/material.dart';
import 'package:pos_tablet/ui/sale/widget/cart/cart_content.dart';

import '../shared/tablet_scaffold.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabletScaffold(
      child: SafeArea(
        child: Padding(padding: EdgeInsets.all(24), child: CartContent()),
      ),
    );
  }
}
