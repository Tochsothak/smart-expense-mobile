import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_expense/models/account_type.dart';

class AccountTypeService {
  static Future<AccountTypeModel> create(
    Map<String, dynamic> accountTypes,
  ) async {
    final accountTypeBox = await Hive.openBox(AccountTypeModel.accountTypeBox);

    var accountTypeModel = AccountTypeModel.fromMap(accountTypes);
    await accountTypeBox.put(accountTypeModel.id, accountTypeModel);
    return accountTypeModel;
  }

  static Future<List<AccountTypeModel>?> getAll() async {
    final accountTypeBoxList = await Hive.openBox(
      AccountTypeModel.accountTypeBox,
    );
    if (accountTypeBoxList.isEmpty) return null;
    List<AccountTypeModel> accountTypeList =
        accountTypeBoxList.values.cast<AccountTypeModel>().toList();
    return accountTypeList;
  }

  static Future<List<AccountTypeModel>> createAccountTypes(
    List accountTypes,
  ) async {
    final accountTypeBox = await Hive.openBox(AccountTypeModel.accountTypeBox);
    await accountTypeBox.clear();

    List<AccountTypeModel> accountTypeModels = [];

    for (var accountType in accountTypes) {
      var accountTypeModel = AccountTypeModel.fromMap(accountType);

      await accountTypeBox.put(accountTypeModel.id, accountTypeModel);
      accountTypeModels.add(accountTypeModel);
    }

    return accountTypeModels;
  }
}
