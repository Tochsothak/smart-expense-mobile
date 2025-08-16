import 'package:hive/hive.dart';
import 'package:smart_expense/models/transaction.dart';

class TransactionService {
  static Future<TransactionModel> create(
    Map<String, dynamic> transaction,
  ) async {
    final transactionBox = await Hive.openBox(TransactionModel.transactionBox);

    var transactionModel = TransactionModel.fromMap(transaction);

    await transactionBox.put(transactionModel.id, transactionModel);

    return transactionModel as TransactionModel;
  }

  static Future<TransactionModel?> getById(String id) async {
    final transactionBox = await Hive.openBox(TransactionModel.transactionBox);

    final transactionModel = await transactionBox.get(id);
    return transactionModel as TransactionModel;
  }

  static Future<bool> deleteById(String id) async {
    final transactionBox = await Hive.openBox(TransactionModel.transactionBox);
    if (transactionBox.containsKey(id)) {
      await transactionBox.delete(id);
      return true;
    }
    return false;
  }

  static Future<List<TransactionModel>> createTransactions(
    List transactions,
  ) async {
    final transactionBox = await Hive.openBox(TransactionModel.transactionBox);
    await transactionBox.clear();

    List<TransactionModel> transactionModels = [];

    for (var transaction in transactions) {
      var transactionModel = TransactionModel.fromMap(transaction);

      await transactionBox.put(transactionModel.id, transactionModel);
      transactionModels.add(transactionModel);
    }

    return transactionModels;
  }

  static Future<TransactionModel?> get() async {
    final transactionBox = await Hive.openBox(TransactionModel.transactionBox);
    if (transactionBox.isEmpty) return null;
    final transactionModel = await transactionBox.values.first;
    return transactionModel as TransactionModel;
  }

  static Future<List<TransactionModel>?> getAll() async {
    final transactionBox = await Hive.openBox(TransactionModel.transactionBox);
    if (transactionBox.isEmpty) return null;
    List<TransactionModel> transactionModels =
        transactionBox.values.cast<TransactionModel>().toList();
    return transactionModels;
  }

  static Future delete() async {
    final transactionBox = await Hive.openBox(TransactionModel.transactionBox);
    await transactionBox.clear();
  }
}
