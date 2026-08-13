import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class FileServices {
  FileServices._init();
  static FileServices? _i;
  static FileServices get i => _i ??= FileServices._init();

  Future<FilePickerResult?> pickExcelFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );
      return result;
    } catch (e) {
      rethrow;
    }
  }

  //./ Reads and decodes the workbook off the UI thread — `ExceldecodeBytes`
  /// is CPU-heavy and would otherwise freeze the UI on large files.
  Future<List<List<dynamic>>> readFile({required String? path}) async {
    if (path == null) return [];
    final bytes = await File(path).readAsBytes();
    return compute(_parseExcelBytes, bytes);
  }

  Future<void> createSampleTemplate(String path) async {
    final excel = Excel.createExcel();
    final Sheet sheet = excel['Sheet1'];

    sheet.appendRow([
      TextCellValue('key'),
      TextCellValue('en'),
      TextCellValue('km'),
    ]);
    sheet.appendRow([
      TextCellValue('hello'),
      TextCellValue('Hello'),
      TextCellValue('សួស្តី'),
    ]);
    sheet.appendRow([
      TextCellValue('bye'),
      TextCellValue('Goodbye'),
      TextCellValue('លាហើយ'),
    ]);


    sheet.appendRow([
      TextCellValue('morning'),
      TextCellValue('Good morning'),
      TextCellValue(''),
    ]);

    final fileBytes = excel.save();
    if (fileBytes != null) {
      File(path)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
    }
  }
}

/// Runs in a background isolate via [compute]. Returns the rows of the first
/// sheet that actually contains data, skipping sheets that are entirely empty
/// (e.g. a default blank "Sheet1") instead of always taking whichever sheet
/// happens to be listed first and silently dropping the rest.
List<List<dynamic>> _parseExcelBytes(Uint8List bytes) {
  final excel = Excel.decodeBytes(bytes);

  for (final table in excel.tables.keys) {
    final rows = excel.tables[table]!.rows
        .map((r) => r.map((c) => c?.value).toList())
        .toList();
    if (rows.isNotEmpty) return rows;
  }
  return [];
}
