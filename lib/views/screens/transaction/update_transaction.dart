import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_expense/controllers/account.dart';
import 'package:smart_expense/controllers/category.dart';
import 'package:smart_expense/controllers/transaction.dart';
import 'package:smart_expense/models/account.dart';
import 'package:smart_expense/models/category.dart';
import 'package:smart_expense/models/transaction.dart';
import 'package:smart_expense/models/transaction_attachment.dart';
import 'package:smart_expense/resources/app_colours.dart';
import 'package:smart_expense/resources/app_route.dart';
import 'package:smart_expense/resources/app_spacing.dart';
import 'package:smart_expense/resources/app_strings.dart';
import 'package:smart_expense/resources/app_styles.dart';
import 'package:smart_expense/utills/bottom_sheet.dart';
import 'package:smart_expense/utills/helper.dart';
import 'package:smart_expense/views/components/form/select_input.dart';
import 'package:smart_expense/views/components/form/text_input.dart';
import 'package:smart_expense/views/components/ui/app_bar.dart';
import 'package:smart_expense/views/components/ui/button.dart';
import 'package:smart_expense/views/components/ui/type_toggle.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateTransaction extends StatefulWidget {
  const UpdateTransaction({super.key});

  @override
  State<UpdateTransaction> createState() => _UpdateTransactionState();
}

class _UpdateTransactionState extends State<UpdateTransaction> {
  String? transactionId;

  final _formKey = GlobalKey<FormState>();
  final _amountEditingController = TextEditingController();
  final _textEditingDescriptionController = TextEditingController();
  final _textEditingNoteController = TextEditingController();
  final _textEditingDateTimeController = TextEditingController();

  final _balanceFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  final _noteFocus = FocusNode();
  final _dateTimeFocus = FocusNode();

  TransactionModel? transaction;

  List<AccountModel> accounts = [];
  List<CategoryModel> categories = [];

  AccountModel? selectedAccount;
  CategoryModel? selectedCategory;

  // File upload variables
  List<File> newFiles = []; // New files to upload
  List<String> filesToDelete = []; // Existing files to delete
  List<TransactionAttachmentModel> existingAttachments =
      []; // Current attachments
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploading = false;

  List<BottomSheetItem> bottomSheetItem = [];

  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _amountEditingController.dispose();
    _textEditingDescriptionController.dispose();
    _textEditingNoteController.dispose();
    _textEditingDateTimeController.dispose();

