import 'package:lan_gen/services/excel_parser.dart';
import 'package:lan_gen/services/exportor.dart';
import 'package:lan_gen/shared/provider/app_provider.dart';
import 'package:riverpod/riverpod.dart';

import '../../../models/translation_data.dart';
import '../../../services/file_services.dart';
import 'translation_state.dart';

final translationProvider =
    StateNotifierProvider<TranslationNotifier, TranslationState>(
      (ref) => TranslationNotifier(ref),
    );

class TranslationNotifier extends StateNotifier<TranslationState> {
  TranslationNotifier(this.ref) : super(TranslationState());

  final Ref ref;

  FileServices fileServices = FileServices.i;

  Future<void> onImportSheet() async {
    try {
      final result = await fileServices.pickExcelFile();
      if (result != null) {
        final filePath = result.files.single.path;
        final fileName = result.files.single.name;
        final sheetData = await _getSheetData(filePath);
        _addSheetData(
          sheetData: sheetData,
          trData: UserTranslationData(
            name: fileName,
            excelFilePath: filePath ?? "",
            savedTranslateFilePath: '',
            savedLocaleKeyFilePath: '',
          ),
        );
      }
    } catch (e) {
      _setErrMsg(e.toString());
    }
  }

  void onExportAndGenerate() {
    final mode = ref.watch(exportModeProvider);
    if (state.translations == null) {
      _setErrMsg("Translations is empty :D");
      return;
    }
    Exportor.i.exportTranslations(
      state.translations ?? {},
      useCamelCase: state.useCamelCase,
      merge: mode == ExportMode.merge ? true : false,
      userDir: state.userData?.savedTranslateFilePath,
      userLocaleKeyDir: state.userData?.savedLocaleKeyFilePath,
    );
  }

  /// use when assign generate file;
  void setUserData (UserTranslationData trData) {
    state = state.copyWith(userData: trData);
  }

  void loadProjectHistory() {}

  Future<Map<String, Map<String, String>>> _getSheetData(
    String? filePath,
  ) async {
    try {
      final result = await fileServices.readFile(path: filePath);

      return ExcelParser.i.parseTranslation(result);
    } catch (e) {
      _setErrMsg(e.toString());
      rethrow;
    }
  }

  void _addSheetData({
    required Map<String, Map<String, String>> sheetData,
    required UserTranslationData trData,
  }) {
    state = state.copyWith(translations: sheetData, userData: trData);
  }



  void _setErrMsg(String errMsg) {
    state = state.copyWith(errMsg: errMsg);
  }

  bool validateDate() {
    final data = state.userData;
    return data?.savedLocaleKeyFilePath != null &&
        data?.excelFilePath != null &&
        data?.savedTranslateFilePath != null &&
        isNotEmptyUserData();
  }

  bool isNotEmptyUserData() {
    final data = state.userData;
    return (data?.savedLocaleKeyFilePath.isNotEmpty ?? false) &&
        (data?.excelFilePath.isNotEmpty ?? false) &&
        (data?.savedTranslateFilePath.isNotEmpty ?? false);
  }

  void clearStateValue() {
    state = state.copyWith(
      userData: null,
      exportMode: ExportMode.overWrite,
      useCamelCase: false,
      errMsg: null,
    );
  }
}
