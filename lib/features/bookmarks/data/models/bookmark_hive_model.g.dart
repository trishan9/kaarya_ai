// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmark_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class JobBookmarkHiveModelAdapter extends TypeAdapter<JobBookmarkHiveModel> {
  @override
  final int typeId = 16;

  @override
  JobBookmarkHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return JobBookmarkHiveModel(
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
  void write(BinaryWriter writer, JobBookmarkHiveModel obj) {
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
      other is JobBookmarkHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InterviewBookmarkHiveModelAdapter
    extends TypeAdapter<InterviewBookmarkHiveModel> {
  @override
  final int typeId = 17;

  @override
  InterviewBookmarkHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InterviewBookmarkHiveModel(
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
  void write(BinaryWriter writer, InterviewBookmarkHiveModel obj) {
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
      other is InterviewBookmarkHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BookmarksHiveModelAdapter extends TypeAdapter<BookmarksHiveModel> {
  @override
  final int typeId = 18;

  @override
  BookmarksHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BookmarksHiveModel(
      jobs: (fields[0] as List).cast<JobBookmarkHiveModel>(),
      interviews: (fields[1] as List).cast<InterviewBookmarkHiveModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, BookmarksHiveModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.jobs)
      ..writeByte(1)
      ..write(obj.interviews);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookmarksHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
