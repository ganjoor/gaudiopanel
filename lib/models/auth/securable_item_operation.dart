class SecurableItemOperation {
  final String shortName;
  final String description;
  final bool status;

  SecurableItemOperation(
      {required this.shortName,
      required this.description,
      required this.status});

  factory SecurableItemOperation.fromJson(Map<String, dynamic> json) {
    return SecurableItemOperation(
        shortName: json['shortName'],
        description: json['description'],
        status: json['status']);
  }

  toJson() {
    Map<String, dynamic> m = {};
    m['shortName'] = shortName;
    m['description'] = description;
    m['status'] = status;
    return m;
  }
}
