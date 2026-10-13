import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:personal_finance_tracker/features/recurring_expenses/data/data_sources/local/recurring_expense_local_data_source.dart';
import 'package:personal_finance_tracker/features/recurring_expenses/data/repositories/recurring_expense_repository_impl.dart';
import 'package:personal_finance_tracker/features/recurring_expenses/domain/usecases/save_recurring_expense_rule.dart';
import 'package:personal_finance_tracker/features/recurring_expenses/presentation/cubit/recurring_expense_cubit.dart';
import 'package:personal_finance_tracker/features/recurring_expenses/presentation/screens/recurring_expense_rules_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RecurringExpenseCubit cubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = RecurringExpenseRepositoryImpl(
      localDataSource: RecurringExpenseLocalDataSource(prefs: preferences),
    );
    cubit = RecurringExpenseCubit(
      repository: repository,
      saveRuleUseCase: SaveRecurringExpenseRuleUseCase(repository),
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  testWidgets('creates, edits, and deletes a recurring expense rule', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider.value(
            value: cubit,
            child: const RecurringExpenseRulesScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No recurring expenses yet.'), findsOneWidget);

    await tester.tap(
      find.widgetWithText(FilledButton, 'Add recurring expense'),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '25');
    await tester.tap(find.text('Create rule'));
    await tester.pumpAndSettle();
    expect(find.text('Food'), findsOneWidget);
    expect(find.textContaining('25.00 ALL'), findsOneWidget);

    await tester.tap(find.text('Food'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '42');
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    expect(find.textContaining('42.00 ALL'), findsOneWidget);

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();
    expect(find.text('No recurring expenses yet.'), findsOneWidget);
  });
}
