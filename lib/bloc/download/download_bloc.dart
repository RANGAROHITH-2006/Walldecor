// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walldecor/bloc/download/download_event.dart';
import 'package:walldecor/bloc/download/download_state.dart';
import 'package:walldecor/repositories/download_repository.dart';

class DownloadBloc extends Bloc<DownloadEvent, DownloadState> {
  final DownloadRepository downloadRepository;

  DownloadBloc({required this.downloadRepository}) : super(DownloadInitial()) {
    on<AddToDownloadEvent>(_onAddToDownload);
    on<GetAllDownloadsEvent>(_onGetAllDownloads);
    on<RemoveFromDownloadEvent>(_onRemoveFromDownload);
    on<CheckDownloadStatusEvent>(_onCheckDownloadStatus);
    on<CheckDownloadLimitEvent>(_onCheckDownloadLimit);
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
      
      if (result['success'] == true) {
        emit(DownloadAddSuccess(
          message: result['message'] ?? 'Image added to downloads successfully',
        ));
      } else {
        emit(DownloadAddError(
          message: result['message'] ?? result['error'] ?? 'Failed to add to downloads',
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
      
      if (result['success'] == true) {
        emit(DownloadRemoveSuccess(
          message: result['message'] ?? 'Image removed from downloads successfully',
        ));
      } else {
        emit(DownloadRemoveError(
          message: result['message'] ?? result['error'] ?? 'Failed to remove from downloads',
        ));
      }
    } catch (e) {
      print('🔥 DownloadBloc: Remove from downloads error - $e');
      emit(DownloadRemoveError(message: e.toString()));
    }
  }

  Future<void> _onCheckDownloadStatus(
    CheckDownloadStatusEvent event,
    Emitter<DownloadState> emit,
  ) async {
    try {
      print('🔥 DownloadBloc: Checking download status for - ${event.imageId}');
      
      final isDownloaded = await downloadRepository.isImageDownloaded(event.imageId);
      
      print('🔥 DownloadBloc: Image ${event.imageId} download status - $isDownloaded');
      
      emit(DownloadStatusChecked(
        imageId: event.imageId,
        isDownloaded: isDownloaded,
      ));
    } catch (e) {
      print('🔥 DownloadBloc: Check download status error - $e');
      emit(DownloadError(message: e.toString()));
    }
  }

  Future<void> _onCheckDownloadLimit(
    CheckDownloadLimitEvent event,
    Emitter<DownloadState> emit,
  ) async {
    try {
      print('🔥 DownloadBloc: Checking download limit');
      
      // Get user's pro status from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      bool isProUser = false;
      
      if (userDataString != null) {
        try {
          // Parse user data to check pro status
          final userData = jsonDecode(userDataString);
          isProUser = (userData['isProUser'] == true) || 
                     (userData['hasActiveSubscription'] == true) ||
                     (userData['userType'] == 'premium');
        } catch (e) {
          // Fallback to string checking if JSON parsing fails
          isProUser = userDataString.contains('"isProUser":true') || 
                     userDataString.contains('"hasActiveSubscription":true') ||
                     userDataString.contains('"userType":"premium"');
        }
      }
      
      // Get current download count
      final downloads = await downloadRepository.fetchDownloads();
      final currentCount = downloads.length;
      
      // Set limits: 10 for normal users, unlimited for pro users
      final maxLimit = isProUser ? -1 : 10; // -1 means unlimited
      final canDownload = isProUser || currentCount < 10;
      
      print('🔥 DownloadBloc: User is pro: $isProUser, current downloads: $currentCount, can download: $canDownload');
      
      emit(DownloadLimitChecked(
        currentCount: currentCount,
        maxLimit: maxLimit,
        canDownload: canDownload,
        isProUser: isProUser,
      ));
    } catch (e) {
      print('🔥 DownloadBloc: Check download limit error - $e');
      emit(DownloadError(message: e.toString()));
    }
  }
}