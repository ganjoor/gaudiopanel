import 'package:gaudiopanel/models/auth/public_rapp_user.dart';
import 'package:gaudiopanel/models/recitation/recitation_verse_sync.dart';

enum RecitationModerationResult { metadataNeedsFixation, approve, reject }

class RecitationModerateViewModel {
  /// MetadataNeedsFixation = 0
  /// Approve = 1
  /// Reject = 2
  final int result;
  final String message;

  RecitationModerateViewModel({required this.result, required this.message});

  toJson() {
    Map<String, dynamic> m = {};
    m['result'] = result;
    m['message'] = message;
    return m;
  }
}

class AudioReviewStatus {
  static const int all = -1;
  static const int draft = 0;
  static const int pending = 1;
  static const int approved = 2;
  static const int rejected = 3;
  static const int reported = 4;
  static const int mistakes = 5;

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
      case reported:
        return 'برگشت خورده';
      case mistakes:
        return 'دارای خطا';
      default:
        return 'همه';
    }
  }
}

class RecitationViewModel {
  bool isMarked = false;
  bool isModified = false;
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
  final int audioSyncStatus;
  int reviewStatus;
  List<RecitationVerseSync>? verses;
  final String reviewMsg;

  RecitationViewModel(
      {required this.id,
      required this.owner,
      required this.ganjoorAudioId,
      required this.ganjoorPostId,
      required this.poemFullTitle,
      required this.poemFullUrl,
      required this.mp3Url,
      required this.xmlUrl,
      required this.audioTitle,
      required this.audioArtist,
      required this.audioArtistUrl,
      required this.audioSrc,
      required this.audioSrcUrl,
      required this.mp3SizeInBytes,
      required this.uploadDate,
      required this.audioSyncStatus,
      required this.reviewStatus,
      required this.reviewMsg});

  factory RecitationViewModel.fromJson(Map<String, dynamic> json) {
    return RecitationViewModel(
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
        audioSyncStatus: json['audioSyncStatus'],
        reviewStatus: json['reviewStatus'],
        reviewMsg: json['reviewMsg']);
  }

  toJson() {
    Map<String, dynamic> m = {};
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
    m['audioSyncStatus'] = audioSyncStatus;
    m['reviewStatus'] = reviewStatus;
    m['reviewMsg'] = reviewMsg;
    return m;
  }
}
