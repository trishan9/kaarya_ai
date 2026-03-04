// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'college_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CollegeHiveModelAdapter extends TypeAdapter<CollegeHiveModel> {
  @override
  final int typeId = 23;

  @override
  CollegeHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CollegeHiveModel(
      id: fields[0] as String,
      name: fields[1] as String,
      institutionType: fields[2] as String,
      location: fields[3] as String,
      logo: fields[4] as String?,
      inviteCode: fields[5] as String?,
      studentsCount: fields[6] as int,
      createdAt: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CollegeHiveModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.institutionType)
      ..writeByte(3)
      ..write(obj.location)
      ..writeByte(4)
      ..write(obj.logo)
      ..writeByte(5)
      ..write(obj.inviteCode)
      ..writeByte(6)
      ..write(obj.studentsCount)
      ..writeByte(7)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CollegeHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
