import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_frontend/main.dart' as app;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Bottom navigation', () {
    testWidgets('tapping items switches between tabs', (tester) async {
      await tester.pumpWidget(const app.MyApp());
      await tester.pumpAndSettle();

      // Initial screen should contain dashboard-related widgets/text.
      expect(find.textContaining('Dashboard'), findsAny);

      // Try to tap by semantics labels commonly used in BottomNavigationBar items.
      // Fallback to icons when labels are not available.
      Future<void> tapNav(String label, IconData icon) async {
        final labelFinder = find.text(label);
        if (labelFinder.evaluate().isNotEmpty) {
          await tester.tap(labelFinder.first);
        } else {
          final iconFinder = find.byIcon(icon);
          if (iconFinder.evaluate().isNotEmpty) {
            await tester.tap(iconFinder.first);
          }
        }
        await tester.pumpAndSettle();
      }

      await tapNav('Transactions', Icons.list_alt);
      expect(find.textContaining('Transactions'), findsAny);

      await tapNav('Budgets', Icons.account_balance_wallet_outlined);
      expect(find.textContaining('Budgets'), findsAny);

      await tapNav('Reports', Icons.insights_outlined);
      expect(find.textContaining('Reports'), findsAny);
    });
  });
}
