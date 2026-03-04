// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interview_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InterviewHiveModelAdapter extends TypeAdapter<InterviewHiveModel> {
  @override
  final int typeId = 12;

  @override
  InterviewHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InterviewHiveModel(
      id: fields[0] as String,
      title: fields[1] as String,
      role: fields[2] as String,
      interviewType: fields[3] as String,
      status: fields[4] as String,
      source: fields[5] as String,
      companyName: fields[6] as String,
      companyLogo: fields[7] as String?,
      attemptsCount: fields[8] as int,
      myLatestScore: fields[9] as double?,
      myLatestSessionId: fields[10] as String?,
      hasAttempted: fields[11] as bool,
      isSaved: fields[12] as bool,
      techStack: (fields[13] as List).cast<String>(),
      createdAt: fields[14] as String,
      updatedAt: fields[15] as String,
    );
  }

  @override
  void write(BinaryWriter writer, InterviewHiveModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.role)
      ..writeByte(3)
      ..write(obj.interviewType)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.source)
      ..writeByte(6)
      ..write(obj.companyName)
      ..writeByte(7)
      ..write(obj.companyLogo)
      ..writeByte(8)
      ..write(obj.attemptsCount)
      ..writeByte(9)
      ..write(obj.myLatestScore)
      ..writeByte(10)
      ..write(obj.myLatestSessionId)
      ..writeByte(11)
      ..write(obj.hasAttempted)
      ..writeByte(12)
      ..write(obj.isSaved)
      ..writeByte(13)
      ..write(obj.techStack)
      ..writeByte(14)
      ..write(obj.createdAt)
      ..writeByte(15)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InterviewHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InterviewsSectionHiveModelAdapter
    extends TypeAdapter<InterviewsSectionHiveModel> {
  @override
  final int typeId = 13;

  @override
  InterviewsSectionHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InterviewsSectionHiveModel(
      forYou: (fields[0] as List).cast<InterviewHiveModel>(),
      trending: (fields[1] as List).cast<InterviewHiveModel>(),
      newThisWeek: (fields[2] as List).cast<InterviewHiveModel>(),
      allTimePopular: (fields[3] as List).cast<InterviewHiveModel>(),
      byYou: (fields[4] as List).cast<InterviewHiveModel>(),
      all: (fields[5] as List).cast<InterviewHiveModel>(),
      createdByMe: (fields[6] as List).cast<InterviewHiveModel>(),
      takenByMe: (fields[7] as List).cast<InterviewHiveModel>(),
      drafts: (fields[8] as List).cast<InterviewHiveModel>(),
      averageScore: fields[9] as double,
      lastUpdatedAt: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, InterviewsSectionHiveModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.forYou)
      ..writeByte(1)
      ..write(obj.trending)
      ..writeByte(2)
      ..write(obj.newThisWeek)
      ..writeByte(3)
      ..write(obj.allTimePopular)
      ..writeByte(4)
      ..write(obj.byYou)
      ..writeByte(5)
      ..write(obj.all)
      ..writeByte(6)
      ..write(obj.createdByMe)
      ..writeByte(7)
      ..write(obj.takenByMe)
      ..writeByte(8)
      ..write(obj.drafts)
      ..writeByte(9)
      ..write(obj.averageScore)
      ..writeByte(10)
      ..write(obj.lastUpdatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InterviewsSectionHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
