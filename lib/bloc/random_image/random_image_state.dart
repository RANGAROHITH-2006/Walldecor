import 'package:walldecor/models/random_image_model.dart';

abstract class RandomImageState {}

class RandomImageInitial extends RandomImageState {}

class RandomImageLoading extends RandomImageState {}

class RandomImageLoaded extends RandomImageState {
  final List<RandomImageModel> data;
  RandomImageLoaded(this.data);
}

class RandomImageError extends RandomImageState {
  final String message;
  RandomImageError(this.message);
}