import 'package:lan_gen/core/utils/logger.dart';
import 'package:lan_gen/core/services/excel_parser.dart';
import 'package:lan_gen/core/services/exportor.dart';
import 'package:lan_gen/shared/provider/app_provider.dart';
import 'package:riverpod/riverpod.dart';

import '../../../core/services/storage_service.dart';
import '../../../models/translation_data.dart';
import '../../../core/services/file_services.dart';
import 'translation_state.dart';

final translationProvider =
    StateNotifierProvider<TranslationNotifier, TranslationState>(
      (ref) => TranslationNotifier(ref),
    );

class TranslationNotifier extends StateNotifier<TranslationState> {
  TranslationNotifier(this.ref) : super(TranslationState()) {
    // load history as soon app initialized
    loadProjectHistory();
  }

  final Ref ref;
  final FileServices fileServices = FileServices.i;

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
      final mode = ref.read(exportModeProvider);
      await Exportor.i.exportTranslations(
        state.translations!,
        useCamelCase: state.useCamelCase,
        merge: mode == ExportMode.merge,
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

  /// Toggle camelCase key mode
  void toggleKeyModeBehaviour() {
    state = state.copyWith(useCamelCase: !state.useCamelCase);
  }

  /// Load saved project history
  Future<void> loadProjectHistory() async {
    try {
      final userTrData = await StorageManager.getSavedTranslationDate();
      AppLogger.debug("load trData $userTrData");
      if (userTrData.isNotEmpty) {
        state = state.copyWith(userTrHistory: userTrData);
      }
    } catch (e, st) {
      _setErrMsg("Couldn't load history", err: e);
      AppLogger.error("loadProjectHistory exception", [e, st]);
    }
  }

  Future<Map<String, Map<String, String>>> _getSheetData(
    String filePath,
  ) async {
    try {
      final result = await fileServices.readFile(path: filePath);
      return ExcelParser.i.parseTranslation(result, ref: ref);
    } catch (e, st) {
      _setErrMsg("Failed to parse sheet", err: e);
      AppLogger.error("_getSheetData exception", [e, st]);
      rethrow;
    }
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
    state = state.copyWith(
      userData: null,
      translations: null,
      exportMode: ExportMode.overWrite,
      useCamelCase: false,
      errMsg: null,
    );
  }
}
