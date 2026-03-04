// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resume_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ResumeHiveModelAdapter extends TypeAdapter<ResumeHiveModel> {
  @override
  final int typeId = 15;

  @override
  ResumeHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ResumeHiveModel(
      id: fields[0] as String,
      fileName: fields[1] as String,
      url: fields[2] as String,
      uploadedAt: fields[3] as String,
      atsScore: fields[4] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, ResumeHiveModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fileName)
      ..writeByte(2)
      ..write(obj.url)
      ..writeByte(3)
      ..write(obj.uploadedAt)
      ..writeByte(4)
      ..write(obj.atsScore);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResumeHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
