class DuplicateRecord {
  final String lang;
  final String key;
  final String oldValue;
  final String newValue;
  final int rowNumber;

  DuplicateRecord({
    required this.lang,
    required this.key,
    required this.oldValue,
    required this.newValue,
    required this.rowNumber,
  });
}
