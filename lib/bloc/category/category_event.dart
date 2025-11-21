

abstract class CategoryEvent {}

class FetchCategoryEvent extends CategoryEvent {}

class FetchCategoryDetailsEvent extends CategoryEvent {
  final String categoryId;

  FetchCategoryDetailsEvent(this.categoryId);
}

class FetchCarouselWallpapersEvent extends CategoryEvent {
  final String categorySlug;
  final int limit;

  FetchCarouselWallpapersEvent(this.categorySlug, {this.limit = 4});
}
