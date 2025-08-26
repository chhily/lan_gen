import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:lan_gen/core/utils/logger.dart';
import 'package:lan_gen/core/services/excel_parser.dart';

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
      // Use saved directory or prompt
      String? outputDir = userDir;

      if (outputDir == null || outputDir.isEmpty) {
        outputDir = await FilePicker.platform.getDirectoryPath();
      }

      if (outputDir == null || outputDir.isEmpty) {
        // Instead of throwing, handle gracefully
        AppLogger.info("⚠️ User canceled directory selection.");
        return;
      }

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
          finalMap = ExcelParser.i.mergeTranslation(
            existing: existingMap,
            incoming: map,
          );
        }

        await file.writeAsString(
          JsonEncoder.withIndent('  ').convert(finalMap),
        );
      }

      // Locale key generation
      String? localeDir = userLocaleKeyDir;
      if (userLocaleKeyDir == null || userLocaleKeyDir.isEmpty) {
        localeDir = outputDir;
      }
      final localeDirectory = Directory(localeDir!);
      if (!localeDirectory.existsSync()) {
        localeDirectory.createSync(recursive: true);
      }

      LocaleKeyGenerator.i.generateKeysFile(
        translations: translations,
        outputDir: localeDir,
        useCamelCase: useCamelCase,
      );
    } catch (e, st) {
      AppLogger.error("❌ exportTranslations failed: $e\n$st");
      rethrow;
    }
  }
}
