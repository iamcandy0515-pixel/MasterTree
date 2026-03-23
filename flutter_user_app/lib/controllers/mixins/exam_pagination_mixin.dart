mixin ExamPaginationMixin {
  int currentPage = 1;
  int totalPages = 1;
  int totalResults = 0;
  static const int itemsPerPage = 5;

  void firstPagePrimitive() {
    currentPage = 1;
  }

  void lastPagePrimitive() {
    currentPage = totalPages;
  }

  void nextPagePrimitive() {
    if (currentPage < totalPages) {
      currentPage++;
    }
  }

  void prevPagePrimitive() {
    if (currentPage > 1) {
      currentPage--;
    }
  }

  void resetPagination() {
    currentPage = 1;
    totalPages = 1;
    totalResults = 0;
  }
}
