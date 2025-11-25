import 'package:walldecor/models/applist_model.dart';

abstract class ApplistState {}

class ApplistInitial extends ApplistState {}

class ApplistLoading extends ApplistState {}

class ApplistLoaded extends ApplistState {
  final ApplistModel data;
  ApplistLoaded(this.data);
}

class ApplistError extends ApplistState {
  final String message;
  ApplistError(this.message);
}