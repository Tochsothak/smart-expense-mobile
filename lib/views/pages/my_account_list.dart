import 'package:flutter/material.dart';
import 'package:smart_expense/controllers/account.dart';
import 'package:smart_expense/models/account.dart';
import 'package:smart_expense/resources/app_colours.dart';
import 'package:smart_expense/resources/app_route.dart';
import 'package:smart_expense/resources/app_spacing.dart';
import 'package:smart_expense/resources/app_strings.dart';
import 'package:smart_expense/resources/app_styles.dart';
import 'package:smart_expense/views/components/ui/account_tile.dart';
import 'package:smart_expense/views/components/ui/button.dart';
import 'package:smart_expense/views/components/ui/indecator.dart';

class MyAccountList extends StatefulWidget {
  const MyAccountList({super.key});

  @override
  State<MyAccountList> createState() => _MyAccountListState();
}

class _MyAccountListState extends State<MyAccountList> {
  bool _isLoading = false;
  List<AccountModel> accountModels = [];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColours.bgColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            _header(),
            AppSpacing.vertical(size: 38),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: ButtonComponent(
                label: AppStrings.addNewAccount,
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.addAccount);
                },
              ),
            ),
            AppSpacing.vertical(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                'My ${accountModels.length > 1 ? 'accounts' : 'account'}',
                style: AppStyles.semibold(),
              ),
            ),
            AppSpacing.vertical(),
            if (!_isLoading && accountModels.isEmpty)
              Center(
                child: Column(
                  children: [
                    AppSpacing.vertical(size: 120),
                    Icon(
                      Icons.receipt_long,
                      size: 68,
                      color: Colors.grey.shade400,
                    ),
                    AppSpacing.vertical(size: 4),
                    TextButton(
                      onPressed: _loadAccounts,
                      child: Text(AppStrings.refresh),
                    ),
                  ],
                ),
              ),
            if (_isLoading) Center(child: Column(children: [MyIndecator()])),
            if (!_isLoading && accountModels.isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  itemCount: accountModels.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    final account = accountModels[index];
                    return AccountTile(
                      width: 383,
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          AppRoutes.accountDetail,
                          arguments: account.id,
                        );
                      },
                      accountName: account.name,
                      currency: account.currency.code,
                      currentBalance: account.currentBalanceText,
                      transactionCount:
                          '${account.transactionCount.toString()} ${accountModels.length > 1 ? 'transactions' : 'transaction'}',
                      income: account.totalIncomeText,
                      expense: account.totalExpenseText,
                      topSize: 24,
                      midSize: 28,
                      bottomSize: 16,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: 300,
          decoration: BoxDecoration(
            color: AppColours.primaryColour,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: MediaQuery.of(context).size.width / 2 - 150,
          child: Image.asset("assets/images/wallet.png", width: 300),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  _loadAccounts() async {
    setState(() => _isLoading = true);
    final result = await AccountController.load();
    if (!result.isSuccess && result.results == null) {
      setState(() => _isLoading = false);
      return;
    }
    setState(() {
      accountModels = result.results as List<AccountModel>;
      _isLoading = false;
    });
  }
}
