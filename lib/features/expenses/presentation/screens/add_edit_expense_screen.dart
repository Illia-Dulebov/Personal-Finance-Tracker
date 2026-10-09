import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../currency/domain/currency_catalog.dart';
import '../../../currency/domain/entities/currency_code.dart';
import '../../../currency/domain/repositories/currency_repository.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/expense.dart';
import '../cubit/conversion_preview_cubit.dart';
import '../cubit/conversion_preview_state.dart';

class AddEditExpenseScreen extends StatefulWidget {
  final Expense? expense;
  final CurrencyRepository currencyRepository;

  const AddEditExpenseScreen({
    super.key,
    this.expense,
    required this.currencyRepository,
  });

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _amountController;
  late TextEditingController _descriptionController;

  late Category _selectedCategory;
  late PaymentMethod _selectedPaymentMethod;
  late DateTime _selectedDate;
  late CurrencyCode _selectedCurrency;
  late ConversionPreviewCubit _conversionPreviewCubit;

  bool get _isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    final expense = widget.expense;

    _amountController = TextEditingController(
      text: expense != null ? expense.amount.toString() : '',
    );
    _descriptionController = TextEditingController(
      text: expense != null ? expense.description : '',
    );
    _selectedCurrency = expense?.currency ?? CurrencyCode.all;

    _selectedCategory = expense != null
        ? AppConstants.defaultCategories.firstWhere(
            (c) => c.id == expense.category.id,
            orElse: () => expense.category,
          )
        : AppConstants.defaultCategories.first;

    _selectedPaymentMethod = expense != null
        ? expense.paymentMethod
        : PaymentMethod.cash;

    _selectedDate = expense != null ? expense.date : DateTime.now();
    _conversionPreviewCubit = ConversionPreviewCubit(
      currencyRepository: widget.currencyRepository,
    );
    _amountController.addListener(_refreshConversionPreview);
    _refreshConversionPreview();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _conversionPreviewCubit.close();
    super.dispose();
  }

  void _refreshConversionPreview() {
    final amount = double.tryParse(_amountController.text.trim());
    final expense = widget.expense;
    final historicalRate =
        expense?.exchangeRateToBaseCurrency ??
        (expense?.currency == CurrencyCode.all ? 1.0 : null);
    _conversionPreviewCubit.refresh(
      amount: amount,
      currency: _selectedCurrency,
      isEditing: expense != null,
      historicalRate: historicalRate,
    );
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          _selectedDate.hour,
          _selectedDate.minute,
        );
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text.trim());
    final description = _descriptionController.text.trim();

    final resultExpense = Expense(
      id: _isEditing ? widget.expense!.id : const Uuid().v4(),
      amount: amount,
      currency: _isEditing ? widget.expense!.currency : _selectedCurrency,
      date: _selectedDate,
      category: _selectedCategory,
      paymentMethod: _selectedPaymentMethod,
      description: description,
      amountInBaseCurrency: widget.expense?.amountInBaseCurrency,
      exchangeRateToBaseCurrency: widget.expense?.exchangeRateToBaseCurrency,
      conversionBaseCurrency: widget.expense?.conversionBaseCurrency,
      conversionRateCapturedAt: widget.expense?.conversionRateCapturedAt,
    );

    Navigator.of(context).pop(resultExpense);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _conversionPreviewCubit,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Edit Expense' : 'Add Expense'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: _ExpenseForm(
            formKey: _formKey,
            amountController: _amountController,
            descriptionController: _descriptionController,
            isEditing: _isEditing,
            existingCurrency: widget.expense?.currency,
            selectedCurrency: _selectedCurrency,
            selectedCategory: _selectedCategory,
            selectedPaymentMethod: _selectedPaymentMethod,
            selectedDate: _selectedDate,
            onCurrencyChanged: (currency) {
              setState(() => _selectedCurrency = currency);
              _refreshConversionPreview();
            },
            onCategoryChanged: (cat) => setState(() => _selectedCategory = cat),
            onPaymentMethodChanged: (pm) =>
                setState(() => _selectedPaymentMethod = pm),
            onPickDate: _pickDate,
            onSubmit: _submit,
          ),
        ),
      ),
    );
  }
}

