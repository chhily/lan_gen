// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'translation_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TranslationDataAdapter extends TypeAdapter<UserTranslationData> {
  @override
  final int typeId = 1;

  @override
  UserTranslationData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserTranslationData(
      name: fields[0] as String,
      excelFilePath: fields[1] as String,
      savedTranslateFilePath: fields[2] as String,
      savedLocaleKeyFilePath: fields[3] as String,
      timeStamps: fields[4] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, UserTranslationData obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.excelFilePath)
      ..writeByte(2)
      ..write(obj.savedTranslateFilePath)
      ..writeByte(3)
      ..write(obj.savedLocaleKeyFilePath)
      ..writeByte(4)
      ..write(obj.timeStamps);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranslationDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
