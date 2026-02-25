import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/dashboard/presentation/pages/home_page.dart'; // Changed from dashboard_page.dart
import '../../features/dashboard/presentation/pages/main_screen.dart'; // Added
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
      ShellRoute(
        builder: (context, state, child) => MainScreen(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomePage(),
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
          // Keep other routes that are not part of the bottom navigation bar but accessible
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
      ),
    ],
  );
}
