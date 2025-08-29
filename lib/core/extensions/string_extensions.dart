extension StringCaseExtension on String {
  /// Convert string to camelCase
  String toCamelCase() {
    if (isEmpty) return this;

    final parts = split(RegExp(r'[_\s-]+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return this;

    return parts.first.toLowerCase() +
        parts
            .skip(1)
            .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
            .join();
  }

  /// Convert string to snake_case
  String toSnakeCase() {
    if (isEmpty) return this;

    final regex = RegExp(r'(?<=[a-z])[A-Z]');
    final snake = replaceAllMapped(regex, (m) => "_${m.group(0)}");
    return snake.replaceAll(RegExp(r'[\s-]+'), '_').toLowerCase();
  }
}





