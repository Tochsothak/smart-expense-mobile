import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:smart_expense/controllers/transaction.dart';
import 'package:smart_expense/models/transaction.dart';
import 'package:smart_expense/resources/app_colours.dart';
import 'package:smart_expense/resources/app_route.dart';
import 'package:smart_expense/resources/app_spacing.dart';
import 'package:smart_expense/resources/app_strings.dart';
import 'package:smart_expense/resources/app_styles.dart';
import 'package:smart_expense/utills/helper.dart';
import 'package:smart_expense/views/components/ui/list_tile.dart';

class StatisticScreen extends StatefulWidget {
  const StatisticScreen({super.key});

  @override
  State<StatisticScreen> createState() => _StatisticScreenState();
}

class _StatisticScreenState extends State<StatisticScreen> {
  List<String> days = ['Day', 'Week', 'Month', 'Year'];
  int currentIndex = 2; // Default to Month

  List<TransactionModel> allTransactions = [];
  List<TransactionModel> filteredTransactions = [];
  Map<String, double> categorySpending = {};
  List<FlSpot> chartData = [];
  bool isLoading = true;
  String selectedType = 'expense'; // 'expense' or 'income'

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    setState(() => isLoading = true);

    final result = await TransactionController.load();
    if (result.isSuccess && result.results != null) {
      setState(() {
        allTransactions = result.results!;
        _filterTransactionsByPeriod();
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
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
        allTransactions.where((transaction) {
          DateTime transactionDate = transaction.transactionDate;
          return transactionDate.isAfter(
                startDate.subtract(Duration(days: 1)),
              ) &&
              transactionDate.isBefore(now.add(Duration(days: 1))) &&
              transaction.type == selectedType;
        }).toList();

    _calculateCategorySpending();
    _generateChartData();
  }

  _calculateCategorySpending() {
    categorySpending.clear();

    for (var transaction in filteredTransactions) {
      String categoryName = transaction.category.name;
      categorySpending[categoryName] =
          (categorySpending[categoryName] ?? 0) + transaction.amount;
    }

    // Sort by spending amount (descending)
    var sortedEntries =
        categorySpending.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    categorySpending = Map.fromEntries(sortedEntries);
  }

  _generateChartData() {
    chartData.clear();

    if (filteredTransactions.isEmpty) return;

    Map<String, double> dailyData = {};

    // Group transactions by date
    for (var transaction in filteredTransactions) {
      DateTime date = transaction.transactionDate;
      String dateKey;

      switch (currentIndex) {
        case 0: // Day - group by hour
          dateKey = '${date.hour}:00';
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

      dailyData[dateKey] = (dailyData[dateKey] ?? 0) + transaction.amount;
    }

    // Convert to chart data points
    int index = 0;
    dailyData.forEach((key, value) {
      chartData.add(FlSpot(index.toDouble(), value));
      index++;
    });
  }

  double _getTotalAmount() {
    return filteredTransactions.fold(
      0.0,
      (sum, transaction) => sum + transaction.amount,
    );
  }

  String _getPeriodTitle() {
    DateTime now = DateTime.now();

    switch (currentIndex) {
      case 0:
        return DateFormat('EEEE, MMM dd').format(now);
      case 1:
        DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        DateTime endOfWeek = startOfWeek.add(Duration(days: 6));
        return '${DateFormat('MMM dd').format(startOfWeek)} - ${DateFormat('MMM dd').format(endOfWeek)}';
      case 2:
        return DateFormat('MMMM yyyy').format(now);
      case 3:
        return DateFormat('yyyy').format(now);
      default:
        return DateFormat('MMMM yyyy').format(now);
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
              expandedHeight: 60,
              floating: false,
              backgroundColor: AppColours.bgColor,
              flexibleSpace: FlexibleSpaceBar(
                background:
                // Period Title
                Column(
                  children: [
                    AppSpacing.vertical(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        _getPeriodTitle(),
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
                            onTap: () {
                              setState(() {
                                currentIndex = index;
                                _filterTransactionsByPeriod();
                              });
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
                        Column(
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
                              '\$${_getTotalAmount().toStringAsFixed(2)}',
                              style: AppStyles.title3(
                                size: 24,
                                color:
                                    selectedType == 'expense'
                                        ? Colors.red.shade400
                                        : Colors.green.shade400,
                              ),
                            ),
                          ],
                        ),
                        // Type Selector
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedType =
                                  selectedType == 'expense'
                                      ? 'income'
                                      : 'expense';
                              _filterTransactionsByPeriod();
                            });
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
                  // Chart
                  if (isLoading)
                    Container(
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColours.primaryColour,
                        ),
                      ),
                    )
                  else if (chartData.isEmpty)
                    Container(
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
                            SizedBox(height: 8),
                            Text(
                              'No data for this period',
                              style: AppStyles.regular1(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    _buildChart(),
                  AppSpacing.vertical(),
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
                          '${filteredTransactions.length} transactions',
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
            // Top Spending List
            if (isLoading)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      color: AppColours.primaryColour,
                    ),
                  ),
                ),
              )
            else if (categorySpending.isEmpty)
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
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  var entry = categorySpending.entries.elementAt(index);
                  String categoryName = entry.key;
                  double amount = entry.value;

                  // Find a transaction from this category to get icon and color
                  var categoryTransaction = filteredTransactions.firstWhere(
                    (t) => t.category.name == categoryName,
                  );

                  // Calculate percentage of total
                  double percentage =
                      (_getTotalAmount() > 0)
                          ? (amount / _getTotalAmount()) * 100
                          : 0;

                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                    child: ListTileComponent(
                      leadingIcon: Icon(
                        Helper.transactionIcon[categoryTransaction
                                .category
                                .icon] ??
                            Icons.category,
                        color: Color(
                          int.parse(categoryTransaction.category.colourCode),
                        ),
                        size: 30,
                      ),
                      iconBackgroundColor: Color(
                        int.parse(categoryTransaction.category.colourCode),
                      ).withAlpha(50),
                      title: categoryName,
                      subtitle: '${percentage.toStringAsFixed(1)}% of total',
                      subTitleColor: Color(
                        int.parse(categoryTransaction.category.colourCode),
                      ),
                      trailing: '\$${amount.toStringAsFixed(2)}',
                      trailingColor:
                          selectedType == 'expense'
                              ? Colors.red.shade400
                              : Colors.green.shade400,
                      subTraiLing: _getTransactionCount(categoryName),
                      onTap: () {
                        // Navigate to category details or filter by category
                        Navigator.of(context).pushNamed(
                          AppRoutes.detailTransaction,
                          arguments: {
                            'category': categoryName,
                            'type': selectedType,
                          },
                        );
                      },
                    ),
                  );
                }, childCount: categorySpending.length),
              ),
          ],
        ),
      ),
    );
  }

  String _getTransactionCount(String categoryName) {
    int count =
        filteredTransactions
            .where((t) => t.category.name == categoryName)
            .length;
    return '$count transaction${count != 1 ? 's' : ''}';
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
            horizontalInterval: _getTotalAmount() / 5,
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
                  if (value.toInt() >= chartData.length) return Text('');

                  String label = '';
                  switch (currentIndex) {
                    case 0: // Day
                      label = '${value.toInt()}h';
                      break;
                    case 1: // Week
                      List<String> weekDays = [
                        'Mon',
                        'Tue',
                        'Wed',
                        'Thu',
                        'Fri',
                        'Sat',
                        'Sun',
                      ];
                      if (value.toInt() < weekDays.length) {
                        label = weekDays[value.toInt()];
                      }
                      break;
                    case 2: // Month
                      label = '${value.toInt() + 1}';
                      break;
                    case 3: // Year
                      List<String> months = [
                        'Jan',
                        'Feb',
                        'Mar',
                        'Apr',
                        'May',
                        'Jun',
                        'Jul',
                        'Aug',
                        'Sep',
                        'Oct',
                        'Nov',
                        'Dec',
                      ];
                      if (value.toInt() < months.length) {
                        label = months[value.toInt()];
                      }
                      break;
                  }

                  return Text(label, style: AppStyles.regular1(size: 10));
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: _getTotalAmount() / 4,
                reservedSize: 40,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text(
                    '\$${value.toInt()}',
                    style: AppStyles.regular1(size: 10),
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
          maxX: chartData.length.toDouble() - 1,
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
                            Colors.red.shade400.withOpacity(0.3),
                            Colors.red.shade400.withOpacity(0.1),
                          ]
                          : [
                            Colors.green.shade400.withOpacity(0.3),
                            Colors.green.shade400.withOpacity(0.1),
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
}
