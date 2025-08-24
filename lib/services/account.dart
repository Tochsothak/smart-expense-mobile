import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_expense/models/account.dart';

class AccountService {
  static Future<AccountModel> create(Map<String, dynamic> account) async {
    final accountBox = await Hive.openBox(AccountModel.accountBox);

    var accountModel = AccountModel.fromMap(account);

    await accountBox.put(accountModel.id, accountModel);

    return accountModel;
  }

  static Future<AccountModel?> getById(String id) async {
    final accountBox = await Hive.openBox(AccountModel.accountBox);

    final accountModel = await accountBox.get(id);
    return accountModel as AccountModel;
  }

  static Future<bool> deleteById(String id) async {
    final accountBox = await Hive.openBox(AccountModel.accountBox);
    if (accountBox.containsKey(id)) {
      await accountBox.delete(id);
      return true;
    }
    return false;
  }

  static Future<List<AccountModel>> createAccounts(List accounts) async {
    final accountBox = await Hive.openBox(AccountModel.accountBox);
    await accountBox.clear();

    List<AccountModel> accountModels = [];

    for (var account in accounts) {
      var accountModel = AccountModel.fromMap(account);

      await accountBox.put(accountModel.id, accountModel);
      accountModels.add(accountModel);
    }

    return accountModels;
  }

  static Future<AccountModel?> get() async {
    final accountBox = await Hive.openBox(AccountModel.accountBox);
    if (accountBox.isEmpty) return null;
    final accountModel = await accountBox.values.first;
    return accountModel as AccountModel;
  }

  static Future<List<AccountModel>?> getAll() async {
    final accountListBox = await Hive.openBox(AccountModel.accountBox);
    if (accountListBox.isEmpty) return null;
    List<AccountModel> accountModels =
        accountListBox.values.cast<AccountModel>().toList();
    return accountModels;
  }

  static Future delete() async {
    final accountBox = await Hive.openBox(AccountModel.accountBox);
    await accountBox.clear();
  }
}
