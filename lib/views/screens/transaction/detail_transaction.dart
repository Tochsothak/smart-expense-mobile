import 'package:flutter/material.dart';
import 'package:smart_expense/controllers/transaction.dart';
import 'package:smart_expense/models/transaction.dart';
import 'package:smart_expense/resources/app_colours.dart';
import 'package:smart_expense/resources/app_route.dart';
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
  TransactionModel? transaction;
  String? id;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final arg =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    type = arg['type'] as String;
    id = arg['id'] as String;
    _getTransaction(id!);
  }

  _getTransaction(String id) async {
    final result = await TransactionController.get({'id': id});
    if (result!.isSuccess && result.results != null) {
      setState(() {
        transaction = result.results;
      });
    }
  }

  _handleDelete(String id) async {
    final result = await TransactionController.delete({'id': id});
    if (!result.isSuccess) {
      Helper.snackBar(
        context,
        message: AppStrings.failToDeleteData.replaceAll(
          ':data',
          AppStrings.transaction,
        ),
        isSuccess: false,
      );
    }
    Helper.snackBar(
      context,
      message: AppStrings.dataDeleteSuccess.replaceAll(
        ':data',
        AppStrings.transaction,
      ),
      isSuccess: true,
    );

    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.bottomNavigationBar,
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        context,
        AppStrings.detailTransaction,
        icon: Icons.delete,
        onTap: () {
          _handleDelete(id!);
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
              Transform.translate(offset: Offset(0, -40), child: _main()),
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
          Text(transaction!.description, style: AppStyles.regular1(size: 20)),
          AppSpacing.vertical(size: 16),
          Text(
            AppStrings.note,
            style: AppStyles.regular1(color: AppColours.light20, size: 14),
          ),
          AppSpacing.vertical(size: 16),
          Text(transaction!.notes ?? '', style: AppStyles.regular1(size: 20)),
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
              child: Image.asset("assets/images/logo.jpg", width: 200),
            ),
          ),
          AppSpacing.vertical(),
          ButtonComponent(
            label: AppStrings.edit,
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.updateTransaction,
                arguments: transaction as TransactionModel,
              );
            },
            type:
                transaction!.type == 'income'
                    ? ButtonType.income
                    : ButtonType.expense,
          ),
          AppSpacing.vertical(size: 48),
        ],
      ),
    );
  }

  Container _main() {
    return Container(
      padding: EdgeInsets.only(top: 15, left: 8, bottom: 8, right: 8),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade400,
            offset: Offset(0, 0.2),
            spreadRadius: 0.2,
            blurRadius: 0.2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _middle(
              type == 'income' ? Colors.green.shade400 : Colors.red.shade400,
              type == 'income'
                  ? Colors.green.shade400.withAlpha(50)
                  : Colors.red.shade400.withAlpha(50),

              Icon(
                type == 'income' ? Icons.arrow_downward : Icons.arrow_upward,
                size: 20,
                color:
                    type == 'expense'
                        ? Colors.red.shade400
                        : Colors.green.shade400,
              ),
              AppStrings.type,
              type == 'income' ? AppStrings.income : AppStrings.expense,
              type == 'expense'
                  ? Colors.red.shade400.withAlpha(50)
                  : Colors.green.shade400.withAlpha(50),
            ),
          ),
          SizedBox(
            height: 100,
            child: VerticalDivider(color: Colors.grey.withAlpha(50)),
          ),
          Expanded(
            child: _middle(
              Color(int.parse(transaction!.category.colourCode)),
              Color(int.parse(transaction!.category.colourCode)).withAlpha(50),

              Icon(
                Helper.transactionIcon[transaction!.category.icon],
                size: 20,
                color: Color(int.parse(transaction!.category.colourCode)),
              ),
              AppStrings.category,
              transaction!.category.name,
              Color(int.parse(transaction!.category.colourCode)).withAlpha(50),
            ),
          ),
          SizedBox(
            height: 100,
            child: VerticalDivider(color: Colors.grey.withAlpha(50)),
          ),
          Expanded(
            child: _middle(
              type == 'income' ? Colors.green.shade400 : Colors.red.shade400,
              type == 'income'
                  ? Colors.green.shade400.withAlpha(50)
                  : Colors.red.shade400.withAlpha(50),

              Icon(
                Helper.accountTypeIcons[transaction!.account.accountType.code],
                size: 20,
                color: Colors.blue.shade400,
              ),
              AppStrings.account,
              transaction!.account.name,
              Colors.blue.withAlpha(50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _middle(
    Color color,
    Color backgroundColor,
    Widget icon,
    String title,
    String content,
    Color? iconBackgroundColor,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: iconBackgroundColor ?? Colors.blue.shade400,
                borderRadius: BorderRadius.circular(8),
              ),
              child: icon,
            ),
            AppSpacing.horizontal(size: 12),
            Text(
              title,
              style: AppStyles.medium(color: AppColours.light20, size: 14),
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
          ],
        ),
        AppSpacing.vertical(size: 16),
        Text(
          content,
          style: AppStyles.semibold(size: 14),
          overflow: TextOverflow.ellipsis,
          maxLines: 5,
          textAlign: TextAlign.start,
        ),
      ],
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
                    type == 'income'
                        ? transaction!.formattedAmountText
                        : "- ${transaction!.formattedAmountText}",
                    style: AppStyles.titleX(color: Colors.white, size: 48),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ),
          Text(
            " ${Helper.getFormattedDate(transaction!.transactionDate.toString())} (${Helper.timeFormat(transaction!.createdAt.toString())})",

            style: AppStyles.medium(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
