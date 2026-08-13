import 'package:lan_gen/models/translation_data.dart';
import 'package:lan_gen/core/services/exportor.dart';

class TranslationState {
  final UserTranslationData? userData;
  final Map<String, Map<String, String>>? translations;
  final List<UserTranslationData>? userTrHistory;
  final String? errMsg;
  final String searchQuery;

  TranslationState({
    this.userData,
    this.translations = const {},
    this.userTrHistory = const [],
    this.errMsg,
    this.searchQuery = '',
  });

  TranslationState.initial({
    this.userData,
    this.translations,
    this.errMsg,
    this.userTrHistory,
    this.searchQuery = '',
  });
  TranslationState copyWith({
    UserTranslationData? userData,
    Map<String, Map<String, String>>? translations,
    List<UserTranslationData>? userTrHistory,
    ExportMode? exportMode,
    bool? useCamelCase,
    String? errMsg,
    String? searchQuery,
  }) {
    return TranslationState(
      userData: userData ?? this.userData,
      translations: translations ?? this.translations,
      userTrHistory: userTrHistory ?? this.userTrHistory,
      errMsg: errMsg ?? this.errMsg,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
