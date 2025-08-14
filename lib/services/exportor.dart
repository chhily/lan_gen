import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:lan_gen/services/excel_parser.dart';

import 'locale_key_generator.dart';

enum ExportMode { overWrite, merge }

class Exportor {
  Exportor._init();
  static Exportor? _i;
  static Exportor get i => _i ??= Exportor._init();

  Future<void> exportWithMerged({
    required Map<String, Map<String, String>> translations,
    String? userDir,
    String? userLocaleKeyDir,
    bool useCamelCase = false,
  }) async {
    try {
      String? outputDir =
          userDir ?? await FilePicker.platform.getDirectoryPath();
      if (outputDir == null) return;
      translations.forEach((lang, newMap) {
        final filePath = '$outputDir/$lang.json';
        final existingMap = ExcelParser.i.loadExistingJson(filePath);
        final mergedMap = ExcelParser.i.mergTranslation(
          existing: existingMap,
          incoming: newMap,
        );

        File(
          filePath,
        ).writeAsStringSync(JsonEncoder.withIndent(' ').convert(mergedMap));
      });

      LocaleKeyGenerator.i.generateKeysFile(
        translations: translations,
        outputDir: userLocaleKeyDir ?? outputDir,
        useCamelCase: useCamelCase,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> exportTranslations(
    Map<String, Map<String, String>> translations, {
    String? userDir,
    String? userLocaleKeyDir,
    bool useCamelCase = false,
  }) async {
    try {
      String? outputDir =
          userDir ?? await FilePicker.platform.getDirectoryPath();

      if (outputDir != null) {
        translations.forEach((lang, map) {
          final file = File('$outputDir/$lang.json');
          file.writeAsStringSync(JsonEncoder.withIndent('  ').convert(map));
        });

        LocaleKeyGenerator.i.generateKeysFile(
          translations: translations,
          outputDir: userLocaleKeyDir ?? outputDir,
          useCamelCase: useCamelCase,
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
