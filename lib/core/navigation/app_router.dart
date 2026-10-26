import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';
import '../../features/budgets/presentation/screens/budget_screen.dart';
import '../../features/currency/domain/repositories/currency_repository.dart';
import '../../features/expenses/domain/entities/expense.dart';
import '../../features/expenses/presentation/screens/add_edit_expense_screen.dart';
import '../../features/expenses/presentation/screens/expense_list_screen.dart';
import '../../features/statistics/presentation/screens/statistics_screen.dart';
import '../di/injection_container.dart';

final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => Scaffold(
        body: navigationShell,
        bottomNavigationBar: _AppTabBar(navigationShell: navigationShell),
      ),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const ExpenseListScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/statistics',
              builder: (context, state) => const StatisticsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/budget',
              builder: (context, state) => const BudgetScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/expense/add',
      builder: (context, state) =>
          AddEditExpenseScreen(currencyRepository: sl<CurrencyRepository>()),
    ),
    GoRoute(
      path: '/expense/edit',
      builder: (context, state) {
        final expense = state.extra;
        if (expense is! Expense) {
          return const Scaffold(
            body: Center(child: Text('Expense details are unavailable.')),
          );
        }
        return AddEditExpenseScreen(
          expense: expense,
          currencyRepository: sl<CurrencyRepository>(),
        );
      },
    ),
  ],
);

class _AppTabBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const _AppTabBar({required this.navigationShell});

  static const _items = [
    ('🏠', 'Home'),
    ('📊', 'Statistics'),
    ('🗂️', 'Budget'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 58,
        decoration: const BoxDecoration(
          color: AppTheme.paper,
          border: Border(top: BorderSide(color: AppTheme.line)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (var index = 0; index < _items.length; index++)
              Expanded(
                child: InkWell(
                  onTap: () => navigationShell.goBranch(
                    index,
                    initialLocation: index == navigationShell.currentIndex,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _items[index].$1,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _items[index].$2,
                        style: TextStyle(
                          color: index == navigationShell.currentIndex
                              ? AppTheme.ink
                              : AppTheme.muted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
