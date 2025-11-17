abstract class DownloadEvent {}

class AddToDownloadEvent extends DownloadEvent {
  final String id;
  final Map<String, dynamic> urls;
  final Map<String, dynamic> user;

  AddToDownloadEvent({
    required this.id,
    required this.urls,
    required this.user,
  });
}

class GetAllDownloadsEvent extends DownloadEvent {}

class RemoveFromDownloadEvent extends DownloadEvent {
  final String imageId;

  RemoveFromDownloadEvent({required this.imageId});
}