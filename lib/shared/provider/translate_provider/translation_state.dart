import 'package:lan_gen/models/translation_data.dart';
import 'package:lan_gen/core/services/exportor.dart';

class TranslationState {
  final UserTranslationData? userData;
  final Map<String, Map<String, String>>? translations;
  final List<UserTranslationData>? userTrHistory;
  final ExportMode? exportMode;
  bool useCamelCase;
  final String? errMsg;

  TranslationState({
    this.userData,
    this.translations = const {},
    this.userTrHistory = const [],
    this.exportMode,
    this.useCamelCase = false,
    this.errMsg,
  });

  TranslationState.initial({
    this.userData,
    this.translations,
    this.exportMode = ExportMode.overWrite,
    this.useCamelCase = false,
    this.errMsg,
    this.userTrHistory,
  });
  TranslationState copyWith({
    UserTranslationData? userData,
    Map<String, Map<String, String>>? translations,
    List<UserTranslationData>? userTrHistory,
    ExportMode? exportMode,
    bool? useCamelCase,
    String? errMsg,
  }) {
    return TranslationState(
      userData: userData ?? this.userData,
      translations: translations ?? this.translations,
      userTrHistory: userTrHistory ?? this.userTrHistory,
      exportMode: exportMode ?? this.exportMode,
      useCamelCase: useCamelCase ?? this.useCamelCase,
      errMsg: errMsg ?? this.errMsg,
    );
  }
}
