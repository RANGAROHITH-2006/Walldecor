abstract class RandomImageEvent {}

class FetchRandomImagesEvent extends RandomImageEvent {
  final String categoryId;

  FetchRandomImagesEvent(this.categoryId);
}