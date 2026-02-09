// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_overview_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DashboardOverviewHiveModelAdapter
    extends TypeAdapter<DashboardOverviewHiveModel> {
  @override
  final int typeId = 21;

  @override
  DashboardOverviewHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DashboardOverviewHiveModel(
      monthKey: fields[0] as String,
      json: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DashboardOverviewHiveModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.monthKey)
      ..writeByte(1)
      ..write(obj.json);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashboardOverviewHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
