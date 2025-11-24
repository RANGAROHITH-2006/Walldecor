import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walldecor/bloc/random_image/random_image_event.dart';
import 'package:walldecor/bloc/random_image/random_image_state.dart';
import 'package:walldecor/repositories/random_image_repository.dart';

class RandomImageBloc extends Bloc<RandomImageEvent, RandomImageState> {
  final RandomImageRepository repository;

  RandomImageBloc(this.repository) : super(RandomImageInitial()) {
    on<FetchRandomImagesEvent>(_onFetchRandomImages);
  }

  Future<void> _onFetchRandomImages(
    FetchRandomImagesEvent event,
    Emitter<RandomImageState> emit,
  ) async {
    emit(RandomImageLoading());
    try {
      final data = await repository.fetchRandomImages(event.categoryId);
      emit(RandomImageLoaded(data));
    } catch (e) {
      emit(RandomImageError(e.toString()));
    }
  }
}