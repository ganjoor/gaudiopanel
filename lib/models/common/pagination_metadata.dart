class PaginationMetadata {
  final int totalCount;
  final int pageSize;
  int currentPage;
  final int totalPages;
  final bool hasPreviousPage;
  final bool hasNextPage;

  PaginationMetadata(
      {this.totalCount,
      this.pageSize,
      this.currentPage,
      this.totalPages,
      this.hasPreviousPage,
      this.hasNextPage});

  factory PaginationMetadata.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    return PaginationMetadata(
      totalCount: json['totalCount'],
      pageSize: json['pageSize'],
      currentPage: json['currentPage'],
      totalPages: json['totalPages'],
      hasPreviousPage: json['hasPreviousPage'],
      hasNextPage: json['hasNextPage'],
    );
  }
}
