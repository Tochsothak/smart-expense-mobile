import 'package:flutter/material.dart';
import 'package:smart_expense/resources/app_colours.dart';
import 'package:smart_expense/resources/app_spacing.dart';
import 'package:smart_expense/resources/app_styles.dart';

class ListTileComponent extends StatefulWidget {
  final Widget? leadingIcon;

  final String title;
  final String? subtitle;
  final String? trailing;
  final String? subTraiLing;
  final Color? trailingColor;
  final Color? backGroundColor;
  final Color? iconBackgroundColor;
  final Color? subTitleColor;
  final String? time;
  final Function() onTap;

  const ListTileComponent({
    super.key,
    this.leadingIcon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.subTraiLing,
    this.trailingColor,
    required this.onTap,

    this.backGroundColor,
    this.time,
    this.iconBackgroundColor,
    this.subTitleColor,
  });

  @override
  State<ListTileComponent> createState() => _ListTileComponentState();
}

class _ListTileComponentState extends State<ListTileComponent> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: widget.backGroundColor ?? Colors.grey.shade50,
            ),

            child: ListTile(
              onTap: widget.onTap,
              leading: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.iconBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: widget.leadingIcon,
              ),

              title: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: AppStyles.medium(),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  AppSpacing.vertical(size: 10),
                  Text(
                    widget.subtitle ?? '',
                    style: AppStyles.regular1(
                      color: widget.subTitleColor ?? AppColours.light20,
                      size: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),

              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.trailing ?? '',
                    style: AppStyles.medium(
                      color: widget.trailingColor ?? Colors.green,
                    ),
                  ),

                  Text(
                    widget.subTraiLing ?? '',
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
          ),
          // Positioned(
          //   right: 24,
          //   top: 30,
          //   child: Container(
          //     decoration: BoxDecoration(
          //       borderRadius: BorderRadius.circular(4),
          //       color: Colors.grey.shade200,
          //     ),
          //     child: Padding(
          //       padding: const EdgeInsets.all(1.5),
          //       child: Text(
          //         widget.time ?? '',
          //         style: AppStyles.regular1(size: 8, color: Colors.black),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
