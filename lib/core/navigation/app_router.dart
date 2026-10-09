import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/budgets/presentation/screens/budget_screen.dart';
import '../../features/currency/domain/repositories/currency_repository.dart';
import '../../features/expenses/domain/entities/expense.dart';
import '../../features/expenses/presentation/screens/add_edit_expense_screen.dart';
import '../../features/expenses/presentation/screens/expense_list_screen.dart';
import '../di/injection_container.dart';

final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) => navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          ),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.query_stats_outlined),
              selectedIcon: Icon(Icons.query_stats),
              label: 'Statistics',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: Icon(Icons.account_balance_wallet),
              label: 'Budget',
            ),
          ],
        ),
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
              builder: (context, state) => const _StatisticsPlaceholder(),
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

class _StatisticsPlaceholder extends StatelessWidget {
  const _StatisticsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: const Center(
        child: Text('Basic expense statistics will be added in a later step.'),
      ),
    );
  }
}
