class RecitationVerseSync {
  final int verseOrder;
  final String verseText;
  final int audioStartMilliseconds;

  RecitationVerseSync(
      {required this.verseOrder,
      required this.verseText,
      required this.audioStartMilliseconds});

  factory RecitationVerseSync.fromJson(Map<String, dynamic> json) {
    return RecitationVerseSync(
        verseOrder: json['verseOrder'],
        verseText: json['verseText'],
        audioStartMilliseconds: json['audioStartMilliseconds']);
  }
}
