import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../repositories/feedback_repository.dart';
import 'feedback_event.dart';
import 'feedback_state.dart';

class FeedbackBloc extends Bloc<FeedbackEvent, FeedbackState> {
  final FeedbackService _feedbackService;

  FeedbackBloc({FeedbackService? feedbackService})
      : _feedbackService = feedbackService ?? FeedbackService(),
        super(const FeedbackState()) {
    on<UpdateRatingEvent>(_onUpdateRating);
    on<UpdateFeedbackOptionEvent>(_onUpdateFeedbackOption);
    on<UpdateCommentEvent>(_onUpdateComment);
    on<SubmitFeedbackEvent>(_onSubmitFeedback);
    on<ResetFeedbackEvent>(_onResetFeedback);
  }

  void _onUpdateRating(UpdateRatingEvent event, Emitter<FeedbackState> emit) {
    emit(state.copyWith(rating: event.rating));
  }

  void _onUpdateFeedbackOption(UpdateFeedbackOptionEvent event, Emitter<FeedbackState> emit) {
    switch (event.option) {
      case 'option1':
        emit(state.copyWith(option1: event.isSelected));
        break;
      case 'option2':
        emit(state.copyWith(option2: event.isSelected));
        break;
      case 'option3':
        emit(state.copyWith(option3: event.isSelected));
        break;
      case 'option4':
        emit(state.copyWith(option4: event.isSelected));
        break;
    }
  }

  void _onUpdateComment(UpdateCommentEvent event, Emitter<FeedbackState> emit) {
    emit(state.copyWith(comment: event.comment));
  }

  void _onSubmitFeedback(SubmitFeedbackEvent event, Emitter<FeedbackState> emit) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    try {
      final success = await _feedbackService.submitFeedback(
        option1: state.option1,
        option2: state.option2,
        option3: state.option3,
        option4: state.option4,
        comment: state.comment,
      );

      if (success) {
        emit(state.copyWith(
          isSubmitting: false,
          isSubmitted: true,
        ));
      } else {
        emit(state.copyWith(
          isSubmitting: false,
          errorMessage: 'Failed to submit feedback. Please try again.',
        ));
      }
    } catch (e) {
      if (kDebugMode) print('Error in feedback bloc: $e');
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: 'An error occurred. Please try again.',
      ));
    }
  }

  void _onResetFeedback(ResetFeedbackEvent event, Emitter<FeedbackState> emit) {
    emit(const FeedbackState());
  }
}