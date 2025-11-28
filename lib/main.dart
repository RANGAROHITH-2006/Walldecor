import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walldecor/bloc/auth/auth_bloc.dart';
import 'package:walldecor/bloc/category/category_bloc.dart';
import 'package:walldecor/bloc/category/category_event.dart';
import 'package:walldecor/bloc/collection/collection_bloc.dart';
import 'package:walldecor/bloc/collection/collection_event.dart';
import 'package:walldecor/bloc/connectivity/connectivity_bloc.dart';
import 'package:walldecor/bloc/connectivity/connectivity_event.dart';
import 'package:walldecor/bloc/download/download_bloc.dart';
import 'package:walldecor/bloc/favorite/favorite_bloc.dart';
import 'package:walldecor/bloc/library/library_bloc.dart';
import 'package:walldecor/bloc/search/search_bloc.dart';
// import 'package:walldecor/bloc/library/library_event.dart';
import 'package:walldecor/bloc/trending/trending_bloc.dart';
import 'package:walldecor/bloc/trending/trending_event.dart';
import 'package:walldecor/firebase_options.dart';
import 'package:walldecor/repositories/connectivity_repository.dart';

import 'package:walldecor/repositories/category_repository.dart';
import 'package:walldecor/repositories/collection_repository.dart';
import 'package:walldecor/repositories/download_repository.dart';
import 'package:walldecor/repositories/favorite_repository.dart';
import 'package:walldecor/repositories/library_repository.dart';
import 'package:walldecor/repositories/Search_repository.dart';
import 'package:walldecor/repositories/trending_repository.dart';
import 'package:walldecor/router.dart';
import 'package:flutter/material.dart';
// import 'package:walldecor/screens/bottomscreens/librarypagedata.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase only if not already initialized
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    }
  } catch (e) {
    // If Firebase is already initialized, ignore the error
    print('Firebase already initialized: $e');
  }
  
  // Initialize connectivity service
  final connectivityService = ConnectivityService();
  connectivityService.initialize();
  
  runApp(MyApp(connectivityService: connectivityService));
}

class MyApp extends StatelessWidget {
  final ConnectivityService connectivityService;
  
  const MyApp({super.key, required this.connectivityService});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ConnectivityBloc(connectivityService)..add(CheckConnectivity()),
        ),
        BlocProvider(create: (_) => LibraryBloc(LibraryRepository())),
        BlocProvider(create: (_) => DownloadBloc(downloadRepository: DownloadRepository())),
        BlocProvider(create: (_) => FavoriteBloc(favoriteRepository: FavoriteRepository())),
        BlocProvider(create: (_) => SearchBloc(SearchRepository())),
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
          create: (context) => AuthBloc(),
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
          fontFamily: 'MonaSans',
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        routerConfig: route,
      ),
    );
  }
}
