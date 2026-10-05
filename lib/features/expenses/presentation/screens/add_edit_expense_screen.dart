import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/expense.dart';

class AddEditExpenseScreen extends StatefulWidget {
  final Expense? expense;

  const AddEditExpenseScreen({super.key, this.expense});

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late TextEditingController _currencyController;

  late Category _selectedCategory;
  late PaymentMethod _selectedPaymentMethod;
  late DateTime _selectedDate;

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
    _currencyController = TextEditingController(
      text: expense != null ? expense.currency : AppConstants.defaultCurrency,
    );

    _selectedCategory = expense != null
        ? AppConstants.defaultCategories.firstWhere(
            (c) => c.id == expense.category.id,
            orElse: () => expense.category,
          )
        : AppConstants.defaultCategories.first;

    _selectedPaymentMethod = expense != null ? expense.paymentMethod : PaymentMethod.cash;

    _selectedDate = expense != null ? expense.date : DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _currencyController.dispose();
    super.dispose();
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
    final currency = _isEditing
        ? widget.expense!.currency
        : _currencyController.text.trim();

    final resultExpense = Expense(
      id: _isEditing ? widget.expense!.id : const Uuid().v4(),
      amount: amount,
      currency: currency,
      date: _selectedDate,
      category: _selectedCategory,
      paymentMethod: _selectedPaymentMethod,
      description: description,
    );

    Navigator.of(context).pop(resultExpense);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Wireframe: Edit Expense' : 'Wireframe: Add Expense'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _ExpenseForm(
          formKey: _formKey,
          amountController: _amountController,
          descriptionController: _descriptionController,
          currencyController: _currencyController,
          isEditing: _isEditing,
          existingCurrency: widget.expense?.currency,
          selectedCategory: _selectedCategory,
          selectedPaymentMethod: _selectedPaymentMethod,
          selectedDate: _selectedDate,
          onCategoryChanged: (cat) => setState(() => _selectedCategory = cat),
          onPaymentMethodChanged: (pm) => setState(() => _selectedPaymentMethod = pm),
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
  final TextEditingController currencyController;
  final bool isEditing;
  final String? existingCurrency;
  final Category selectedCategory;
  final PaymentMethod selectedPaymentMethod;
  final DateTime selectedDate;
  final ValueChanged<Category> onCategoryChanged;
  final ValueChanged<PaymentMethod> onPaymentMethodChanged;
  final VoidCallback onPickDate;
  final VoidCallback onSubmit;

  const _ExpenseForm({
    required this.formKey,
    required this.amountController,
    required this.descriptionController,
    required this.currencyController,
    required this.isEditing,
    this.existingCurrency,
    required this.selectedCategory,
    required this.selectedPaymentMethod,
    required this.selectedDate,
    required this.onCategoryChanged,
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
              if (parsed == null || parsed <= 0) {
                return 'Amount must be a positive number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          if (!isEditing) ...[
            TextFormField(
              controller: currencyController,
              decoration: const InputDecoration(
                labelText: 'Currency',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter currency code';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
          ] else ...[
            _ImmutableCurrencyBadge(currency: existingCurrency ?? AppConstants.defaultCurrency),
            const SizedBox(height: 16),
          ],
          DropdownButtonFormField<Category>(
            initialValue: selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            items: AppConstants.defaultCategories
                .map((cat) => DropdownMenuItem(
                      value: cat,
                      child: Text('${cat.emoji} ${cat.name}'),
                    ))
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
                .map((pm) => DropdownMenuItem(
                      value: pm,
                      child: Text(pm.label),
                    ))
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
      label: Text(
        'Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
      ),
    );
  }
}

class _ImmutableCurrencyBadge extends StatelessWidget {
  final String currency;

  const _ImmutableCurrencyBadge({required this.currency});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text('Currency: $currency (Immutable)'),
    );
  }
}
