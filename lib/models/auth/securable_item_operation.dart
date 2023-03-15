class SecurableItemOperation {
  final String shortName;
  final String description;
  final bool status;

  SecurableItemOperation({this.shortName, this.description, this.status});

  factory SecurableItemOperation.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return SecurableItemOperation(
        shortName: json['shortName'],
        description: json['description'],
        status: json['status']);
  }

  toJson() {
    Map<String, dynamic> m = new Map();
    m['shortName'] = shortName;
    m['description'] = description;
    m['status'] = status;
    return m;
  }
}
