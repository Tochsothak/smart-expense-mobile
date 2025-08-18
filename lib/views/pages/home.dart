import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:smart_expense/controllers/transaction.dart';
import 'package:smart_expense/models/transaction.dart';
import 'package:smart_expense/models/user.dart';
import 'package:smart_expense/resources/app_colours.dart';
import 'package:smart_expense/resources/app_route.dart';
import 'package:smart_expense/resources/app_spacing.dart';
import 'package:smart_expense/resources/app_strings.dart';
import 'package:smart_expense/resources/app_styles.dart';
import 'package:smart_expense/services/auth.dart';
import 'package:smart_expense/utills/helper.dart';
import 'package:smart_expense/views/components/ui/list_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<TransactionModel> transactions = [];
  Map<String, List<TransactionModel>> groupedTransactions = {};
  bool _isLoading = false;

  UserModel? user;

  @override
  void initState() {
    super.initState();
    _initScreen();
    _getUser();
  }

  _getUser() async {
    final currentUser = await AuthService.get();
    if (currentUser != null) {
      setState(() => user = currentUser);
    }
  }

  _initScreen() async {
    setState(() => _isLoading = true);
    final result = await TransactionController.load();
    if (result.isSuccess && result.results != null) {
      setState(() {
        transactions = result.results!;
        groupedTransactions = _groupTransactionsByDay(transactions);

        _isLoading = false;
      });
      // print(result.results);
    } else {
      setState(() => _isLoading = false);
    }
  }

  // GroupTransaction By Days
  Map<String, List<TransactionModel>> _groupTransactionsByDay(
    List<TransactionModel> transactions,
  ) {
    Map<String, List<TransactionModel>> grouped = {};

    for (var transaction in transactions) {
      // Format date as key (e.g "2024-01-15")
      String dateKey = DateFormat(
        'yyy-MM-dd',
      ).format(transaction.transactionDate);
      if (grouped[dateKey] == null) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(transaction);

      // Sort each day's transactions by time (newes first)
      grouped.forEach((key, value) {
        value.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
      });
    }
    return grouped;
  }

  // Get Formatted date to display
  String _getFormattedDate(String dateKey) {
    DateTime date = DateTime.parse(dateKey);
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = today.subtract(Duration(days: 1));
    DateTime transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'Today';
    } else if (transactionDate == yesterday) {
      return 'Yesterday';
    } else {
      return Helper.dateFormat(date);
    }
  }

  // Calculate daily total
  double _getDailyTotal(List<TransactionModel> dayTransactions) {
    double total = 0;
    for (var transaction in dayTransactions) {
      if (transaction.type == 'income') {
        total += transaction.amount;
      } else {
        total -= transaction.amount;
      }
    }
    return total;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColours.bgColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 90,
              floating: false,
              backgroundColor: AppColours.secondaryColour,
              flexibleSpace: FlexibleSpaceBar(background: _topBar()),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.of(context).size.height / 4,
                child: _head(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.recentTransactions,
                      style: AppStyles.semibold(),
                    ),
                    TextButton(
                      style: ButtonStyle(),
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).pushNamed(AppRoutes.allTransactions);
                      },
                      child: Text(
                        AppStrings.seeAll,
                        style: AppStyles.semibold().copyWith(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      color: AppColours.primaryColour,
                    ),
                  ),
                ),
              ),

            if (!_isLoading && groupedTransactions.isNotEmpty)
              ...groupedTransactions.entries.map((entry) {
                String dateKey = entry.key;
                List<TransactionModel> dayTransactions = entry.value;
                double dailyTotal = _getDailyTotal(dayTransactions);
                return SliverList(
                  // Date header with daily total
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _getFormattedDate(dateKey),
                            style: AppStyles.medium(
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),

                          Text(
                            dailyTotal >= 0
                                ? '+\$${dailyTotal.toString()}'
                                : '-\$${dailyTotal.abs().toStringAsFixed(2)}',
                            style: AppStyles.semibold(
                              size: 14,
                              color:
                                  dailyTotal >= 0
                                      ? Colors.green.shade400
                                      : Colors.red.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    //Transaction for this day
                    AppSpacing.vertical(size: 12),
                    ...dayTransactions
                        .map(
                          (transaction) => Slidable(
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
                                Helper.transactionIcon[transaction
                                    .category
                                    .icon],
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
                              subTraiLing: Helper.timeFormat(
                                transaction.createdAt!,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    AppSpacing.vertical(size: 16),
                  ]),
                );
              }).toList(),

            if (!_isLoading && groupedTransactions.isEmpty)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Column(
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
              ),
          ],
        ),
      ),
    );
  }

  Widget _head() {
    // Calculate totals from transactions
    double totalIncome = 0;
    double totalExpense = 0;

    for (var transaction in transactions) {
      if (transaction.type == 'income') {
        totalIncome += transaction.amount;
      } else {
        totalExpense += transaction.amount;
      }
    }
    double accountBalance = totalIncome - totalExpense;
    return Stack(
      children: [
        Column(
          children: [
            Container(
              width: double.infinity,
              height: 130,
              decoration: BoxDecoration(
                color: AppColours.secondaryColour,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          top: 10,
          left: MediaQuery.of(context).size.width / 2 - 180,
          child: Container(
            width: 360,
            height: MediaQuery.of(context).size.height / 4.5,
            decoration: BoxDecoration(
              color: AppColours.primaryColour,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColours.primaryColour.withAlpha(900),
                  offset: Offset(0, 6),
                  blurRadius: 12,
                  spreadRadius: 6,
                ),
              ],
            ),
            child: Column(
              children: [
                AppSpacing.vertical(size: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.accountBalance,
                        style: AppStyles.regular1(
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                      Icon(Icons.more_horiz, color: Colors.white, size: 30),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Row(
                    children: [
                      Text(
                        "\$${accountBalance.toStringAsFixed(2)}",
                        style: AppStyles.title3(color: Colors.white, size: 24),
                      ),
                    ],
                  ),
                ),
                AppSpacing.vertical(size: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.green.shade400,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 10,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 10,
                                    child: Icon(
                                      Icons.arrow_downward,
                                      size: 20,
                                      color: Colors.green,
                                    ),
                                  ),
                                  AppSpacing.horizontal(size: 4),
                                  Text(
                                    AppStrings.income,
                                    style: AppStyles.medium(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "\$${totalIncome.toStringAsFixed(2)}",
                                style: AppStyles.medium(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 60,
                        child: VerticalDivider(color: Colors.white),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 10,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 10,
                                    child: Icon(
                                      Icons.arrow_upward,
                                      size: 20,
                                      color: Colors.red,
                                    ),
                                  ),
                                  AppSpacing.horizontal(size: 4),
                                  Text(
                                    AppStrings.expense,
                                    style: AppStyles.medium(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "\$${totalExpense.toStringAsFixed(2)}",
                                style: AppStyles.medium(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(width: 2, color: Colors.white),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.asset("assets/images/sothak.jpg"),
                  ),
                ),
              ),
              AppSpacing.horizontal(size: 6),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Helper.greeting(),
                    style: AppStyles.medium(color: Colors.white),
                  ),
                  Text(
                    user?.name ?? '',
                    style: AppStyles.regular1(color: Colors.white, size: 12),
                  ),
                ],
              ),
            ],
          ),

          Icon(Icons.notifications, color: Colors.white, size: 30),
        ],
      ),
    );
  }
}
