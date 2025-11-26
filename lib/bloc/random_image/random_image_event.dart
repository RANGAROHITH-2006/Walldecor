abstract class RandomImageEvent {}

class FetchRandomImagesEvent extends RandomImageEvent {
  final String categoryId;

  FetchRandomImagesEvent(this.categoryId);
}

class FetchMoreRandomImagesEvent extends RandomImageEvent {
  final String categoryId;

  FetchMoreRandomImagesEvent(this.categoryId);
}