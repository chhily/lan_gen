import 'package:lan_gen/models/translation_data.dart';
import 'package:lan_gen/services/exportor.dart';

class TranslationState {
  final UserTranslationData? userData;
  final Map<String, Map<String, String>>? translations;
  final ExportMode? exportMode;
  final bool useCamelCase;
  final String? errMsg;

  TranslationState({
    this.userData,
    this.translations = const {},
    this.exportMode,
    this.useCamelCase = false,
    this.errMsg,
  });

  TranslationState copyWith({
    UserTranslationData? userData,
     Map<String, Map<String, String>>? translations,

    ExportMode? exportMode,
    bool? useCamelCase,
    String? errMsg,
  }) {
    return TranslationState(
      userData: userData ?? this.userData,
      translations: translations ?? this.translations,
      exportMode: exportMode ?? this.exportMode,
      useCamelCase: useCamelCase ?? this.useCamelCase,
      errMsg: errMsg ?? this.errMsg,
    );
  }
}
