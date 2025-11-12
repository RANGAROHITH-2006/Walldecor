import 'package:equatable/equatable.dart';

abstract class GuestEvent extends Equatable {
  const GuestEvent();

  @override
  List<Object> get props => [];
}

/// Event to check if guest token exists in SharedPreferences
class CheckGuestEvent extends GuestEvent {
  const CheckGuestEvent();
}

/// Event to create a new guest account via API
class CreateGuestEvent extends GuestEvent {
  const CreateGuestEvent();
}



/// Event to logout guest (remove token)
class LogoutGuestEvent extends GuestEvent {
  const LogoutGuestEvent();
}