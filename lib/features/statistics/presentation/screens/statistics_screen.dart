import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_ui_tokens.dart';
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
    final maxAmount = statistics.categorySpending.fold<double>(
      0,
      (maximum, item) => math.max(maximum, item.amountInAll),
    );
    final categoryName = filter.categoryId == null
        ? 'All categories'
        : statistics.availableCategories
              .firstWhere((item) => item.id == filter.categoryId)
              .name;
    final periodLabel = switch (filter.period) {
      StatisticsPeriod.today => 'Today',
      StatisticsPeriod.thisWeek => 'This week',
      StatisticsPeriod.thisMonth => 'This month',
      StatisticsPeriod.month => 'Choose month',
      StatisticsPeriod.custom => 'Custom range',
    };
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md + 2,
        AppSpacing.xl,
        AppSpacing.xxl + 8,
      ),
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            _FilterChipMenu<StatisticsPeriod>(
              label: periodLabel,
              selected: filter.period == StatisticsPeriod.thisMonth,
              items: const [
                PopupMenuItem(
                  value: StatisticsPeriod.today,
                  child: Text('Today'),
                ),
                PopupMenuItem(
                  value: StatisticsPeriod.thisWeek,
                  child: Text('This week'),
                ),
                PopupMenuItem(
                  value: StatisticsPeriod.thisMonth,
                  child: Text('This month'),
                ),
                PopupMenuItem(
                  value: StatisticsPeriod.month,
                  child: Text('Choose month'),
                ),
                PopupMenuItem(
                  value: StatisticsPeriod.custom,
                  child: Text('Custom range'),
                ),
              ],
              onSelected: onPeriodChanged,
            ),
            _FilterChipMenu<_FilterOption<String>>(
              label: categoryName,
              items: [
                const PopupMenuItem<_FilterOption<String>>(
                  value: _FilterOption(null),
                  child: Text('All categories'),
                ),
                ...statistics.availableCategories.map(
                  (category) => PopupMenuItem<_FilterOption<String>>(
                    value: _FilterOption(category.id),
                    child: Text('${category.emoji} ${category.name}'),
                  ),
                ),
              ],
              onSelected: (option) {
                final id = option.value;
                final category = id == null
                    ? null
                    : statistics.availableCategories.firstWhere(
                        (item) => item.id == id,
                      );
                context.read<StatisticsCubit>().selectCategory(category);
              },
            ),
            _FilterChipMenu<_FilterOption<String>>(
              label: filter.currency?.value ?? 'All currencies',
              items: [
                const PopupMenuItem<_FilterOption<String>>(
                  value: _FilterOption(null),
                  child: Text('All currencies'),
                ),
                ...CurrencyCode.values.map(
                  (currency) => PopupMenuItem<_FilterOption<String>>(
                    value: _FilterOption(currency.value),
                    child: Text(currency.value),
                  ),
                ),
              ],
              onSelected: (option) {
                final value = option.value;
                final currency = value == null
                    ? null
                    : CurrencyCode.fromValue(value);
                context.read<StatisticsCubit>().selectCurrency(currency);
              },
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.sm,
            bottom: AppSpacing.md,
          ),
          child: Text(dateLabel, style: AppTextStyles.caption),
        ),
        if (statistics.categorySpending.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text('No converted spending for this selection.'),
          )
        else
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
            child: Column(
              children: [
                for (final item in statistics.categorySpending)
                  _StatisticsBarRow(
                    label: item.category.name,
                    amount: item.amountInAll,
                    widthFactor: maxAmount == 0
                        ? 0
                        : (item.amountInAll / maxAmount)
                              .clamp(0.0, 1.0)
                              .toDouble(),
                  ),
              ],
            ),
          ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.ink),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: const Text(
            'Make report',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 20),
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

class _FilterChipMenu<T> extends StatelessWidget {
  final String label;
  final bool selected;
  final List<PopupMenuEntry<T>> items;
  final ValueChanged<T> onSelected;

  const _FilterChipMenu({
    required this.label,
    this.selected = false,
    required this.items,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      itemBuilder: (_) => items,
      onSelected: onSelected,
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: selected ? AppTheme.ink : Colors.white,
          border: Border.all(color: selected ? AppTheme.ink : AppTheme.line),
          borderRadius: BorderRadius.circular(AppRadii.chip),
        ),
        child: Text(
          label,
          style: AppTextStyles.chip.copyWith(
            color: selected ? AppTheme.paper : AppTheme.ink,
          ),
        ),
      ),
    );
  }
}

class _FilterOption<T> {
  final T? value;

  const _FilterOption(this.value);
}

class _StatisticsBarRow extends StatelessWidget {
  final String label;
  final double amount;
  final double widthFactor;

  const _StatisticsBarRow({
    required this.label,
    required this.amount,
    required this.widthFactor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md + 2),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.chip.copyWith(color: AppTheme.muted),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: SizedBox(
                height: 16,
                child: Stack(
                  children: [
                    const ColoredBox(color: AppTheme.paperSecondary),
                    FractionallySizedBox(
                      widthFactor: widthFactor,
                      child: const ColoredBox(color: AppTheme.gold),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 64,
            child: Text(
              '${amount.toStringAsFixed(0)} ALL',
              textAlign: TextAlign.right,
              style: AppTextStyles.amountSmall.copyWith(fontSize: 13),
            ),
          ),
        ],
      ),
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
