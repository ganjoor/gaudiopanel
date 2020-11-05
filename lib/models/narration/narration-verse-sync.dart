class NarrationVerseSync {
  final int verseOrder;
  final String verseText;
  final int audioStartMilliseconds;

  NarrationVerseSync(
      {this.verseOrder, this.verseText, this.audioStartMilliseconds});

  factory NarrationVerseSync.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return NarrationVerseSync(
        verseOrder: json['verseOrder'],
        verseText: json['verseText'],
        audioStartMilliseconds: json['audioStartMilliseconds']);
  }
}
