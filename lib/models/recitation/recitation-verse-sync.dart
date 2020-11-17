class RecitationVerseSync {
  final int verseOrder;
  final String verseText;
  final int audioStartMilliseconds;

  RecitationVerseSync(
      {this.verseOrder, this.verseText, this.audioStartMilliseconds});

  factory RecitationVerseSync.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return RecitationVerseSync(
        verseOrder: json['verseOrder'],
        verseText: json['verseText'],
        audioStartMilliseconds: json['audioStartMilliseconds']);
  }
}
