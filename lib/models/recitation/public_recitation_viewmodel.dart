import 'recitation_verse_sync.dart';

class PublicRecitationViewModel {
  final int id;
  final int poemId;
  final String poemFullTitle;
  final String poemFullUrl;
  final String audioTitle;
  final String audioArtist;
  final String audioArtistUrl;
  final String audioSrc;
  final String audioSrcUrl;
  final String legacyAudioGuid;
  final String mp3FileCheckSum;
  final int mp3SizeInBytes;
  final String publishDate;
  final String fileLastUpdated;
  final String mp3Url;
  final String xmlText;
  final String plainText;
  final String htmlText;
  List<RecitationVerseSync>? verses;
  bool isExpanded = false;

  PublicRecitationViewModel(
      {required this.id,
      required this.poemId,
      required this.poemFullTitle,
      required this.poemFullUrl,
      required this.audioTitle,
      required this.audioArtist,
      required this.audioArtistUrl,
      required this.audioSrc,
      required this.audioSrcUrl,
      required this.legacyAudioGuid,
      required this.mp3FileCheckSum,
      required this.mp3SizeInBytes,
      required this.publishDate,
      required this.fileLastUpdated,
      required this.mp3Url,
      required this.xmlText,
      required this.plainText,
      required this.htmlText});

  factory PublicRecitationViewModel.fromJson(Map<String, dynamic> json) {
    return PublicRecitationViewModel(
        id: json['id'],
        poemId: json['poemId'],
        poemFullTitle: json['poemFullTitle'],
        poemFullUrl: json['poemFullUrl'],
        audioTitle: json['audioTitle'],
        audioArtist: json['audioArtist'],
        audioArtistUrl: json['audioArtistUrl'],
        audioSrc: json['audioSrc'],
        audioSrcUrl: json['audioSrcUrl'],
        legacyAudioGuid: json['legacyAudioGuid'],
        mp3FileCheckSum: json['mp3FileCheckSum'],
        mp3SizeInBytes: json['mp3SizeInBytes'],
        publishDate: json['publishDate'],
        fileLastUpdated: json['fileLastUpdated'],
        mp3Url: json['mp3Url'],
        xmlText: json['xmlText'],
        plainText: json['plainText'],
        htmlText: json['htmlText']);
  }
}
