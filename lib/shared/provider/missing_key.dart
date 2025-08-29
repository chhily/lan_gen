import 'package:lan_gen/core/extensions/string_extensions.dart';
import 'package:riverpod/riverpod.dart';

import 'app_provider.dart';

final missingKeyProvider =
    StateNotifierProvider<MissingKeyNotifier, MissingKeyState>(
      (ref) => MissingKeyNotifier(ref),
    );

class MissingKeyNotifier extends StateNotifier<MissingKeyState> {
  final Ref ref;

  MissingKeyNotifier(this.ref) : super(MissingKeyState.initial());

  /// Run detection whenever new sheet data is imported
  void detectMissing(Map<String, Map<String, String>> translations) {
    final missingByLang = <String, List<MissingEntry>>{};

    // collect all keys
    final allKeys = <String>{};
    for (final lang in translations.keys) {
      allKeys.addAll(translations[lang]?.keys ?? []);
    }

    // scan languages
    for (final lang in translations.keys) {
      final map = translations[lang] ?? {};
      for (final key in allKeys) {
        final value = map[key];
        if (value == null || value.isEmpty) {
          // find any existing non-empty translation in another language
          final altValue = translations.entries
              .where((e) => e.key != lang)
              .map((e) => e.value[key])
              .firstWhere((v) => v != null && v.isNotEmpty, orElse: () => null);

          missingByLang
              .putIfAbsent(lang, () => [])
              .add(
                MissingEntry(
                  key: key,
                  lang: lang,
                  suggestion: _generateKeySuggestion(altValue),
                ),
              );
        }
      }
    }

    state = state.copyWith(missingByLang: missingByLang);
  }

  /// reset
  void clear() {
    state = MissingKeyState.initial();
  }

  String? _generateKeySuggestion(String? altValue) {
    if (altValue == null || altValue.isEmpty) return null;

    final appCfg = ref.read(appConfigProvider);
    return appCfg.useCamelCase
        ? altValue.toCamelCase()
        : altValue.toSnakeCase();
  }
}

class MissingKeyState {
  final Map<String, List<MissingEntry>> missingByLang;

  const MissingKeyState({required this.missingByLang});

  factory MissingKeyState.initial() => const MissingKeyState(missingByLang: {});

  MissingKeyState copyWith({Map<String, List<MissingEntry>>? missingByLang}) {
    return MissingKeyState(missingByLang: missingByLang ?? this.missingByLang);
  }
}

class MissingEntry {
  final String key;
  final String lang;
  final String? suggestion;

  const MissingEntry({required this.key, required this.lang, this.suggestion});
}
