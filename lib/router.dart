import 'package:walldecor/screens/bottomscreens/homescreen.dart';
import 'package:walldecor/screens/library/download_screen.dart';
import 'package:walldecor/screens/library/favorite_screen.dart';
import 'package:walldecor/screens/library/librarydownload.dart';
import 'package:walldecor/screens/startscreens/loginscreen.dart';
import 'package:walldecor/screens/startscreens/mainscreen.dart';
import 'package:walldecor/screens/startscreens/splashscreen.dart';
import 'package:go_router/go_router.dart';

final route = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/splashscreen',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/loginscreen',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/mainscreen',
      builder: (context, state) => const MainScreen(),
    ),
    GoRoute(
      path: '/homescreen',
      builder: (context, state) => const Homescreen(),
    ),
    GoRoute(
      path: '/librarydownload',
      builder: (context, state) => const DownloadScreen(),
    ),
    GoRoute(
      path: '/libraryfavorite',
      builder: (context, state) => const FavoriteScreen(),
    ),
    GoRoute(
      path: '/downloadscreen',
      builder: (context, state) => const Librarydownload(),
    ),

  ],
);
