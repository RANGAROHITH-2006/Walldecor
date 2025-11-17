// ignore_for_file: avoid_print
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walldecor/bloc/favorite/favorite_event.dart';
import 'package:walldecor/bloc/favorite/favorite_state.dart';
import 'package:walldecor/repositories/favorite_repository.dart';

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  final FavoriteRepository favoriteRepository;

  FavoriteBloc({required this.favoriteRepository}) : super(FavoriteInitial()) {
    on<AddToFavoriteEvent>(_onAddToFavorite);
    on<GetAllFavoritesEvent>(_onGetAllFavorites);
    on<RemoveFromFavoriteEvent>(_onRemoveFromFavorite);
  }

  Future<void> _onAddToFavorite(
    AddToFavoriteEvent event,
    Emitter<FavoriteState> emit,
  ) async {
    emit(FavoriteLoading());
    try {
      print('🔥 FavoriteBloc: Adding to favorites - ${event.id}');
      
      final result = await favoriteRepository.addToFavorites(
        id: event.id,
        urls: event.urls,
        user: event.user,
      );

      print('🔥 FavoriteBloc: Add to favorites result - $result');
      
      if (result['success'] == true || result.containsKey('message')) {
        emit(FavoriteAddSuccess(
          message: result['message'] ?? 'Image added to favorites successfully',
        ));
      } else {
        emit(FavoriteAddError(
          message: result['error'] ?? 'Failed to add to favorites',
        ));
      }
    } catch (e) {
      print('🔥 FavoriteBloc: Add to favorites error - $e');
      emit(FavoriteAddError(message: e.toString()));
    }
  }

  Future<void> _onGetAllFavorites(
    GetAllFavoritesEvent event,
    Emitter<FavoriteState> emit,
  ) async {
    emit(FavoriteLoading());
    try {
      print('🔥 FavoriteBloc: Fetching all favorites');
      
      final favorites = await favoriteRepository.fetchFavorites();
      
      print('🔥 FavoriteBloc: Fetched ${favorites.length} favorites');
      
      emit(FavoritesLoaded(favorites: favorites));
    } catch (e) {
      print('🔥 FavoriteBloc: Fetch favorites error - $e');
      emit(FavoriteError(message: e.toString()));
    }
  }

  Future<void> _onRemoveFromFavorite(
    RemoveFromFavoriteEvent event,
    Emitter<FavoriteState> emit,
  ) async {
    emit(FavoriteLoading());
    try {
      print('🔥 FavoriteBloc: Removing from favorites - ${event.imageId}');
      
      final result = await favoriteRepository.removeFromFavorites(event.imageId);
      
      print('🔥 FavoriteBloc: Remove from favorites result - $result');
      
      if (result['success'] == true || result.containsKey('message')) {
        emit(FavoriteRemoveSuccess(
          message: result['message'] ?? 'Image removed from favorites successfully',
        ));
      } else {
        emit(FavoriteRemoveError(
          message: result['error'] ?? 'Failed to remove from favorites',
        ));
      }
    } catch (e) {
      print('🔥 FavoriteBloc: Remove from favorites error - $e');
      emit(FavoriteRemoveError(message: e.toString()));
    }
  }
}