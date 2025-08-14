import 'package:hive/hive.dart';

part 'translation_data.g.dart';

@HiveType(typeId: 1)
class TranslationData {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final String excelFilePath;
  @HiveField(2)
  final String savedTranslateFilePath;
  @HiveField(3)
  final String savedLocaleKeyFilePath;
  @HiveField(4)
  final int? timeStamps;

  TranslationData({
    required this.name,
    required this.excelFilePath,
    required this.savedTranslateFilePath,
    required this.savedLocaleKeyFilePath,
    this.timeStamps,
  });

  TranslationData copyWith({
    String? name,
    String? excelFilePath,
    String? savedTranslateFilePath,
    String? savedLocaleKeyFilePath,
    int? timeStamps,
  }) {
    return TranslationData(
      name: name ?? this.name,
      excelFilePath: excelFilePath ?? this.excelFilePath,
      savedTranslateFilePath:
          savedTranslateFilePath ?? this.savedTranslateFilePath,
      savedLocaleKeyFilePath:
          savedLocaleKeyFilePath ?? this.savedLocaleKeyFilePath,
      timeStamps: timeStamps ?? this.timeStamps,
    );
  }
}
