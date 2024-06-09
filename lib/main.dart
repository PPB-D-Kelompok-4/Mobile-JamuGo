import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:jamugo/firebase_options.dart';
import 'package:jamugo/pages/menus/add_menu_page.dart';
import 'package:jamugo/pages/carts/cart_detail_page.dart';
import 'package:jamugo/pages/menus/home_page.dart';
import 'package:go_router/go_router.dart';
import 'package:jamugo/pages/auth/landing_page.dart';
import 'package:jamugo/pages/auth/login_page.dart';
import 'package:jamugo/pages/orders/order_detail_page.dart';
import 'package:jamugo/pages/orders/order_page.dart';
import 'package:jamugo/pages/profiles/profile_edit_page.dart';
// import 'package:jamugo/pages/profiles/profile_page.dart';
import 'package:jamugo/pages/auth/register_page.dart';
import 'package:jamugo/pages/menus/update_menu_page.dart';
import 'package:jamugo/api/menu/menu.dart';
import 'package:jamugo/pages/profiles/profile_view_page.dart';

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
        builder: (context, state) => const ProfileViewPage(),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const ProfileEditPage(),
      ),
      GoRoute(
        path: '/order',
        builder: (context, state) => const OrderPage(),
      ),
      GoRoute(
        path: '/order_detail',
        builder: (context, state) {
          final orderId = state.extra as int;
          return OrderDetailPage(orderId: orderId);
        },
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartDetailPage(),
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
