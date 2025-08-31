import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smart_expense/controllers/transaction.dart';
import 'package:smart_expense/models/transaction.dart';
import 'package:smart_expense/models/transaction_attachment.dart';
import 'package:smart_expense/resources/app_colours.dart';
import 'package:smart_expense/resources/app_route.dart';
import 'package:smart_expense/resources/app_spacing.dart';
import 'package:smart_expense/resources/app_strings.dart';
import 'package:smart_expense/resources/app_styles.dart';
import 'package:smart_expense/utills/helper.dart';
import 'package:smart_expense/views/components/ui/app_bar.dart';
import 'package:smart_expense/views/components/ui/button.dart';
import 'package:smart_expense/views/components/ui/indecator.dart';

class DetailTransaction extends StatefulWidget {
  const DetailTransaction({super.key});

  @override
  State<DetailTransaction> createState() => _DetailTransactionState();
}

class _DetailTransactionState extends State<DetailTransaction> {
  String? type;
  TransactionModel? transaction;
  String? id;
  bool _isLoading = true;
  bool _isDeleting = false;
  bool _isDownloading = false;

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
    setState(() => _isLoading = true);

    try {
      final result = await TransactionController.get({'id': id});
      if (result!.isSuccess && result.results != null) {
        setState(() {
          transaction = result.results;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        Helper.snackBar(
          context,
          message: 'Failed to load transaction details',
          isSuccess: false,
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      Helper.snackBar(
        context,
        message: 'Error loading transaction: $e',
        isSuccess: false,
      );
    }
  }

  _handleDelete(String id) async {
    // Show confirmation dialog
    bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Transaction'),
          content: Text(
            'Are you sure you want to delete this transaction? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    setState(() => _isDeleting = true);

    try {
      final result = await TransactionController.delete({'id': id});

      setState(() => _isDeleting = false);

      if (!result.isSuccess) {
        Helper.snackBar(
          context,
          message: AppStrings.failToDeleteData.replaceAll(
            ':data',
            AppStrings.transaction,
          ),
          isSuccess: false,
        );
        return;
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
    } catch (e) {
      setState(() => _isDeleting = false);
      Helper.snackBar(
        context,
        message: 'Error deleting transaction: $e',
        isSuccess: false,
      );
    }
  }

  Future<void> _downloadAttachment(
    TransactionAttachmentModel attachment,
  ) async {
    setState(() => _isDownloading = true);

    try {
      print('=== DEBUGGING FILE DOWNLOAD ===');
      print('Transaction ID: ${transaction!.id}');
      print('Attachment ID: ${attachment.id}');
      print('File URL: ${attachment.fileUrl}');
      print('================================');

      // Try the download endpoint first (this will serve the file directly)
      String downloadUrl =
          'http://192.168.78.180:8000/api/transactions/${transaction!.id}/attachments/${attachment.id}/download';

      try {
        final Uri url = Uri.parse(downloadUrl);
        print('Download URL: $url');

        bool canLaunch = await canLaunchUrl(url);
        print('Can launch URL: $canLaunch');

        if (canLaunch) {
          if (attachment.isImage) {
            // For images, try in-app browser first
            await launchUrl(url, mode: LaunchMode.inAppBrowserView);
            Helper.snackBar(
              context,
              message: 'Image opened successfully',
              isSuccess: true,
            );
          } else {
            // For documents, open externally
            await launchUrl(url, mode: LaunchMode.externalApplication);
            Helper.snackBar(
              context,
              message: 'File opened successfully',
              isSuccess: true,
            );
          }
        } else {
          // Fallback: try the file URL from attachment
          if (attachment.fileUrl != null && attachment.fileUrl!.isNotEmpty) {
            final Uri fallbackUrl = Uri.parse(attachment.fileUrl!);
            await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
            Helper.snackBar(
              context,
              message: 'File opened with fallback URL',
              isSuccess: true,
            );
          } else {
            _showUrlDialog(downloadUrl, attachment.filename);
          }
        }
      } catch (e) {
        print('Error launching URL: $e');
        _showUrlDialog(downloadUrl, attachment.filename);
      }
    } catch (e) {
      print('Error in _downloadAttachment: $e');
      Helper.snackBar(
        context,
        message: 'Error accessing file: $e',
        isSuccess: false,
      );
    } finally {
      setState(() => _isDownloading = false);
    }
  }

  // Helper method to show URL dialog
  void _showUrlDialog(String url, String filename) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('File URL'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cannot open file automatically. You can access it using this URL:',
                ),
                SizedBox(height: 10),
                SelectableText(
                  url,
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
                SizedBox(height: 10),
                Text('File: $filename'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final Uri uri = Uri.parse(url);
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                },
                child: Text('Try Again'),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteAttachment(TransactionAttachmentModel attachment) async {
    // Show confirmation dialog
    bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Attachment'),
          content: Text(
            'Are you sure you want to delete "${attachment.filename}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    try {
      final result = await TransactionController.deleteAttachment(
        transaction!.id,
        attachment.id,
      );

      if (result.isSuccess) {
        // Remove attachment from local list
        setState(() {
          transaction!.removeAttachment(attachment.id);
        });

        Helper.snackBar(
          context,
          message: 'Attachment deleted successfully',
          isSuccess: true,
        );
      } else {
        Helper.snackBar(context, message: result.message, isSuccess: false);
      }
    } catch (e) {
      Helper.snackBar(
        context,
        message: 'Error deleting attachment: $e',
        isSuccess: false,
      );
    }
  }

  IconData _getAttachmentIcon(TransactionAttachmentModel attachment) {
    switch (attachment.fileExtension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'txt':
        return Icons.text_snippet;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getAttachmentColor(TransactionAttachmentModel attachment) {
    if (attachment.isImage) {
      return Colors.blue.shade600;
    } else if (attachment.isDocument) {
      return Colors.red.shade600;
    } else {
      return Colors.grey.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColours.bgColor,
      appBar: buildAppBar(
        context,
        AppStrings.detailTransaction,
        icon: _isDeleting ? null : Icons.delete,
        onTap:
            _isDeleting
                ? null
                : () {
                  _handleDelete(id!);
                },
        foregroundColor: Colors.white,
        backgroundColor:
            type == 'expense' ? Colors.red.shade400 : Colors.green.shade400,
      ),
      body:
          _isLoading
              ? Center(child: MyIndecator())
              : transaction == null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Transaction not found',
                      style: AppStyles.semibold(
                        size: 18,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextButton(
                      onPressed: () => _getTransaction(id!),
                      child: Text('Retry'),
                    ),
                  ],
                ),
              )
              : ListView(
                children: [
                  Column(
                    children: [
                      _head(),
                      Transform.translate(
                        offset: Offset(0, -40),
                        child: _main(),
                      ),
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
          // Description Section
          Text(
            AppStrings.description,
            style: AppStyles.regular1(color: AppColours.light20, size: 14),
          ),
          AppSpacing.vertical(size: 16),
          Text(transaction!.description, style: AppStyles.regular1(size: 20)),
          AppSpacing.vertical(size: 16),

          // Notes Section
          Text(
            AppStrings.note,
            style: AppStyles.regular1(color: AppColours.light20, size: 14),
          ),
          AppSpacing.vertical(size: 16),
          Text(
            transaction!.notes?.isNotEmpty == true
                ? transaction!.notes!
                : 'No notes added',
            style: AppStyles.regular1(
              size: 20,
              color:
                  transaction!.notes?.isNotEmpty == true
                      ? Colors.black
                      : Colors.grey.shade500,
            ),
          ),
          AppSpacing.vertical(size: 16),

          // Attachments Section
          Text(
            AppStrings.attachment,
            style: AppStyles.regular1(color: AppColours.light20, size: 14),
          ),
          AppSpacing.vertical(size: 16),

          // Attachments Display
          if (transaction!.hasAttachments)
            _buildAttachmentsSection()
          else
            _buildNoAttachmentsSection(),

          AppSpacing.vertical(),

          // Edit Button - FIXED
          ButtonComponent(
            label: AppStrings.edit,
            isLoading: _isDeleting,
            onPressed: () {
              if (!_isDeleting) {
                Navigator.pushNamed(
                  context,
                  AppRoutes.updateTransaction,
                  arguments: transaction,
                );
              }
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

  Widget _buildAttachmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Attachments count
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColours.primaryColour.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${transaction!.attachmentCount} attachment${transaction!.attachmentCount != 1 ? 's' : ''}',
            style: AppStyles.medium(color: AppColours.primaryColour, size: 12),
          ),
        ),
        AppSpacing.vertical(size: 12),

        // Attachments list
        ...transaction!.attachments!
            .map(
              (attachment) => Container(
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade100,
                      offset: Offset(0, 2),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // File icon
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getAttachmentColor(attachment).withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getAttachmentIcon(attachment),
                        color: _getAttachmentColor(attachment),
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 12),

                    // File details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            attachment.displayName,
                            style: AppStyles.medium(size: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                attachment.fileSizeFormatted,
                                style: AppStyles.regular1(
                                  color: Colors.grey.shade600,
                                  size: 12,
                                ),
                              ),
                              SizedBox(width: 8),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getAttachmentColor(
                                    attachment,
                                  ).withAlpha(20),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  attachment.fileExtension.toUpperCase(),
                                  style: AppStyles.regular1(
                                    color: _getAttachmentColor(attachment),
                                    size: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Action buttons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Download/View button
                        IconButton(
                          onPressed:
                              _isDownloading
                                  ? null
                                  : () => _downloadAttachment(attachment),
                          icon:
                              _isDownloading
                                  ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : Icon(
                                    attachment.isImage
                                        ? Icons.visibility
                                        : Icons.download,
                                    color: Colors.blue.shade600,
                                    size: 20,
                                  ),
                          tooltip: attachment.isImage ? 'View' : 'Download',
                        ),

                        // Delete button
                        IconButton(
                          onPressed: () => _deleteAttachment(attachment),
                          icon: Icon(
                            Icons.delete_outline,
                            color: Colors.red.shade600,
                            size: 20,
                          ),
                          tooltip: 'Delete',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ],
    );
  }

  Widget _buildNoAttachmentsSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.attach_file, size: 48, color: Colors.grey.shade400),
          SizedBox(height: 12),
          Text(
            'No attachments',
            style: AppStyles.medium(color: Colors.grey.shade600, size: 16),
          ),
          SizedBox(height: 4),
          Text(
            'No files attached to this transaction',
            style: AppStyles.regular1(color: Colors.grey.shade500, size: 12),
          ),
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
