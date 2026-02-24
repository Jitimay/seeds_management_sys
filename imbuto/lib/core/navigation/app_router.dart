import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/stocks/presentation/pages/stocks_list_page.dart';
import '../../features/orders/presentation/pages/orders_list_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/plants/presentation/pages/plants_list_page.dart';
import '../../features/losses/presentation/pages/losses_list_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../shared/widgets/splash_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
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
        path: '/dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/stocks',
        builder: (context, state) => const StocksListPage(),
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrdersListPage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/plants',
        builder: (context, state) => const PlantsListPage(),
      ),
      GoRoute(
        path: '/losses',
        builder: (context, state) => const LossesListPage(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardPage(),
      ),
    ],
  );
}
