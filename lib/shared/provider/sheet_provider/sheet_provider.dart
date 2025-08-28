import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:translator/translator.dart';

import '../../../core/utils/logger.dart';
import '../../utils/util.dart';

final rawSheetProvider = StateProvider<List<List<dynamic>>>((ref) => []);

final suggestedTranslationProvider =
    StateNotifierProvider<
      SuggestedTranslationNotifier,
      Map<String, Map<String, String>>
    >((ref) => SuggestedTranslationNotifier());

class SuggestedTranslationNotifier
    extends StateNotifier<Map<String, Map<String, String>>> {
  SuggestedTranslationNotifier() : super({});
  final GoogleTranslator _translator = GoogleTranslator();
  final _debouncer = Debouncer(milliseconds: 600);

  Future<void> setSuggestion(
    Map<String, Map<String, String>>? currentTranslate, {
    String sourceLang = 'en',
  }) async {
    if (currentTranslate == null || currentTranslate.isEmpty) return;

    final currentTranslations = {
      for (var lang in currentTranslate.keys)
        lang: Map<String, String>.from(currentTranslate[lang] ?? {}),
    };

    final languages = currentTranslations.keys.toList();
    final keys = currentTranslations[sourceLang]?.keys.toList() ?? [];

    await _debouncer.run(() async {
      for (final lang in languages) {
        if (lang == sourceLang) continue;

        for (final key in keys) {
          final currentValue = currentTranslations[lang]?[key] ?? '';
          if (currentValue.isEmpty) {
            final translated = await translateText(
              currentTranslations[sourceLang]![key]!,
              from: sourceLang,
              to: lang,
            );
            currentTranslations[lang]?[key] = translated;
          }
        }
      }

      // single state update after all translations
      state = {
        for (var l in currentTranslations.keys)
          l: Map<String, String>.from(currentTranslations[l]!),
      };

      AppLogger.verbose("SUGGESTION $state");
    });
  }

  Future<String> translateText(
    String text, {
    String from = 'en',
    required String to,
  }) async {
    if (text.isEmpty) return '';
    try {
      final result = await _translator.translate(text, from: from, to: to);
      return result.text;
    } catch (e) {
      AppLogger.error("Translation error", [e]);
      return '';
    }
  }

  void acceptSuggestion(
    String lang,
    String key,
    void Function(String lang, String key, String value) onApply,
  ) {
    final value = state[lang]?[key] ?? '';
    onApply(lang, key, value);
    removeSuggestion(lang, key);
  }

  void removeSuggestion(String lang, String key) {
    final langMap = Map<String, String>.from(state[lang] ?? {});
    langMap.remove(key);
    final newState = {...state, lang: langMap};
    if (langMap.isEmpty) newState.remove(lang);
    state = newState;
  }

  void clear() => state = {};
}
