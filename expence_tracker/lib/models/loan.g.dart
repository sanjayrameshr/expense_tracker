// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loan.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LoanAdapter extends TypeAdapter<Loan> {
  @override
  final int typeId = 2;

  @override
  Loan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Loan(
      id: fields[0] as String,
      name: fields[1] as String,
      initialPrincipal: fields[2] as double,
      currentPrincipal: fields[3] as double,
      interestRateAnnual: fields[4] as double,
      startDate: fields[5] as DateTime?,
      payments: (fields[6] as List?)?.cast<LoanPayment>(),
    );
  }

  @override
  void write(BinaryWriter writer, Loan obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.initialPrincipal)
      ..writeByte(3)
      ..write(obj.currentPrincipal)
      ..writeByte(4)
      ..write(obj.interestRateAnnual)
      ..writeByte(5)
      ..write(obj.startDate)
      ..writeByte(6)
      ..write(obj.payments);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LoanPaymentAdapter extends TypeAdapter<LoanPayment> {
  @override
  final int typeId = 3;

  @override
  LoanPayment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LoanPayment(
      id: fields[0] as String,
      amount: fields[1] as double,
      interestPortion: fields[2] as double,
      principalPortion: fields[3] as double,
      date: fields[4] as DateTime?,
      transactionId: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, LoanPayment obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.interestPortion)
      ..writeByte(3)
      ..write(obj.principalPortion)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.transactionId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoanPaymentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
