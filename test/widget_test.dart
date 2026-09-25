import 'package:flutter_test/flutter_test.dart';
import 'package:madurai_finance_app/main.dart';
import 'package:madurai_finance_app/screens/splash_screen.dart';

void main() {
  testWidgets('MaduraiFinanceApp renders splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaduraiFinanceApp());

    // Verify that MaduraiFinanceApp initializes and displays the splash screen elements
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('Madurai Finance'), findsWidgets);

    // Advance time to allow SplashScreen timers to expire
    await tester.pump(const Duration(seconds: 2));
  });
}
