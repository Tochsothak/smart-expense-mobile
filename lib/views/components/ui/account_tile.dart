import 'package:flutter/material.dart';
import 'package:smart_expense/resources/app_colours.dart';
import 'package:smart_expense/resources/app_spacing.dart';
import 'package:smart_expense/resources/app_styles.dart';

class AccountTile extends StatefulWidget {
  final String accountName;
  final String currency;
  final String currentBalance;
  final String accountType;
  final VoidCallback onTap;
  const AccountTile({
    super.key,
    required this.accountName,
    required this.currency,
    required this.currentBalance,
    required this.accountType,
    required this.onTap,
  });

  @override
  State<AccountTile> createState() => _AccountTileState();
}

class _AccountTileState extends State<AccountTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.blue.shade300..withAlpha(90)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                Icons.account_balance_wallet,
                size: 50,
                color: AppColours.primaryColour,
              ),
              SizedBox(
                height: 30,
                child: VerticalDivider(color: Colors.grey.shade300),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.accountName, style: AppStyles.medium(size: 18)),
                  AppSpacing.vertical(size: 6),
                  Text(
                    widget.currency,
                    style: AppStyles.regular1(
                      color: AppColours.light20,
                      size: 12,
                    ),
                    overflow: TextOverflow.clip,
                    maxLines: 1,
                  ),
                ],
              ),
              Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.currentBalance,
                    style: AppStyles.medium(
                      color: Colors.blue.shade400,
                      size: 18,
                    ),
                  ),
                  AppSpacing.vertical(size: 6),
                  Text(
                    widget.accountType,
                    style: AppStyles.regular1(
                      color: AppColours.light20,
                      size: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
