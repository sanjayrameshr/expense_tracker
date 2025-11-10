// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionAdapter extends TypeAdapter<Transaction> {
  @override
  final int typeId = 1;

  @override
  Transaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Transaction(
      id: fields[0] as String,
      amount: fields[1] as double,
      category: fields[2] as TransactionCategory,
      description: fields[3] as String,
      date: fields[4] as DateTime?,
      loanId: fields[5] as String?,
      interestPortion: fields[6] as double?,
      principalPortion: fields[7] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, Transaction obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.loanId)
      ..writeByte(6)
      ..write(obj.interestPortion)
      ..writeByte(7)
      ..write(obj.principalPortion);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TransactionCategoryAdapter extends TypeAdapter<TransactionCategory> {
  @override
  final int typeId = 10;

  @override
  TransactionCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TransactionCategory.income;
      case 1:
        return TransactionCategory.spend;
      case 2:
        return TransactionCategory.family;
      case 3:
        return TransactionCategory.savingsDeposit;
      case 4:
        return TransactionCategory.loanPayment;
      case 5:
        return TransactionCategory.feePayment;
      default:
        return TransactionCategory.income;
    }
  }

  @override
  void write(BinaryWriter writer, TransactionCategory obj) {
    switch (obj) {
      case TransactionCategory.income:
        writer.writeByte(0);
        break;
      case TransactionCategory.spend:
        writer.writeByte(1);
        break;
      case TransactionCategory.family:
        writer.writeByte(2);
        break;
      case TransactionCategory.savingsDeposit:
        writer.writeByte(3);
        break;
      case TransactionCategory.loanPayment:
        writer.writeByte(4);
        break;
      case TransactionCategory.feePayment:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
