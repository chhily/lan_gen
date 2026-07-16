import 'dart:io';

import 'package:lan_gen/core/extensions/string_extensions.dart';

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

  /// Marks a tree node as a real translation key (as opposed to a namespace
  /// segment introduced only because deeper dotted keys exist under it), so
  /// a key that is both a leaf and a parent — e.g. "home" and "home.title"
  /// both present — keeps its own value instead of it being silently
  /// dropped once the node gains children.
  static const _leafMarker = '__leaf__';

  void _writeNested(StringBuffer buffer, List<String> keys, bool camelCase) {
    final Map<String, dynamic> tree = {};

    // Build nested map structure
    for (var key in keys) {
      var parts = key.split('.');
      var current = tree;
      for (var i = 0; i < parts.length; i++) {
        current =
            current.putIfAbsent(parts[i], () => <String, dynamic>{})
                as Map<String, dynamic>;
        if (i == parts.length - 1) {
          current[_leafMarker] = true;
        }
      }
    }

    // Dart doesn't allow a class declaration inside another class's body, so
    // each namespace becomes its own top-level class instead of a literal
    // nested one.
    void writeClass(
      Map<String, dynamic> node,
      String className,
      String prefix,
    ) {
      final usedNames = <String>{};
      final nestedClasses = <MapEntry<String, String>>[]; // (name, fullKey)

      buffer.writeln("class $className {");
      for (final entry in node.entries) {
        final name = entry.key;
        if (name == _leafMarker) continue;
        final child = entry.value as Map<String, dynamic>;
        final fullKey = prefix.isEmpty ? name : "$prefix.$name";
        final hasChildren = child.keys.any((k) => k != _leafMarker);

        if (child.containsKey(_leafMarker)) {
          final suffix = hasChildren ? (camelCase ? 'Value' : '_value') : '';
          final baseName =
              (camelCase ? name.toCamelCase() : name.toSnakeCase()) + suffix;
          final constName = _uniqueName(baseName, usedNames);
          buffer.writeln("  static const $constName = '$fullKey';");
        }

        if (hasChildren) {
          nestedClasses.add(MapEntry(name, fullKey));
        }
      }
      buffer.writeln("}");

      for (final entry in nestedClasses) {
        final name = entry.key;
        final fullKey = entry.value;
        final nestedName = camelCase
            ? _capitalize(name.toCamelCase())
            : name.toSnakeCase();
        writeClass(node[name] as Map<String, dynamic>, nestedName, fullKey);
      }
    }

    writeClass(tree, "LocaleKeys", "");
  }

  /// Appends a numeric suffix when two keys normalize to the same identifier
  /// (e.g. "user-name" and "user_name"), so generation never emits two
  /// static consts with the same name.
  String _uniqueName(String base, Set<String> used) {
    var name = base;
    var suffix = 2;
    while (!used.add(name)) {
      name = '${base}_$suffix';
      suffix++;
    }
    return name;
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
      final usedNames = <String>{};
      for (final key in keys) {
        final baseName = useCamelCase ? key.toCamelCase() : key.toSnakeCase();
        final constName = _uniqueName(baseName, usedNames);

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
