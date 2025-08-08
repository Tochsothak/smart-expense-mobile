import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:smart_expense/resources/app_colours.dart';
import 'package:smart_expense/resources/app_spacing.dart';
import 'package:smart_expense/resources/app_styles.dart';

class ListTileComponent extends StatefulWidget {
  final IconData leadingIcon;

  final String title;
  final String? subtitle;
  final String? trailing;
  final String? subTraiLing;
  final Color? iconColor;
  final Color? trailingColor;
  final Color? backGroundColor;
  final Function() onTap;
  final Function()? onDelete;
  final Function()? onEdit;

  const ListTileComponent({
    super.key,
    required this.leadingIcon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.subTraiLing,
    this.iconColor,
    this.trailingColor,
    required this.onTap,
    this.onDelete,
    this.onEdit,
    this.backGroundColor,
  });

  @override
  State<ListTileComponent> createState() => _ListTileComponentState();
}

class _ListTileComponentState extends State<ListTileComponent> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 4),
      child: Slidable(
        endActionPane: ActionPane(
          motion: ScrollMotion(),
          children: [
            SlidableAction(
              foregroundColor: Colors.red.shade400,
              icon: Icons.delete,
              label: 'Delete',
              backgroundColor: Colors.red.shade50,

              onPressed: (value) => widget.onDelete,
            ),

            SlidableAction(
              onPressed: (value) => widget.onEdit,
              icon: Icons.edit,
              label: 'Edit',
              backgroundColor: Colors.blue.shade50,
              foregroundColor: Colors.blue.shade400,
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: widget.backGroundColor ?? Colors.grey.shade100,
          ),
          child: ListTile(
            onTap: widget.onTap,
            leading: Container(
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(width: 0.8, color: Colors.grey.shade500),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Icon(
                  widget.leadingIcon,
                  color: widget.iconColor ?? Colors.blue.shade400,
                  size: 30,
                ),
              ),
            ),

            title: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title, style: AppStyles.medium()),
                AppSpacing.vertical(size: 10),
                Text(
                  widget.subtitle ?? '',
                  style: AppStyles.regular1(
                    color: AppColours.light20,
                    size: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),

            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  widget.trailing ?? '',
                  style: AppStyles.medium(
                    color: widget.trailingColor ?? Colors.green,
                  ),
                ),
                AppSpacing.vertical(size: 10),
                Expanded(
                  child: Text(
                    widget.subTraiLing ?? '',
                    style: AppStyles.regular1(
                      color: AppColours.light20,
                      size: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
