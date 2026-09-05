import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/api_constants.dart';

class SupabaseService {
  static SupabaseClient? _client;
  static bool _isInitialized = false;

  static bool get isInitialized => _isInitialized;
  static SupabaseClient? get client => _client;

  static Future<void> initialize() async {
    try {
      if (ApiConstants.supabaseUrl.isNotEmpty &&
          !ApiConstants.supabaseUrl.contains('comfortcare.supabase.co')) {
        await Supabase.initialize(
          url: ApiConstants.supabaseUrl,
          // ignore: deprecated_member_use
          anonKey: ApiConstants.supabaseAnonKey,
          debug: kDebugMode,
        );
        _client = Supabase.instance.client;
        _isInitialized = true;
        if (kDebugMode) {
          debugPrint(' Supabase initialized successfully');
        }
      } else {
        if (kDebugMode) {
          debugPrint('ℹ️ Supabase placeholder credentials active. Running in Decoupled Local/Demo Mode.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Supabase initialization failed ($e). Operating in Decoupled Local/Demo Mode.');
      }
      _isInitialized = false;
    }
  }
}
