import 'package:flutter/material.dart';
import 'package:smart_expense/resources/app_colours.dart';
import 'package:smart_expense/resources/app_spacing.dart';
import 'package:smart_expense/resources/app_strings.dart';
import 'package:smart_expense/resources/app_styles.dart';
import 'package:smart_expense/utills/helper.dart';
import 'package:smart_expense/views/components/ui/app_bar.dart';
import 'package:smart_expense/views/components/ui/button.dart';

class DetailTransaction extends StatefulWidget {
  const DetailTransaction({super.key});

  @override
  State<DetailTransaction> createState() => _DetailTransactionState();
}

class _DetailTransactionState extends State<DetailTransaction> {
  String? type;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final arg = ModalRoute.of(context)!.settings.arguments;
    type = arg as String;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        context,
        AppStrings.detailTransaction,
        icon: Icons.delete,
        onTap: () {
          Helper.snackBar(
            context,
            message: "Cambodia want peace",
            isSuccess: true,
          );
        },
        foregroundColor: Colors.white,
        backgroundColor:
            type == 'expense' ? Colors.red.shade400 : Colors.green.shade400,
      ),
      body: ListView(
        children: [
          Column(
            children: [
              _head(),
              Transform.translate(offset: Offset(0, -20), child: _main()),
            ],
          ),
          _body(),
        ],
      ),
    );
  }

  Widget _body() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.description,
            style: AppStyles.regular1(color: AppColours.light20, size: 14),
          ),
          AppSpacing.vertical(size: 16),
          Text(
            "Grab a cup of coffee at bjabbvkanvk;annvnk;a  cml  cm ;lfnnçxlz  c,a. /.,jfblaclka ckm clmlm.jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj",
            style: AppStyles.regular1(size: 20),
          ),
          AppSpacing.vertical(size: 16),
          Text(
            AppStrings.attachment,
            style: AppStyles.regular1(color: AppColours.light20, size: 14),
          ),
          AppSpacing.vertical(size: 16),
          Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(width: 0.5, color: AppColours.light20),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset("assets/images/email.png", width: 200),
            ),
          ),
          AppSpacing.vertical(),
          ButtonComponent(
            label: AppStrings.edit,
            onPressed: () {},
            type: ButtonType.income,
          ),
          AppSpacing.vertical(size: 48),
        ],
      ),
    );
  }

  Container _main() {
    return Container(
      width: MediaQuery.of(context).size.width / 1.03,
      height: MediaQuery.of(context).size.height / 9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade400,
            offset: Offset(0, 0.2),
            spreadRadius: 0.2,
            blurRadius: 0.2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Type",
                  style: AppStyles.medium(color: AppColours.light20, size: 14),
                ),
                Text(
                  type == 'expense' ? AppStrings.expense : AppStrings.income,
                  style: AppStyles.regular1(),
                ),
              ],
            ),
            SizedBox(
              height: 50,
              child: VerticalDivider(color: Colors.grey.shade400),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Category",
                  style: AppStyles.medium(color: AppColours.light20, size: 14),
                ),
                Text("Food And Drink", style: AppStyles.regular1()),
              ],
            ),
            SizedBox(
              height: 50,
              child: VerticalDivider(color: Colors.grey.shade400),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Wallet",
                  style: AppStyles.medium(color: AppColours.light20, size: 14),
                ),
                Text("Personal", style: AppStyles.regular1()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Container _head() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 4,
      decoration: BoxDecoration(
        color: type == 'expense' ? Colors.red.shade400 : Colors.green.shade400,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          AppSpacing.vertical(),
          Text(AppStrings.amount, style: AppStyles.medium(color: Colors.white)),
          Row(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    "\$ 50",
                    style: AppStyles.titleX(color: Colors.white),
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ),
          Text(
            DateTime.now().toString(),
            style: AppStyles.medium(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
