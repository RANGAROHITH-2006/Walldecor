import 'package:walldecor/models/random_image_model.dart';

abstract class RandomImageState {}

class RandomImageInitial extends RandomImageState {}

class RandomImageLoading extends RandomImageState {}

class RandomImageLoaded extends RandomImageState {
  final List<RandomImageModel> data;
  final bool isLoadingMore;

  RandomImageLoaded(this.data, {this.isLoadingMore = false});

  RandomImageLoaded copyWith({
    List<RandomImageModel>? data,
    bool? isLoadingMore,
  }) {
    return RandomImageLoaded(
      data ?? this.data,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class RandomImageError extends RandomImageState {
  final String message;
  RandomImageError(this.message);
}