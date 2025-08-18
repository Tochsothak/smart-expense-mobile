import 'package:flutter/material.dart';
import 'package:smart_expense/resources/app_colours.dart';
import 'package:smart_expense/resources/app_spacing.dart';
import 'package:smart_expense/resources/app_styles.dart';

class AccountTile extends StatefulWidget {
  final Widget? icon;
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
    required this.icon,
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
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade400.withAlpha(100),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: widget.icon,
              ),
              SizedBox(
                height: 30,
                child: VerticalDivider(color: Colors.grey.shade300),
              ),

              Expanded(
                flex: 50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.accountName,
                      style: AppStyles.medium(size: 18),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    AppSpacing.vertical(size: 6),
                    Text(
                      widget.currency,
                      style: AppStyles.regular1(
                        color: AppColours.light20,
                        size: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
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
