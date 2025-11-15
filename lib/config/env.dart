import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static bool _loaded = false;

  static Future<void> load() async {
    try {
      // Tentar carregar do asset (para mobile/web)
      await dotenv.load(fileName: '.env');
      _loaded = true;
    } catch (e) {
      // .env não existe - usar valores padrão
      _loaded = false;
    }
  }

  static String? get geminiApiKey {
    if (!_loaded) return null;
    try {
      return dotenv.env['GEMINI_API_KEY'];
    } catch (e) {
      return null;
    }
  }

  static String? get supabaseUrl {
    if (!_loaded) return null;
    try {
      return dotenv.env['SUPABASE_URL'];
    } catch (e) {
      return null;
    }
  }

  static String? get supabaseAnonKey {
    if (!_loaded) return null;
    try {
      return dotenv.env['SUPABASE_ANON_KEY'];
    } catch (e) {
      return null;
    }
  }
}
