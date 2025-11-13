

abstract class CategoryEvent {}

class FetchCategoryEvent extends CategoryEvent {}

class FetchCategoryDetailsEvent extends CategoryEvent {
  final String categoryId;

  FetchCategoryDetailsEvent(this.categoryId);
}
