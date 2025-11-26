import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walldecor/bloc/random_image/random_image_event.dart';
import 'package:walldecor/bloc/random_image/random_image_state.dart';
import 'package:walldecor/repositories/random_image_repository.dart';

class RandomImageBloc extends Bloc<RandomImageEvent, RandomImageState> {
  final RandomImageRepository repository;
  String? currentCategoryId;

  RandomImageBloc(this.repository) : super(RandomImageInitial()) {
    on<FetchRandomImagesEvent>(_onFetchRandomImages);
    on<FetchMoreRandomImagesEvent>(_onFetchMoreRandomImages);
  }

  Future<void> _onFetchRandomImages(
    FetchRandomImagesEvent event,
    Emitter<RandomImageState> emit,
  ) async {
    currentCategoryId = event.categoryId;
    emit(RandomImageLoading());
    try {
      final data = await repository.fetchRandomImages(event.categoryId);
      emit(RandomImageLoaded(data));
    } catch (e) {
      emit(RandomImageError(e.toString()));
    }
  }

  Future<void> _onFetchMoreRandomImages(
    FetchMoreRandomImagesEvent event,
    Emitter<RandomImageState> emit,
  ) async {
    final currentState = state;
    if (currentState is RandomImageLoaded && !currentState.isLoadingMore) {
      // Set loading more state
      emit(currentState.copyWith(isLoadingMore: true));
      
      try {
        final newData = await repository.fetchRandomImagesInfinite(event.categoryId);
        final allData = [...currentState.data, ...newData];
        emit(RandomImageLoaded(allData, isLoadingMore: false));
      } catch (e) {
        emit(currentState.copyWith(isLoadingMore: false));
        // Optionally emit error or just keep current state
      }
    }
  }
}