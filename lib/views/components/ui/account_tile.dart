import 'package:flutter/material.dart';
import 'package:smart_expense/resources/app_colours.dart';
import 'package:smart_expense/resources/app_spacing.dart';
import 'package:smart_expense/resources/app_styles.dart';

class AccountTile extends StatefulWidget {
  final Widget? icon;
  final String? accountName;
  final String? currency;
  final String? currentBalance;
  final String? transactionCount;
  final String? income;
  final String? expense;
  final double? width;
  final double topSize;
  final double midSize;
  final double bottomSize;
  final VoidCallback? onTap;
  const AccountTile({
    super.key,
    this.accountName,
    this.currency,
    this.currentBalance,
    this.transactionCount,
    this.onTap,
    this.icon,
    this.income,
    this.expense,
    this.width,
    this.topSize = 12,
    this.midSize = 16,
    this.bottomSize = 10,
  });

  @override
  State<AccountTile> createState() => _AccountTileState();
}

class _AccountTileState extends State<AccountTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: widget.width ?? MediaQuery.of(context).size.width / 1 - 30,
        margin: EdgeInsets.only(right: 12),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColours.primaryColour,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  // Account Name
                  child: Text(
                    widget.accountName ?? 'Account Name',
                    style: AppStyles.regular1(
                      size: widget.topSize,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  // Currency Code
                  widget.currency ?? 'Currency Code',
                  style: AppStyles.regular1(
                    size: widget.topSize,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            AppSpacing.vertical(size: 8),

            // Account balance
            Text(
              widget.currentBalance ?? 'Account Balance',
              style: AppStyles.semibold(
                size: widget.midSize,
                color: Colors.white,
              ),
            ),
            AppSpacing.vertical(size: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Total Income
                Text(
                  widget.income ?? 'Total Income',
                  style: AppStyles.regular1(
                    size: widget.bottomSize,
                    color: Colors.green.shade400,
                  ),
                ),
                // Total Expense
                Text(
                  widget.expense ?? 'Total Expense',
                  style: AppStyles.regular1(
                    size: widget.bottomSize,
                    color: Colors.red.shade400,
                  ),
                ),
                AppSpacing.horizontal(size: 2),
                // Transactions Count
                Text(
                  widget.transactionCount ?? 'Transaction Count',
                  style: AppStyles.regular1(
                    size: widget.bottomSize,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
