class PaginationModel {
  final int currentPage;
  final int perPage;
  final int totalPages;
  final int totalItems;

  const PaginationModel({
    required this.currentPage,
    required this.perPage,
    required this.totalPages,
    required this.totalItems,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      currentPage: json['current_page'] as int,
      perPage: json['per_page'] as int,
      totalPages: json['total_pages'] as int,
      totalItems: json['total_items'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'per_page': perPage,
      'total_pages': totalPages,
      'total_items': totalItems,
    };
  }

  bool get hasNextPage => currentPage < totalPages;
  bool get hasPreviousPage => currentPage > 1;
}
