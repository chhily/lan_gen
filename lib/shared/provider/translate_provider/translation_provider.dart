import 'package:file_picker/file_picker.dart';
import 'package:lan_gen/core/utils/logger.dart';
import 'package:lan_gen/core/services/excel_parser.dart';
import 'package:lan_gen/core/services/exportor.dart';
import 'package:lan_gen/shared/provider/app_provider.dart';
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
      if (!mounted) return; // notifier may have been disposed while parsing

      _addSheetData(
        sheetData: sheetData,
        trData: UserTranslationData(
          name: fileName,
          excelFilePath: filePath,
          savedTranslateFilePath: '',
          savedLocaleKeyFilePath: '',
        ),
      );
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
      if (!mounted) return;
      state = state.copyWith(translations: sheetData, userData: trData);
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
      _ensureValidRaw(result);
      return ExcelParser.i.parseTranslation(result, ref: ref);
    } catch (e, st) {
      final message = e is FormatException ? e.message : "Failed to parse sheet";
      _setErrMsg(message, err: e);
      AppLogger.error("_getSheetData exception", [e, st]);
      rethrow;
    }
  }

  bool validateRaw(List<List<dynamic>> rows) {
    try {
      _ensureValidRaw(rows);
      return true;
    } on FormatException {
      return false;
    }
  }

  /// Throws a [FormatException] with a user-facing reason when the sheet
  /// doesn't have the shape we expect, instead of quietly resolving to an
  /// empty translation set.
  void _ensureValidRaw(List<List<dynamic>> rows) {
    if (rows.isEmpty) {
      throw const FormatException("The sheet is empty.");
    }
    final headers = rows.first;
    if (headers.isEmpty || headers.first.toString().toLowerCase() != "key") {
      throw const FormatException('The first column header must be "key".');
    }
    if (headers.length < 2) {
      throw const FormatException(
        'No language columns found — add at least one language column after "key".',
      );
    }
  }

  Future<void> getSheetData(String filePath, String fileName) async {
    try {
      final sheetData = await _getSheetData(filePath);
      if (!mounted) return;
      _addSheetData(
        sheetData: sheetData,
        trData: UserTranslationData(
          name: fileName,
          excelFilePath: filePath,
          savedTranslateFilePath: '',
          savedLocaleKeyFilePath: '',
        ),
      );
    } catch (_) {
      // Already logged and surfaced via _setErrMsg inside _getSheetData.
    }
  }

  /// Sets a single translation value immutably so every widget watching
  /// `translationProvider` rebuilds, instead of the caller mutating the
  /// stored map in place.
  void setTranslationValue(String lang, String key, String value) {
    final current = state.translations;
    if (current == null) return;

    final updated = Map<String, Map<String, String>>.from(current);
    updated[lang] = {...?current[lang], key: value};
    state = state.copyWith(translations: updated);
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

  /// Clear the current error message once it has been shown to the user.
  /// Bypasses `copyWith` (which never overwrites `errMsg` with null) so the
  /// same error can be surfaced again if it recurs.
  void clearErrMsg() {
    state = TranslationState(
      userData: state.userData,
      translations: state.translations,
      userTrHistory: state.userTrHistory,
      errMsg: null,
    );
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
