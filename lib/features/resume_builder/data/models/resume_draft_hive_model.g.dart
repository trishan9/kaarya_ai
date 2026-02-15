// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resume_draft_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ResumeDraftHiveModelAdapter extends TypeAdapter<ResumeDraftHiveModel> {
  @override
  final int typeId = 25;

  @override
  ResumeDraftHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ResumeDraftHiveModel(
      id: fields[0] as String,
      title: fields[1] as String,
      template: fields[2] as String,
      professionalSummary: fields[3] as String,
      sectionsJson: fields[4] as String,
      createdAt: fields[5] as String,
      updatedAt: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ResumeDraftHiveModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.template)
      ..writeByte(3)
      ..write(obj.professionalSummary)
      ..writeByte(4)
      ..write(obj.sectionsJson)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResumeDraftHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
