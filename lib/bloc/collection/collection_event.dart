

abstract class CollectionEvent {}

class FetchCollectionEvent extends CollectionEvent {}

class FetchCollectionDetailsEvent extends CollectionEvent {
  final String CollectionId;

  FetchCollectionDetailsEvent(this.CollectionId);
}
