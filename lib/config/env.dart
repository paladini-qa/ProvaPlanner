import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static bool _loaded = false;

  static Future<void> load() async {
    try {
      // Tentar carregar do asset (para mobile/web)
      await dotenv.load(fileName: '.env');
      _loaded = true;
      if (kDebugMode) {
        print('✓ Arquivo .env carregado com sucesso');
        final apiKey = dotenv.env['GEMINI_API_KEY'];
        if (apiKey != null && apiKey.isNotEmpty) {
          print('✓ GEMINI_API_KEY encontrada (${apiKey.substring(0, 10)}...)');
        } else {
          print('⚠ GEMINI_API_KEY não encontrada ou vazia');
        }
      }
    } catch (e) {
      // .env não existe - usar valores padrão
      _loaded = false;
      if (kDebugMode) {
        print('⚠ Arquivo .env não encontrado. Usando modo mock para IA.');
        print('  Erro: $e');
      }
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

  static bool get useMockAi {
    if (!_loaded) return true; // Por padrão usar mock se não carregou
    try {
      return dotenv.env['USE_MOCK_AI'] == 'true';
    } catch (e) {
      return true;
    }
  }
}
