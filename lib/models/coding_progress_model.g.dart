// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coding_progress_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CodingProgressModelAdapter extends TypeAdapter<CodingProgressModel> {
  @override
  final int typeId = 3;

  @override
  CodingProgressModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CodingProgressModel(
      id: fields[0] as String,
      platform: fields[1] as String,
      problemsSolved: fields[2] as int,
      dailyGoal: fields[3] as int,
      totalGoal: fields[4] as int,
      lastUpdated: fields[5] as DateTime,
      weeklyHistory: (fields[6] as List).cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, CodingProgressModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.platform)
      ..writeByte(2)
      ..write(obj.problemsSolved)
      ..writeByte(3)
      ..write(obj.dailyGoal)
      ..writeByte(4)
      ..write(obj.totalGoal)
      ..writeByte(5)
      ..write(obj.lastUpdated)
      ..writeByte(6)
      ..write(obj.weeklyHistory);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CodingProgressModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
