import 'package:walldecor/screens/bottomscreens/homescreen.dart';
import 'package:walldecor/screens/detailedscreens/librarydownload.dart';
import 'package:walldecor/screens/startscreens/loginscreen.dart';
import 'package:walldecor/screens/startscreens/mainscreen.dart';
import 'package:walldecor/screens/startscreens/splashscreen.dart';
import 'package:go_router/go_router.dart';

final route = GoRouter(
  initialLocation: '/splashscreen',
  routes: [
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
      builder: (context, state) => const Librarydownload(),
    ),

  ],
);
