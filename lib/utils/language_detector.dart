class LanguageDetector {
  /// Detects if text is primarily Tamil or English
  /// Returns 'ta' for Tamil, 'en' for English
  static String detectLanguage(String text) {
    if (text.isEmpty) return 'en';

    // Count Tamil characters (Tamil Unicode range: 0x0B80 to 0x0BFF)
    int tamilCharCount = 0;
    int totalChars = 0;

    for (int i = 0; i < text.length; i++) {
      int codeUnit = text.codeUnitAt(i);

      // Check if character is Tamil
      if (codeUnit >= 0x0B80 && codeUnit <= 0x0BFF) {
        tamilCharCount++;
        totalChars++;
      }
      // Check if character is alphabetic (English or other Latin)
      else if ((codeUnit >= 65 && codeUnit <= 90) || // A-Z
               (codeUnit >= 97 && codeUnit <= 122)) { // a-z
        totalChars++;
      }
    }

    // If more than 30% of characters are Tamil, consider it Tamil
    if (totalChars > 0 && (tamilCharCount / totalChars) > 0.3) {
      return 'ta';
    }

    return 'en';
  }
}
