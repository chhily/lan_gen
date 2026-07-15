class SuggestionItem {
  final String value;
  final bool accepted;

  const SuggestionItem({
    required this.value,
    this.accepted = false,
  });

  SuggestionItem copyWith({
    String? value,
    bool? accepted,
  }) {
    return SuggestionItem(
      value: value ?? this.value,
      accepted: accepted ?? this.accepted,
    );
  }
}