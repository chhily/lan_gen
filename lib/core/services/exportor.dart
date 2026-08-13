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
        AppLogger.info("User canceled directory selection.");
        return;
      }

      final dir = Directory(outputDir);
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }

      // Prepare every language's content first so a merge/encoding failure
      // aborts before anything touches disk.
      final pendingWrites = <MapEntry<File, String>>[];
      for (final entry in translations.entries) {
        final lang = entry.key;
        final map = entry.value;
        final file = File('$outputDir/${_sanitizeFileName(lang)}.json');

        Map<String, dynamic> finalMap = map;

        if (merge && file.existsSync()) {
          final existingMap = ExcelParser.i.loadExistingJson(file.path);
          finalMap = ExcelParser.i.mergeTranslation(
            existing: existingMap,
            incoming: map,
          );
        }

        pendingWrites.add(
          MapEntry(file, JsonEncoder.withIndent('  ').convert(finalMap)),
        );
      }

      // Write everything, keeping a backup of any pre-existing content. If a
      // write fails partway, restore the files this export already touched
      // instead of leaving a mix of old and new locale files on disk.
      final backups = <File, String?>{};
      try {
        for (final entry in pendingWrites) {
          final file = entry.key;
          backups[file] = file.existsSync() ? await file.readAsString() : null;
          await file.writeAsString(entry.value);
        }
      } catch (e) {
        for (final entry in backups.entries) {
          final file = entry.key;
          final original = entry.value;
          try {
            if (original == null) {
              if (file.existsSync()) file.deleteSync();
            } else {
              file.writeAsStringSync(original);
            }
          } catch (_) {
            // Best-effort rollback; ignore secondary failures.
          }
        }
        rethrow;
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
      AppLogger.error("exportTranslations failed: $e\n$st");
      rethrow;
    }
  }

  /// Replaces characters that are illegal (or path separators) in a filename
  /// so a language header like "en/US" can't escape the export directory.
  String _sanitizeFileName(String name) {
    return name.trim().replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  }
}
