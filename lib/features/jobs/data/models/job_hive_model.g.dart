// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class JobHiveModelAdapter extends TypeAdapter<JobHiveModel> {
  @override
  final int typeId = 10;

  @override
  JobHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return JobHiveModel(
      id: fields[0] as String,
      title: fields[1] as String,
      companyName: fields[2] as String,
      companyLogo: fields[3] as String?,
      location: fields[4] as String,
      employmentType: fields[5] as String,
      engagementType: fields[6] as String,
      workMode: fields[7] as String,
      salaryRange: fields[8] as String,
      status: fields[9] as String,
      deadline: fields[10] as String,
      createdAt: fields[11] as String,
      applicationsCount: fields[12] as int,
      viewsCount: fields[13] as int,
      isSaved: fields[14] as bool,
      hasApplied: fields[15] as bool,
      myApplicationId: fields[16] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, JobHiveModel obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.companyName)
      ..writeByte(3)
      ..write(obj.companyLogo)
      ..writeByte(4)
      ..write(obj.location)
      ..writeByte(5)
      ..write(obj.employmentType)
      ..writeByte(6)
      ..write(obj.engagementType)
      ..writeByte(7)
      ..write(obj.workMode)
      ..writeByte(8)
      ..write(obj.salaryRange)
      ..writeByte(9)
      ..write(obj.status)
      ..writeByte(10)
      ..write(obj.deadline)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.applicationsCount)
      ..writeByte(13)
      ..write(obj.viewsCount)
      ..writeByte(14)
      ..write(obj.isSaved)
      ..writeByte(15)
      ..write(obj.hasApplied)
      ..writeByte(16)
      ..write(obj.myApplicationId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JobHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class JobsSectionHiveModelAdapter extends TypeAdapter<JobsSectionHiveModel> {
  @override
  final int typeId = 11;

  @override
  JobsSectionHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return JobsSectionHiveModel(
      searchQuery: fields[0] as String,
      locationQuery: fields[1] as String,
      forYou: (fields[2] as List).cast<JobHiveModel>(),
      trending: (fields[3] as List).cast<JobHiveModel>(),
      newThisWeek: (fields[4] as List).cast<JobHiveModel>(),
      remote: (fields[5] as List).cast<JobHiveModel>(),
      urgent: (fields[6] as List).cast<JobHiveModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, JobsSectionHiveModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.searchQuery)
      ..writeByte(1)
      ..write(obj.locationQuery)
      ..writeByte(2)
      ..write(obj.forYou)
      ..writeByte(3)
      ..write(obj.trending)
      ..writeByte(4)
      ..write(obj.newThisWeek)
      ..writeByte(5)
      ..write(obj.remote)
      ..writeByte(6)
      ..write(obj.urgent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JobsSectionHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
