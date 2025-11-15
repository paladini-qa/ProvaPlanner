import 'package:supabase_flutter/supabase_flutter.dart';
import 'env.dart';

class SupabaseConfig {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    final supabaseUrl = Env.supabaseUrl;
    final supabaseAnonKey = Env.supabaseAnonKey;

    if (supabaseUrl == null || supabaseAnonKey == null) {
      throw Exception(
        'Supabase credentials not found. Please set SUPABASE_URL and SUPABASE_ANON_KEY in .env file',
      );
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );

    _initialized = true;
  }

  static SupabaseClient get client {
    if (!_initialized) {
      throw Exception('Supabase not initialized. Call SupabaseConfig.initialize() first.');
    }
    return Supabase.instance.client;
  }

  static bool get isInitialized => _initialized;
}

