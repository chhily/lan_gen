import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:translator/translator.dart';

import '../../../core/utils/logger.dart';
import '../../../models/suggest_item.dart';

final rawSheetProvider = StateProvider<List<List<dynamic>>>((ref) => []);

final suggestedTranslationProvider =
    StateNotifierProvider<
      SuggestedTranslationNotifier,
      SuggestedTranslationState
    >((ref) => SuggestedTranslationNotifier());

class SuggestedTranslationState {
  final Map<String, Map<String, SuggestionItem>> translations;
  final bool isLoading;

  const SuggestedTranslationState({
    this.translations = const {},
    this.isLoading = false,
  });

  SuggestedTranslationState copyWith({
    Map<String, Map<String, SuggestionItem>>? translations,
    bool? isLoading,
  }) {
    return SuggestedTranslationState(
      translations: translations ?? this.translations,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SuggestedTranslationNotifier
    extends StateNotifier<SuggestedTranslationState> {
  SuggestedTranslationNotifier() : super(const SuggestedTranslationState());
  final GoogleTranslator _translator = GoogleTranslator();

  /// Max number of translation requests in flight at once. Keeps the call
  /// bounded/concurrent instead of one-at-a-time, without hammering the
  /// (unofficial) translate endpoint with hundreds of simultaneous requests.
  static const _maxConcurrentRequests = 6;

  /// Per-request cap so a single hung call can't stall the whole batch (and
  /// the full-screen loading spinner) indefinitely.
  static const _requestTimeout = Duration(seconds: 15);

  /// Bumped by [cancelSuggestion] and on every new [setSuggestion] call, so
  /// in-flight requests from a superseded run discard their results instead
  /// of overwriting newer state (the translator client has no cancel hook,
  /// so requests already sent still run to completion or timeout).
  int _generation = 0;


  // Add to SuggestedTranslationNotifier in sheet_provider.dart
  void acceptAllSuggestions(void Function(String lang, String key, String value) onApply,
      ) {
    state.translations.forEach((lang, keysMap) {
      keysMap.forEach((key, item) {
        if (!item.accepted) {
          onApply(lang, key, item.value);
        }
      });
    });

    // Update state to set all as accepted
    final updatedTranslations = state.translations.map((lang, keysMap) {
      return MapEntry(
        lang,
        keysMap.map((key, item) => MapEntry(key, item.copyWith(accepted: true))),
      );
    });
    state = state.copyWith(translations: updatedTranslations);
  }


  Future<void> setSuggestion(
    Map<String, Map<String, String>>? currentTranslate, {
    String sourceLang = 'en',
  }) async {
    if (state.isLoading) return;
    if (currentTranslate == null || currentTranslate.isEmpty) return;

    final sourceMap = currentTranslate[sourceLang];
    if (sourceMap == null || sourceMap.isEmpty) return;

    final pending = <_TranslationTask>[
      for (final lang in currentTranslate.keys)
        if (lang != sourceLang)
          for (final key in sourceMap.keys)
            if ((currentTranslate[lang]?[key] ?? '').isEmpty)
              _TranslationTask(lang: lang, key: key, text: sourceMap[key]!),
    ];

    if (pending.isEmpty) return;

    final myGeneration = ++_generation;
    state = state.copyWith(isLoading: true);
    try {
      final results = <String, Map<String, SuggestionItem>>{};

      await _runWithConcurrency(pending, _maxConcurrentRequests, (item) async {
        if (myGeneration != _generation) return;
        final translated = await _translateText(
          item.text,
          from: sourceLang,
          to: item.lang,
        );
        if (translated.isEmpty) return;
        results.putIfAbsent(item.lang, () => {})[item.key] = SuggestionItem(
          value: translated,
          accepted: false,
        );
      });

      if (myGeneration != _generation) return;
      state = state.copyWith(translations: results, isLoading: false);
      AppLogger.verbose("SUGGESTION ${state.translations}");
    } catch (e, st) {
      if (myGeneration == _generation) {
        state = state.copyWith(isLoading: false);
      }
      AppLogger.error("setSuggestion failed", [e, st]);
    }
  }

  /// Cancels the in-flight auto-translate run; already-sent requests keep
  /// running but their results are discarded once they land.
  void cancelSuggestion() {
    _generation++;
    state = state.copyWith(isLoading: false);
  }

  Future<String> _translateText(
    String text, {
    String from = 'en',
    required String to,
  }) async {
    if (text.isEmpty) return '';
    try {
      final result = await _translator
          .translate(text, from: from, to: to)
          .timeout(_requestTimeout);
      return result.text;
    } on TimeoutException catch (e) {
      AppLogger.error("Translation timed out", [e]);
      return '';
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
    final item = state.translations[lang]?[key];
    if (item == null) return;

    onApply(lang, key, item.value);

    _setAccepted(lang, key);
  }

  void acceptLanguageSuggestion(
    String lang,
    void Function(String key, String value) onApply,
  ) {
    final langMap = state.translations[lang];
    if (langMap == null || langMap.isEmpty) return;

    final newLang = <String, SuggestionItem>{};

    for (final entry in langMap.entries) {
      onApply(entry.key, entry.value.value);

      newLang[entry.key] = entry.value.copyWith(accepted: true);
    }

    state = state.copyWith(
      translations: {...state.translations, lang: newLang},
    );
  }

  void resetSuggestion(String lang, String key) {
    final item = state.translations[lang]?[key];
    if (item == null) return;

    final langMap = Map<String, SuggestionItem>.from(state.translations[lang]!);

    langMap[key] = item.copyWith(accepted: false);

    state = state.copyWith(
      translations: {...state.translations, lang: langMap},
    );
  }

  void _setAccepted(String lang, String key) {
    final item = state.translations[lang]?[key];
    if (item == null) return;

    final langMap = Map<String, SuggestionItem>.from(state.translations[lang]!);

    langMap[key] = item.copyWith(accepted: true);

    state = state.copyWith(
      translations: {...state.translations, lang: langMap},
    );
  }

  void clear() => state = const SuggestedTranslationState();
}

class _TranslationTask {
  final String lang;
  final String key;
  final String text;

  const _TranslationTask({
    required this.lang,
    required this.key,
    required this.text,
  });
}

/// Runs [task] over [items] using a fixed pool of [concurrency] workers that
/// pull the next item as soon as they're free, instead of awaiting one item
/// at a time or blocking on a whole batch's slowest item.
Future<void> _runWithConcurrency<T>(
  List<T> items,
  int concurrency,
  Future<void> Function(T item) task,
) async {
  final iterator = items.iterator;

  Future<void> worker() async {
    while (iterator.moveNext()) {
      await task(iterator.current);
    }
  }

  await Future.wait(
    List.generate(concurrency.clamp(1, items.length), (_) => worker()),
  );
}
