import 'package:flutter/material.dart';
import 'package:smart_expense/controllers/account.dart';
import 'package:smart_expense/models/account.dart';
import 'package:smart_expense/resources/app_colours.dart';
import 'package:smart_expense/resources/app_route.dart';
import 'package:smart_expense/resources/app_spacing.dart';
import 'package:smart_expense/resources/app_strings.dart';
import 'package:smart_expense/resources/app_styles.dart';
import 'package:smart_expense/views/components/ui/account_tile.dart';
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
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 80,
              floating: false,
              backgroundColor: AppColours.primaryColour,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                background: Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.accountWallet,
                        style: AppStyles.title3(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).pushNamed(AppRoutes.setUpAccount);
                        },
                        child: Text(
                          AppStrings.newA,
                          style: AppStyles.title3(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(child: _header()),
            SliverToBoxAdapter(child: AppSpacing.vertical(size: 10)),
            _isLoading
                ? SliverToBoxAdapter(child: MyIndecator())
                : SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return AccountTile(
                      onTap:
                          () => Navigator.of(context).pushNamed(
                            AppRoutes.accountDetail,
                            arguments: accountModels[index].id,
                          ),
                      accountName: accountModels[index].name,
                      currency: accountModels[index].currency.code,
                      accountType: accountModels[index].accountType.name,
                      currentBalance: accountModels[index].currentBalanceText,
                    );
                  }, childCount: accountModels.length),
                ),
            SliverToBoxAdapter(child: AppSpacing.vertical()),
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
          height: 330,
          decoration: BoxDecoration(
            color: AppColours.primaryColour,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
        ),
        Positioned(
          top: -10,
          left: MediaQuery.of(context).size.width / 2 - 175,
          child: Image.asset("assets/images/wallet.png", width: 350),
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
