// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LeaderboardEntryHiveModelAdapter
    extends TypeAdapter<LeaderboardEntryHiveModel> {
  @override
  final int typeId = 19;

  @override
  LeaderboardEntryHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LeaderboardEntryHiveModel(
      rank: fields[0] as String,
      userId: fields[1] as String,
      name: fields[2] as String,
      photo: fields[3] as String?,
      xp: fields[4] as int,
      level: fields[5] as String,
      college: fields[6] as String?,
      isCurrentUser: fields[7] as bool,
      score: (fields[8] as num?)?.toInt() ?? 0,
      kRank: (fields[9] as num?)?.toInt() ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, LeaderboardEntryHiveModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.rank)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.photo)
      ..writeByte(4)
      ..write(obj.xp)
      ..writeByte(5)
      ..write(obj.level)
      ..writeByte(6)
      ..write(obj.college)
      ..writeByte(7)
      ..write(obj.isCurrentUser)
      ..writeByte(8)
      ..write(obj.score)
      ..writeByte(9)
      ..write(obj.kRank);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeaderboardEntryHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LeaderboardHiveModelAdapter extends TypeAdapter<LeaderboardHiveModel> {
  @override
  final int typeId = 20;

  @override
  LeaderboardHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LeaderboardHiveModel(
      entries: (fields[0] as List).cast<LeaderboardEntryHiveModel>(),
      totalEntries: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, LeaderboardHiveModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.entries)
      ..writeByte(1)
      ..write(obj.totalEntries);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeaderboardHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
