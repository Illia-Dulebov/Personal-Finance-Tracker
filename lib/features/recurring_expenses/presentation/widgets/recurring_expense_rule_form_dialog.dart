import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../currency/domain/entities/currency_code.dart';
import '../../../expenses/domain/entities/category.dart';
import '../../domain/entities/recurring_expense_rule.dart';
import '../../domain/entities/recurring_frequency.dart';
import '../../domain/utils/recurrence_schedule.dart';
import 'recurring_expense_details_fields.dart';
import 'recurring_expense_schedule_fields.dart';

class RecurringExpenseRuleFormDialog extends StatefulWidget {
  final RecurringExpenseRule? rule;

  const RecurringExpenseRuleFormDialog({super.key, this.rule});

  @override
  State<RecurringExpenseRuleFormDialog> createState() =>
      _RecurringExpenseRuleFormDialogState();
}

class _RecurringExpenseRuleFormDialogState
    extends State<RecurringExpenseRuleFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  late CurrencyCode _currency;
  late Category _category;
  late PaymentMethod _paymentMethod;
  late RecurringFrequency _frequency;
  late int _scheduleDay;

  @override
  void initState() {
    super.initState();
    final rule = widget.rule;
    _amountController = TextEditingController(
      text: rule?.amount.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: rule?.description ?? '',
    );
    _currency = rule?.currency ?? CurrencyCode.all;
    _category = rule?.category ?? AppConstants.defaultCategories.first;
    _paymentMethod = rule?.paymentMethod ?? PaymentMethod.cash;
    _frequency = rule?.frequency ?? RecurringFrequency.monthly;
    _scheduleDay =
        rule?.scheduleDay ??
        (rule?.frequency == RecurringFrequency.weekly
            ? DateTime.monday
            : DateTime.now().day);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now();
    final effectiveDate = widget.rule == null
        ? DateTime(now.year, now.month, now.day)
        : DateTime(now.year, now.month, now.day + 1);
    final nextDate = RecurrenceSchedule.firstOccurrenceOnOrAfter(
      _frequency,
      _frequency == RecurringFrequency.daily ? null : _scheduleDay,
      effectiveDate,
    );
    Navigator.of(context).pop(
      RecurringExpenseRule(
        id: widget.rule?.id ?? const Uuid().v4(),
        amount: double.parse(_amountController.text.trim()),
        currency: _currency,
        category: _category,
        paymentMethod: _paymentMethod,
        description: _descriptionController.text.trim(),
        frequency: _frequency,
        scheduleDay: _frequency == RecurringFrequency.daily
            ? null
            : _scheduleDay,
        lastGeneratedDate: widget.rule?.lastGeneratedDate,
        nextGenerationDate: nextDate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.rule == null
            ? 'Add recurring expense'
            : 'Edit recurring expense',
      ),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RecurringExpenseDetailsFields(
                  amountController: _amountController,
                  descriptionController: _descriptionController,
                  currency: _currency,
                  category: _category,
                  paymentMethod: _paymentMethod,
                  onCurrencyChanged: (value) =>
                      setState(() => _currency = value),
                  onCategoryChanged: (value) =>
                      setState(() => _category = value),
                  onPaymentMethodChanged: (value) =>
                      setState(() => _paymentMethod = value),
                ),
                RecurringExpenseScheduleFields(
                  frequency: _frequency,
                  scheduleDay: _scheduleDay,
                  onFrequencyChanged: _changeFrequency,
                  onScheduleDayChanged: (value) =>
                      setState(() => _scheduleDay = value),
                ),
                if (widget.rule != null)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                      'The updated schedule starts after today. Past expenses remain unchanged.',
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(widget.rule == null ? 'Create rule' : 'Save changes'),
        ),
      ],
    );
  }

  void _changeFrequency(RecurringFrequency frequency) {
    setState(() {
      _frequency = frequency;
      if (frequency == RecurringFrequency.weekly) {
        _scheduleDay = DateTime.now().weekday;
      } else if (frequency == RecurringFrequency.monthly) {
        _scheduleDay = DateTime.now().day;
      }
    });
  }
}
