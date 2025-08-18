// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionModelAdapter extends TypeAdapter<TransactionModel> {
  @override
  final int typeId = 6;

  @override
  TransactionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransactionModel()
      ..id = fields[0] as String
      ..description = fields[1] as String
      ..notes = fields[2] as String?
      ..amount = fields[3] as double
      ..formattedAmountText = fields[4] as String
      ..type = fields[5] as String
      ..formattedType = fields[6] as String
      ..transactionDate = fields[7] as DateTime
      ..referenceNumber = fields[8] as String?
      ..active = fields[9] as int?
      ..account = fields[10] as AccountModel
      ..category = fields[11] as CategoryModel
      ..createdAt = fields[12] as String?
      ..updatedAt = fields[13] as String?;
  }

  @override
  void write(BinaryWriter writer, TransactionModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.notes)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.formattedAmountText)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.formattedType)
      ..writeByte(7)
      ..write(obj.transactionDate)
      ..writeByte(8)
      ..write(obj.referenceNumber)
      ..writeByte(9)
      ..write(obj.active)
      ..writeByte(10)
      ..write(obj.account)
      ..writeByte(11)
      ..write(obj.category)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
