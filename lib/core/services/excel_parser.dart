import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lan_gen/core/utils/logger.dart';
import 'package:lan_gen/models/duplicate_record.dart';
import 'package:lan_gen/shared/provider/app_provider.dart';

class ExcelParser {
  ExcelParser._init();
  static ExcelParser? _i;
  static ExcelParser get i => _i ??= ExcelParser._init();

  Map<String, Map<String, String>> parseTranslation(
    List<List<dynamic>> rows, {
    required Ref ref,
  }) {
    ref.read(duplicateProvider.notifier).clear();
    if (rows.isEmpty) return {};

    final rawHeaders = rows.first.map((e) => e.toString().trim()).toList();
    final keyIndex = 0;

    // Columns with a blank header have no language name to key by — drop
    // them instead of writing into a shared "" bucket that different blank
    // columns would silently overwrite.
    final languageCols = <int>[
      for (int col = 1; col < rawHeaders.length; col++)
        if (rawHeaders[col].isNotEmpty) col,
    ];

    // Two columns claiming the same language name is a real ambiguity
    // (which one wins?) rather than something safe to resolve silently.
    final seenHeaders = <String>{};
    for (final col in languageCols) {
      final header = rawHeaders[col];
      if (!seenHeaders.add(header)) {
        throw FormatException(
          'Duplicate language column "$header" — each language must appear in only one column.',
        );
      }
    }

    final Map<String, Map<String, String>> translations = {};

    // Initialize empty maps for each language column
    for (final col in languageCols) {
      translations[rawHeaders[col]] = {};
    }

    for (int rowIndex = 1; rowIndex < rows.length; rowIndex++) {
      final row = rows[rowIndex];
      if (row.isEmpty) continue;

      final key = row[keyIndex]?.toString() ?? '';
      if (key.isEmpty) continue;

      for (final col in languageCols) {
        final lang = rawHeaders[col];
        final value = row.length > col ? (row[col]?.toString() ?? '') : '';

        // If this key already exists for this language
        if (translations[lang]!.containsKey(key)) {
          ref
              .read(duplicateProvider.notifier)
              .add(
                DuplicateRecord(
                  lang: lang,
                  key: key,
                  oldValue: translations[lang]![key]!,
                  newValue: value,
                  rowNumber: rowIndex + 1, // Excel rows are 1-indexed
                ),
              );
          // Only overwrite if the current value is empty and the new value is not empty
          if ((translations[lang]![key] == null ||
                  translations[lang]![key]!.isEmpty) &&
              value.isNotEmpty) {
            translations[lang]![key] = value;
          }
          // Otherwise, keep the first non-empty value
        } else {
          // Only set if value is not empty, or if it's the first occurrence
          translations[lang]![key] = value;
        }
      }
    }

    return translations;
  }

  Map<String, String> loadExistingJson(String path) {
    final file = File(path);
    if (!file.existsSync()) return {};
    try {
      final decoded = jsonDecode(file.readAsStringSync());
      if (decoded is! Map) {
        AppLogger.error('Existing translation file is not a JSON object, ignoring: $path');
        return {};
      }
      return decoded.map(
        (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
      );
    } catch (e) {
      AppLogger.error(
        'Failed to read existing translation file, ignoring: $path',
        [e],
      );
      return {};
    }
  }

  Map<String, String> mergeTranslation({
    required Map<String, String> existing,
    required Map<String, String> incoming,
  }) {
    final merged = Map<String, String>.from(existing);
    for (final entry in incoming.entries) {
      merged[entry.key] = entry.value;
    }
    return merged;
  }
}
