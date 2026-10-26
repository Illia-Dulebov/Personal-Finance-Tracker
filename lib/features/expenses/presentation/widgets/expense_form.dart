import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_ui_tokens.dart';
import '../../../currency/domain/currency_catalog.dart';
import '../../../currency/domain/entities/currency_code.dart';
import '../../domain/entities/category.dart';
import '../cubit/conversion_preview_cubit.dart';
import '../cubit/conversion_preview_state.dart';

class ExpenseForm extends StatelessWidget {
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
  final VoidCallback? onDelete;

  const ExpenseForm({
    super.key,
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
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Column(
              children: [
                const Text('Amount', style: AppTextStyles.fieldLabel),
                TextFormField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.amount,
                  decoration: const InputDecoration(
                    hintText: '0.00',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    errorMaxLines: 2,
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
                if (!isEditing)
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: AppSpacing.sm,
                    children: CurrencyCatalog.supported
                        .map(
                          (currency) => _SelectChip<CurrencyCode>(
                            label: currency.code.value,
                            value: currency.code,
                            selected: selectedCurrency,
                            onSelected: onCurrencyChanged,
                          ),
                        )
                        .toList(),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Text(
                      'Currency ${existingCurrency?.value ?? 'ALL'} · locked after creation',
                      style: AppTextStyles.lockedValue,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          BlocBuilder<ConversionPreviewCubit, ConversionPreviewState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.lg),
                  child: Text('Calculating base-currency equivalent...'),
                );
              }
              if (state.error != null) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
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
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: Text(
                    'Approximate equivalent: ${state.preview}'
                    '${isEditing ? '' : ' (reference rate; not live)'}',
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const _FormSectionLabel('Category'),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: AppConstants.defaultCategories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final category = AppConstants.defaultCategories[index];
              final isSelected = selectedCategory.id == category.id;
              return Semantics(
                button: true,
                selected: isSelected,
                label: category.name,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadii.field),
                  onTap: () => onCategoryChanged(category),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFBF4E4)
                          : Colors.white,
                      border: Border.all(
                        color: isSelected ? AppTheme.gold : AppTheme.line,
                      ),
                      borderRadius: BorderRadius.circular(AppRadii.field),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      category.emoji,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          const _FormSectionLabel('Payment method'),
          Wrap(
            spacing: AppSpacing.sm,
            children: PaymentMethod.values
                .map(
                  (method) => _SelectChip<PaymentMethod>(
                    label: method.label,
                    value: method,
                    selected: selectedPaymentMethod,
                    onSelected: onPaymentMethodChanged,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          const _FormSectionLabel('Date'),
          _FieldButton(label: _dateLabel(selectedDate), onPressed: onPickDate),
          const SizedBox(height: AppSpacing.lg),
          _FormSectionLabel(
            isEditing ? 'Description' : 'Description (optional)',
          ),
          TextFormField(
            controller: descriptionController,
            decoration: InputDecoration(
              hintText: 'e.g. Weekly groceries',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.field),
                borderSide: const BorderSide(color: AppTheme.line),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.field),
                borderSide: const BorderSide(color: AppTheme.line),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 11,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const _FormSectionLabel('Receipt (optional)'),
          const _ReceiptPlaceholder(),
          const SizedBox(height: 22),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.ink,
              foregroundColor: AppTheme.paper,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.field),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              textStyle: AppTextStyles.action,
            ),
            onPressed: onSubmit,
            child: Text(isEditing ? 'Save changes' : 'Save expense'),
          ),
          if (onDelete != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: TextButton(
                onPressed: onDelete,
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.rust,
                  textStyle: AppTextStyles.deleteAction,
                ),
                child: const Text('Delete expense'),
              ),
            ),
        ],
      ),
    );
  }

  String _dateLabel(DateTime date) {
    final isToday = DateUtils.isSameDay(date, DateTime.now());
    final formattedDate = DateFormat('MMM d yyyy').format(date);
    return isToday ? 'Today, $formattedDate' : formattedDate;
  }
}

class _FormSectionLabel extends StatelessWidget {
  final String label;

  const _FormSectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(label, style: AppTextStyles.fieldLabel),
    );
  }
}

class _SelectChip<T> extends StatelessWidget {
  final String label;
  final T value;
  final T selected;
  final ValueChanged<T> onSelected;

  const _SelectChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      showCheckmark: false,
      visualDensity: VisualDensity.compact,
      labelPadding: const EdgeInsets.symmetric(horizontal: 1),
      side: BorderSide(color: isSelected ? AppTheme.ink : AppTheme.line),
      backgroundColor: Colors.white,
      selectedColor: AppTheme.ink,
      labelStyle: AppTextStyles.chip.copyWith(
        color: isSelected ? AppTheme.paper : AppTheme.ink,
      ),
      onSelected: (_) => onSelected(value),
    );
  }
}

class _FieldButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _FieldButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppRadii.field),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppTheme.line),
          borderRadius: BorderRadius.circular(AppRadii.field),
        ),
        child: Text(label, style: AppTextStyles.fieldValue),
      ),
    );
  }
}

class _ReceiptPlaceholder extends StatelessWidget {
  const _ReceiptPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.line),
        borderRadius: BorderRadius.circular(AppRadii.field),
      ),
      child: const Row(
        children: [
          Text('📎', style: TextStyle(fontSize: 16)),
          SizedBox(width: AppSpacing.sm),
          Text(
            'Attach photo or file',
            style: TextStyle(color: AppTheme.muted, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
