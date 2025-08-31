// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_attachment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionAttachmentModelAdapter
    extends TypeAdapter<TransactionAttachmentModel> {
  @override
  final int typeId = 7;

  @override
  TransactionAttachmentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransactionAttachmentModel()
      ..id = fields[0] as String
      ..transactionId = fields[1] as String
      ..filename = fields[2] as String
      ..filePath = fields[3] as String
      ..fileSize = fields[4] as int
      ..mimeType = fields[5] as String
      ..fileUrl = fields[6] as String?
      ..createdAt = fields[7] as String?
      ..updatedAt = fields[8] as String?;
  }

  @override
  void write(BinaryWriter writer, TransactionAttachmentModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.transactionId)
      ..writeByte(2)
      ..write(obj.filename)
      ..writeByte(3)
      ..write(obj.filePath)
      ..writeByte(4)
      ..write(obj.fileSize)
      ..writeByte(5)
      ..write(obj.mimeType)
      ..writeByte(6)
      ..write(obj.fileUrl)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionAttachmentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
