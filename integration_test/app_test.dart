import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:personal_finance_tracker/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('End-To-End Expense Lifecycle (Create -> Edit -> Delete)', (tester) async {
    SharedPreferences.setMockInitialValues({});

    app.main();
    await tester.pumpAndSettle();

    // 1. Initial State: Confirm empty dashboard
    expect(find.text('No expenses recorded yet.'), findsOneWidget);

    // 2. Open Add Expense form
    await tester.tap(find.text('Add Expense'));
    await tester.pumpAndSettle();

    expect(find.text('Wireframe: Add Expense'), findsOneWidget);

    // 3. Fill in Form
    final amountField = find.byType(TextFormField).first;
    final descriptionField = find.byType(TextFormField).last;

    await tester.enterText(amountField, '100');
    await tester.enterText(descriptionField, 'Dinner');
    await tester.pumpAndSettle();

    // Submit form
    await tester.tap(find.text('Save Expense'));
    await tester.pumpAndSettle();

    // 4. Verify item appears in dashboard
    expect(find.text('Dinner'), findsOneWidget);
    expect(find.text('100.00 ALL'), findsOneWidget);

    // 5. Open Edit Expense form by tapping card
    await tester.tap(find.text('Dinner'));
    await tester.pumpAndSettle();

    expect(find.text('Wireframe: Edit Expense'), findsOneWidget);
    expect(find.text('Currency: ALL (Immutable)'), findsOneWidget);

    // Edit amount to 200
    final editAmountField = find.byType(TextFormField).first;
    await tester.enterText(editAmountField, '200');
    await tester.pumpAndSettle();

    // Submit update
    await tester.tap(find.text('Update Expense'));
    await tester.pumpAndSettle();

    // 6. Verify dashboard displays updated amount
    expect(find.text('200.00 ALL'), findsOneWidget);

    // 7. Delete expense item
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    // 8. Confirm dashboard returned to empty state
    expect(find.text('No expenses recorded yet.'), findsOneWidget);
  });
}
