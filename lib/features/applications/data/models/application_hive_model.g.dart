// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'application_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ApplicationHiveModelAdapter extends TypeAdapter<ApplicationHiveModel> {
  @override
  final int typeId = 14;

  @override
  ApplicationHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ApplicationHiveModel(
      id: fields[0] as String,
      jobId: fields[1] as String,
      jobTitle: fields[2] as String,
      companyName: fields[3] as String,
      companyLogo: fields[4] as String?,
      status: fields[5] as String,
      appliedAt: fields[6] as String,
      updatedAt: fields[7] as String,
      nextStep: fields[8] as String?,
      location: fields[9] as String,
      employmentType: fields[10] as String,
      workMode: fields[11] as String,
      salaryRange: fields[12] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ApplicationHiveModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.jobId)
      ..writeByte(2)
      ..write(obj.jobTitle)
      ..writeByte(3)
      ..write(obj.companyName)
      ..writeByte(4)
      ..write(obj.companyLogo)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.appliedAt)
      ..writeByte(7)
      ..write(obj.updatedAt)
      ..writeByte(8)
      ..write(obj.nextStep)
      ..writeByte(9)
      ..write(obj.location)
      ..writeByte(10)
      ..write(obj.employmentType)
      ..writeByte(11)
      ..write(obj.workMode)
      ..writeByte(12)
      ..write(obj.salaryRange);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApplicationHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
