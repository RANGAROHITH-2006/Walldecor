// ignore_for_file: avoid_print
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walldecor/bloc/download/download_event.dart';
import 'package:walldecor/bloc/download/download_state.dart';
import 'package:walldecor/repositories/download_repository.dart';

class DownloadBloc extends Bloc<DownloadEvent, DownloadState> {
  final DownloadRepository downloadRepository;

  DownloadBloc({required this.downloadRepository}) : super(DownloadInitial()) {
    on<AddToDownloadEvent>(_onAddToDownload);
    on<GetAllDownloadsEvent>(_onGetAllDownloads);
    on<RemoveFromDownloadEvent>(_onRemoveFromDownload);
  }

  Future<void> _onAddToDownload(
    AddToDownloadEvent event,
    Emitter<DownloadState> emit,
  ) async {
    emit(DownloadLoading());
    try {
      print('🔥 DownloadBloc: Adding to downloads - ${event.id}');
      
      final result = await downloadRepository.addToDownloads(
        id: event.id,
        urls: event.urls,
        user: event.user,
      );

      print('🔥 DownloadBloc: Add to downloads result - $result');
      
      if (result['success'] == true || result.containsKey('message')) {
        emit(DownloadAddSuccess(
          message: result['message'] ?? 'Image added to downloads successfully',
        ));
      } else {
        emit(DownloadAddError(
          message: result['error'] ?? 'Failed to add to downloads',
        ));
      }
    } catch (e) {
      print('🔥 DownloadBloc: Add to downloads error - $e');
      emit(DownloadAddError(message: e.toString()));
    }
  }

  Future<void> _onGetAllDownloads(
    GetAllDownloadsEvent event,
    Emitter<DownloadState> emit,
  ) async {
    emit(DownloadLoading());
    try {
      print('🔥 DownloadBloc: Fetching all downloads');
      
      final downloads = await downloadRepository.fetchDownloads();
      
      print('🔥 DownloadBloc: Fetched ${downloads.length} downloads');
      
      emit(DownloadsLoaded(downloads: downloads));
    } catch (e) {
      print('🔥 DownloadBloc: Fetch downloads error - $e');
      emit(DownloadError(message: e.toString()));
    }
  }

  Future<void> _onRemoveFromDownload(
    RemoveFromDownloadEvent event,
    Emitter<DownloadState> emit,
  ) async {
    emit(DownloadLoading());
    try {
      print('🔥 DownloadBloc: Removing from downloads - ${event.imageId}');
      
      final result = await downloadRepository.removeFromDownloads(event.imageId);
      
      print('🔥 DownloadBloc: Remove from downloads result - $result');
      
      if (result['success'] == true || result.containsKey('message')) {
        emit(DownloadRemoveSuccess(
          message: result['message'] ?? 'Image removed from downloads successfully',
        ));
      } else {
        emit(DownloadRemoveError(
          message: result['error'] ?? 'Failed to remove from downloads',
        ));
      }
    } catch (e) {
      print('🔥 DownloadBloc: Remove from downloads error - $e');
      emit(DownloadRemoveError(message: e.toString()));
    }
  }
}