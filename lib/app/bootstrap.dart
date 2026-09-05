import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/helpers/bloc_observer.dart';
import '../core/services/supabase_service.dart';
import 'app.dart';
import 'dependencies.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Global BLoC state logger
  Bloc.observer = AppBlocObserver();

  // Initialize Supabase client
  await SupabaseService.initialize();

  // Initialize Dependency Injection
  await initDependencies();

  runApp(const ComfortCareApp());
}
