class RecitationPublishingTrackerViewModel {
  final String userEmail;
  final String poemFullTitle;
  final String artistName;
  final String operation;
  final bool inProgress;
  final bool xmlFileCopied;
  final bool mp3FileCopied;
  final bool firstDbUpdated;
  final bool secondDbUpdated;
  final bool succeeded;
  final bool error;
  final String lastException;
  final String startDate;
  final String finishDate;

  RecitationPublishingTrackerViewModel(
      {this.userEmail,
      this.poemFullTitle,
      this.artistName,
      this.operation,
      this.inProgress,
      this.xmlFileCopied,
      this.mp3FileCopied,
      this.firstDbUpdated,
      this.secondDbUpdated,
      this.succeeded,
      this.error,
      this.lastException,
      this.startDate,
      this.finishDate});

  factory RecitationPublishingTrackerViewModel.fromJson(
      Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return RecitationPublishingTrackerViewModel(
        userEmail: json['userEmail'],
        poemFullTitle: json['poemFullTitle'],
        artistName: json['artistName'],
        operation: json['operation'],
        inProgress: json['inProgress'],
        xmlFileCopied: json['xmlFileCopied'],
        mp3FileCopied: json['mp3FileCopied'],
        firstDbUpdated: json['firstDbUpdated'],
        secondDbUpdated: json['secondDbUpdated'],
        succeeded: json['succeeded'],
        error: json['error'],
        lastException: json['lastException'],
        startDate: json['startDate'],
        finishDate: json['finishDate']);
  }
}
