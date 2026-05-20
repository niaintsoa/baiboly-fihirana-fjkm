class TextCleaner {
  static String cleanVerseText(String text, int verseNumber) {
    final prefix1 = "$verseNumber ";
    final prefix2 = "$verseNumber. ";
    if (text.startsWith(prefix2)) {
      return text.substring(prefix2.length).trim();
    } else if (text.startsWith(prefix1)) {
      return text.substring(prefix1.length).trim();
    }
    return text;
  }
}
