import 'package:walldecor/models/favorite_model.dart';

abstract class FavoriteState {}

class FavoriteInitial extends FavoriteState {}

class FavoriteLoading extends FavoriteState {}

class FavoriteAddSuccess extends FavoriteState {
  final String message;

  FavoriteAddSuccess({required this.message});
}

class FavoriteAddError extends FavoriteState {
  final String message;

  FavoriteAddError({required this.message});
}

class FavoritesLoaded extends FavoriteState {
  final List<FavoriteImageModel> favorites;

  FavoritesLoaded({required this.favorites});
}

class FavoriteStatusChecked extends FavoriteState {
  final bool isFavorited;

  FavoriteStatusChecked({required this.isFavorited});
}

class FavoriteError extends FavoriteState {
  final String message;

  FavoriteError({required this.message});
}

class FavoriteRemoveSuccess extends FavoriteState {
  final String message;

  FavoriteRemoveSuccess({required this.message});
}

class FavoriteRemoveError extends FavoriteState {
  final String message;

  FavoriteRemoveError({required this.message});
}