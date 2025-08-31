import 'package:hive/hive.dart';

part 'transaction_attachment.g.dart';

@HiveType(typeId: 7)
class TransactionAttachmentModel {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String transactionId;

  @HiveField(2)
  late String filename;

  @HiveField(3)
  late String filePath;

  @HiveField(4)
  late int fileSize;

  @HiveField(5)
  late String mimeType;

  @HiveField(6)
  late String? fileUrl;

  @HiveField(7)
  late String? createdAt;

  @HiveField(8)
  late String? updatedAt;

  static String attachmentBox = "transaction_attachments";

  // Constructor
  TransactionAttachmentModel();

  static TransactionAttachmentModel fromMap(Map<String, dynamic> attachment) {
    var attachmentModel = TransactionAttachmentModel();

    // Simple and clean - ID contains UUID
    attachmentModel.id = attachment['id']?.toString() ?? '';
    attachmentModel.transactionId =
        attachment['transaction_id']?.toString() ?? '';
    attachmentModel.filename = attachment['filename'] ?? '';
    attachmentModel.filePath = attachment['file_path'] ?? '';
    attachmentModel.fileSize =
        int.tryParse(attachment['file_size']?.toString() ?? '0') ?? 0;
    attachmentModel.mimeType = attachment['mime_type'] ?? '';
    attachmentModel.fileUrl = attachment['file_url'];
    attachmentModel.createdAt = attachment['created_at'];
    attachmentModel.updatedAt = attachment['updated_at'];

    return attachmentModel;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id, // UUID
      'transaction_id': transactionId,
      'filename': filename,
      'file_path': filePath,
      'file_size': fileSize,
      'mime_type': mimeType,
      'file_url': fileUrl,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Helper methods
  bool get isImage {
    return mimeType.startsWith('image/') ||
        ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(fileExtension);
  }

  bool get isDocument {
    return mimeType == 'application/pdf' ||
        mimeType == 'application/msword' ||
        mimeType ==
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document' ||
        mimeType == 'text/plain' ||
        ['pdf', 'doc', 'docx', 'txt'].contains(fileExtension);
  }

  String get fileExtension {
    if (filename.contains('.')) {
      return filename.split('.').last.toLowerCase();
    }
    return '';
  }

  String get fileSizeFormatted {
    if (fileSize >= 1073741824) {
      return '${(fileSize / 1073741824).toStringAsFixed(2)} GB';
    } else if (fileSize >= 1048576) {
      return '${(fileSize / 1048576).toStringAsFixed(2)} MB';
    } else if (fileSize >= 1024) {
      return '${(fileSize / 1024).toStringAsFixed(2)} KB';
    } else {
      return '$fileSize bytes';
    }
  }

  String get displayName {
    if (filename.length > 30) {
      return '${filename.substring(0, 27)}...';
    }
    return filename;
  }

  String get shortDisplayName {
    if (filename.length > 20) {
      return '${filename.substring(0, 17)}...';
    }
    return filename;
  }

  @override
  String toString() => filename;

  bool isEqual(TransactionAttachmentModel model) {
    return id == model.id;
  }
}
