import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:smart_expense/models/user.dart';
import 'package:smart_expense/resources/app_colours.dart';
import 'package:smart_expense/resources/app_route.dart';
import 'package:smart_expense/resources/app_spacing.dart';
import 'package:smart_expense/resources/app_strings.dart';
import 'package:smart_expense/resources/app_styles.dart';
import 'package:smart_expense/services/auth.dart';
import 'package:smart_expense/views/components/ui/list_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserModel? user;

  List monthly = [
    "This month",
    "Last month",
    "Last 3 months",
    "Last 6 months",
    "Last 12 months",
  ];

  String? selectedItem;

  @override
  void initState() {
    super.initState();

    _getUser();
  }

  Future<void> _getUser() async {
    user = await AuthService.get();
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
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: AppColours.primaryColourLight,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 6,
                          ),
                          child: Text(
                            'See all',
                            style: AppStyles.regular1(size: 14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return Slidable(
                  endActionPane: ActionPane(
                    motion: ScrollMotion(),
                    children: [
                      SlidableAction(
                        foregroundColor: Colors.red.shade400,
                        icon: Icons.delete,
                        label: 'Delete',
                        backgroundColor: Colors.red.shade50,

                        onPressed: (value) {},
                      ),

                      SlidableAction(
                        onPressed: (value) {},
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
                        arguments: 'income',
                      );
                    },
                    leadingIcon: Icons.fastfood,
                    iconColor: Colors.red,
                    title: 'Food And Drink',
                    subtitle: 'Dinner at resturant with family',
                    trailing: '\$50',
                    trailingColor: Colors.green,
                    subTraiLing: 'Today',
                  ),
                );
              }, childCount: 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _head() {
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
                        "\$ 2,955",
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
                                "\$ 10000",
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
                                "\$ 10000",
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
                    "Good Afternoon!",
                    style: AppStyles.medium(color: Colors.white),
                  ),
                  Text(
                    "Sothak",
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
