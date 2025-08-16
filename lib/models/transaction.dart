import 'package:hive/hive.dart';
import 'package:smart_expense/models/account.dart';
import 'package:smart_expense/models/category.dart';

part 'transaction.g.dart';

@HiveType(typeId: 6)
class TransactionModel {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String description;

  @HiveField(2)
  late String? notes;

  @HiveField(3)
  late double amount;

  @HiveField(4)
  late String formattedAmountText;

  @HiveField(5)
  late String type;

  @HiveField(6)
  late String formattedType;

  @HiveField(7)
  late DateTime transactionDate;

  @HiveField(8)
  late String? referenceNumber;

  @HiveField(9)
  int? active;

  @HiveField(10)
  late AccountModel account;

  @HiveField(11)
  late CategoryModel category;

  static String transactionBox = "transactions";

  static fromMap(Map<String, dynamic> transactions) {
    var transactionModel = TransactionModel();

    transactionModel.id = transactions['id'];
    transactionModel.description = transactions['description'];
    transactionModel.notes = transactions['notes'];
    transactionModel.amount = double.parse(transactions['amount'].toString());
    transactionModel.type = transactions['type'].toString();
    transactionModel.formattedType = transactions['formatted_type'];
    transactionModel.formattedAmountText =
        transactions['formatted_amount_text'];
    transactionModel.transactionDate = DateTime.parse(
      transactions['transaction_date'],
    );
    transactionModel.category = CategoryModel.fromMap(transactions['category']);
    transactionModel.account = AccountModel.fromMap(transactions['account']);

    transactionModel.referenceNumber = transactions['reference_number'];
    transactionModel.active = int.parse(transactions['active'].toString());

    return transactionModel;
  }

  bool isEqual(TransactionModel model) {
    return id == model.id;
  }

  @override
  String toString() => description;
}
