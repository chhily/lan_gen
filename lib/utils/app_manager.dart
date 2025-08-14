import 'package:flutter/material.dart';
import 'package:lan_gen/services/excel_parser.dart';
import '../models/translation_data.dart';
import '../services/exportor.dart';
import '../services/file_services.dart';
import 'exportor_manager.dart';

class AppManager {
  AppManager();
  FileServices fileServices = FileServices.i;

  void exportTranslations(
    Map<String, Map<String, String>> translations,
    BuildContext context, {
    String? userDir,
    String? userLocaleKeyDir,
    bool useCamelCase = false,
    required ExportMode exportMode,
  }) {
    try {
      switch (exportMode) {
        case ExportMode.overWrite:
          Exportor.i.exportTranslations(
            translations,
            userDir: userDir,
            useCamelCase: useCamelCase,
            userLocaleKeyDir: userLocaleKeyDir,
          );
          break;

        case ExportMode.merge:
          Exportor.i.exportWithMerged(
            translations: translations,
            useCamelCase: useCamelCase,
            userDir: userDir,
            userLocaleKeyDir: userLocaleKeyDir,
          );
          break;
      }

      showSnackBar(context, "Success!");
    } catch (e, stack) {
      debugPrint("Error exporting translations: $e\n$stack");
      showSnackBar(context, "Something went wrong: ${e.toString()}");
    }
  }

  Future<void> saveData(
    BuildContext context, {
    required String name,
    required String excelFilePath,
    required String savedTranslateFilePath,
    required String savedLocaleKeyFilePath,
    required Future<void> Function() loadProjectHistory,
  }) async {
    await ExportPathManager.saveTranslation(
          TranslationData(
            name: name,
            excelFilePath: excelFilePath,
            savedTranslateFilePath: savedTranslateFilePath,
            savedLocaleKeyFilePath: savedLocaleKeyFilePath,
          ),
        )
        .whenComplete(() async {
          await loadProjectHistory();
        })
        .onError((error, stackTrace) {
          if (!context.mounted) return;
          showSnackBar(context, "Something went wrong!");
        });
  }

  Future<(String, TextEditingValue)> pickSheetFile() async {
    final result = await fileServices.pickExcelFile();
    if (result != null && result.files.single.path != null) {
      return (
        result.files.single.path!,
        TextEditingValue(text: result.files.single.path!),
      );
    }
    throw Exception("No file selected");
  }

  Future<Map<String, Map<String, String>>?> getSheetData({
    String? filePath,
  }) async {
    try {
      final result = await fileServices.readFile(path: filePath);
      if (result.isNotEmpty) {
        return ExcelParser.i.parseTranslation(result);
      }
    } catch (e) {
      debugPrint("$e");
      rethrow;
    }
    return null;
  }

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Durations.medium4),
    );
  }
}
