import 'package:smart_expense/models/transaction.dart';

class CategoryStats {
  final String categoryName;
  final double originalAmount;
  final double convertedAmount;
  final int transactionCount;
  final String categoryIcon;
  final String categoryColor;
  final List<TransactionModel> transactions;

  CategoryStats({
    required this.categoryName,
    required this.originalAmount,
    required this.convertedAmount,
    required this.transactionCount,
    required this.categoryIcon,
    required this.categoryColor,
    required this.transactions,
  });
}
