// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meditation_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MeditationSessionAdapter extends TypeAdapter<MeditationSession> {
  @override
  final int typeId = 3;

  @override
  MeditationSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MeditationSession(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      durationMinutes: fields[3] as int,
      category: fields[4] as String,
      audioUrl: fields[5] as String?,
      script: fields[6] as String?,
      imageUrl: fields[7] as String?,
      isPremium: fields[8] as bool,
      tags: (fields[9] as List?)?.cast<String>(),
      instructor: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MeditationSession obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.durationMinutes)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.audioUrl)
      ..writeByte(6)
      ..write(obj.script)
      ..writeByte(7)
      ..write(obj.imageUrl)
      ..writeByte(8)
      ..write(obj.isPremium)
      ..writeByte(9)
      ..write(obj.tags)
      ..writeByte(10)
      ..write(obj.instructor);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MeditationSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MeditationHistoryAdapter extends TypeAdapter<MeditationHistory> {
  @override
  final int typeId = 4;

  @override
  MeditationHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MeditationHistory(
      id: fields[0] as String,
      userId: fields[1] as String,
      sessionId: fields[2] as String,
      completedAt: fields[3] as DateTime?,
      durationMinutes: fields[4] as int,
      completed: fields[5] as bool,
      rating: fields[6] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, MeditationHistory obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.sessionId)
      ..writeByte(3)
      ..write(obj.completedAt)
      ..writeByte(4)
      ..write(obj.durationMinutes)
      ..writeByte(5)
      ..write(obj.completed)
      ..writeByte(6)
      ..write(obj.rating);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MeditationHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
