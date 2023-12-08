class UserRecitationProfileViewModel {
  String? id;
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
      required this.name,
      required this.fileSuffixWithoutDash,
      required this.artistName,
      required this.artistUrl,
      required this.audioSrc,
      required this.audioSrcUrl,
      required this.isDefault});

  factory UserRecitationProfileViewModel.fromJson(Map<String, dynamic> json) {
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
    Map<String, dynamic> m = {};
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
