// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CompanyHiveModelAdapter extends TypeAdapter<CompanyHiveModel> {
  @override
  final int typeId = 22;

  @override
  CompanyHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CompanyHiveModel(
      id: fields[0] as String,
      name: fields[1] as String,
      industry: fields[2] as String,
      location: fields[3] as String,
      logo: fields[4] as String?,
      verifiedStatus: fields[5] as String,
      inviteCode: fields[6] as String?,
      recruitersCount: fields[7] as int,
      createdAt: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CompanyHiveModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.industry)
      ..writeByte(3)
      ..write(obj.location)
      ..writeByte(4)
      ..write(obj.logo)
      ..writeByte(5)
      ..write(obj.verifiedStatus)
      ..writeByte(6)
      ..write(obj.inviteCode)
      ..writeByte(7)
      ..write(obj.recruitersCount)
      ..writeByte(8)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompanyHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
