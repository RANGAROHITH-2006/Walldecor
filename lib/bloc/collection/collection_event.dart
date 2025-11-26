

abstract class CollectionEvent {}

class FetchCollectionEvent extends CollectionEvent {}

class FetchCollectionDetailsEvent extends CollectionEvent {
  final String CollectionId;

  FetchCollectionDetailsEvent(this.CollectionId);
}

class FetchCollectionDetailsPaginatedEvent extends CollectionEvent {
  final String collectionId;
  final int page;
  final int limit;
  final bool isLoadMore;

  FetchCollectionDetailsPaginatedEvent({
    required this.collectionId,
    this.page = 1,
    this.limit = 15,
    this.isLoadMore = false,
  });
}
