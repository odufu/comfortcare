import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/constants/app_constants.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/bloc/theme_bloc.dart';
import '../core/theme/bloc/theme_event.dart';
import '../core/theme/bloc/theme_state.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/cart/presentation/bloc/cart_bloc.dart';
import '../features/cart/presentation/bloc/cart_event.dart';
import '../features/clinical/presentation/bloc/clinical_bloc.dart';
import '../features/dashboard/presentation/bloc/dashboard_bloc.dart';
import '../features/orders/presentation/bloc/orders_bloc.dart';
import '../features/orders/presentation/bloc/orders_event.dart';
import '../features/products/presentation/bloc/products_bloc.dart';
import '../features/profile/presentation/bloc/profile_bloc.dart';
import '../features/payments/presentation/bloc/payments_bloc.dart';
import 'dependencies.dart';

class ComfortCareApp extends StatelessWidget {
  const ComfortCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(
          create: (_) => sl<ThemeBloc>()..add(LoadTheme()),
        ),
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>(),
        ),
        BlocProvider<CartBloc>(
          create: (_) => sl<CartBloc>()..add(LoadCart()),
        ),
        BlocProvider<DashboardBloc>(
          create: (_) => sl<DashboardBloc>(),
        ),
        BlocProvider<ProductsBloc>(
          create: (_) => sl<ProductsBloc>(),
        ),
        BlocProvider<OrdersBloc>(
          create: (_) => sl<OrdersBloc>()..add(LoadOrders()),
        ),
        BlocProvider<PaymentsBloc>(
          create: (_) => sl<PaymentsBloc>(),
        ),
        BlocProvider<ClinicalBloc>(
          create: (_) => sl<ClinicalBloc>(),
        ),
        BlocProvider<ProfileBloc>(
          create: (_) => sl<ProfileBloc>(),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeState.themeMode,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
