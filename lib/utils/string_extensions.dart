
extension StringExtensions on String {
  /// Capitalizes the first letter and makes the rest lowercase.
  String toSentenceCase() {
    if (isEmpty) return this;
    if (length == 1) return toUpperCase();
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}
