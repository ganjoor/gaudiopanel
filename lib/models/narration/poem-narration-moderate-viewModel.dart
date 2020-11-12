enum PoemNarrationModerationResult { MetadataNeedsFixation, Approve, Reject }

class PoemNarrationModerateViewModel {
  /// MetadataNeedsFixation = 0
  /// Approve = 1
  /// Reject = 2
  final int result;
  final String message;

  PoemNarrationModerateViewModel({this.result, this.message});

  toJson() {
    Map<String, dynamic> m = new Map();
    m['result'] = result;
    m['message'] = message;
    return m;
  }
}
