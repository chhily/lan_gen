import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';

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

  Future<List<List<dynamic>>> readFile({required String? path}) async {
    if (path == null) return [];
    final bytes = File(path).readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);

    for (final table in excel.tables.keys) {
      debugPrint("table :: $table");
      final rows = excel.tables[table]!.rows
          .map((r) => r.map((c) => c?.value).toList())
          .toList();
      return rows;
    }
    return [];
  }
}
