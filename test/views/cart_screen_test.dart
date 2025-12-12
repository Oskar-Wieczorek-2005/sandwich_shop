import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sandwich_shop/views/cart_screen.dart';
import 'package:sandwich_shop/models/cart.dart';
import 'package:sandwich_shop/models/sandwich.dart';
import 'package:sandwich_shop/views/styled_button.dart';
import 'package:sandwich_shop/repositories/pricing_repository.dart';

void main() {
  group('CartScreen', () {
    testWidgets('displays empty cart message when cart is empty',
        (WidgetTester tester) async {
      final Cart emptyCart = Cart();
      // CartScreen now reads Cart from Provider, no cart argument
      final MaterialApp app = MaterialApp(
        home: ChangeNotifierProvider<Cart>.value(
          value: emptyCart,
          child: const Scaffold(body: CartScreen()),
        ),
      );

      await tester.pumpWidget(app);

      // Title is 'Cart' now
      expect(find.text('Cart'), findsOneWidget);
      expect(find.text('Your cart is empty.'), findsOneWidget);
      expect(find.text('Total: £0.00'), findsOneWidget);
    });

    testWidgets('displays cart items when cart has items',
        (WidgetTester tester) async {
      final Cart cart = Cart();
      final Sandwich sandwich = Sandwich(
        type: SandwichType.veggieDelight,
        isFootlong: true,
        breadType: BreadType.white,
      );
      cart.add(sandwich, quantity: 2);

      final PricingRepository pricingRepository = PricingRepository();
      final double itemPrice =
          pricingRepository.calculatePrice(quantity: 2, isFootlong: true);
      final String expectedItemPrice = '£${itemPrice.toStringAsFixed(2)}';
      final String expectedTotal =
          'Total: £${cart.totalPrice.toStringAsFixed(2)}';

      final MaterialApp app = MaterialApp(
        home: ChangeNotifierProvider<Cart>.value(
          value: cart,
          child: const Scaffold(body: CartScreen()),
        ),
      );

      await tester.pumpWidget(app);

      expect(find.text('Cart'), findsOneWidget);

      // CartScreen uses sandwich.name, which is likely enum name or similar;
      // adjust expectations to match current implementation.
      expect(find.text(sandwich.name), findsOneWidget);
      expect(
        find.textContaining('Footlong'),
        findsOneWidget,
      );
      expect(
        find.textContaining('white'),
        findsOneWidget,
      );
      expect(find.text('Qty: 2'), findsOneWidget);
      expect(find.text(expectedItemPrice), findsOneWidget);
      expect(find.text(expectedTotal), findsOneWidget);
    });

    testWidgets('displays multiple cart items correctly',
        (WidgetTester tester) async {
      final Cart cart = Cart();
      final Sandwich sandwich1 = Sandwich(
        type: SandwichType.veggieDelight,
        isFootlong: true,
        breadType: BreadType.white,
      );
      final Sandwich sandwich2 = Sandwich(
        type: SandwichType.chickenTeriyaki,
        isFootlong: false,
        breadType: BreadType.wheat,
      );
      cart
        ..add(sandwich1, quantity: 1)
        ..add(sandwich2, quantity: 3);

      final PricingRepository pricingRepository = PricingRepository();
      final double item1Price = pricingRepository.calculatePrice(
        quantity: 1,
        isFootlong: sandwich1.isFootlong,
      );
      final double item2Price = pricingRepository.calculatePrice(
        quantity: 3,
        isFootlong: sandwich2.isFootlong,
      );

      final MaterialApp app = MaterialApp(
        home: ChangeNotifierProvider<Cart>.value(
          value: cart,
          child: const Scaffold(body: CartScreen()),
        ),
      );

      await tester.pumpWidget(app);

      // Names as used in CartScreen
      expect(find.text(sandwich1.name), findsOneWidget);
      expect(find.text(sandwich2.name), findsOneWidget);

      // Size and bread text
      expect(find.textContaining('Footlong'), findsOneWidget);
      expect(find.textContaining('Six-inch'), findsOneWidget);
      expect(find.textContaining('white'), findsOneWidget);
      expect(find.textContaining('wheat'), findsOneWidget);

      expect(find.text('Qty: 1'), findsOneWidget);
      expect(find.text('Qty: 3'), findsOneWidget);

      expect(
        find.text('£${item1Price.toStringAsFixed(2)}'),
        findsOneWidget,
      );
      expect(
        find.text('£${item2Price.toStringAsFixed(2)}'),
        findsOneWidget,
      );

      expect(
        find.text('Total: £${cart.totalPrice.toStringAsFixed(2)}'),
        findsOneWidget,
      );
    });

    testWidgets('shows checkout button when cart has items',
        (WidgetTester tester) async {
      final Cart cart = Cart();
      final Sandwich sandwich = Sandwich(
        type: SandwichType.veggieDelight,
        isFootlong: true,
        breadType: BreadType.white,
      );
      cart.add(sandwich, quantity: 1);

      final MaterialApp app = MaterialApp(
        home: ChangeNotifierProvider<Cart>.value(
          value: cart,
          child: const Scaffold(body: CartScreen()),
        ),
      );

      await tester.pumpWidget(app);

      expect(find.widgetWithText(StyledButton, 'Checkout'), findsOneWidget);
    });

    testWidgets('hides checkout button when cart is empty',
        (WidgetTester tester) async {
      final Cart emptyCart = Cart();

      final MaterialApp app = MaterialApp(
        home: ChangeNotifierProvider<Cart>.value(
          value: emptyCart,
          child: const Scaffold(body: CartScreen()),
        ),
      );

      await tester.pumpWidget(app);

      expect(find.widgetWithText(StyledButton, 'Checkout'), findsNothing);
    });

    testWidgets('increment quantity button works correctly',
        (WidgetTester tester) async {
      final Cart cart = Cart();
      final Sandwich sandwich = Sandwich(
        type: SandwichType.veggieDelight,
        isFootlong: true,
        breadType: BreadType.white,
      );
      cart.add(sandwich, quantity: 1);

      final MaterialApp app = MaterialApp(
        home: ChangeNotifierProvider<Cart>.value(
          value: cart,
          child: const Scaffold(body: CartScreen()),
        ),
      );

      await tester.pumpWidget(app);

      expect(find.text('Qty: 1'), findsOneWidget);

      final Finder addButtonFinder = find.byIcon(Icons.add);
      await tester.tap(addButtonFinder);
      await tester.pump(); // pump for state + snackbar
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Qty: 2'), findsOneWidget);
      expect(find.text('Quantity increased'), findsOneWidget);
    });

    testWidgets('decrement quantity button works correctly',
        (WidgetTester tester) async {
      final Cart cart = Cart();
      final Sandwich sandwich = Sandwich(
        type: SandwichType.veggieDelight,
        isFootlong: true,
        breadType: BreadType.white,
      );
      cart.add(sandwich, quantity: 2);

      final MaterialApp app = MaterialApp(
        home: ChangeNotifierProvider<Cart>.value(
          value: cart,
          child: const Scaffold(body: CartScreen()),
        ),
      );

      await tester.pumpWidget(app);

      expect(find.text('Qty: 2'), findsOneWidget);

      final Finder removeButtonFinder = find.byIcon(Icons.remove);
      await tester.tap(removeButtonFinder);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Qty: 1'), findsOneWidget);
      expect(find.text('Quantity decreased'), findsOneWidget);
    });

    testWidgets('remove item button works correctly',
        (WidgetTester tester) async {
      final Cart cart = Cart();
      final Sandwich sandwich = Sandwich(
        type: SandwichType.veggieDelight,
        isFootlong: true,
        breadType: BreadType.white,
      );
      cart.add(sandwich, quantity: 2);

      final MaterialApp app = MaterialApp(
        home: ChangeNotifierProvider<Cart>.value(
          value: cart,
          child: const Scaffold(body: CartScreen()),
        ),
      );

      await tester.pumpWidget(app);

      expect(find.text(sandwich.name), findsOneWidget);

      final Finder deleteButtonFinder = find.byIcon(Icons.delete);
      await tester.tap(deleteButtonFinder);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text(sandwich.name), findsNothing);
      expect(find.text('Your cart is empty.'), findsOneWidget);
      expect(find.text('Item removed from cart'), findsOneWidget);
    });

    testWidgets('back button has onPressed handler',
        (WidgetTester tester) async {
      final Cart cart = Cart();

      final MaterialApp app = MaterialApp(
        home: ChangeNotifierProvider<Cart>.value(
          value: cart,
          child: const Scaffold(body: CartScreen()),
        ),
      );

      await tester.pumpWidget(app);

      final Finder backButtonFinder =
          find.widgetWithText(StyledButton, 'Back to Order');
      expect(backButtonFinder, findsOneWidget);

      final StyledButton backButton =
          tester.widget<StyledButton>(backButtonFinder);
      expect(backButton.onPressed, isNotNull);
    });
  });
}
