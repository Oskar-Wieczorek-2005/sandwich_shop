import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sandwich_shop/main.dart' as app;
import 'package:sandwich_shop/models/sandwich.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    // New shared setup: opens the app fresh before every test.
    setUp(() async {
      app.main();
      // Give the app time to build the first frame.
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });

    // Verifies adding the default sandwich to the cart and that it appears with the correct total.
    testWidgets('add a sandwich to the cart and verify it is in the cart',
        (WidgetTester tester) async {
      await tester.pumpAndSettle();

      expect(find.text('Sandwich Counter'), findsOneWidget);
      expect(find.text('Cart: 0 items - £0.00'), findsOneWidget);
      expect(find.text('Veggie Delight'), findsWidgets);

      final addToCartButton =
          find.widgetWithText(ElevatedButton, 'Add to Cart');
      await tester.ensureVisible(addToCartButton);
      await tester.pumpAndSettle();

      await tester.tap(addToCartButton);
      await tester.pumpAndSettle();

      expect(find.text('Cart: 1 items - £11.00'), findsOneWidget);

      final viewCartButton = find.widgetWithText(ElevatedButton, 'View Cart');
      await tester.ensureVisible(viewCartButton);
      await tester.pumpAndSettle();
      await tester.tap(viewCartButton);
      await tester.pumpAndSettle();

      expect(find.text('Cart'), findsOneWidget);
      expect(find.text('Veggie Delight'), findsOneWidget);
      expect(find.text('Total: £11.00'), findsOneWidget);
    });

    // Verifies that changing the sandwich type via the dropdown is reflected in the cart.
    testWidgets('change sandwich type and add to cart',
        (WidgetTester tester) async {
      await tester.pumpAndSettle();

      final sandwichDropdown = find.byType(DropdownMenu<SandwichType>);
      await tester.tap(sandwichDropdown);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Chicken Teriyaki').last);
      await tester.pumpAndSettle();

      final addToCartButton =
          find.widgetWithText(ElevatedButton, 'Add to Cart');
      await tester.ensureVisible(addToCartButton);
      await tester.pumpAndSettle();

      await tester.tap(addToCartButton);
      await tester.pumpAndSettle();

      final viewCartButton = find.widgetWithText(ElevatedButton, 'View Cart');
      await tester.ensureVisible(viewCartButton);
      await tester.pumpAndSettle();

      await tester.tap(viewCartButton);
      await tester.pumpAndSettle();

      expect(find.text('Cart'), findsOneWidget);
      expect(find.text('Chicken Teriyaki'), findsOneWidget);
    });

    // Verifies that increasing the quantity on the main screen affects the cart count and total.
    testWidgets('modify quantity and add to cart', (WidgetTester tester) async {
      await tester.pumpAndSettle();

      final quantitySection = find.text('Quantity: ');
      expect(quantitySection, findsOneWidget);

      final addButtons = find.byIcon(Icons.add);
      final quantityAddButton = addButtons.first;

      await tester.tap(quantityAddButton);
      await tester.pumpAndSettle();
      await tester.tap(quantityAddButton);
      await tester.pumpAndSettle();

      expect(find.text('3'), findsOneWidget);

      final addToCartButton =
          find.widgetWithText(ElevatedButton, 'Add to Cart');
      await tester.ensureVisible(addToCartButton);
      await tester.pumpAndSettle();

      await tester.tap(addToCartButton);
      await tester.pumpAndSettle();

      expect(find.text('Cart: 3 items - £33.00'), findsOneWidget);
    });

    // Verifies the complete checkout flow and that the app resets the cart after payment.
    testWidgets('complete checkout flow', (WidgetTester tester) async {
      await tester.pumpAndSettle();

      final addToCartButton =
          find.widgetWithText(ElevatedButton, 'Add to Cart');
      await tester.ensureVisible(addToCartButton);
      await tester.tap(addToCartButton);
      await tester.pumpAndSettle();

      final viewCartButton = find.widgetWithText(ElevatedButton, 'View Cart');
      await tester.ensureVisible(viewCartButton);
      await tester.tap(viewCartButton);
      await tester.pumpAndSettle();

      final checkoutButton = find.widgetWithText(ElevatedButton, 'Checkout');
      await tester.tap(checkoutButton);
      await tester.pumpAndSettle();

      expect(find.text('Checkout'), findsOneWidget);
      expect(find.text('Order Summary'), findsOneWidget);

      final confirmPaymentButton = find.text('Confirm Payment');
      await tester.tap(confirmPaymentButton);
      await tester.pumpAndSettle();

      await tester.pump(const Duration(seconds: 3));

      expect(find.text('Sandwich Counter'), findsOneWidget);
      expect(find.text('Cart: 0 items - £0.00'), findsOneWidget);
    });

    // Verifies that quantity cannot exceed maxQuantity and that the enforced value is shown.
    testWidgets('maxQuantity is enforced and user sees validation feedback',
        (WidgetTester tester) async {
      await tester.pumpAndSettle();

      final addButtons = find.byIcon(Icons.add);
      final quantityAddButton = addButtons.first;

      for (int i = 0; i < 10; i++) {
        await tester.tap(quantityAddButton);
        await tester.pumpAndSettle();
      }

      expect(find.text('5'), findsOneWidget);
    });

    // Verifies that items can be removed from the cart and that the empty-cart UI is shown.
    testWidgets('user can remove items and see empty-cart state',
        (WidgetTester tester) async {
      await tester.pumpAndSettle();

      final addToCartButton =
          find.widgetWithText(ElevatedButton, 'Add to Cart');
      await tester.tap(addToCartButton);
      await tester.pumpAndSettle();

      final viewCartButton = find.widgetWithText(ElevatedButton, 'View Cart');
      await tester.tap(viewCartButton);
      await tester.pumpAndSettle();

      final removeButton = find.text('Remove');
      expect(removeButton, findsOneWidget);
      await tester.tap(removeButton);
      await tester.pumpAndSettle();

      expect(find.text('Your cart is empty'), findsOneWidget);
      expect(find.text('Total: £0.00'), findsOneWidget);
    });

    // Verifies that changing quantities in the cart updates the total price.
    testWidgets('updating quantities in cart updates totals',
        (WidgetTester tester) async {
      await tester.pumpAndSettle();

      final addToCartButton =
          find.widgetWithText(ElevatedButton, 'Add to Cart');
      await tester.tap(addToCartButton);
      await tester.pumpAndSettle();

      final viewCartButton = find.widgetWithText(ElevatedButton, 'View Cart');
      await tester.tap(viewCartButton);
      await tester.pumpAndSettle();

      expect(find.text('Total: £11.00'), findsOneWidget);

      final cartAddButtons = find.byIcon(Icons.add);
      final cartItemAddButton = cartAddButtons.first;
      await tester.tap(cartItemAddButton);
      await tester.pumpAndSettle();

      expect(find.text('Total: £22.00'), findsOneWidget);
    });

    // Verifies that navigating back from the cart preserves cart contents when reopening it.
    testWidgets('back navigation preserves cart contents',
        (WidgetTester tester) async {
      await tester.pumpAndSettle();

      final addToCartButton =
          find.widgetWithText(ElevatedButton, 'Add to Cart');
      await tester.tap(addToCartButton);
      await tester.pumpAndSettle();

      final viewCartButton = find.widgetWithText(ElevatedButton, 'View Cart');
      await tester.tap(viewCartButton);
      await tester.pumpAndSettle();

      expect(find.text('Cart'), findsOneWidget);
      expect(find.text('Veggie Delight'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('Sandwich Counter'), findsOneWidget);

      await tester.tap(viewCartButton);
      await tester.pumpAndSettle();

      expect(find.text('Veggie Delight'), findsOneWidget);
      expect(find.text('Total: £11.00'), findsOneWidget);
    });

    // Verifies that restarting the app clears any existing cart state.
    testWidgets('restarting app clears cart (stateless behaviour)',
        (WidgetTester tester) async {
      await tester.pumpAndSettle();

      final addToCartButton =
          find.widgetWithText(ElevatedButton, 'Add to Cart');
      await tester.tap(addToCartButton);
      await tester.pumpAndSettle();

      expect(find.text('Cart: 1 items - £11.00'), findsOneWidget);

      app.main();
      await tester.pumpAndSettle();

      expect(find.text('Sandwich Counter'), findsOneWidget);
      expect(find.text('Cart: 0 items - £0.00'), findsOneWidget);
    });
  });
}
