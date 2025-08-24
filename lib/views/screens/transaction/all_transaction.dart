import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:smart_expense/controllers/transaction.dart';
import 'package:smart_expense/models/result.dart';
import 'package:smart_expense/models/transaction.dart';
import 'package:smart_expense/resources/app_colours.dart';
import 'package:smart_expense/resources/app_route.dart';
import 'package:smart_expense/resources/app_spacing.dart';
import 'package:smart_expense/resources/app_strings.dart';
import 'package:smart_expense/resources/app_styles.dart';
import 'package:smart_expense/utills/helper.dart';
import 'package:smart_expense/views/components/ui/app_bar.dart';
import 'package:smart_expense/views/components/ui/indecator.dart';
import 'package:smart_expense/views/components/ui/list_tile.dart';

class AllTransactions extends StatefulWidget {
  const AllTransactions({super.key});

  @override
  State<AllTransactions> createState() => _AllTransactionsState();
}

class _AllTransactionsState extends State<AllTransactions> {
  List<TransactionModel> transactions = [];

  bool _initializing = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initScreen();
  }

  _initScreen() async {
    setState(() => _initializing = true);
    final result = await TransactionController.load();
    if (result.isSuccess && result.results != null) {
      setState(() {
        transactions = result.results!;

        _initializing = false;
      });
    }
  }

  _handleDelete(String transactionId) async {
    final result = await TransactionController.delete({'id': transactionId});
    if (result.isSuccess) {
      Helper.snackBar(
        context,
        message: AppStrings.dataDeleteSuccess.replaceAll(
          ':data',
          AppStrings.transaction,
        ),
        isSuccess: true,
      );
      _initScreen(); // Refresh
    } else {
      Helper.snackBar(context, message: result.message, isSuccess: false);
    }
  }

  // _getLatestTransaction() {
  //   DateTime now = DateTime.now();
  //   transactions.where((transaction) {
  //     return transaction.transactionDate.isAfter(
  //       now.subtract(Duration(days: 7)),
  //     );
  //   }).toList();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColours.bgColor,
      appBar: buildAppBar(
        context,
        AppStrings.allTransactions,
        foregroundColor: Colors.white,
        backgroundColor: AppColours.primaryColour,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: AppSpacing.vertical(size: 4)),
          if (_initializing)
            SliverToBoxAdapter(
              child: Center(heightFactor: 5, child: MyIndecator()),
            ),
          if (!_initializing && transactions.isEmpty)
            SliverToBoxAdapter(
              child: Center(
                heightFactor: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    AppSpacing.vertical(size: 16),
                    Text(
                      AppStrings.noTransactionYet,
                      style: AppStyles.semibold(
                        size: 18,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      AppStrings.startTrackingYourExpenseAndIncome,
                      style: AppStyles.regular1(
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          SliverList(
            delegate: SliverChildListDelegate([
              ...transactions.map((transaction) {
                return Padding(
                  padding: EdgeInsets.all(0),
                  child: Slidable(
                    endActionPane: ActionPane(
                      motion: ScrollMotion(),
                      children: [
                        SlidableAction(
                          foregroundColor: Colors.red.shade400,
                          icon: Icons.delete,
                          label: 'Delete',
                          backgroundColor: Colors.red.shade50,

                          onPressed: (context) {
                            _handleDelete(transaction.id);
                          },
                        ),

                        SlidableAction(
                          onPressed: (context) {
                            Navigator.of(context).pushNamed(
                              AppRoutes.updateTransaction,
                              arguments: transaction,
                            );
                          },
                          icon: Icons.edit,
                          label: 'Edit',
                          backgroundColor: Colors.blue.shade50,
                          foregroundColor: Colors.blue.shade400,
                        ),
                      ],
                    ),
                    child: ListTileComponent(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          AppRoutes.detailTransaction,
                          arguments: {
                            'id': transaction.id,
                            'type': transaction.type,
                          },
                        );
                      },
                      leadingIcon: Icon(
                        Helper.transactionIcon[transaction.category.icon],
                        color: Color(
                          int.parse(transaction.category.colourCode),
                        ),
                        size: 30,
                      ),
                      iconBackgroundColor: Color(
                        int.parse(transaction.category.colourCode),
                      ).withAlpha(50),
                      title: transaction.description,
                      subtitle: transaction.category.name,
                      subTitleColor: Color(
                        int.parse(transaction.category.colourCode),
                      ),
                      trailing:
                          transaction.type == 'income'
                              ? transaction.formattedAmountText
                              : "- ${transaction.formattedAmountText}",
                      trailingColor:
                          transaction.type == 'income'
                              ? Colors.green
                              : Colors.red.shade400,
                      subTraiLing: Helper.getFormattedDate(
                        transaction.transactionDate.toString(),
                      ),
                      // time: Helper.timeFormat(transaction.createdAt.toString()),
                    ),
                  ),
                );
              }),
            ]),
          ),
        ],
      ),
    );
  }
}
