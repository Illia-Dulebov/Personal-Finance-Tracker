import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../currency/domain/currency_catalog.dart';
import '../../../currency/domain/entities/currency_code.dart';
import '../../../currency/domain/repositories/currency_repository.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/expense.dart';

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
  String? _conversionPreview;
  String? _conversionError;
  bool _isLoadingConversion = false;
  int _conversionRequest = 0;

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
    _amountController.addListener(_refreshConversionPreview);

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
    _refreshConversionPreview(notify: false);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _refreshConversionPreview({bool notify = true}) async {
    final request = ++_conversionRequest;
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || !amount.isFinite || amount <= 0) {
      if (notify) {
        setState(() {
          _conversionPreview = null;
          _conversionError = null;
          _isLoadingConversion = false;
        });
      } else {
        _conversionPreview = null;
        _conversionError = null;
        _isLoadingConversion = false;
      }
      return;
    }

    final expense = widget.expense;
    final historicalRate =
        expense?.exchangeRateToBaseCurrency ??
        (expense?.currency == CurrencyCode.all ? 1.0 : null);
    if (expense != null && historicalRate == null) {
      if (notify) {
        setState(() {
          _conversionPreview = null;
          _conversionError =
              'No historical conversion is available for this expense.';
          _isLoadingConversion = false;
        });
      } else {
        _conversionPreview = null;
        _conversionError =
            'No historical conversion is available for this expense.';
        _isLoadingConversion = false;
      }
      return;
    }

    if (notify) {
      setState(() {
        _conversionPreview = null;
        _conversionError = null;
        _isLoadingConversion = true;
      });
    } else {
      _isLoadingConversion = true;
    }

    try {
      final rate =
          historicalRate ??
          (await widget.currencyRepository.getRateToBaseCurrency(
            _selectedCurrency,
          )).rate;
      final convertedAmount = amount * rate;
      if (!rate.isFinite || rate <= 0 || !convertedAmount.isFinite) {
        throw StateError(
          'The exchange rate produced an invalid converted amount.',
        );
      }
      if (!mounted || request != _conversionRequest) return;
      setState(() {
        _conversionPreview =
            '${convertedAmount.toStringAsFixed(2)} ${CurrencyCode.all.value}';
        _conversionError = null;
        _isLoadingConversion = false;
      });
    } on Exception catch (error) {
      _showConversionError(request, error);
    } on ArgumentError catch (error) {
      _showConversionError(request, error);
    } on StateError catch (error) {
      _showConversionError(request, error);
    }
  }

  void _showConversionError(int request, Object error) {
    if (!mounted || request != _conversionRequest) return;
    setState(() {
      _conversionPreview = null;
      _conversionError = 'Unable to calculate conversion: $error';
      _isLoadingConversion = false;
    });
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Wireframe: Edit Expense' : 'Wireframe: Add Expense',
        ),
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
          conversionPreview: _conversionPreview,
          conversionError: _conversionError,
          isLoadingConversion: _isLoadingConversion,
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
  final String? conversionPreview;
  final String? conversionError;
  final bool isLoadingConversion;
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
    this.conversionPreview,
    this.conversionError,
    required this.isLoadingConversion,
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
          if (isLoadingConversion)
            const Text('Calculating base-currency equivalent...')
          else if (conversionError != null)
            Text(
              conversionError!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            )
          else if (conversionPreview != null)
            Text(
              'Approximate equivalent: $conversionPreview'
              '${isEditing ? '' : ' (reference rate; not live)'}',
            ),
          if (conversionPreview != null || conversionError != null) ...[
            const SizedBox(height: 16),
          ],
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