class _ExpenseForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController amountController;
  final TextEditingController descriptionController;
  final bool isEditing;
  final CurrencyCode? existingCurrency;
  final CurrencyCode selectedCurrency;
  final Category selectedCategory;
  final PaymentMethod selectedPaymentMethod;
  final DateTime selectedDate;
  final ValueChanged<Category> onCategoryChanged;
  final ValueChanged<CurrencyCode> onCurrencyChanged;
  final ValueChanged<PaymentMethod> onPaymentMethodChanged;
  final VoidCallback onPickDate;
  final VoidCallback onSubmit;

  const _ExpenseForm({
    required this.formKey,
    required this.amountController,
    required this.descriptionController,
    required this.isEditing,
    this.existingCurrency,
    required this.selectedCurrency,
    required this.selectedCategory,
    required this.selectedPaymentMethod,
    required this.selectedDate,
    required this.onCategoryChanged,
    required this.onCurrencyChanged,
    required this.onPaymentMethodChanged,
    required this.onPickDate,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter an amount';
              }
              final parsed = double.tryParse(value.trim());
              if (parsed == null || !parsed.isFinite || parsed <= 0) {
                return 'Amount must be a positive number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          if (!isEditing) ...[
            DropdownButtonFormField<CurrencyCode>(
              initialValue: selectedCurrency,
              decoration: const InputDecoration(
                labelText: 'Currency',
                border: OutlineInputBorder(),
              ),
              items: CurrencyCatalog.supported
                  .map(
                    (currency) => DropdownMenuItem(
                      value: currency.code,
                      child: Text('${currency.code.value} - ${currency.name}'),
                    ),
                  )
                  .toList(),
              onChanged: (currency) {
                if (currency != null) onCurrencyChanged(currency);
              },
            ),
            const SizedBox(height: 16),
          ] else ...[
            _ImmutableCurrencyBadge(
              currency: existingCurrency ?? CurrencyCode.all,
            ),
            const SizedBox(height: 16),
          ],
          BlocBuilder<ConversionPreviewCubit, ConversionPreviewState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text('Calculating base-currency equivalent...'),
                );
              }
              if (state.error != null) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    state.error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                );
              }
              if (state.preview != null) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Approximate equivalent: ${state.preview}'
                    '${isEditing ? '' : ' (reference rate; not live)'}',
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          DropdownButtonFormField<Category>(
            initialValue: selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            items: AppConstants.defaultCategories
                .map(
                  (cat) => DropdownMenuItem(
                    value: cat,
                    child: Text('${cat.emoji} ${cat.name}'),
                  ),
                )
                .toList(),
            onChanged: (cat) {
              if (cat != null) onCategoryChanged(cat);
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<PaymentMethod>(
            initialValue: selectedPaymentMethod,
            decoration: const InputDecoration(
              labelText: 'Payment Method',
              border: OutlineInputBorder(),
            ),
            items: PaymentMethod.values
                .map((pm) => DropdownMenuItem(value: pm, child: Text(pm.label)))
                .toList(),
            onChanged: (pm) {
              if (pm != null) onPaymentMethodChanged(pm);
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description (Optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          _DateSelectorButton(
            selectedDate: selectedDate,
            onPressed: onPickDate,
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: onSubmit,
            child: Text(isEditing ? 'Update Expense' : 'Save Expense'),
          ),
        ],
      ),
    );
  }
}

class _DateSelectorButton extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onPressed;

  const _DateSelectorButton({
    required this.selectedDate,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.calendar_today),
      label: Text('Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}'),
    );
  }
}

class _ImmutableCurrencyBadge extends StatelessWidget {
  final CurrencyCode currency;

  const _ImmutableCurrencyBadge({required this.currency});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text('Currency: ${currency.value} (Immutable)'),
    );
  }
}
