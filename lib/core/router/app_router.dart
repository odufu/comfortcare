import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/dependencies.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/cart/presentation/pages/cart_prescription_review_page.dart';
import '../../features/clinical/presentation/pages/ai_clinical_consultation_page.dart';
import '../../features/clinical/presentation/pages/health_vitals_monitor_page.dart';
import '../../features/dashboard/presentation/pages/customer_hub_page.dart';
import '../../features/dashboard/presentation/pages/onboarding_page.dart';
import '../../features/dashboard/presentation/pages/splash_page.dart';
import '../../features/orders/presentation/pages/delivery_dispatch_page.dart';
import '../../features/orders/presentation/pages/live_delivery_tracking_page.dart';
import '../../features/orders/presentation/pages/order_confirmed_page.dart';
import '../../features/payments/presentation/pages/payment_clinical_authorization_page.dart';
import '../../features/products/presentation/pages/product_details_page.dart';
import '../../features/products/presentation/pages/products_catalog_page.dart';
import '../../features/profile/presentation/pages/account_profile_settings_page.dart';
import '../storage/local_storage_service.dart';
import '../widgets/cc_bottom_nav_bar.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shell');

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => SplashPage(
          localStorageService: sl<LocalStorageService>(),
        ),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => OnboardingPage(
          localStorageService: sl<LocalStorageService>(),
        ),
      ),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      // Direct Top-level Pages
      GoRoute(
        path: '/products/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'prod-coartem-80-480';
          return ProductDetailsPage(productId: id);
        },
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartPrescriptionReviewPage(),
      ),
      GoRoute(
        path: '/checkout/delivery',
        builder: (context, state) => const DeliveryDispatchPage(),
      ),
      GoRoute(
        path: '/checkout/payment',
        builder: (context, state) => const PaymentClinicalAuthorizationPage(),
      ),
      GoRoute(
        path: '/checkout/confirmed',
        builder: (context, state) => const OrderConfirmedPage(),
      ),
      GoRoute(
        path: '/orders/:id/track',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'CC-84920';
          return LiveDeliveryTrackingPage(orderId: id);
        },
      ),
      GoRoute(
        path: '/vitals',
        builder: (context, state) => const HealthVitalsMonitorPage(),
      ),
      // Shell Route for bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          int index = 0;
          final location = state.uri.path;
          if (location.startsWith('/products')) {
            index = 1;
          } else if (location.startsWith('/ai-consult')) {
            index = 2;
          } else if (location.startsWith('/orders')) {
            index = 3;
          } else if (location.startsWith('/profile')) {
            index = 4;
          }

          return Scaffold(
            body: child,
            bottomNavigationBar: CCBottomNavBar(
              currentIndex: index,
              onTap: (newIndex) {
                switch (newIndex) {
                  case 0:
                    context.go('/dashboard');
                    break;
                  case 1:
                    context.go('/products');
                    break;
                  case 2:
                    context.go('/ai-consult');
                    break;
                  case 3:
                    context.go('/orders');
                    break;
                  case 4:
                    context.go('/profile');
                    break;
                }
              },
            ),
          );
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const CustomerHubPage(),
          ),
          GoRoute(
            path: '/products',
            builder: (context, state) => const ProductsCatalogPage(),
          ),
          GoRoute(
            path: '/ai-consult',
            builder: (context, state) => const AiClinicalConsultationPage(),
          ),
          GoRoute(
            path: '/orders',
            builder: (context, state) => const LiveDeliveryTrackingPage(orderId: 'CC-84920'),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const AccountProfileSettingsPage(),
          ),
        ],
      ),
    ],
  );
}
