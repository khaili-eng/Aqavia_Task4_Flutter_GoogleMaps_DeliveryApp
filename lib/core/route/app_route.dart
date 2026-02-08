import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled18/core/route/routes_name.dart';

import '../../features/main/presentation/view/driver_home.dart';
import '../../features/main/presentation/view/main_screen.dart';
import '../../features/order/presentation/view/order_details_screen.dart';
import '../../features/order/presentation/view/order_page.dart';
import '../../features/user/presentation/view/user_page.dart';
import '../../features/user/presentation/view/users_page.dart';

class AppRouter {
  AppRouter();

  final GlobalKey<NavigatorState> _rootKey =
  GlobalKey<NavigatorState>();

  late final GoRouter router = GoRouter(
    navigatorKey: _rootKey,
    debugLogDiagnostics: true,
    initialLocation: RoutesName.login,

    redirect: (context, state) {
      final bool isLoggedIn = true;
      final bool isLoggingIn =
          state.uri.toString() == RoutesName.login;

      if (!isLoggedIn && !isLoggingIn) {
        return RoutesName.login;
      }

      if (isLoggedIn && isLoggingIn) {
        return RoutesName.home;
      }

      return null;
    },

    routes: [

      GoRoute(
        path: RoutesName.login,
        name: 'login',
        builder: (context, state) =>  UserPage(),
      ),
      GoRoute(
          path: RoutesName.orderDetails,
      name: 'orderDetails',
      builder: (context, state) {
        final orderId = state.uri.queryParameters['orderId'];
        return OrderDetailsScreen(orderId: orderId!);
      },
      ),


      ShellRoute(
        builder: (context, state, child) {
          return MainScreen();
        },
        routes: [
          GoRoute(
            path: RoutesName.home,
            name: 'home',
            pageBuilder: (context, state) =>
            const NoTransitionPage(child: DriverHome()),
          ),

          GoRoute(
            path: RoutesName.order,
            name: 'orders',
            pageBuilder: (context, state) =>
            const NoTransitionPage(child: OrderPage()),
          ),



          GoRoute(
            path: RoutesName.users,
            name: 'users',
            pageBuilder: (context, state) =>
            const NoTransitionPage(child: UsersPage()),
          ),
        ],
      ),
    ],
  );
}