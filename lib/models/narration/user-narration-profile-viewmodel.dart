class UserNarrationProfileViewModel {
  final String id;
  String name;
  String fileSuffixWithoutDash;
  String artistName;
  String artistUrl;
  String audioSrc;
  String audioSrcUrl;
  final bool isDefault;
  bool isExpanded = false;
  bool isMarked = false;
  bool modified = false;

  UserNarrationProfileViewModel(
      {this.id,
      this.name,
      this.fileSuffixWithoutDash,
      this.artistName,
      this.artistUrl,
      this.audioSrc,
      this.audioSrcUrl,
      this.isDefault});

  factory UserNarrationProfileViewModel.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return UserNarrationProfileViewModel(
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
}
