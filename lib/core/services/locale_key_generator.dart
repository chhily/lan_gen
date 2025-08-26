import 'dart:io';

class LocaleKeyGenerator {
  LocaleKeyGenerator._init();
  static LocaleKeyGenerator? _i;
  static LocaleKeyGenerator get i => _i ??= LocaleKeyGenerator._init();
  bool shouldUseNestedClasses(List<String> keys) {
    return keys.any((key) => key.contains('.'));
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  void _writeNested(StringBuffer buffer, List<String> keys, bool camelCase) {
    final Map<String, dynamic> tree = {};

    // Build nested map structure
    for (var key in keys) {
      var parts = key.split('.');
      var current = tree;
      for (var part in parts) {
        current = current.putIfAbsent(part, () => {}) as Map<String, dynamic>;
      }
    }

    // Recursive class writer
    void writeClass(
      Map<String, dynamic> node,
      String className,
      String prefix,
    ) {
      buffer.writeln("class $className {");
      node.forEach((name, child) {
        final fullKey = prefix.isEmpty ? name : "$prefix.$name";
        if (child.isEmpty) {
          final constName = camelCase ? _toCamelCase(name) : _toSnakeCase(name);
          buffer.writeln("  static const $constName = '$fullKey';");
        } else {
          final nestedName = camelCase ? _capitalize(name) : name.toLowerCase();
          writeClass(child as Map<String, dynamic>, nestedName, fullKey);
        }
      });
      buffer.writeln("}");
    }

    writeClass(tree, "LocaleKeys", "");
  }

  String _toSnakeCase(String text) {
    return text.replaceAll('.', '_').toLowerCase();
  }

  String _toCamelCase(String text) {
    if (text.isEmpty) return text;

    // Normalize separators into spaces
    final separators = RegExp(r'[.\-_ ]+');
    final parts = text.split(separators);

    if (parts.isEmpty) return text;

    // Lowercase first part, capitalize rest
    return parts.first.toLowerCase() +
        parts.skip(1).map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1);
        }).join();
  }

  void generateKeysFile({
    required Map<String, Map<String, String>> translations,
    required String? outputDir,
    bool? nested,
    bool useCamelCase = false,
  }) {
    if (translations.isEmpty) return;

    final firstLang = translations.values.first;
    final keys = firstLang.keys.toList()..sort();

    // If nested is not explicitly set, auto detect
    final useNested = nested ?? shouldUseNestedClasses(keys);

    final buffer = StringBuffer();
    buffer.writeln("// GENERATED FILE - DO NOT MODIFY");
    buffer.writeln("// ignore_for_file: constant_identifier_names");
    buffer.writeln();

    if (!useNested) {
      // flat generation
      buffer.writeln("class LocaleKeys {");
      for (final key in keys) {
        final constName = useCamelCase ? _toCamelCase(key) : _toSnakeCase(key);

        buffer.writeln("  static const $constName = '$key';");
      }
      buffer.writeln("}");
    } else {
      // nested generation
      _writeNested(buffer, keys, useCamelCase);
    }

    final file = File("$outputDir/locale_keys.g.dart");
    file.writeAsStringSync(buffer.toString());
  }
}
