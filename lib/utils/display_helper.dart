class DisplayHelper {
  DisplayHelper._();

  static String displayValue(String? value, {String fallback = '-'}) {
    final trimmed = value?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      return trimmed;
    }
    return fallback;
  }
}
