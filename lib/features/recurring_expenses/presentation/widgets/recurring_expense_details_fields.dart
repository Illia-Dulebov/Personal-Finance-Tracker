import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../currency/domain/currency_catalog.dart';
import '../../../currency/domain/entities/currency_code.dart';
import '../../../expenses/domain/entities/category.dart';

class RecurringExpenseDetailsFields extends StatelessWidget {
  final TextEditingController amountController;
  final TextEditingController descriptionController;
  final CurrencyCode currency;
  final Category category;
  final PaymentMethod paymentMethod;
  final ValueChanged<CurrencyCode> onCurrencyChanged;
  final ValueChanged<Category> onCategoryChanged;
  final ValueChanged<PaymentMethod> onPaymentMethodChanged;

  const RecurringExpenseDetailsFields({
    super.key,
    required this.amountController,
    required this.descriptionController,
    required this.currency,
    required this.category,
    required this.paymentMethod,
    required this.onCurrencyChanged,
    required this.onCategoryChanged,
    required this.onPaymentMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Amount'),
          validator: (value) {
            final amount = double.tryParse(value?.trim() ?? '');
            if (amount == null || !amount.isFinite || amount <= 0) {
              return 'Enter a positive amount';
            }
            return null;
          },
        ),
        DropdownButtonFormField<CurrencyCode>(
          initialValue: currency,
          decoration: const InputDecoration(labelText: 'Currency'),
          items: CurrencyCatalog.supported
              .map(
                (item) => DropdownMenuItem(
                  value: item.code,
                  child: Text('${item.code.value} - ${item.name}'),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) onCurrencyChanged(value);
          },
        ),
        DropdownButtonFormField<Category>(
          initialValue: category,
          decoration: const InputDecoration(labelText: 'Category'),
          items: AppConstants.defaultCategories
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text('${item.emoji} ${item.name}'),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) onCategoryChanged(value);
          },
        ),
        DropdownButtonFormField<PaymentMethod>(
          initialValue: paymentMethod,
          decoration: const InputDecoration(labelText: 'Payment method'),
          items: PaymentMethod.values
              .map(
                (item) =>
                    DropdownMenuItem(value: item, child: Text(item.label)),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) onPaymentMethodChanged(value);
          },
        ),
        TextFormField(
          controller: descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description (optional)',
          ),
        ),
      ],
    );
  }
}
