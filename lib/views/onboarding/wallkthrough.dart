import 'package:flutter/material.dart';
import 'package:smart_expense/models/slide.dart';
import 'package:smart_expense/resources/app_colours.dart';
import 'package:smart_expense/resources/app_route.dart';
import 'package:smart_expense/resources/app_spacing.dart';
import 'package:smart_expense/resources/app_strings.dart';
import 'package:smart_expense/resources/app_styles.dart';
import 'package:smart_expense/views/components/ui/button.dart';

class WalkThroughScreen extends StatefulWidget {
  const WalkThroughScreen({super.key});

  @override
  State<WalkThroughScreen> createState() => _WalkThroughScreenState();
}

class _WalkThroughScreenState extends State<WalkThroughScreen> {
  PageController pageController = PageController();

  List<SlideModel> slides = [
    SlideModel(
      AppStrings.walkThroughTitle1,
      AppStrings.walkThroughDescription1,
      "assets/images/walkthrough1.png",
    ),
    SlideModel(
      AppStrings.walkThroughTitle2,
      AppStrings.walkThroughDescription2,
      "assets/images/walkthrough2.png",
    ),
    SlideModel(
      AppStrings.walkThroughTitle3,
      AppStrings.walkThroughDescription3,
      "assets/images/walkthrough3.png",
    ),
  ];

  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColours.bgColor,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: pages()),
            AppSpacing.vertical(),
            indicator(),
            Padding(padding: const EdgeInsets.all(24), child: buttons()),
            AppSpacing.vertical(),
          ],
        ),
      ),
    );
  }

  Widget indicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (int i = 0; i < slides.length; i++) ...[
          InkWell(
            onTap: () {
              if (i != currentPage) {
                pageController.animateToPage(
                  i,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              }
            },
            child: Icon(
              Icons.circle_rounded,
              size: currentPage == i ? 16 : 8,
              color:
                  currentPage == i
                      ? AppColours.primaryColour
                      : AppColours.primaryColourLight,
            ),
          ),
          if (i < slides.length - 1) AppSpacing.horizontal(size: 8),
        ],
      ],
    );
  }

  Widget buttons() {
    return Column(
      children: [
        AppSpacing.vertical(size: 16),
        ButtonComponent(
          label: AppStrings.signUp,
          type: ButtonType.primary,
          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.signup),
        ),
        AppSpacing.vertical(size: 16),
        ButtonComponent(
          label: AppStrings.login,
          type: ButtonType.secondary,
          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.login),
        ),
      ],
    );
  }

  Widget pages() {
    return PageView.builder(
      itemBuilder: (context, index) {
        return ListView(
          padding: EdgeInsets.all(24),
          shrinkWrap: true,
          children: [
            Center(
              child: Image.asset(
                slides[index].image,
                width: MediaQuery.of(context).size.width / 1.3,
              ),
            ),
            AppSpacing.vertical(),
            Text(
              slides[index].title,
              style: AppStyles.title1(),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vertical(),
            Text(
              slides[index].description,
              style: AppStyles.regular1(
                color: AppColours.light20,
                weight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
      controller: pageController,
      itemCount: slides.length,
      onPageChanged: (index) => setState(() => currentPage = index),
    );
  }
}
