class UserNarrationProfileViewModel {
  final String id;
  final String name;
  final String fileSuffixWithoutDash;
  final String artistName;
  final String artistUrl;
  final String audioSrc;
  final String audioSrcUrl;
  final bool isDefault;

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
