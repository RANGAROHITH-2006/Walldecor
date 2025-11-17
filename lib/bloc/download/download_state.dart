import 'package:walldecor/models/download_model.dart';

abstract class DownloadState {}

class DownloadInitial extends DownloadState {}

class DownloadLoading extends DownloadState {}

class DownloadAddSuccess extends DownloadState {
  final String message;

  DownloadAddSuccess({required this.message});
}

class DownloadAddError extends DownloadState {
  final String message;

  DownloadAddError({required this.message});
}

class DownloadsLoaded extends DownloadState {
  final List<DownloadImageModel> downloads;

  DownloadsLoaded({required this.downloads});
}

class DownloadError extends DownloadState {
  final String message;

  DownloadError({required this.message});
}

class DownloadRemoveSuccess extends DownloadState {
  final String message;

  DownloadRemoveSuccess({required this.message});
}

class DownloadRemoveError extends DownloadState {
  final String message;

  DownloadRemoveError({required this.message});
}