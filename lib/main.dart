import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mobile_jamugo/firebase_options.dart';
import 'package:mobile_jamugo/pages/add_menu_page.dart';
import 'package:mobile_jamugo/pages/cart_page.dart';
import 'package:mobile_jamugo/pages/home_page.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_jamugo/pages/landing_page.dart';
import 'package:mobile_jamugo/pages/login_page.dart';
import 'package:mobile_jamugo/pages/order_page.dart';
import 'package:mobile_jamugo/pages/profile_page.dart';
import 'package:mobile_jamugo/pages/register_page.dart';
import 'package:mobile_jamugo/pages/update_menu_page.dart';
import 'package:mobile_jamugo/api/menu/menu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final _router = GoRouter(
    initialLocation: '/landing',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/landing',
        builder: (context, state) => const LandingPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/order',
        builder: (context, state) => const OrderPage(),
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartPage(),
      ),
      GoRoute(
        path: '/add_menu',
        builder: (context, state) {
          final onMenuCreated = state.extra as Function;
          return AddMenuPage(onMenuCreated: onMenuCreated);
        },
      ),
      GoRoute(
        path: '/update_menu',
        builder: (context, state) {
          final Map<String, dynamic> params =
              state.extra as Map<String, dynamic>;
          final menu = params['menu'] as Menu;
          final onMenuUpdated = params['onMenuUpdated'] as Function;
          return UpdateMenuPage(menu: menu, onMenuUpdated: onMenuUpdated);
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}
