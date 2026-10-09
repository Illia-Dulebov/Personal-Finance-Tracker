import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../currency/domain/entities/currency_code.dart';
import '../../../expenses/presentation/cubit/expense_cubit.dart';
import '../../../expenses/presentation/cubit/expense_state.dart';
import '../../domain/entities/expense_statistics.dart';
import '../../domain/entities/statistics_filter.dart';
import '../cubit/statistics_cubit.dart';
import '../cubit/statistics_state.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StatisticsCubit>().load();
  }

  Future<void> _pickMonth() async {
    final filter = context.read<StatisticsCubit>().state.filter;
    final picked = await showDatePicker(
      context: context,
      initialDate: filter.startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Select a month',
    );
    if (picked != null && mounted) {
      await context.read<StatisticsCubit>().selectMonth(picked);
    }
  }

  Future<void> _pickCustomRange() async {
    final filter = context.read<StatisticsCubit>().state.filter;
    final currentEnd = filter.endDateExclusive.subtract(
      const Duration(days: 1),
    );
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(
        start: filter.startDate,
        end: currentEnd.isBefore(filter.startDate)
            ? filter.startDate
            : currentEnd,
      ),
    );
    if (range != null && mounted) {
      await context.read<StatisticsCubit>().selectCustomRange(
        range.start,
        range.end,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExpenseCubit, ExpenseState>(
      listenWhen: (previous, current) =>
          current is ExpenseLoadedState || current is ExpenseEmptyState,
      listener: (context, state) => context.read<StatisticsCubit>().refresh(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Statistics')),
        body: BlocBuilder<StatisticsCubit, StatisticsState>(
          builder: (context, state) => switch (state) {
            StatisticsLoadingState() => const Center(
              child: CircularProgressIndicator(),
            ),
            StatisticsErrorState() => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Unable to load statistics.'),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: context.read<StatisticsCubit>().refresh,
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ),
            StatisticsLoadedState() => _StatisticsContent(
              filter: state.filter,
              statistics: state.statistics,
              onPeriodChanged: _selectPeriod,
            ),
          },
        ),
      ),
    );
  }

  Future<void> _selectPeriod(StatisticsPeriod period) async {
    if (period == StatisticsPeriod.month) {
      await _pickMonth();
    } else if (period == StatisticsPeriod.custom) {
      await _pickCustomRange();
    } else {
      await context.read<StatisticsCubit>().selectPeriod(period);
    }
  }
}

class _StatisticsContent extends StatelessWidget {
  final StatisticsFilter filter;
  final ExpenseStatistics statistics;
  final ValueChanged<StatisticsPeriod> onPeriodChanged;

  const _StatisticsContent({
    required this.filter,
    required this.statistics,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        '${DateFormat.yMMMd().format(filter.startDate)} – '
        '${DateFormat.yMMMd().format(filter.endDateExclusive.subtract(const Duration(days: 1)))}';
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        DropdownButtonFormField<StatisticsPeriod>(
          initialValue: filter.period,
          decoration: const InputDecoration(
            labelText: 'Period',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(
              value: StatisticsPeriod.today,
              child: Text('Today'),
            ),
            DropdownMenuItem(
              value: StatisticsPeriod.thisWeek,
              child: Text('This week'),
            ),
            DropdownMenuItem(
              value: StatisticsPeriod.thisMonth,
              child: Text('This month'),
            ),
            DropdownMenuItem(
              value: StatisticsPeriod.month,
              child: Text('Choose month'),
            ),
            DropdownMenuItem(
              value: StatisticsPeriod.custom,
              child: Text('Custom range'),
            ),
          ],
          onChanged: (period) {
            if (period != null) onPeriodChanged(period);
          },
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          child: Text(
            dateLabel,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.muted),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _FilterDropdown<String>(
                label: 'Category',
                value: filter.categoryId,
                items: [
                  const DropdownMenuItem(value: null, child: Text('All')),
                  ...statistics.availableCategories.map(
                    (category) => DropdownMenuItem(
                      value: category.id,
                      child: Text('${category.emoji} ${category.name}'),
                    ),
                  ),
                ],
                onChanged: (id) {
                  final category = id == null
                      ? null
                      : statistics.availableCategories.firstWhere(
                          (item) => item.id == id,
                        );
                  context.read<StatisticsCubit>().selectCategory(category);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FilterDropdown<String>(
                label: 'Currency',
                value: filter.currency?.value,
                items: [
                  const DropdownMenuItem(value: null, child: Text('All')),
                  ...CurrencyCode.values.map(
                    (currency) => DropdownMenuItem(
                      value: currency.value,
                      child: Text(currency.value),
                    ),
                  ),
                ],
                onChanged: (value) {
                  final currency = value == null
                      ? null
                      : CurrencyCode.fromValue(value);
                  context.read<StatisticsCubit>().selectCurrency(currency);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _TotalCard(statistics: statistics),
        if (statistics.unconvertedExpenseCount > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${statistics.unconvertedExpenseCount} expense(s) without saved '
              'conversion are excluded from ALL totals.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.muted),
            ),
          ),
        const SizedBox(height: 20),
        _Section(
          title: 'Spending by category',
          emptyMessage: 'No converted spending for this selection.',
          isEmpty: statistics.categorySpending.isEmpty,
          children: statistics.categorySpending
              .map(
                (item) => _AmountRow(
                  leading: '${item.category.emoji} ${item.category.name}',
                  amount: item.amountInAll,
                  currency: 'ALL',
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 20),
        _Section(
          title: 'Monthly spending',
          emptyMessage: 'No monthly totals for this selection.',
          isEmpty: statistics.monthlySpending.isEmpty,
          children: statistics.monthlySpending
              .map(
                (item) => _AmountRow(
                  leading: DateFormat.yMMMM().format(item.month),
                  amount: item.amountInAll,
                  currency: 'ALL',
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 20),
        _Section(
          title: 'Original currency distribution',
          emptyMessage: 'No expenses for this selection.',
          isEmpty: statistics.currencyDistribution.isEmpty,
          children: statistics.currencyDistribution
              .map(
                (item) => _AmountRow(
                  leading: item.currency.value,
                  amount: item.originalAmount,
                  currency: item.currency.value,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _FilterDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items,
      onChanged: onChanged,
    );
  }
}

class _TotalCard extends StatelessWidget {
  final ExpenseStatistics statistics;

  const _TotalCard({required this.statistics});

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const ValueKey('statistics-total-card'),
      color: AppTheme.paperSecondary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total spending',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: AppTheme.muted),
            ),
            const SizedBox(height: 4),
            Text(
              key: const ValueKey('statistics-total-amount'),
              '${statistics.totalInAll.toStringAsFixed(2)} ALL',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontFamily: 'serif',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text('${statistics.expenseCount} expense(s)'),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String emptyMessage;
  final bool isEmpty;
  final List<Widget> children;

  const _Section({
    required this.title,
    required this.emptyMessage,
    required this.isEmpty,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(emptyMessage),
          )
        else
          ...children,
      ],
    );
  }
}

class _AmountRow extends StatelessWidget {
  final String leading;
  final double amount;
  final String currency;

  const _AmountRow({
    required this.leading,
    required this.amount,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(child: Text(leading)),
          Text('${amount.toStringAsFixed(2)} $currency'),
        ],
      ),
    );
  }
}
