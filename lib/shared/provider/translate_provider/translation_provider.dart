import 'package:file_picker/file_picker.dart';
import 'package:lan_gen/core/utils/logger.dart';
import 'package:lan_gen/core/services/excel_parser.dart';
import 'package:lan_gen/core/services/exportor.dart';
import 'package:lan_gen/shared/provider/app_provider.dart';
import 'package:lan_gen/shared/provider/missing_key.dart';
import 'package:riverpod/riverpod.dart';

import '../../../core/services/storage_service.dart';
import '../../../models/translation_data.dart';
import '../../../core/services/file_services.dart';
import '../sheet_provider/sheet_provider.dart';
import 'translation_state.dart';

final translationProvider =
    StateNotifierProvider<TranslationNotifier, TranslationState>(
      (ref) => TranslationNotifier(ref),
    );

class TranslationNotifier extends StateNotifier<TranslationState> {
  final Ref ref;
  final FileServices fileServices = FileServices.i;

  TranslationNotifier(this.ref) : super(TranslationState()) {
    // load history as soon app initialized
    loadProjectHistory();
  }

  /// Returns a map: language -> list of missing keys (missing = not present or empty string)
  Map<String, List<String>> getMissingKeysPerLanguage() {
    final translations = state.translations;
    if (translations == null || translations.isEmpty) return {};

    // Collect all unique keys across all languages
    final allKeys = <String>{};
    for (final lang in translations.keys) {
      allKeys.addAll(translations[lang]?.keys ?? []);
    }

    final missing = <String, List<String>>{};
    for (final lang in translations.keys) {
      final langMap = translations[lang] ?? {};
      final missingKeys = <String>[];
      for (final key in allKeys) {
        final value = langMap[key];
        if (value == null || value.isEmpty) {
          missingKeys.add(key);
        }
      }
      if (missingKeys.isNotEmpty) {
        missing[lang] = missingKeys;
      }
    }
    return missing;
  }

  /// Returns a map: key -> list of languages where the key is missing (missing = not present or empty string)
  Map<String, List<String>> getMissingLanguagesPerKey() {
    final translations = state.translations;
    if (translations == null || translations.isEmpty) return {};

    // Collect all unique keys across all languages
    final allKeys = <String>{};
    for (final lang in translations.keys) {
      allKeys.addAll(translations[lang]?.keys ?? []);
    }

    final missing = <String, List<String>>{};
    for (final key in allKeys) {
      final missingLangs = <String>[];
      for (final lang in translations.keys) {
        final value = translations[lang]?[key];
        if (value == null || value.isEmpty) {
          missingLangs.add(lang);
        }
      }
      if (missingLangs.isNotEmpty) {
        missing[key] = missingLangs;
      }
    }

    return missing;
  }

  /// Import an Excel sheet and store it in state
  Future<void> onImportSheet() async {
    try {
      final result = await fileServices.pickExcelFile();
      if (result == null) return;

      final filePath = result.files.single.path ?? '';
      if (filePath.isEmpty) {
        _setErrMsg("Invalid file path");
        return;
      }
      if (!mounted) return; // <- don't update if disposed
      final fileName = result.files.single.name;
      final sheetData = await _getSheetData(filePath);

      _addSheetData(
        sheetData: sheetData,
        trData: UserTranslationData(
          name: fileName,
          excelFilePath: filePath,
          savedTranslateFilePath: '',
          savedLocaleKeyFilePath: '',
        ),
      );

      ref.read(missingKeyProvider.notifier).detectMissing(sheetData);
    } catch (e, st) {
      _setErrMsg("Failed to import sheet", err: e);
      AppLogger.error("onImportSheet exception", [e, st]);
    }
  }

  /// Export translations to JSON + keys
  Future<void> onExportAndGenerate() async {
    if (state.translations == null || state.translations!.isEmpty) {
      _setErrMsg("Translations are empty");
      return;
    }

    try {
      final appProvider = ref.watch(appConfigProvider);
      await Exportor.i.exportTranslations(
        state.translations!,
        useCamelCase: appProvider.useCamelCase,
        merge: appProvider.exportMode == ExportMode.merge,
        userDir: state.userData?.savedTranslateFilePath,
        userLocaleKeyDir: state.userData?.savedLocaleKeyFilePath,
      );
    } catch (e, st) {
      _setErrMsg("Export failed", err: e);
      AppLogger.error("onExportAndGenerate exception", [e, st]);
    }
  }

