import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walldecor/repositories/guest_repository.dart';
import 'guest_event.dart';
import 'guest_state.dart';

class GuestBloc extends Bloc<GuestEvent, GuestState> {
  final GuestRepository _guestRepository;

  GuestBloc({required GuestRepository guestRepository})
    : _guestRepository = guestRepository,
      super(const GuestInitial()) {
    on<CheckGuestEvent>(_onCheckGuest);
    on<CreateGuestEvent>(_onCreateGuest);
    on<LogoutGuestEvent>(_onLogoutGuest);
  }

  /// Here we will check CheckGuestEvent
  Future<void> _onCheckGuest(
    CheckGuestEvent event,
    Emitter<GuestState> emit,
  ) async {
    emit(const GuestLoading());
    try {
      final token = await _guestRepository.getStoredGuestToken();
      print('Stored guest token: $token');
      if (token != null && token.isNotEmpty) {
        emit(GuestCreated(token));
      } else {
        // No token found, create guest account
        add(const CreateGuestEvent());
      }
    } catch (e) {
      emit(GuestError('Failed to check guest status: ${e.toString()}'));
    }
  }

  /// Handle CreateGuestEvent
  Future<void> _onCreateGuest(
    CreateGuestEvent event,
    Emitter<GuestState> emit,
  ) async {
    if (state is! GuestLoading) {
      emit(const GuestLoading());
    }

    try {
      final token = await _guestRepository.createGuestAccount();
      emit(GuestCreated(token));
    } catch (e) {
      emit(GuestError('Failed to create guest account: ${e.toString()}'));
    }
  }

  /// Handle LogoutGuestEvent
  Future<void> _onLogoutGuest(
    LogoutGuestEvent event,
    Emitter<GuestState> emit,
  ) async {
    emit(const GuestLoading());

    try {
      await _guestRepository.removeGuestToken();
      emit(const GuestInitial());
    } catch (e) {
      emit(GuestError('Failed to logout: ${e.toString()}'));
    }
  }
}
