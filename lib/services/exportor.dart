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

  /// Exports translations to JSON files and optionally generates locale keys
  Future<void> exportTranslations(
    Map<String, Map<String, String>> translations, {
    String? userDir,
    String? userLocaleKeyDir,
    bool useCamelCase = false,
    bool merge = false,
  }) async {
    try {
      // Ask user for directory if not provided
      String? outputDir =
          userDir ?? await FilePicker.platform.getDirectoryPath();
      print("userDir $userDir");
      if (outputDir == null || outputDir.isEmpty) {
        throw Exception("No output directory selected.");
      }

      // Ensure the directory exists
      final dir = Directory(outputDir);
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }

      for (final entry in translations.entries) {
        final lang = entry.key;
        final map = entry.value;
        final file = File('$outputDir/$lang.json');

        Map<String, dynamic> finalMap = map;

        if (merge && file.existsSync()) {
          final existingMap = ExcelParser.i.loadExistingJson(file.path);
          finalMap = ExcelParser.i.mergTranslation(
            existing: existingMap,
            incoming: map,
          );
        }

        await file.writeAsString(
          JsonEncoder.withIndent('  ').convert(finalMap),
        );
      }

      // Generate locale keys
      final localeDir = userLocaleKeyDir ?? outputDir;
      final localeDirectory = Directory(localeDir);
      if (!localeDirectory.existsSync()) {
        localeDirectory.createSync(recursive: true);
      }

      LocaleKeyGenerator.i.generateKeysFile(
        translations: translations,
        outputDir: localeDir,
        useCamelCase: useCamelCase,
      );
    } catch (e) {
      rethrow;
    }
  }
}
