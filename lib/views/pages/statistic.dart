import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:smart_expense/controllers/transaction.dart';
import 'package:smart_expense/models/currency.dart';
import 'package:smart_expense/models/transaction.dart';
import 'package:smart_expense/models/user.dart';
import 'package:smart_expense/resources/app_colours.dart';
import 'package:smart_expense/resources/app_route.dart';
import 'package:smart_expense/resources/app_spacing.dart';
import 'package:smart_expense/resources/app_strings.dart';
import 'package:smart_expense/resources/app_styles.dart';
import 'package:smart_expense/utills/helper.dart';
import 'package:smart_expense/utills/helper_models/category_stats.dart';
import 'package:smart_expense/utills/helper_models/currency_breakdown.dart';
import 'package:smart_expense/views/components/ui/indecator.dart';
import 'package:smart_expense/views/components/ui/list_tile.dart';

class StatisticScreen extends StatefulWidget {
  const StatisticScreen({super.key});

  @override
  State<StatisticScreen> createState() => _StatisticScreenState();
}

class _StatisticScreenState extends State<StatisticScreen> {
  List<String> days = ['Day', 'Week', 'Month', 'Year'];
  int currentIndex = 2; // Default to Month

  List<TransactionModel> transactions = [];
  List<TransactionModel> filteredTransactions = [];
  Map<String, CategoryStats> categoryStats = {};
  Map<String, CurrencyBreakdown> currencyBreakdowns = {};
  List<FlSpot> chartData = [];
  Map<String, String> chartLabels = {}; // for x-axis labels

