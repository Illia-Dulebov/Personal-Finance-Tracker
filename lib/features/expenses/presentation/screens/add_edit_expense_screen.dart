import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_ui_tokens.dart';
import '../../../currency/domain/entities/currency_code.dart';
import '../../../currency/domain/repositories/currency_repository.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/expense.dart';
import '../cubit/conversion_preview_cubit.dart';
import '../models/expense_edit_result.dart';
import '../widgets/delete_expense_confirmation_dialog.dart';
import '../widgets/expense_form.dart';

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
            (category) => category.id == expense.category.id,
            orElse: () => expense.category,
          )
        : AppConstants.defaultCategories.first;

    _selectedPaymentMethod = expense?.paymentMethod ?? PaymentMethod.card;
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

  Future<void> _deleteExpense() async {
    final shouldDelete = await showAdaptiveDialog<bool>(
      context: context,
      builder: (_) => const DeleteExpenseConfirmationDialog(),
    );
    if (shouldDelete == true && mounted) {
      Navigator.of(context).pop(ExpenseDeleted(widget.expense!.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _conversionPreviewCubit,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 48,
          title: Text(_isEditing ? 'Edit expense' : 'Add expense'),
          titleTextStyle: AppTextStyles.caption.copyWith(fontSize: 13),
        ),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.sm,
              AppSpacing.xl,
              AppSpacing.xxl,
            ),
            child: ExpenseForm(
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
              onCategoryChanged: (category) =>
                  setState(() => _selectedCategory = category),
              onPaymentMethodChanged: (method) =>
                  setState(() => _selectedPaymentMethod = method),
              onPickDate: _pickDate,
              onSubmit: _submit,
              onDelete: _isEditing ? _deleteExpense : null,
            ),
          ),
        ),
      ),
    );
  }
}
