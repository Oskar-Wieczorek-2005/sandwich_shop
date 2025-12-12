import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sandwich_shop/models/cart.dart';

/// Standard app bar used across all screens.
PreferredSizeWidget buildStandardAppBar({
  required BuildContext context,
  required String title,
  bool showCart = true,
}) {
  // Reusable AppBar with optional cart icon.
  return AppBar(
    title: Text(title),
    actions: [
      if (showCart) const _CartIcon(),
    ],
  );
}

/// Shared scaffold that enforces a common app bar and layout across the app.
class StandardScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final bool showCart;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  const StandardScaffold({
    super.key,
    required this.title,
    required this.body,
    this.showCart = true,
    this.floatingActionButton,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    // Common page layout used across screens.
    return Scaffold(
      appBar: buildStandardAppBar(
        context: context,
        title: title,
        showCart: showCart,
      ),
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

/// Simple cart icon with item count, re-used across screens.
class _CartIcon extends StatelessWidget {
  const _CartIcon();

  @override
  Widget build(BuildContext context) {
    // Cart icon with a badge showing the number of items.
    final cart = context.watch<Cart>();
    final itemCount = cart.items.length;

    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.shopping_cart),
          onPressed: () {
            // hook up navigation to a cart screen here if desired
          },
        ),
        if (itemCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                '$itemCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