  bool isLoading = true;
  String selectedType = 'expense'; // 'expense' or 'income'
  String baseCurrency = 'USD';
  UserModel? currentUser;
  List<CurrencyModel> selectedCurrency = [];
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _initScreen();
  }

  _initScreen() async {
    await _loadData();
  }

  _loadData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
      final result = await TransactionController.load();
      if (result.isSuccess && result.results != null) {
        setState(() {
          transactions = result.results!;
        });
        await _processTransactions();
        setState(() => isLoading = false);
      } else {
        setState(() {
          isLoading = false;
          errorMessage = result.message;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = AppStrings.failedToLoadData;
      });
    }
  }

  Future<void> _processTransactions() async {
    try {
      _filterTransactionsByPeriod();
      await _calculateCurrencyBreakdowns();
      await _calculateCategoryStats();
      await _generateChartData();
    } catch (e) {
      setState(() {
        errorMessage = AppStrings.failedToLoadData;
      });
    }
  }

  _filterTransactionsByPeriod() {
    DateTime now = DateTime.now();
    DateTime startDate;
    switch (currentIndex) {
      case 0: // Day
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 1: // Week
        startDate = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        break;
      case 2: // Month
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 3: // Year
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        startDate = DateTime(now.year, now.month, 1);
    }

    filteredTransactions =
        transactions.where((transaction) {
          DateTime transactionDate = transaction.transactionDate;
          return transactionDate.isAfter(
                startDate.subtract(Duration(days: 1)),
              ) &&
              transactionDate.isBefore(now.add(Duration(days: 1))) &&
              transaction.type == selectedType;
        }).toList();
  }

  Future<void> _calculateCurrencyBreakdowns() async {
    currencyBreakdowns.clear();
    // Group transaction by currency
    Map<String, List<TransactionModel>> transactionByCurrency = {};
    for (var transaction in filteredTransactions) {
      String currency = transaction.account.currency.code;
      if (transactionByCurrency[currency] == null) {
        transactionByCurrency[currency] = [];
      }
      transactionByCurrency[currency]!.add(transaction);
    }

    // Calculate breakdown for each currency
    for (var entry in transactionByCurrency.entries) {
      String currency = entry.key;
      List<TransactionModel> currencyTransactions = entry.value;
      double originalTotal = currencyTransactions.fold(
        0.0,
        (sum, t) => sum + t.amount,
      );
      double convertedTotal = originalTotal;

      // Convert to base currency if different
      if (currency != baseCurrency) {
        convertedTotal = await Helper.convertAmount(
          originalTotal,
          currency,
          baseCurrency,
        );
      }

      currencyBreakdowns[currency] = CurrencyBreakdown(
        currency: currency,
        originalAmount: originalTotal,
        convertedAmount: convertedTotal,
        transactionCount: currencyTransactions.length,
        exchangeRate:
            currency != baseCurrency ? convertedTotal / originalTotal : 1.0,
      );
    }
  }

  Future<void> _calculateCategoryStats() async {
    categoryStats.clear();
    // Group transactions by category
    Map<String, List<TransactionModel>> transactionByCategory = {};
    for (var transaction in filteredTransactions) {
      String categoryName = transaction.category.name;
      if (transactionByCategory[categoryName] == null) {
        transactionByCategory[categoryName] = [];
      }
      transactionByCategory[categoryName]!.add(transaction);
    }

    // Calculate stats for each Category (always convert to base currency)
    for (var entry in transactionByCategory.entries) {
      String categoryName = entry.key;
      List<TransactionModel> categoryTransactions = entry.value;
      double originalTotal = 0;
      double convertedTotal = 0;

      // Calculate totals with currency conversion to base currency
      for (var transaction in categoryTransactions) {
        originalTotal += transaction.amount;

        // Always convert to base currency for statistics
        if (transaction.account.currency.code != baseCurrency) {
          double convertedAmount = await Helper.convertAmount(
            transaction.amount,
            transaction.account.currency.code,
            baseCurrency,
          );
          convertedTotal += convertedAmount;
        } else {
          convertedTotal += transaction.amount;
        }
      }

      // Get category info from first transaction
      var firstTransaction = categoryTransactions.first;
      categoryStats[categoryName] = CategoryStats(
        categoryName: categoryName,
        originalAmount: originalTotal,
        convertedAmount: convertedTotal,
        transactionCount: categoryTransactions.length,
        categoryIcon: firstTransaction.category.icon,
        categoryColor: firstTransaction.category.colourCode,
        transactions: categoryTransactions,
      );
    }

    // Sort by converted amount (descending)
    var sortedEntries =
        categoryStats.entries.toList()..sort(
          (a, b) => b.value.convertedAmount.compareTo(a.value.convertedAmount),
        );
    categoryStats = Map.fromEntries(sortedEntries);
  }

  Future<void> _generateChartData() async {
    chartData.clear();
    chartLabels.clear();
    if (filteredTransactions.isEmpty) return;

    Map<String, double> timeData = {};

    // Group transactions by time period (always convert to base currency)
    for (var transaction in filteredTransactions) {
      DateTime date = transaction.transactionDate;
      String dateKey;
      switch (currentIndex) {
        case 0: // Day - group by hour
          dateKey = '${date.hour.toString().padLeft(2, '0')}:00';
          break;
        case 1: // Week - group by day
          dateKey = DateFormat('EEE').format(date);
          break;
        case 2: // Month - group by day
          dateKey = '${date.day}';
          break;
        case 3: // Year - group by month
          dateKey = DateFormat('MMM').format(date);
          break;
        default:
          dateKey = '${date.day}';
      }

      double amount = transaction.amount;

      // Always convert to base currency for chart
      if (transaction.account.currency.code != baseCurrency) {
        amount = await Helper.convertAmount(
          transaction.amount,
          transaction.account.currency.code,
          baseCurrency,
        );
      }

      timeData[dateKey] = (timeData[dateKey] ?? 0) + amount;
    }

    // Convert to chart data points
    int index = 0;
    var sortedEntries = timeData.entries.toList();

    // Sort entries based on period type
    if (currentIndex == 2) {
      // Month sort by day number
      sortedEntries.sort(
        (a, b) => int.parse(a.key).compareTo(int.parse(b.key)),
      );
    } else if (currentIndex == 1) {
      // Week sort by day order
      List<String> dayOrder = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      sortedEntries.sort(
        (a, b) => dayOrder.indexOf(a.key).compareTo(dayOrder.indexOf(b.key)),
      );
    }

    for (var entry in sortedEntries) {
      chartData.add(FlSpot(index.toDouble(), entry.value));
      chartLabels[index.toString()] = entry.key;
      index++;
    }
  }

  double _getTotalAmount() {
    // Always use converted amounts for totals
    return categoryStats.values.fold(
      0.0,
      (sum, stats) => sum + stats.convertedAmount,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColours.bgColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 60,
              floating: false,
              backgroundColor: AppColours.bgColor,
              flexibleSpace: FlexibleSpaceBar(
                background: Column(
                  children: [
                    AppSpacing.vertical(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      // Period Title
                      child: Text(
                        Helper.getPeriodTitle(currentIndex),
                        style: AppStyles.title3(size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  AppSpacing.vertical(),
                  // Period Selection Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ...List.generate(4, (index) {
                          return GestureDetector(
                            onTap: () async {
                              if (isLoading) return;
                              setState(() {
                                currentIndex = index;
                                isLoading = true;
                              });
                              await _processTransactions();
                              setState(() => isLoading = false);
                            },
                            child: Container(
                              alignment: Alignment.center,
                              height: 40,
                              width: 90,
                              decoration: BoxDecoration(
                                color:
                                    currentIndex == index
                                        ? AppColours.primaryColour
                                        : AppColours.secondaryColourLight
                                            .withAlpha(20),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                days[index],
                                style: AppStyles.medium(
                                  color:
                                      currentIndex == index
                                          ? Colors.white
                                          : Colors.black,
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  AppSpacing.vertical(),
                  // Income/Expense Toggle
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Total Amount Display
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total ${selectedType == 'expense' ? 'Expenses' : 'Income'}',
                                style: AppStyles.regular1(
                                  color: AppColours.light20,
                                  size: 14,
                                ),
                              ),
                              Text(
                                Helper.formatCurrency(
                                  _getTotalAmount(),
                                  '\$',
                                  symbolPosition: 'before',
                                  compact: true,
                                ),
                                style: AppStyles.title3(
                                  size: 24,
                                  color:
                                      selectedType == 'expense'
                                          ? Colors.red.shade400
                                          : Colors.green.shade400,
                                ),
                              ),
                              if (currencyBreakdowns.length > 1)
                                Text(
                                  'All amounts in $baseCurrency',
                                  style: AppStyles.regular1(
                                    color: Colors.grey.shade600,
                                    size: 10,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // Type selector only
                        GestureDetector(
                          onTap: () async {
                            if (isLoading) return;
                            setState(() {
                              selectedType =
                                  selectedType == 'expense'
                                      ? 'income'
                                      : 'expense';
                              isLoading = true;
                            });
                            await _processTransactions();
                            setState(() => isLoading = false);
                          },
                          child: Container(
                            width: 120,
                            height: 40,
                            decoration: BoxDecoration(
                              color:
                                  selectedType == 'expense'
                                      ? Colors.red.shade50
                                      : Colors.green.shade50,
                              border: Border.all(
                                color:
                                    selectedType == 'expense'
                                        ? Colors.red.shade400
                                        : Colors.green.shade400,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  selectedType == 'expense'
                                      ? 'Expenses'
                                      : 'Income',
                                  style: AppStyles.regular1(
                                    color:
                                        selectedType == 'expense'
                                            ? Colors.red.shade400
                                            : Colors.green.shade400,
                                  ),
                                ),
                                Icon(
                                  selectedType == 'expense'
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward,
                                  color:
                                      selectedType == 'expense'
                                          ? Colors.red.shade400
                                          : Colors.green.shade400,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.vertical(),
                  // Currency Breakdown if multiple currencies (shows original amounts)
                  if (currencyBreakdowns.length > 1) _buildCurrencyBreakdown(),
                  // Loading
                  if (isLoading)
                    SizedBox(height: 200, child: Center(child: MyIndecator()))
                  // Error Message
                  else if (errorMessage != null)
                    _errorMessageState()
                  // Empty state
                  else if (chartData.isEmpty)
                    SizedBox(
                      height: 200,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bar_chart,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            AppSpacing.vertical(size: 8),
                            Text(
                              'No data for this period',
                              style: AppStyles.regular1(
                                color: Colors.grey.shade600,
                              ),
                            ),
                            AppSpacing.vertical(size: 4),
                            Text(
                              'Try selecting a different period or transaction type',
                              style: AppStyles.regular1(
                                color: Colors.grey.shade500,
                                size: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    _buildChart(),

                  // Top Spending Header
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedType == 'expense'
                              ? 'Top Spending'
                              : 'Top Income Sources',
                          style: AppStyles.semibold(),
                        ),
                        Text(
                          '${filteredTransactions.length} transaction${filteredTransactions.length != 1 ? 's' : ''}',
                          style: AppStyles.regular1(
                            color: AppColours.light20,
                            size: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Loading
            if (isLoading)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: MyIndecator(),
                  ),
                ),
              )
            // Error State
            else if (errorMessage != null)
              SliverToBoxAdapter(child: _errorMessageState())
            // Empty State
            else if (categoryStats.isEmpty)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No ${selectedType}s for this period',
                          style: AppStyles.semibold(
                            size: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Try selecting a different time period or add some transactions',
                          style: AppStyles.regular1(
                            color: Colors.grey.shade500,
                            size: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            // Category stats list (always shows base currency amounts)
            else
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    var stats = categoryStats.values.elementAt(index);
                    double displayAmount = stats.convertedAmount;
                    double percentage =
                        (_getTotalAmount() > 0)
                            ? (displayAmount / _getTotalAmount()) * 100
                            : 0;
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          AppRoutes.detailTransaction,
                          arguments: {
                            'category': stats.categoryName,
                            'type': selectedType,
                          },
                        );
                      },
                      child: Container(
                        // Removed margin here for clean grid spacing
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withAlpha(50),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: Color(
                                int.parse(stats.categoryColor),
                              ).withAlpha(50),
                              child: Icon(
                                Helper.transactionIcon[stats.categoryIcon] ??
                                    Icons.category,
                                color: Color(int.parse(stats.categoryColor)),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              stats.categoryName,
                              style: AppStyles.semibold(size: 14),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${percentage.toStringAsFixed(1)}% of total',
                              style: AppStyles.regular1(
                                color: Color(int.parse(stats.categoryColor)),
                                size: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 4),
                            Text(
                              Helper.formatCurrency(
                                stats.convertedAmount,
                                '\$',
                                compact: true,
                                symbolPosition: 'before',
                              ),
                              style: AppStyles.semibold(
                                color:
                                    selectedType == 'expense'
                                        ? Colors.red.shade400
                                        : Colors.green.shade400,
                                size: 14,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              '${stats.transactionCount} transaction${stats.transactionCount != 1 ? 's' : ''}',
                              style: AppStyles.regular1(
                                color: Colors.grey.shade600,
                                size: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }, childCount: categoryStats.length),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 0.9,
                  ),
                ),
              ),
            SliverToBoxAdapter(child: AppSpacing.vertical(size: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyBreakdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Currency Breakdown', style: AppStyles.semibold()),
              Text(
                'Original amounts',
                style: AppStyles.regular1(
                  color: Colors.grey.shade600,
                  size: 12,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 15),
            itemCount: currencyBreakdowns.length,
            itemBuilder: ((context, index) {
              var breakdown = currencyBreakdowns.values.elementAt(index);
              // Always show original amounts in currency breakdown
              double displayAmount = breakdown.originalAmount;
              String currency = breakdown.currency;
              return Container(
                width: 120,
                margin: EdgeInsets.only(right: 12),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          breakdown.currency,
                          style: AppStyles.medium(size: 12),
                        ),
                        if (breakdown.currency != baseCurrency)
                          Icon(
                            Icons.currency_exchange,
                            size: 10,
                            color: Colors.grey,
                          ),
                      ],
                    ),
                    AppSpacing.vertical(size: 4),
                    Text(
                      Helper.formatCurrency(
                        displayAmount,
                        currency,
                        compact: true,
                        symbolPosition: 'before',
                      ),
                      style: AppStyles.semibold(
                        size: 14,
                        color:
                            selectedType == 'expense'
                                ? Colors.red.shade400
                                : Colors.green.shade400,
                      ),
                    ),
                    Text(
                      '${breakdown.transactionCount} transaction${breakdown.transactionCount != 1 ? 's' : ''}',
                      style: AppStyles.regular1(
                        size: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
        AppSpacing.vertical(size: 30),
      ],
    );
  }

  Widget _buildChart() {
    return Container(
      height: 200,
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval:
                _getTotalAmount() > 0 ? _getTotalAmount() / 5 : 20,
            getDrawingHorizontalLine: (value) {
              return FlLine(color: Colors.grey.shade300, strokeWidth: 1);
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (double value, TitleMeta meta) {
                  String label = chartLabels[value.toInt().toString()] ?? '';
                  return Text(label, style: AppStyles.regular1(size: 10));
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: _getTotalAmount() > 0 ? _getTotalAmount() / 4 : 25,
                reservedSize: 40,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text(
                    Helper.formatCurrency(
                      value,
                      '\$',
                      compact: true,
                      symbolPosition: 'before',
                    ),
                    style: AppStyles.regular1(size: 8),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.shade300),
          ),
          minX: 0,
          maxX: chartData.isNotEmpty ? chartData.length.toDouble() - 1 : 0,
          minY: 0,
          maxY:
              chartData.isNotEmpty
                  ? chartData
                          .map((spot) => spot.y)
                          .reduce((a, b) => a > b ? a : b) *
                      1.2
                  : 100,
          lineBarsData: [
            LineChartBarData(
              spots: chartData,
              isCurved: true,
              gradient: LinearGradient(
                colors:
                    selectedType == 'expense'
                        ? [Colors.red.shade400, Colors.red.shade200]
                        : [Colors.green.shade400, Colors.green.shade200],
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color:
                        selectedType == 'expense'
                            ? Colors.red.shade400
                            : Colors.green.shade400,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors:
                      selectedType == 'expense'
                          ? [
                            Colors.red.shade400.withAlpha(50),
                            Colors.red.shade400.withAlpha(20),
                          ]
                          : [
                            Colors.green.shade400.withAlpha(50),
                            Colors.green.shade400.withAlpha(20),
                          ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorMessageState() {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
            AppSpacing.vertical(size: 8),
            Text(
              errorMessage!,
              style: AppStyles.regular1(color: Colors.red.shade600),
            ),
            AppSpacing.vertical(),
            TextButton(onPressed: _loadData, child: Text('Retry')),
          ],
        ),
      ),
    );
  }
}
