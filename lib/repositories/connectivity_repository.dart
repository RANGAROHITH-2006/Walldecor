import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  
  factory ConnectivityService() {
    return _instance;
  }
  
  ConnectivityService._internal();
  
  final Connectivity _connectivity = Connectivity();
  late StreamController<bool> _connectionStreamController;
  
  Stream<bool> get connectionStream => _connectionStreamController.stream;
  
  bool _isConnected = false;
  bool get isConnected => _isConnected;
  
  void initialize() {
    _connectionStreamController = StreamController<bool>.broadcast();
    _checkInitialConnection();
    _connectivity.onConnectivityChanged.listen(_handleConnectivityChange);
  }
  
  Future<void> _checkInitialConnection() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    await _handleConnectivityChange(connectivityResult);
  }
  
  Future<void> _handleConnectivityChange(List<ConnectivityResult> result) async {
    final bool hasConnection = await _hasInternetConnection(result);
    _isConnected = hasConnection;
    _connectionStreamController.add(hasConnection);
  }
  
  Future<bool> _hasInternetConnection(List<ConnectivityResult> connectivityResult) async {
    // Check if device has any network connection
    if (connectivityResult.contains(ConnectivityResult.none)) {
      return false;
    }
    
    // Verify actual internet connectivity by pinging a reliable server
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } catch (e) {
      return false;
    }
    
    return false;
  }
  
  Future<bool> checkConnectivity() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return await _hasInternetConnection(connectivityResult);
  }
  
  void dispose() {
    _connectionStreamController.close();
  }
}