  /// Save user’s project history
  Future<void> onSaveUserData() async {
    final userTrData = state.userData;
    if (userTrData == null) {
      _setErrMsg("No user translation data to save");
      return;
    }
    try {
      await StorageManager.saveTranslation(userTrData);
      await loadProjectHistory();
    } catch (e, st) {
      _setErrMsg("Failed to save user data", err: e);
      AppLogger.error("onSaveUserData exception", [e, st]);
    }
  }

  /// Assign user data
  void setUserData(UserTranslationData trData) {
    state = state.copyWith(userData: trData);
  }

  /// Load saved project history
  Future<void> loadProjectHistory() async {
    try {
      final userTrData = await StorageManager.getSavedTranslationDate();
      AppLogger.debug("load trData $userTrData");
        state = state.copyWith(userTrHistory: userTrData);
    } catch (e, st) {
      _setErrMsg("Couldn't load history", err: e);
      AppLogger.error("loadProjectHistory exception", [e, st]);
    }
  }

  /// Delete a project from history
  Future<void> deleteHistoryItem(UserTranslationData trData) async {
    try {
      await StorageManager.deleteProject(trData);
      await loadProjectHistory();
    } catch (e, st) {
      _setErrMsg("Failed to delete history item", err: e);
      AppLogger.error("deleteHistoryItem exception", [e, st]);
    }
  }

  /// Load a project from history into the current state
  Future<void> editHistoryItem(UserTranslationData trData) async {
    try {
      final sheetData = await _getSheetData(trData.excelFilePath);
      state = state.copyWith(translations: sheetData, userData: trData);
      ref.read(missingKeyProvider.notifier).detectMissing(sheetData);
    } catch (e, st) {
      _setErrMsg("Failed to load project from history", err: e);
      AppLogger.error("editHistoryItem exception", [e, st]);
    }
  }

  Future<Map<String, Map<String, String>>> _getSheetData(
    String filePath,
  ) async {
    try {
      final result = await fileServices.readFile(path: filePath);
      ref.read(rawSheetProvider.notifier).state = result;
      if (validateRaw(result)) {
        return ExcelParser.i.parseTranslation(result, ref: ref);
      }
      return {};
    } catch (e, st) {
      _setErrMsg("Failed to parse sheet", err: e);
      AppLogger.error("_getSheetData exception", [e, st]);
      rethrow;
    }
  }

  bool validateRaw(List<List<dynamic>> rows) {
    if (rows.isEmpty) return false;

    final headers = rows.first;
    if (headers.isEmpty || headers.first.toString().toLowerCase() != "key") {
      return false; // first column must be "key"
    }
    return true;
  }

  Future<void> getSheetData(String filePath, String fileName) async {
    final sheetData = await _getSheetData(filePath);
    _addSheetData(
      sheetData: sheetData,
      trData: UserTranslationData(
        name: fileName,
        excelFilePath: filePath,
        savedTranslateFilePath: '',
        savedLocaleKeyFilePath: '',
      ),
    );
  }

  void _addSheetData({
    required Map<String, Map<String, String>> sheetData,
    required UserTranslationData trData,
  }) {
    state = state.copyWith(translations: sheetData, userData: trData);
  }

  void _setErrMsg(String errMsg, {dynamic err}) {
    AppLogger.error(errMsg, [err]);
    state = state.copyWith(errMsg: errMsg);
  }

  /// Validate data before export
  bool validateData() {
    final data = state.userData;
    return data != null &&
        data.savedLocaleKeyFilePath.isNotEmpty &&
        data.excelFilePath.isNotEmpty &&
        data.savedTranslateFilePath.isNotEmpty;
  }

  /// Reset state
  void clearStateValue() {
    state = TranslationState.initial();
    loadProjectHistory();
  }

  Future<void> onDownloadTemplate() async {
    try {
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Sample Template',
        fileName: 'sample_template.xlsx',
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (outputFile == null) return;

      await fileServices.createSampleTemplate(outputFile);
    } catch (e, st) {
      _setErrMsg("Failed to save template", err: e);
      AppLogger.error("onDownloadTemplate exception", [e, st]);
    }
  }
}
