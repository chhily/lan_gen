import 'dart:convert';
import 'dart:io';
import 'package:lan_gen/models/duplicate_record.dart';

class ExcelParser {
  ExcelParser._init();
  static ExcelParser? _i;
  static ExcelParser get i => _i ??= ExcelParser._init();
  List<DuplicateRecord> duplicateRecord = [];

  Map<String, Map<String, String>> parseTranslation(List<List<dynamic>> rows) {
    duplicateRecord.clear();
    if (rows.isEmpty) return {};

    final headers = rows.first.map((e) => e.toString().trim()).toList();
    final keyIndex = 0;

    final Map<String, Map<String, String>> translations = {};

    // Initialize empty maps for each language column
    for (int col = 1; col < headers.length; col++) {
      translations[headers[col]] = {};
    }

    for (int rowIndex = 1; rowIndex < rows.length; rowIndex++) {
      final row = rows[rowIndex];
      if (row.isEmpty) continue;

      final key = row[keyIndex]?.toString() ?? '';
      if (key.isEmpty) continue;

      for (int col = 1; col < headers.length; col++) {
        final lang = headers[col];
        final value = row[col]?.toString() ?? '';

        // Check for duplicate record
        if (translations[lang]!.containsKey(key)) {
          duplicateRecord.add(
            DuplicateRecord(
              lang: lang,
              key: key,
              oldValue: translations[lang]![key]!,
              newValue: value,
              rowNumber: rowIndex + 1, // Excel rows are 1-indexed
            ),
          );
        }
        translations[lang]![key] = value;
      }
    }

    return translations;
  }

  Map<String, String> loadExistingJson(String path) {
    final file = File(path);
    if (!file.existsSync()) return {};
    return Map<String, String>.from(jsonDecode(file.readAsStringSync()));
  }

  Map<String, String> mergTranslation({
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
