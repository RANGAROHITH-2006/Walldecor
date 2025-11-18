// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:walldecor/models/userdata_model.dart';
import 'package:walldecor/repositories/services/google_auth_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  static const String _baseUrl = 'http://172.168.17.2:13024';
  
  AuthBloc() : super(const AuthInitial()) {
    on<AuthEvent>((event, emit) {});
    on<SessionRequest>(_onSessionRequest);
    on<GuestLogin>(_onGuestLogin);
    on<LoginWithGoogle>(_onLoginWithGoogle);
    on<LogOutRequest>(_onLogOutRequest);
    on<SetLoginInitial>(_setLoginInitial);
    on<DeleteUser>(_onDeleteUser);
  }

  _setLoginInitial(SetLoginInitial event, Emitter<AuthState> emit) {
    emit(state.copyWith(status: AuthStatus.initial));
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
        final googleAuthService = GoogleAuthService();
        final isFirebaseValid = await googleAuthService.isFirebaseSessionValid();
        
        if (!isFirebaseValid) {
          print('Firebase session expired, clearing stored data');
          await prefs.remove('auth_token');
          await prefs.remove('user_id');
          await prefs.remove('user_data');
          await prefs.remove('user_type');
          await prefs.remove('isProUser');
          
          event.onError!('Google session expired');
          emit(state.copyWith(status: AuthStatus.failure));
          return;
        }
      }

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
        print(resp.body);
        var data = jsonDecode(resp.body);
        User user = User.fromJson(data);
        bool isProUser = data['isProUser'];

        await prefs.setString('user_data', jsonEncode(data));
        await prefs.setBool('isProUser', isProUser);

        event.onSuccess(user);

        emit(state.copyWith(
            status: AuthStatus.success, token: token, user: user));
      } else {
        // Token is invalid/expired, clear all stored data
        await prefs.remove('auth_token');
        await prefs.remove('user_id');
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
      await prefs.remove('user_id');
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
        prefs.setString('user_type', 'google');
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
        print('---------------- ERROR LOGIN WITH GOOGLE ----------------');
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
          await prefs.remove('user_id');
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
        await prefs.remove('user_id');
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
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');
      
      if (token == null) {
        event.onError('No auth token found');
        emit(state.copyWith(status: AuthStatus.failure));
        return;
      }
      
      var resp = await http.delete(
        Uri.parse('$_baseUrl/user/${event.userId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
      );

      if (resp.statusCode == 200) {
        var data = jsonDecode(resp.body);
        event.onSuccess(data["message"]);
        emit(state.copyWith(status: AuthStatus.success));
      } else {
        print(resp.body);
        print(resp.statusCode);
        var data = jsonDecode(resp.body);
        event.onError(data["message"]);
        emit(state.copyWith(status: AuthStatus.failure));
      }
    } catch (e) {
      print(e);
      print('---------------- ERROR DELETE USER ------------------');
      event.onError('Something happened wrong try again after some time');
      emit(state.copyWith(status: AuthStatus.failure));
    }
  }
}