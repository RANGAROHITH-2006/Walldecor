

abstract class CategoryEvent {}

class FetchCategoryEvent extends CategoryEvent {}

class FetchCategoryDetailsEvent extends CategoryEvent {
  final String categoryId;

  FetchCategoryDetailsEvent(this.categoryId);
}

class FetchCategoryDetailsPaginatedEvent extends CategoryEvent {
  final String categoryId;
  final int page;
  final int limit;
  final bool isLoadMore;

  FetchCategoryDetailsPaginatedEvent({
    required this.categoryId,
    this.page = 1,
    this.limit = 15,
    this.isLoadMore = false,
  });
}

class FetchCarouselWallpapersEvent extends CategoryEvent {
  final String categorySlug;
  final int limit;

  FetchCarouselWallpapersEvent(this.categorySlug, {this.limit = 4});
}
