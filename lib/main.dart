import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walldecor/bloc/auth/auth_bloc.dart';
import 'package:walldecor/bloc/category/category_bloc.dart';
import 'package:walldecor/bloc/category/category_event.dart';
import 'package:walldecor/bloc/collection/collection_bloc.dart';
import 'package:walldecor/bloc/collection/collection_event.dart';
import 'package:walldecor/bloc/library/library_bloc.dart';
import 'package:walldecor/bloc/trending/trending_bloc.dart';
import 'package:walldecor/bloc/trending/trending_event.dart';
import 'package:walldecor/firebase_options.dart';
import 'package:walldecor/repositories/auth_repository.dart';
import 'package:walldecor/repositories/category_repository.dart';
import 'package:walldecor/repositories/collection_repository.dart';
import 'package:walldecor/repositories/library_repository.dart';
import 'package:walldecor/repositories/trending_repository.dart';
import 'package:walldecor/router.dart';
import 'package:flutter/material.dart';
import 'package:walldecor/screens/detailedscreens/resultpage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LibraryBloc(LibraryRepository())),
        BlocProvider(
          create:
              (_) =>
                  CategoryBloc(CategoryRepository())..add(FetchCategoryEvent()),
        ),
        BlocProvider(
          create:
              (_) =>
                  TrendingBloc(TrendingRepository())
                    ..add(FetchCategoryTrendingEvent()),
        ),
        BlocProvider(
          create:
              (_) =>
                  TrendingBloc(TrendingRepository())
                    ..add(FetchSearchTrendingEvent()),
        ),
        BlocProvider(
          create: (context) => AuthBloc(authRepository: AuthRepository()),
        ),
        BlocProvider(create: (_) => CategoryBloc(CategoryRepository())),
        BlocProvider(
          create:
              (_) =>
                  CollectionBloc(CollectionRepository())
                    ..add(FetchCollectionEvent()),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        routerConfig: route,
      ),
    );
  }
}
