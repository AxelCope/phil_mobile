// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CommsAdapter extends TypeAdapter<Comms> {
  @override
  final int typeId = 0;

  @override
  Comms read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Comms(
      nomCommerciaux: fields[0] as String?,
      id: fields[2] as String?,
      startDateTime: fields[4] as DateTime?,
      endDateTime: fields[5] as DateTime?,
      startDateTimeR: fields[6] as DateTime?,
      endDateTimeR: fields[7] as DateTime?,
      startDateTimeT: fields[11] as DateTime?,
      endDateTimeT: fields[12] as DateTime?,
      mail: fields[3] as String?,
      password: fields[8] as String?,
      nicknameCommerciaux: fields[1] as String?,
      StatusCompte: fields[9] as bool?,
      checked: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Comms obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.nomCommerciaux)
      ..writeByte(1)
      ..write(obj.nicknameCommerciaux)
      ..writeByte(2)
      ..write(obj.id)
      ..writeByte(3)
      ..write(obj.mail)
      ..writeByte(4)
      ..write(obj.startDateTime)
      ..writeByte(5)
      ..write(obj.endDateTime)
      ..writeByte(6)
      ..write(obj.startDateTimeR)
      ..writeByte(7)
      ..write(obj.endDateTimeR)
      ..writeByte(8)
      ..write(obj.password)
      ..writeByte(9)
      ..write(obj.StatusCompte)
      ..writeByte(10)
      ..write(obj.checked)
      ..writeByte(11)
      ..write(obj.startDateTimeT)
      ..writeByte(12)
      ..write(obj.endDateTimeT);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
