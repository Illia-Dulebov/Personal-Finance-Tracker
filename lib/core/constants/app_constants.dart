import '../../features/expenses/domain/entities/category.dart';

enum PaymentMethod {
  cash('Cash'),
  card('Card');

  final String label;
  const PaymentMethod(this.label);

  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere(
      (e) =>
          e.label.toLowerCase() == value.toLowerCase() ||
          e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => PaymentMethod.cash,
    );
  }
}

class AppConstants {
  static const List<Category> defaultCategories = [
    Category(id: 'food', name: 'Food', emoji: '🍔'),
    Category(id: 'housing', name: 'Housing', emoji: '🏠'),
    Category(id: 'transport', name: 'Transport', emoji: '🚗'),
    Category(id: 'health', name: 'Health', emoji: '🏥'),
    Category(id: 'entertainment', name: 'Entertainment', emoji: '🎬'),
    Category(id: 'shopping', name: 'Shopping', emoji: '🛍️'),
    Category(id: 'bills', name: 'Bills', emoji: '💡'),
  ];
}
