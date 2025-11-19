import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walldecor/bloc/connectivity/connectivity_event.dart';
import 'package:walldecor/bloc/connectivity/connectivity_state.dart';
import 'package:walldecor/repositories/connectivity_repository.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final ConnectivityService _connectivityService;
  StreamSubscription<bool>? _connectivitySubscription;

  ConnectivityBloc(this._connectivityService) : super(ConnectivityInitial()) {
    on<CheckConnectivity>(_onCheckConnectivity);
    on<ConnectivityChanged>(_onConnectivityChanged);
    
    _connectivitySubscription = _connectivityService.connectionStream.listen(
      (isConnected) {
        add(ConnectivityChanged(isConnected));
      },
    );
  }

  void _onCheckConnectivity(CheckConnectivity event, Emitter<ConnectivityState> emit) async {
    final isConnected = await _connectivityService.checkConnectivity();
    if (isConnected) {
      emit(ConnectivityOnline());
    } else {
      emit(ConnectivityOffline());
    }
  }

  void _onConnectivityChanged(ConnectivityChanged event, Emitter<ConnectivityState> emit) {
    if (event.isConnected) {
      emit(ConnectivityOnline());
    } else {
      emit(ConnectivityOffline());
    }
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}