    _balanceFocus.dispose();
    _descriptionFocus.dispose();
    _noteFocus.dispose();
    _dateTimeFocus.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)!.settings.arguments;
    if (transactionId == null) {
      if (arg != null && arg is TransactionModel) {
        transactionId = arg.id;
        transaction = arg;
        _getPreviousData();
        _loadAccount();
        _loadCategory();
        _initializeBottomSheetItems();
      }
    }
  }

  void _initializeBottomSheetItems() {
    bottomSheetItem = [
      BottomSheetItem(
        text: AppStrings.camera,
        icon: Icons.camera_alt,
        onTap: () => _handleCameraCapture(),
      ),
      BottomSheetItem(
        text: AppStrings.image,
        icon: Icons.image,
        onTap: () => _handleGallerySelection(),
      ),
      BottomSheetItem(
        text: AppStrings.document,
        icon: Icons.document_scanner,
        onTap: () => _handleDocumentSelection(),
      ),
    ];
  }

  _loadAccount() async {
    final result = await AccountController.load();
    if (result.isSuccess && result.results != null) {
      setState(() => accounts = result.results!);
    }
  }

  _loadCategory() async {
    final result = await CategoryController.load();
    if (result.isSuccess && result.results != null) {
      setState(() => categories = result.results!);
    }
  }

  _getPreviousData() {
    _amountEditingController.text = transaction?.amount.toString() ?? '';
    _textEditingDescriptionController.text = transaction?.description ?? '';
    _textEditingNoteController.text = transaction?.notes ?? '';
    _textEditingDateTimeController.text = Helper.dateFormat(
      transaction!.transactionDate,
    );
    selectedAccount = transaction?.account;
    selectedCategory = transaction?.category;

    // Set existing attachments
    existingAttachments = transaction?.attachments ?? [];
  }

  // Media handling methods
  Future<void> _handleCameraCapture() async {
    Navigator.pop(context); // Close bottom sheet

    // Check camera permission
    final cameraStatus = await Permission.camera.request();
    if (cameraStatus.isDenied) {
      _showPermissionDialog('Camera');
      return;
    }

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          newFiles.add(File(image.path));
        });
        Helper.snackBar(
          context,
          message: 'Photo captured successfully',
          isSuccess: true,
        );
      }
    } catch (e) {
      Helper.snackBar(
        context,
        message: 'Failed to capture photo: $e',
        isSuccess: false,
      );
    }
  }

  Future<void> _handleGallerySelection() async {
    Navigator.pop(context); // Close bottom sheet

    // Check photo permission
    final photoStatus = await Permission.storage.request();
    if (photoStatus.isDenied) {
      _showPermissionDialog('Photos');
      return;
    }

    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        setState(() {
          newFiles.addAll(images.map((image) => File(image.path)));
        });
        Helper.snackBar(
          context,
          message: '${images.length} image(s) selected',
          isSuccess: true,
        );
      }
    } catch (e) {
      Helper.snackBar(
        context,
        message: 'Failed to select images: $e',
        isSuccess: false,
      );
    }
  }

  Future<void> _handleDocumentSelection() async {
    Navigator.pop(context); // Close bottom sheet

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png'],
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          newFiles.addAll(result.paths.map((path) => File(path!)).toList());
        });
        Helper.snackBar(
          context,
          message: '${result.files.length} document(s) selected',
          isSuccess: true,
        );
      }
    } catch (e) {
      Helper.snackBar(
        context,
        message: 'Failed to select documents: $e',
        isSuccess: false,
      );
    }
  }

  void _showPermissionDialog(String permissionType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permission Required'),
          content: Text(
            '$permissionType permission is required to upload files. Please enable it in app settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                openAppSettings();
              },
              child: Text('Settings'),
            ),
          ],
        );
      },
    );
  }

  void _removeNewFile(int index) {
    setState(() {
      newFiles.removeAt(index);
    });
    Helper.snackBar(context, message: 'File removed', isSuccess: true);
  }

  void _removeExistingFile(TransactionAttachmentModel attachment) {
    setState(() {
      existingAttachments.remove(attachment);
      filesToDelete.add(attachment.id);
    });
    Helper.snackBar(
      context,
      message: 'File marked for deletion',
      isSuccess: true,
    );
  }

  String _getFileDisplayName(File file) {
    String fileName = file.path.split('/').last;
    if (fileName.length > 20) {
      return '${fileName.substring(0, 17)}...';
    }
    return fileName;
  }

  IconData _getFileIcon(File file) {
    String extension = file.path.split('.').last.toLowerCase();
    switch (extension) {
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
        return Icons.image;
      default:
        return Icons.insert_drive_file;
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
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColours.bgColor,
        appBar: buildAppBar(
          context,
          transaction?.type == 'expense'
              ? AppStrings.updateExpense
              : AppStrings.updateIncome,
          backgroundColor:
              transaction?.type == 'expense'
                  ? Colors.red.shade400
                  : Colors.green.shade400,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _balanceForm(),
                Transform.translate(
                  offset: Offset(0, -105),
                  child: _detailForm(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container _detailForm() {
    bool hasFiles = newFiles.isNotEmpty || existingAttachments.isNotEmpty;

    return Container(
      width: MediaQuery.of(context).size.width / 1.1,
      // Dynamic height based on files
      height: hasFiles ? 950 : 750,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 0.1),
            blurRadius: 5,
            spreadRadius: 0.1,
            color: AppColours.light20,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            AppSpacing.vertical(),
            TypeToggle(
              onTap: () {
                if (transaction?.type == 'expense') {
                  setState(() => transaction?.type = 'income');
                } else if (transaction?.type == 'income') {
                  setState(() => transaction?.type = 'expense');
                }
              },
              expenseBackgroundColor:
                  transaction?.type == 'expense'
                      ? Colors.red.shade400
                      : Colors.transparent,
              incomeBackgroundColor:
                  transaction?.type == 'income'
                      ? Colors.green.shade400
                      : Colors.transparent,
              expenseTextStyle: AppStyles.medium(
                color:
                    transaction?.type == 'expense'
                        ? Colors.white
                        : AppColours.light20,
                size: transaction?.type == 'expense' ? 16 : 12,
              ),
              incomeTextStyle: AppStyles.medium(
                color:
                    transaction?.type == 'income'
                        ? Colors.white
                        : AppColours.light20,
                size: transaction?.type == 'income' ? 16 : 12,
              ),
            ),
            AppSpacing.vertical(),
            SelectInputComponent(
              isRequired: true,
              isEnabled: !_isLoading,
              label: AppStrings.wallet,
              showSearchBox: true,
              searchBoxLabel: AppStrings.searchAccount,
              items: accounts,
              selectedItem: selectedAccount,
              compareFn: (item1, item2) => item1.isEqual(item2),
              onChanged: (AccountModel? value) {
                setState(() => selectedAccount = value);
              },
            ),
            AppSpacing.vertical(),
            SelectInputComponent(
              isRequired: true,
              isEnabled: !_isLoading,
              showSearchBox: true,
              searchBoxLabel: AppStrings.searchCategory,
              label: AppStrings.category,
              items: categories,
              selectedItem: selectedCategory,
              compareFn: (item1, item2) => item1.isEqual(item2),
              onChanged: (CategoryModel? value) {
                setState(() => selectedCategory = value);
              },
            ),
            AppSpacing.vertical(),
            TextInputComponent(
              isRequired: true,
              isEnabled: !_isLoading,
              label: AppStrings.description,
              textEditingController: _textEditingDescriptionController,
              focusNode: _descriptionFocus,
              textInputAction: TextInputAction.next,
              textInputType: TextInputType.text,
            ),
            AppSpacing.vertical(),
            TextInputComponent(
              isEnabled: !_isLoading,
              label: AppStrings.noteOptional,
              textEditingController: _textEditingNoteController,
              focusNode: _noteFocus,
              textInputAction: TextInputAction.next,
              textInputType: TextInputType.text,
            ),
            AppSpacing.vertical(),
            TextInputComponent(
              isEnabled: !_isLoading,
              label: AppStrings.date,
              textEditingController: _textEditingDateTimeController,
              focusNode: _dateTimeFocus,
              textInputAction: TextInputAction.done,
              textInputType: TextInputType.datetime,
              readOnly: true,
              onTap: _selectDate,
              prefixIcon: Icon(Icons.date_range, color: AppColours.light20),
            ),
            AppSpacing.vertical(),
            // File upload section
            GestureDetector(
              onTap: () {
                _showModalBottomSheet();
              },
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(width: 0.5, color: AppColours.light20),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.attachment, size: 24, color: AppColours.light20),
                    AppSpacing.horizontal(size: 6),
                    Text(
                      _getAttachmentText(),
                      style: AppStyles.regular1(
                        color:
                            hasFiles
                                ? AppColours.primaryColour
                                : AppColours.light20,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Files display section
            if (hasFiles) ...[AppSpacing.vertical(), _buildFilesSection()],

            Spacer(),

            ButtonComponent(
              isLoading: _isLoading || _isUploading,
              label: AppStrings.continueText,
              type:
                  transaction?.type == 'expense'
                      ? ButtonType.expense
                      : ButtonType.income,
              onPressed: () {
                _isLoading || _isUploading
                    ? null
                    : _handleSubmit(transaction!.id);
              },
            ),
            AppSpacing.vertical(),
          ],
        ),
      ),
    );
  }

  String _getAttachmentText() {
    int totalFiles = existingAttachments.length + newFiles.length;
    if (totalFiles == 0) {
      return AppStrings.addAttachment;
    } else {
      return '$totalFiles file(s) attached';
    }
  }

  Widget _buildFilesSection() {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Attachments (${existingAttachments.length + newFiles.length})',
                  style: AppStyles.medium(size: 14),
                ),
                if (existingAttachments.isNotEmpty || newFiles.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        // Mark all existing files for deletion
                        filesToDelete.addAll(
                          existingAttachments.map(
                            (attachment) => attachment.id,
                          ),
                        );
                        existingAttachments.clear();
                        newFiles.clear();
                      });
                    },
                    child: Text(
                      'Clear All',
                      style: AppStyles.regular1(
                        color: Colors.red.shade400,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 12),
              children: [
                // Existing attachments
                ...existingAttachments
                    .map(
                      (attachment) => Container(
                        margin: EdgeInsets.only(bottom: 8),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _getAttachmentIcon(attachment),
                              color: Colors.blue.shade600,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    attachment.shortDisplayName,
                                    style: AppStyles.medium(size: 12),
                                  ),
                                  Text(
                                    attachment.fileSizeFormatted,
                                    style: AppStyles.regular1(
                                      color: Colors.grey.shade600,
                                      size: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Download button
                                IconButton(
                                  onPressed:
                                      () => _downloadAttachment(attachment),
                                  icon: Icon(
                                    Icons.download,
                                    color: Colors.green.shade400,
                                    size: 16,
                                  ),
                                  constraints: BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                                // Delete button
                                IconButton(
                                  onPressed:
                                      () => _removeExistingFile(attachment),
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.red.shade400,
                                    size: 16,
                                  ),
                                  constraints: BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),

                // New files
                ...newFiles.asMap().entries.map((entry) {
                  int index = entry.key;
                  File file = entry.value;

                  return Container(
                    margin: EdgeInsets.only(bottom: 8),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getFileIcon(file),
                          color: Colors.green.shade600,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getFileDisplayName(file),
                                style: AppStyles.medium(size: 12),
                              ),
                              Text(
                                '${(file.lengthSync() / 1024).toStringAsFixed(1)} KB',
                                style: AppStyles.regular1(
                                  color: Colors.grey.shade600,
                                  size: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // New file indicator
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'NEW',
                                style: AppStyles.regular1(
                                  color: Colors.green.shade700,
                                  size: 8,
                                ),
                              ),
                            ),
                            SizedBox(width: 4),
                            // Delete button
                            IconButton(
                              onPressed: () => _removeNewFile(index),
                              icon: Icon(
                                Icons.close,
                                color: Colors.red.shade400,
                                size: 16,
                              ),
                              constraints: BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }

  void _downloadAttachment(TransactionAttachmentModel attachment) async {
    setState(() => _isUploading = true);

    try {
      // Skip the API call and directly try to open the file URL
      String? fileUrl;

      // First try the direct file URL from attachment
      if (attachment.fileUrl != null && attachment.fileUrl!.isNotEmpty) {
        fileUrl = attachment.fileUrl!;
        print('Using direct file URL: $fileUrl');
      } else {
        // Construct the download URL directly
        fileUrl =
            'http://192.168.78.180:8000/api/transactions/${transaction!.id}/attachments/${attachment.id}/download';
        print('Using constructed download URL: $fileUrl');
      }

      if (fileUrl != null) {
        try {
          final Uri url = Uri.parse(fileUrl);
          print('Parsed URL: $url');

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
            _showUrlDialog(fileUrl, attachment.filename);
          }
        } catch (parseError) {
          print('Error parsing/launching URL: $parseError');
          _showUrlDialog(fileUrl, attachment.filename);
        }
      } else {
        Helper.snackBar(
          context,
          message: 'No file URL available',
          isSuccess: false,
        );
      }
    } catch (e) {
      print('Error in _downloadAttachment: $e');
      Helper.snackBar(
        context,
        message: 'Error accessing file: $e',
        isSuccess: false,
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  // Add this helper method to show URL dialog
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

  Column _balanceForm() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.width / 1.5,
          decoration: BoxDecoration(
            color:
                transaction?.type == 'expense'
                    ? Colors.red.shade400
                    : Colors.green.shade400,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSpacing.vertical(size: 20),
                Text(
                  AppStrings.amount,
                  style: AppStyles.semibold(color: Colors.white.withAlpha(200)),
                ),
                Row(
                  children: [
                    Text(
                      selectedAccount?.currency.code ?? '',
                      style: AppStyles.semibold(color: Colors.white, size: 48),
                    ),
                    AppSpacing.horizontal(size: 4),
                    Expanded(
                      child: TextFormField(
                        enabled: !_isLoading,
                        controller: _amountEditingController,
                        focusNode: _balanceFocus,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: AppStyles.semibold(
                          size: 48,
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          errorStyle: TextStyle(color: Colors.white),
                        ),
                        cursorColor: Colors.white,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'(^\d*[.,]?\d{0,3})'),
                          ),
                        ],
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppStrings.inputIsRequired.replaceAll(
                              ":input",
                              AppStrings.amount,
                            );
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future _selectDate() async {
    DateTime? pickDate = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );
    if (pickDate != null) {
      _textEditingDateTimeController.text = Helper.dateFormat(pickDate);
    }
    return pickDate;
  }

  _showModalBottomSheet() {
    return showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            height: 190,
            decoration: BoxDecoration(
              color:
                  transaction?.type == 'expense'
                      ? Colors.red.shade50
                      : Colors.green.shade50,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Column(
                children: [
                  Text(
                    "Select attachment type",
                    style: AppStyles.medium(size: 18),
                  ),
                  AppSpacing.vertical(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ...bottomSheetItem.map((b) {
                        return GestureDetector(
                          onTap: b.onTap,
                          child: Container(
                            height: 100,
                            width: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    b.icon,
                                    color:
                                        transaction?.type == 'expense'
                                            ? Colors.red.shade400
                                            : Colors.green.shade400,
                                    size: 50,
                                  ),
                                  Text(
                                    b.text,
                                    style: AppStyles.medium(
                                      color:
                                          transaction?.type == 'expense'
                                              ? Colors.red.shade400
                                              : Colors.green.shade400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  _handleSubmit(String id) async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      Helper.snackBar(
        context,
        message: "Please complete the form",
        isSuccess: false,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Use the new updateWithFiles method
      final result = await TransactionController.updateWithFiles(
        {'id': id},
        selectedCategory?.id ?? transaction!.category.id,
        selectedAccount?.id ?? transaction!.account.id,
        transaction?.type ?? transaction!.type,
        _amountEditingController.text.isNotEmpty
            ? Helper.parseAmount(_amountEditingController.text.trim())
            : transaction!.amount,
        _textEditingDescriptionController.text.isNotEmpty
            ? _textEditingDescriptionController.text.trim()
            : transaction!.description,
        _textEditingNoteController.text.trim(),
        _textEditingDateTimeController.text.trim(),
        1,
        newFiles, // New files to upload
        filesToDelete, // Files to delete
      );

      setState(() => _isLoading = false);

      if (!result.isSuccess) {
        Helper.snackBar(context, message: result.message, isSuccess: false);
        return;
      }

      Helper.snackBar(
        context,
        isSuccess: true,
        message: AppStrings.dataUpdatedSuccess.replaceAll(
          ":data",
          AppStrings.transaction,
        ),
      );

      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.bottomNavigationBar,
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      setState(() => _isLoading = false);
      Helper.snackBar(
        context,
        message: "An error occurred: $e",
        isSuccess: false,
      );
    }
  }
}
