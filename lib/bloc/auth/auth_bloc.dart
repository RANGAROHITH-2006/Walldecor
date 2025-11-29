// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:walldecor/models/userdata_model.dart';
import 'package:walldecor/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  static const String _baseUrl = 'http://172.168.17.2:13024';
  final AuthRepository _authRepository = AuthRepository();
  static const String _guestIdKey = 'user_id';
  
  // Public getter to access AuthRepository methods
  AuthRepository get authRepository => _authRepository;
  
  AuthBloc() : super(const AuthInitial()) {
    on<AuthEvent>((event, emit) {});
    on<SessionRequest>(_onSessionRequest);
    on<GuestLogin>(_onGuestLogin);
    on<LoginWithGoogle>(_onLoginWithGoogle);
    on<LoginWithApple>(_onLoginWithApple);
    on<LogOutRequest>(_onLogOutRequest);
    on<SetLoginInitial>(_setLoginInitial);
    on<DeleteUser>(_onDeleteUser);
    on<UpdateUserSubscription>(_onUpdateUserSubscription);
  }

  _setLoginInitial(SetLoginInitial event, Emitter<AuthState> emit) {
    emit(state.copyWith(status: AuthStatus.initial));
  }

  _onUpdateUserSubscription(UpdateUserSubscription event, Emitter<AuthState> emit) async {
    if (state.user != null) {
      // Set a temporary future expiry date to ensure hasActiveSubscription works immediately
      String tempExpireTime = '';
      if (event.isProUser) {
        // Set expiry to 1 year from now (server will override this with real data)
        final futureDate = DateTime.now().add(const Duration(days: 365));
        tempExpireTime = futureDate.toString();
      }
      
      User updatedUser = state.user!.copyWith(
        isProUser: event.isProUser,
        expireTime: event.isProUser ? tempExpireTime : '',
      );
      
      // Update shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isProUser', event.isProUser);
      
      print('💎 UpdateUserSubscription: Updated user pro status to ${event.isProUser}');
      print('💎 UpdateUserSubscription: Temp expireTime set to: $tempExpireTime');
      print('💎 UpdateUserSubscription: User hasActiveSubscription = ${updatedUser.hasActiveSubscription}');
      print('💎 UpdateUserSubscription: Emitting new state with status: ${AuthStatus.success}');
      
      // Force a state change by creating a completely new state
      emit(AuthState(
        status: AuthStatus.success,
        token: state.token,
        user: updatedUser,
        message: state.message,
      ));
    }
  }

  Future<void> _onSessionRequest(
      SessionRequest event, Emitter<AuthState> emit) async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');
      String? userType = prefs.getString('user_type');
      
      if (token == null) {
        event.onError!('No auth token found');
        emit(state.copyWith(status: AuthStatus.failure));
        return;
      }

      // If it's a Google user, check Firebase session validity
      if (userType == 'google') {
        final isFirebaseValid = await _authRepository.isFirebaseSessionValid();
        
        if (!isFirebaseValid) {
          print('Firebase session expired, clearing stored data');
          await prefs.remove('auth_token');
          await prefs.remove('user_data');
          await prefs.remove('user_type');
          await prefs.remove('isProUser');
          
          event.onError!('Google session expired');
          emit(state.copyWith(status: AuthStatus.failure));
          return;
        }
      }

      // If it's an Apple user, check Firebase session validity
      if (userType == 'apple') {
        final isFirebaseValid = await _authRepository.isFirebaseSessionValid();
        
        if (!isFirebaseValid) {
          print('Apple Firebase session expired, clearing stored data');
          await prefs.remove('auth_token');
          await prefs.remove('user_data');
          await prefs.remove('user_type');
          await prefs.remove('isProUser');
          
          event.onError!('Apple session expired');
          emit(state.copyWith(status: AuthStatus.failure));
          return;
        }
      }
  print('Hitting-----------------------------------------');
      var resp = await http.get(
        Uri.parse('$_baseUrl/user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );
      
      if (resp.statusCode == 200) {
        print('📡 Server Response: ${resp.body}');
        var data = jsonDecode(resp.body);
        User user = User.fromJson(data);
        print('   User hasActiveSubscription: ${user.hasActiveSubscription}');
        
        bool isProUser = data['isProUser'] && !user.isSubscriptionExpired;

        await prefs.setString('user_data', jsonEncode(data));
        await prefs.setBool('isProUser', isProUser);

        // If subscription expired, update the user object
        if (data['isProUser'] && user.isSubscriptionExpired) {
          user = user.copyWith(isProUser: false);
        }

        event.onSuccess(user);

        emit(state.copyWith(
            status: AuthStatus.success, token: token, user: user));
      } else {
        // Token is invalid/expired, clear all stored data
        await prefs.remove('auth_token');
        await prefs.remove('user_data');
        await prefs.remove('user_type');
        await prefs.remove('isProUser');
        
        Map<String, dynamic> data = jsonDecode(resp.body);
        String errorMessage = data["message"] ?? "Unauthorized request.";
        event.onError!(errorMessage);
        print(resp.statusCode);
        print(resp.body);
        emit(state.copyWith(
          status: AuthStatus.failure,
          token: null,
          user: null,
          message: errorMessage,
        ));
      }
    } catch (e) {
      print(e);
      print('--------------- ERROR SESSION REQUEST ---------------');
      
      // Clear stored data on any session error
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
      await prefs.remove('user_type');
      await prefs.remove('isProUser');
      
      event.onError!('Something went wrong');
      emit(state.copyWith(
        status: AuthStatus.failure,
        token: null,
        user: null,
        message: 'Session check failed',
      ));
    }
  }

  _onGuestLogin(GuestLogin event, Emitter<AuthState> emit) async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));
      var resp = await http.post(
        Uri.parse('$_baseUrl/auth/guest'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "firstName": "Guest", // Add default firstName for guest users
          "lastName": "User",   // Add default lastName for guest users
          "deviceId": event.deviceId,
          if (event.pushToken.isNotEmpty) "pushToken": event.pushToken,
        }),
      );

      if (resp.statusCode == 200) {
        print(resp.body);
        Map<String, dynamic> data = jsonDecode(resp.body);
        User user = User.fromJson(data);
        var token = resp.headers["x-auth-token"];
        var id = data["_id"];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('auth_token', token!);
        prefs.setString('user_id', id);
        prefs.setString('user_data', jsonEncode(data));
        prefs.setString('user_type', 'guest');
        bool isProUser = data['isProUser'] ?? false;
        prefs.setBool('isProUser', isProUser);
        
        event.onSuccess(user);
        emit(state.copyWith(
          status: AuthStatus.success,
          token: resp.headers["x-auth-token"],
          user: user,
        ));
      } else {
        print(resp.statusCode);
        print(resp.body);
        Map<String, dynamic> data = jsonDecode(resp.body);
        event.onError(data["message"]);
        emit(state.copyWith(status: AuthStatus.failure));
      }
    } catch (e) {
      print(e);
      print('----------------- ERROR GUEST LOGIN -----------------');
      event.onError('Something went wrong');
      emit(state.copyWith(status: AuthStatus.failure));
    }
  }

  Future<void> _onLoginWithGoogle(
      LoginWithGoogle event, Emitter<AuthState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final guestUserId = prefs.getString(_guestIdKey);
    print('Guest User ID from prefs: $guestUserId');
    try {
      emit(state.copyWith(status: AuthStatus.loading));
      var resp = await http.post(
        Uri.parse('$_baseUrl/auth/loginWithGoogle'),
        headers: {
          'Content-Type': 'application/json',
          "google-id-token": event.googleIdToken,
        },
        body: jsonEncode({
          if (event.firstName.isNotEmpty) "firstName": event.firstName,
          if (event.lastName.isNotEmpty) "lastName": event.lastName,
          "email": event.email,
          "firebaseUserId": event.firebaseUserId,
          "deviceId": event.deviceId,
          'userId': guestUserId ?? '',
          if (event.pushToken.isNotEmpty) "pushToken": event.pushToken,
        }),
      );
      
      print('request body : ${jsonEncode({
            if (event.firstName.isNotEmpty) "firstName": event.firstName,
            if (event.lastName.isNotEmpty) "lastName": event.lastName,
            "email": event.email,
            "firebaseUserId": event.firebaseUserId,
            "deviceId": event.deviceId,
            'userId': guestUserId ?? '',
            if (event.pushToken.isNotEmpty) "pushToken": event.pushToken,
          })}');
      if (resp.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('user_type', 'google');
        Map<String, dynamic> data = jsonDecode(resp.body);
        print('$data-----------------');        
        var token = resp.headers["x-auth-token"];
        var id = data["_id"];
        
        prefs.setString('auth_token', token!);
        prefs.setString('user_id', id);
       
        bool isProUser = data['isProUser'] ?? false;
        prefs.setBool('isProUser', isProUser);
        
        // Store user data with profile image URL
        Map<String, dynamic> userData = Map<String, dynamic>.from(data);
        userData['profileImageUrl'] = event.profileImageUrl;
        
        prefs.setString('user_data', jsonEncode(userData));
        
        User user = User.fromJson(data);
        event.onSuccess(user);
        emit(state.copyWith(
          status: AuthStatus.success,
          token: token,
          user: user,
        ));
      } else {
        print(resp.body);
        print(resp.statusCode);

        var data = jsonDecode(resp.body);
        event.onError(data["message"]);
        emit(state.copyWith(status: AuthStatus.failure));
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
        print('---------------- ERROR LOGIN WITH GOOGLE ----------------');
        event.onError('Something went wrong!');
        emit(state.copyWith(status: AuthStatus.failure));
      }
    }
  }

  Future<void> _onLoginWithApple(
      LoginWithApple event, Emitter<AuthState> emit) async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));
      var resp = await http.post(
        Uri.parse('$_baseUrl/auth/loginWithApple'),
        headers: {
          'Content-Type': 'application/json',
          "apple-id-token": event.appleIdToken,
        },
        body: jsonEncode({
          if (event.firstName.isNotEmpty) "firstName": event.firstName,
          if (event.lastName.isNotEmpty) "lastName": event.lastName,
          "email": event.email,
          "firebaseUserId": event.firebaseUserId,
          "deviceId": event.deviceId,
          if (event.pushToken.isNotEmpty) "pushToken": event.pushToken,
        }),
      );

      if (resp.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(resp.body);
        var token = resp.headers["x-auth-token"];
        var id = data["_id"];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('auth_token', token!);
        prefs.setString('user_id', id);
        prefs.setString('user_data', jsonEncode(data));
        prefs.setString('user_type', 'apple');
        bool isProUser = data['isProUser'] ?? false;
        prefs.setBool('isProUser', isProUser);
        
        User user = User.fromJson(data);
        event.onSuccess(user);
        emit(state.copyWith(
          status: AuthStatus.success,
          token: token,
          user: user,
        ));
      } else {
        print(resp.body);
        print(resp.statusCode);

        var data = jsonDecode(resp.body);
        event.onError(data["message"]);
        emit(state.copyWith(status: AuthStatus.failure));
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
        print('---------------- ERROR LOGIN WITH APPLE ----------------');
        event.onError('Something went wrong!');
        emit(state.copyWith(status: AuthStatus.failure));
      }
    }
  }

  Future<void> _onLogOutRequest(
    LogOutRequest event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');
      
      if (token != null) {
        var resp = await http.post(
          Uri.parse('$_baseUrl/auth/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': token,
          },
          body: jsonEncode({
            "pushToken": event.fcmToken,
          }),
        );
        
        if (resp.statusCode == 200) {
          // Clear all stored data after successful logout
          await prefs.remove('auth_token');
          await prefs.remove('user_data');
          await prefs.remove('user_type');
          await prefs.remove('isProUser');
          
          event.onSuccess();
          emit(state.copyWith(
            status: AuthStatus.initial,
            token: null,
            user: null,
            message: null,
          ));
        } else {
          print(resp.statusCode);
          print(resp.body);
          Map<String, dynamic> data = jsonDecode(resp.body);
          print(data["message"]);
          emit(state.copyWith(status: AuthStatus.failure));
        }
      } else {
        // Even without token, clear any stored data
        await prefs.remove('auth_token');
        await prefs.remove('user_data');
        await prefs.remove('user_type');
        await prefs.remove('isProUser');
        
        event.onSuccess();
        emit(state.copyWith(
          status: AuthStatus.initial,
          token: null,
          user: null,
          message: null,
        ));
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
        print('------------- ERROR LOGOUT -------------');
      }
      print('Something happened wrong try again after some time');
      emit(state.copyWith(status: AuthStatus.failure));
    }
  }

  _onDeleteUser(DeleteUser event, Emitter<AuthState> emit) async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));
      
      // Use AuthRepository to delete account
      final message = await _authRepository.deleteAccount();
      
      // Clear auth state after successful deletion
      emit(state.copyWith(
        status: AuthStatus.initial,
        token: null,
        user: null,
        message: null,
      ));
      
      event.onSuccess(message);
    } catch (e) {
      print(e);
      print('---------------- ERROR DELETE USER ------------------');
      event.onError(e.toString().replaceFirst('Exception: ', ''));
      emit(state.copyWith(status: AuthStatus.failure));
    }
  }
}