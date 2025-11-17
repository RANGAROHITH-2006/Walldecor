abstract class FavoriteEvent {}

class AddToFavoriteEvent extends FavoriteEvent {
  final String id;
  final Map<String, dynamic> urls;
  final Map<String, dynamic> user;

  AddToFavoriteEvent({
    required this.id,
    required this.urls,
    required this.user,
  });
}

class GetAllFavoritesEvent extends FavoriteEvent {}

class RemoveFromFavoriteEvent extends FavoriteEvent {
  final String imageId;

  RemoveFromFavoriteEvent({required this.imageId});
}