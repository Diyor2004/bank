import 'package:flutter_test/flutter_test.dart';
import 'package:bank/main.dart';

void main() {
  testWidgets('Payment screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PaymentApp());

    // Verify that the title is correct.
    expect(find.text("Yangi karta qo'shish"), findsOneWidget);

    // Verify that the payment button exists.
    expect(find.text("Tasdiqlash va to'lash"), findsOneWidget);

    // Verify card holder initial state.
    expect(find.text('KARTA EGASI'), findsAtLeastNWidgets(1));
  });
}
