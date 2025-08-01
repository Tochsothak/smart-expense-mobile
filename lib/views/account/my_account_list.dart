import 'package:flutter/material.dart';
import 'package:smart_expense/controllers/account.dart';
import 'package:smart_expense/models/account.dart';
import 'package:smart_expense/resources/app_colours.dart';
import 'package:smart_expense/resources/app_spacing.dart';
import 'package:smart_expense/resources/app_strings.dart';
import 'package:smart_expense/services/account.dart';
import 'package:smart_expense/views/components/ui/app_bar.dart';
import 'package:smart_expense/views/components/ui/button.dart';
import 'package:smart_expense/views/components/ui/list_tile.dart';

class MyAccountList extends StatefulWidget {
  const MyAccountList({super.key});

  @override
  State<MyAccountList> createState() => _MyAccountListState();
}

class _MyAccountListState extends State<MyAccountList> {
  List<AccountModel> accountModels = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColours.bgColor,
      appBar: buildAppBar(
        context,
        AppStrings.accounts,
        foregroundColor: Colors.black,
      ),

      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: AppSpacing.vertical(size: 48)),
          SliverList.builder(
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15 / 2,
                ),
                child: ListTileComponent(
                  leadingIcon: Icons.wallet,
                  iconColor: Colors.amber,
                  trailingColor: Colors.green,
                  backGroundColor: Colors.blue.shade50,
                  title: accountModels[index].name,
                  subtitle: accountModels[index].currency.toString(),
                  subTraiLing: accountModels[index].accountType.toString(),
                  trailing: accountModels[index].currentBalanceText,
                  onTap: () {},
                ),
              );
            },
            itemCount: accountModels.length,
          ),

          SliverToBoxAdapter(child: AppSpacing.vertical()),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: ButtonComponent(
                label: AppStrings.addNewAccount,
                onPressed: () {
                  print(accountModels);
                },
              ),
            ),
          ),
          SliverToBoxAdapter(child: AppSpacing.vertical(size: 48)),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadAccountList();
  }

  _loadAccountList() async {
    final accountBox = await AccountService.getAll();
    if (accountBox == null) {
      return;
    }
    setState(() => accountModels = accountBox);

    final accounts = await AccountController.load();
    if (!accounts.isSuccess && accounts.results == null) {
      return null;
    }
    setState(() {
      accountModels = accounts.results!;
    });
  }
}
