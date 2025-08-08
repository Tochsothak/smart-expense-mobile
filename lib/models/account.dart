import 'package:hive/hive.dart';
import 'package:smart_expense/models/account_type.dart';
import 'package:smart_expense/models/currency.dart';

part 'account.g.dart';

@HiveType(typeId: 4)
class AccountModel {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late double initialBalance;

  @HiveField(3)
  late String initialBalanceText;

  @HiveField(4)
  late double currentBalance;

  @HiveField(5)
  late String currentBalanceText;

  @HiveField(6)
  double? totalIncome;

  @HiveField(7)
  String? totalIncomeText;

  @HiveField(8)
  double? totalExpense;

  @HiveField(9)
  String? totalExpenseText;

  @HiveField(10)
  int? transactionCount;

  @HiveField(11)
  int? incomeCount;

  @HiveField(12)
  int? expenseCount;

  @HiveField(13)
  String? colourCode;

  @HiveField(14)
  int? active;

  @HiveField(15)
  late CurrencyModel currency;

  @HiveField(16)
  late AccountTypeModel accountType;

  static String accountBox = 'accounts';

  static fromMap(Map<String, dynamic> account) {
    var accountModel = AccountModel();
    accountModel.id = account['id'];
    accountModel.name = account['name'];
    accountModel.initialBalance = double.parse(
      account['initial_balance'].toString(),
    );
    accountModel.initialBalanceText = account['initial_balance_text'];
    accountModel.currentBalance = double.parse(
      account['current_balance'].toString(),
    );
    accountModel.currentBalanceText = account['current_balance_text'];
    accountModel.colourCode = account['colour_code'];
    accountModel.active = int.parse(account['active'].toString());
    accountModel.currency = CurrencyModel.fromMap(account['currency']);
    accountModel.accountType = AccountTypeModel.fromMap(
      account['account_type'],
    );
    accountModel.totalIncome = double.parse(account['total_income'].toString());
    accountModel.totalIncomeText = account['total_income_text'];
    accountModel.totalExpense = double.parse(
      account['total_expense'].toString(),
    );
    accountModel.totalExpenseText = account['total_expense_text'];
    accountModel.transactionCount = account['transaction_count'];
    accountModel.incomeCount = account['income_count'];
    accountModel.expenseCount = account['expense_count'];

    return accountModel;
  }

  bool isEqual(AccountModel model) {
    return id == model.id;
  }

  @override
  String toString() => name;
}
