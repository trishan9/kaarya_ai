// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_course_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ResourceCourseHiveModelAdapter
    extends TypeAdapter<ResourceCourseHiveModel> {
  @override
  final int typeId = 24;

  @override
  ResourceCourseHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ResourceCourseHiveModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      category: fields[3] as String,
      difficulty: fields[4] as String,
      targetRoles: (fields[5] as List).cast<String>(),
      visibility: fields[6] as String,
      source: fields[7] as String,
      generationMode: fields[8] as String,
      chaptersJson: fields[9] as String,
      chaptersCount: fields[10] as int,
      createdAt: fields[11] as String,
      updatedAt: fields[12] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ResourceCourseHiveModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.difficulty)
      ..writeByte(5)
      ..write(obj.targetRoles)
      ..writeByte(6)
      ..write(obj.visibility)
      ..writeByte(7)
      ..write(obj.source)
      ..writeByte(8)
      ..write(obj.generationMode)
      ..writeByte(9)
      ..write(obj.chaptersJson)
      ..writeByte(10)
      ..write(obj.chaptersCount)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResourceCourseHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
