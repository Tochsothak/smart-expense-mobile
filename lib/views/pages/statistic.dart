import 'package:flutter/material.dart';
import 'package:smart_expense/data/top.dart';
import 'package:smart_expense/resources/app_colours.dart';
import 'package:smart_expense/resources/app_route.dart';
import 'package:smart_expense/resources/app_spacing.dart';
import 'package:smart_expense/resources/app_strings.dart';
import 'package:smart_expense/resources/app_styles.dart';
import 'package:smart_expense/views/components/ui/chart.dart';
import 'package:smart_expense/views/components/ui/list_tile.dart';

class StatisticScreen extends StatefulWidget {
  const StatisticScreen({super.key});

  @override
  State<StatisticScreen> createState() => _StatisticScreenState();
}

class _StatisticScreenState extends State<StatisticScreen> {
  List<String> days = ['Day', 'Week', 'Month', 'Year'];
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColours.bgColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  AppSpacing.vertical(size: 20),
                  AppSpacing.vertical(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ...List.generate(4, (index) {
                          return GestureDetector(
                            onTap: () => setState(() => currentIndex = index),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 120,
                          height: 40,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColours.light20,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),

                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                AppStrings.expense,
                                style: AppStyles.regular1(
                                  color: AppColours.light20,
                                ),
                              ),
                              Icon(
                                Icons.arrow_downward,
                                color: AppColours.light20,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.vertical(),
                  ChartComponent(),
                  AppSpacing.vertical(),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppStrings.topSpending,
                          style: AppStyles.semibold(),
                        ),
                        Icon(
                          Icons.swap_vert,
                          size: 25,
                          color: AppColours.light20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return ListTileComponent(
                  leadingIcon: Icons.restaurant,
                  title: "Food And Drink",
                  subtitle: "Have a drink at Cafe shop",
                  subTraiLing: 'Today',
                  trailing: "\$ 9",
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      AppRoutes.detailTransaction,
                      arguments: 'expense',
                    );
                  },
                );
              }, childCount: 20),
            ),
          ],
        ),
      ),
    );
  }
}
