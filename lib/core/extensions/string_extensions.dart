extension StringCaseExtension on String {
  /// Convert string to a valid Dart identifier in camelCase
  String toCamelCase() {
    if (isEmpty) return this;

    final parts = split(
      RegExp(r'[_\s.\-]+'),
    ).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return this;

    final raw =
        parts.first.toLowerCase() +
        parts
            .skip(1)
            .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
            .join();
    return _sanitizeIdentifier(raw);
  }

  /// Convert string to a valid Dart identifier in snake_case
  String toSnakeCase() {
    if (isEmpty) return this;

    final regex = RegExp(r'(?<=[a-z])[A-Z]');
    final snake = replaceAllMapped(regex, (m) => "_${m.group(0)}");
    final raw = snake.replaceAll(RegExp(r'[\s.\-]+'), '_').toLowerCase();
    return _sanitizeIdentifier(raw);
  }
}

/// Strips characters illegal in a Dart identifier and guards against a
/// leading digit or an all-illegal-characters input.
String _sanitizeIdentifier(String raw) {
  final cleaned = raw.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');
  if (cleaned.isEmpty) return '_';
  return RegExp(r'^[0-9]').hasMatch(cleaned) ? '_$cleaned' : cleaned;
}





