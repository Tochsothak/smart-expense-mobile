import 'package:hive/hive.dart';
import 'package:smart_expense/models/account.dart';
import 'package:smart_expense/models/category.dart';
import 'package:smart_expense/models/transaction_attachment.dart';

part 'transaction.g.dart';

@HiveType(typeId: 6)
class TransactionModel {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String description;

  @HiveField(2)
  late String? notes;

  @HiveField(3)
  late double amount;

  @HiveField(4)
  late String formattedAmountText;

  @HiveField(5)
  late String type;

  @HiveField(6)
  late String formattedType;

  @HiveField(7)
  late DateTime transactionDate;

  @HiveField(8)
  late String? referenceNumber;

  @HiveField(9)
  int? active;

  @HiveField(10)
  late AccountModel account;

  @HiveField(11)
  late CategoryModel category;

  @HiveField(12)
  late String? createdAt;

  @HiveField(13)
  late String? updatedAt;

  @HiveField(14)
  List<TransactionAttachmentModel>? attachments;

  // Constructor
  TransactionModel({this.attachments});

  static String transactionBox = "transactions";

  static fromMap(Map<String, dynamic> transactions) {
    var transactionModel = TransactionModel();

    transactionModel.id = transactions['id'];
    transactionModel.description = transactions['description'];
    transactionModel.notes = transactions['notes'];
    transactionModel.amount = double.parse(transactions['amount'].toString());
    transactionModel.type = transactions['type'].toString();
    transactionModel.formattedType = transactions['formatted_type'];
    transactionModel.formattedAmountText =
        transactions['formatted_amount_text'];
    transactionModel.transactionDate = DateTime.parse(
      transactions['transaction_date'],
    );
    transactionModel.createdAt = transactions['created_at'];
    transactionModel.updatedAt = transactions['updated_at'];
    transactionModel.category = CategoryModel.fromMap(transactions['category']);
    transactionModel.account = AccountModel.fromMap(transactions['account']);

    transactionModel.referenceNumber = transactions['reference_number'];
    transactionModel.active = int.parse(transactions['active'].toString());

    // Handle attachments
    if (transactions['attachments'] != null) {
      transactionModel.attachments =
          (transactions['attachments'] as List)
              .map(
                (attachment) => TransactionAttachmentModel.fromMap(attachment),
              )
              .toList();
    } else {
      transactionModel.attachments = [];
    }
    return transactionModel;
  }

  // Helper methods for attachments
  bool get hasAttachments => attachments != null && attachments!.isNotEmpty;

  int get attachmentCount => attachments?.length ?? 0;

  List<TransactionAttachmentModel> get imageAttachments {
    if (attachments == null) return [];
    return attachments!.where((attachment) => attachment.isImage).toList();
  }

  List<TransactionAttachmentModel> get documentAttachments {
    if (attachments == null) return [];
    return attachments!.where((attachment) => attachment.isDocument).toList();
  }

  // Add attachment
  void addAttachment(TransactionAttachmentModel attachment) {
    attachments ??= [];
    attachments!.add(attachment);
  }

  // Remove attachment
  void removeAttachment(String attachmentId) {
    attachments?.removeWhere((attachment) => attachment.id == attachmentId);
  }

  // Get attachment by ID
  TransactionAttachmentModel? getAttachmentById(String attachmentId) {
    if (attachments == null) return null;
    try {
      return attachments!.firstWhere(
        (attachment) => attachment.id == attachmentId,
      );
    } catch (e) {
      return null;
    }
  }

  // Clear all attachments
  void clearAttachments() {
    attachments?.clear();
  }

  // Update attachment
  void updateAttachment(
    String attachmentId,
    TransactionAttachmentModel updatedAttachment,
  ) {
    if (attachments == null) return;

    final index = attachments!.indexWhere(
      (attachment) => attachment.id == attachmentId,
    );
    if (index != -1) {
      attachments![index] = updatedAttachment;
    }
  }

  bool isEqual(TransactionModel model) {
    return id == model.id;
  }

  @override
  String toString() => description;
}
