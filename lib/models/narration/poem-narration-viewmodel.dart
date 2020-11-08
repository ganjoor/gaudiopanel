import 'package:gaudiopanel/models/auth/public-rapp-user.dart';
import 'package:gaudiopanel/models/narration/narration-verse-sync.dart';

class AudioReviewStatus {
  static const int draft = 0;
  static const int pending = 1;
  static const int approved = 2;
  static const int rejected = 3;

  static String valueToString(int value) {
    switch (value) {
      case draft:
        return 'پیش‌نویس';
      case pending:
        return 'در انتظار بررسی';
      case approved:
        return 'تأیید شده';
      case rejected:
        return 'رد شده';
      default:
        return 'همه';
    }
  }
}

class PoemNarrationViewModel {
  bool isMarked = false;
  final int id;
  final PublicRAppUser owner;
  final int ganjoorAudioId;
  final int ganjoorPostId;
  final String poemFullTitle;
  final String poemFullUrl;
  final String mp3Url;
  final String xmlUrl;
  String audioTitle;
  String audioArtist;
  String audioArtistUrl;
  String audioSrc;
  String audioSrcUrl;
  final int mp3SizeInBytes;
  final String uploadDate;
  final List<int> audioSyncStatusArray;
  int reviewStatus;
  List<NarrationVerseSync> verses;

  PoemNarrationViewModel(
      {this.id,
      this.owner,
      this.ganjoorAudioId,
      this.ganjoorPostId,
      this.poemFullTitle,
      this.poemFullUrl,
      this.mp3Url,
      this.xmlUrl,
      this.audioTitle,
      this.audioArtist,
      this.audioArtistUrl,
      this.audioSrc,
      this.audioSrcUrl,
      this.mp3SizeInBytes,
      this.uploadDate,
      this.audioSyncStatusArray,
      this.reviewStatus});

  factory PoemNarrationViewModel.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return PoemNarrationViewModel(
        id: json['id'],
        owner: PublicRAppUser.fromJson(json['owner']),
        ganjoorAudioId: json['ganjoorAudioId'],
        ganjoorPostId: json['ganjoorPostId'],
        poemFullTitle: json['poemFullTitle'],
        poemFullUrl: json['poemFullUrl'],
        mp3Url: json['mp3Url'],
        xmlUrl: json['xmlUrl'],
        audioTitle: json['audioTitle'],
        audioArtist: json['audioArtist'],
        audioArtistUrl: json['audioArtistUrl'],
        audioSrc: json['audioSrc'],
        audioSrcUrl: json['audioSrcUrl'],
        mp3SizeInBytes: json['mp3SizeInBytes'],
        uploadDate: json['uploadDate'],
        audioSyncStatusArray:
            (json['audioSyncStatusArray'] as List).cast<int>().toList(),
        reviewStatus: json['reviewStatus']);
  }

  toJson() {
    Map<String, dynamic> m = new Map();
    m['id'] = id;
    m['owner'] = owner.toJson();
    m['ganjoorAudioId'] = ganjoorAudioId;
    m['ganjoorPostId'] = ganjoorPostId;
    m['poemFullTitle'] = poemFullTitle;
    m['poemFullUrl'] = poemFullUrl;
    m['mp3Url'] = mp3Url;
    m['xmlUrl'] = xmlUrl;
    m['audioTitle'] = audioTitle;
    m['audioArtist'] = audioArtist;
    m['audioArtistUrl'] = audioArtistUrl;
    m['audioSrc'] = audioSrc;
    m['audioSrcUrl'] = audioSrcUrl;
    m['mp3SizeInBytes'] = mp3SizeInBytes;
    m['uploadDate'] = uploadDate;
    m['audioSyncStatusArray'] = audioSyncStatusArray;
    m['reviewStatus'] = reviewStatus;
    return m;
  }
}
