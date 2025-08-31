import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:smart_expense/controllers/account.dart';
import 'package:smart_expense/controllers/currency.dart';
import 'package:smart_expense/controllers/profile.dart';
import 'package:smart_expense/controllers/transaction.dart';
import 'package:smart_expense/models/account.dart';
import 'package:smart_expense/models/currency.dart';
import 'package:smart_expense/models/transaction.dart';
import 'package:smart_expense/models/user.dart';
import 'package:smart_expense/resources/app_colours.dart';
import 'package:smart_expense/resources/app_route.dart';
import 'package:smart_expense/resources/app_spacing.dart';
import 'package:smart_expense/resources/app_strings.dart';
import 'package:smart_expense/resources/app_styles.dart';
import 'package:smart_expense/services/auth.dart';
import 'package:smart_expense/utills/helper.dart';
import 'package:smart_expense/views/components/ui/account_tile.dart';
import 'package:smart_expense/views/components/ui/list_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  List<TransactionModel> transactions = [];
  Map<String, List<TransactionModel>> dayTransactions = {};
  List<AccountModel> accounts = [];
  List<CurrencyModel> currencies = [];
  CurrencyModel? selectedCurrency;
  double? totalAmount;
  double? totalIncome;
  double? totalExpense;
  bool _isLoading = false;
  bool _showConvertedAmounts = true;
  UserModel? user;
  bool _isLoadingProfile = false;

  List<Map<String, double>> convertedAccounts = [];

  @override
  void initState() {
    super.initState();
    _initScreen();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Listen for route changes to refresh profile when returning from profile screen
    ModalRoute.of(context)?.settings.name;
  }

  // Add this method to handle route returns
  void didPopNext() {
    // This is called when returning from another screen
    _refreshProfile();
  }

  _initScreen() async {
    await _loadCurrency();

    if (currencies.isNotEmpty) {
      selectedCurrency = currencies.firstWhere(
        (c) => c.code == 'USD',
        orElse:
            () => currencies.firstWhere(
              (c) => c.code == 'KHR',
              orElse: () => currencies.first,
            ),
      );
    }
    await _loadAccounts();
    await _getUser();
    _loadTransactions();
  }

  // Enhanced user loading with profile refresh
  Future<void> _getUser() async {
    setState(() => _isLoadingProfile = true);
    try {
      // First try to get from local storage
      final currentUser = await AuthService.get();
      if (currentUser != null) {
        setState(() {
          user = currentUser;
        });
      }
      // Then refresh from server
      await _refreshProfile();
    } catch (e) {
      print('Error loading user: $e');
    } finally {
      setState(() => _isLoadingProfile = false);
    }
  }

  // Add method to refresh profile from server
  Future<void> _refreshProfile() async {
    try {
      final result = await ProfileController.getProfile();
      if (result.isSuccess && result.results != null) {
        setState(() {
          user = result.results;
        });
        // Update local storage
        // await AuthService.create(result.results)
      } else {
        print('Failed to refresh profile: ${result.message}');
      }
    } catch (e) {
      print('Error refreshing profile: $e');
    }
  }

  _loadCurrency() async {
    setState(() => _isLoading = true);
    final result = await CurrencyController.load();
    if (result.isSuccess && result.results != null) {
      setState(() {
        currencies = result.results!;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  _loadAccounts() async {
    setState(() => _isLoading = true);
    final result = await AccountController.load();
    if (result.isSuccess && result.results != null) {
      accounts = result.results!;
      convertedAccounts.clear();
      for (var account in accounts) {
        double balance = account.currentBalance;
        double income = account.totalIncome ?? 0;
        double expense = account.totalExpense ?? 0;
        if (account.currency.code != selectedCurrency!.code) {
          balance = await Helper.convertAmount(
            balance,
            account.currency.code,
            selectedCurrency?.code ?? '',
          );
          income = await Helper.convertAmount(
            income,
            account.currency.code,
            selectedCurrency?.code ?? '',
          );
          expense = await Helper.convertAmount(
            expense,
            account.currency.code,
            selectedCurrency?.code ?? '',
          );
        }

        convertedAccounts.add({
          'balance': balance,
          'income': income,
          'expense': expense,
        });
      }
      _getTotalAmount();
      setState(() => _isLoading = false);
    } else {
      setState(() => _isLoading = false);
    }
  }

  _loadTransactions() async {
    setState(() => _isLoading = true);
    final result = await TransactionController.load();
    if (result.isSuccess && result.results != null) {
      setState(() {
        transactions = result.results!;
        dayTransactions = _groupTransactionsByDay(transactions);
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  _getTotalAmount() async {
    double total = 0;
    double income = 0;
    double expense = 0;

    for (var converted in convertedAccounts) {
      total += converted['balance']!;
      income += converted['income']!;
      expense += converted['expense']!;
    }
    setState(() {
      totalAmount = total;
      totalExpense = expense;
      totalIncome = income;
    });
  }

  Map<String, List<TransactionModel>> _groupTransactionsByDay(
    List<TransactionModel> transactions,
  ) {
    Map<String, List<TransactionModel>> grouped = {};

    for (var transaction in transactions) {
      String dateKey = DateFormat(
        'yyy-MM-dd',
      ).format(transaction.transactionDate);
      if (grouped[dateKey] == null) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(transaction);

      grouped.forEach((key, value) {
        value.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
      });
    }
    return grouped;
  }

  Future<double> _getDailyTotal(List<TransactionModel> dayTransactions) async {
    double total = 0;
    for (var transaction in dayTransactions) {
      double transactionAmount = transaction.amount;
      if (transaction.account.currency.code != selectedCurrency?.code) {
        double amount = await Helper.convertAmount(
          transactionAmount,
          transaction.account.currency.code,
          selectedCurrency?.code ?? '',
        );
        transactionAmount = amount;
      }
      if (transaction.type == 'income') {
        total += transactionAmount;
      } else {
        total -= transactionAmount;
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
      _initScreen();
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
                height: MediaQuery.of(context).size.height / 3.9,
                child: _head(),
              ),
            ),
            SliverToBoxAdapter(child: _accountSummariesSection()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.recentTransactions,
                      style: AppStyles.semibold(),
                    ),
                    GestureDetector(
                      onTap:
                          () => Navigator.of(
                            context,
                          ).pushNamed(AppRoutes.allTransactions),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColours.primaryColourLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          AppStrings.seeAll,
                          style: AppStyles.regular1(size: 12),
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
                  heightFactor: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      color: AppColours.primaryColour,
                    ),
                  ),
                ),
              ),

            if (!_isLoading && dayTransactions.isNotEmpty)
              ...dayTransactions.entries.map((entry) {
                String dateKey = entry.key;
                List<TransactionModel> dayTransactions = entry.value;

                return SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            Helper.getFormattedDate(dateKey),
                            style: AppStyles.medium(
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          FutureBuilder<double>(
                            future: _getDailyTotal(dayTransactions),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                double dailyTotal = snapshot.data!;
                                return Text(
                                  dailyTotal >= 0
                                      ? '+ ${Helper.formatCurrency(dailyTotal, selectedCurrency?.symbol ?? '', compact: true, symbolPosition: selectedCurrency?.symbolPosition ?? '')}'
                                      : '- ${Helper.formatCurrency(dailyTotal.abs(), selectedCurrency?.symbol ?? '', compact: true, symbolPosition: selectedCurrency?.symbolPosition ?? '')}',
                                  style: AppStyles.semibold(
                                    size: 14,
                                    color:
                                        dailyTotal >= 0
                                            ? Colors.green.shade400
                                            : Colors.red.shade400,
                                  ),
                                );
                              }
                              return SizedBox();
                            },
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.vertical(size: 12),
                    ...dayTransactions.map(
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
                          subTraiLing: Helper.timeFormat(
                            transaction.createdAt!,
                          ),
                        ),
                      ),
                    ),
                    AppSpacing.vertical(size: 16),
                  ]),
                );
              }),

            if (!_isLoading && dayTransactions.isEmpty)
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

  Widget _accountSummariesSection() {
    if (accounts.isEmpty) return SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppStrings.accountBreakdown, style: AppStyles.semibold()),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showConvertedAmounts = !_showConvertedAmounts;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColours.primaryColourLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _showConvertedAmounts ? 'Show Original' : 'Show Converted',
                    style: AppStyles.regular1(size: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
        AppSpacing.vertical(size: 10),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 15),
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              final account = accounts[index];
              final converted =
                  (convertedAccounts.length > index)
                      ? convertedAccounts[index]
                      : null;
              final showConverted = _showConvertedAmounts && converted != null;

              double balance =
                  showConverted
                      ? converted['balance']!
                      : account.currentBalance;
              double income =
                  showConverted
                      ? converted['income']!
                      : (account.totalIncome ?? 0);
              double expense =
                  showConverted
                      ? converted['expense']!
                      : (account.totalExpense ?? 0);

              return AccountTile(
                onTap: () {
                  Navigator.of(
                    context,
                  ).pushNamed(AppRoutes.accountDetail, arguments: account.id);
                },
                width: 250,
                accountName: account.name,
                currency:
                    _showConvertedAmounts
                        ? selectedCurrency!.code
                        : account.currency.code,
                currentBalance:
                    showConverted
                        ? Helper.formatCurrency(
                          balance,
                          selectedCurrency!.symbol,
                          compact: true,
                          symbolPosition:
                              selectedCurrency?.symbolPosition ?? '',
                        )
                        : Helper.formatCurrency(
                          account.currentBalance,
                          account.currency.symbol,
                          compact: true,
                          symbolPosition: account.currency.symbolPosition,
                        ),
                income:
                    showConverted
                        ? '+ ${Helper.formatCurrency(income, selectedCurrency?.symbol ?? '', compact: true, symbolPosition: selectedCurrency!.symbolPosition)}'
                        : '+ ${Helper.formatCurrency(account.totalIncome ?? 0, account.currency.symbol, compact: true, symbolPosition: account.currency.symbolPosition)}',
                expense:
                    showConverted
                        ? '- ${Helper.formatCurrency(expense, selectedCurrency?.symbol ?? '', compact: true, symbolPosition: selectedCurrency!.symbolPosition)}'
                        : '- ${Helper.formatCurrency(account.totalExpense ?? 0, account.currency.symbol, compact: true, symbolPosition: account.currency.symbolPosition)}',
                transactionCount:
                    '${account.transactionCount} ${account.transactionCount! > 1 ? 'transactions' : 'transaction'}',
              );
            },
          ),
        ),
        AppSpacing.vertical(size: 16),
      ],
    );
  }

  Widget _head() {
    return Stack(
      children: [
        Column(
          children: [
            Container(
              width: double.infinity,
              height: 160,
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
            height: MediaQuery.of(context).size.height / 4.4,
            decoration: BoxDecoration(
              color: AppColours.primaryColour,
              borderRadius: BorderRadius.circular(24),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.totalBalance,
                        style: AppStyles.regular1(
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                      DropdownButton<CurrencyModel>(
                        borderRadius: BorderRadius.circular(12),
                        value: selectedCurrency,
                        dropdownColor: AppColours.primaryColour,
                        style: AppStyles.regular1(color: Colors.white),
                        underline: SizedBox(),
                        icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                        items:
                            currencies.map((currency) {
                              return DropdownMenuItem(
                                alignment: AlignmentDirectional.centerStart,
                                value: currency,
                                child: Text(currency.code),
                              );
                            }).toList(),
                        onChanged: (CurrencyModel? value) async {
                          if (value != null && value != selectedCurrency) {
                            setState(() {
                              selectedCurrency = value;
                              convertedAccounts.clear();
                              _isLoading = true;
                            });

                            for (var account in accounts) {
                              double balance = account.currentBalance;
                              double income = account.totalIncome ?? 0;
                              double expense = account.totalExpense ?? 0;
                              if (account.currency.code !=
                                  selectedCurrency!.code) {
                                balance = await Helper.convertAmount(
                                  balance,
                                  account.currency.code,
                                  selectedCurrency!.code,
                                );
                                income = await Helper.convertAmount(
                                  income,
                                  account.currency.code,
                                  selectedCurrency!.code,
                                );
                                expense = await Helper.convertAmount(
                                  expense,
                                  account.currency.code,
                                  selectedCurrency!.code,
                                );
                              }
                              convertedAccounts.add({
                                'balance': balance,
                                'income': income,
                                'expense': expense,
                              });
                            }
                            _getTotalAmount();
                            setState(() => _isLoading = false);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Row(
                    children: [
                      Text(
                        Helper.formatCurrency(
                          totalAmount ?? 0,
                          selectedCurrency?.symbol ?? '',
                          compact: true,
                          symbolPosition:
                              selectedCurrency?.symbolPosition ?? '',
                        ),
                        style: AppStyles.title3(color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                ),
                AppSpacing.vertical(size: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 2.7,
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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 10,
                                    child: Icon(
                                      Icons.arrow_downward,
                                      size: 14,
                                      color: Colors.green,
                                    ),
                                  ),
                                  AppSpacing.horizontal(size: 8),
                                  Text(
                                    AppStrings.income,
                                    style: AppStyles.medium(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              AppSpacing.vertical(size: 8),
                              Text(
                                Helper.formatCurrency(
                                  totalIncome ?? 0,
                                  selectedCurrency?.symbol ?? '',
                                  compact: true,
                                  symbolPosition:
                                      selectedCurrency?.symbolPosition ?? '',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                                style: AppStyles.medium(
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 2.7,
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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 10,
                                    child: Icon(
                                      Icons.arrow_upward,
                                      size: 14,
                                      color: Colors.red,
                                    ),
                                  ),
                                  AppSpacing.horizontal(size: 8),
                                  Text(
                                    AppStrings.expense,
                                    style: AppStyles.medium(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              AppSpacing.vertical(size: 8),
                              Text(
                                Helper.formatCurrency(
                                  totalExpense ?? 0,
                                  selectedCurrency?.symbol ?? '',
                                  compact: true,
                                  symbolPosition:
                                      selectedCurrency?.symbolPosition ?? '',
                                ),
                                style: AppStyles.medium(
                                  color: Colors.white,
                                  size: 14,
                                ),
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
                    child: _buildProfileImage(),
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
                    user?.name ?? 'Loading...',
                    style: AppStyles.regular1(color: Colors.white, size: 12),
                  ),
                ],
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.notification);
            },
            child: Icon(Icons.notifications, color: Colors.white, size: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    if (_isLoadingProfile) {
      return Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (user?.hasProfileImage == true && user?.profileImageUrl != null) {
      return Image.network(
        user!.profileImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              value:
                  loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
            ),
          );
        },
      );
    } else {
      return _buildDefaultAvatar();
    }
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Icon(Icons.person, size: 30, color: Colors.white),
    );
  }
}
