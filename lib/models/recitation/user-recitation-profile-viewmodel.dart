class UserRecitationProfileViewModel {
  final String id;
  String name;
  String fileSuffixWithoutDash;
  String artistName;
  String artistUrl;
  String audioSrc;
  String audioSrcUrl;
  bool isDefault;
  bool isMarked = false;

  UserRecitationProfileViewModel(
      {this.id,
      this.name,
      this.fileSuffixWithoutDash,
      this.artistName,
      this.artistUrl,
      this.audioSrc,
      this.audioSrcUrl,
      this.isDefault});

  factory UserRecitationProfileViewModel.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return UserRecitationProfileViewModel(
      id: json['id'],
      name: json['name'],
      fileSuffixWithoutDash: json['fileSuffixWithoutDash'],
      artistName: json['artistName'],
      artistUrl: json['artistUrl'],
      audioSrc: json['audioSrc'],
      audioSrcUrl: json['audioSrcUrl'],
      isDefault: json['isDefault'],
    );
  }

  toJson() {
    Map<String, dynamic> m = new Map();
    m['id'] = id;
    m['name'] = name;
    m['fileSuffixWithoutDash'] = fileSuffixWithoutDash;
    m['artistName'] = artistName;
    m['artistUrl'] = artistUrl;
    m['audioSrc'] = audioSrc;
    m['audioSrcUrl'] = audioSrcUrl;
    m['isDefault'] = isDefault;
    return m;
  }
}
