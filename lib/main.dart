import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/policies_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/main_screen.dart';
import 'theme/app_theme.dart';
import 'config/env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Carregar variáveis de ambiente (opcional - não falha se não existir)
  try {
    await Env.load();
    debugPrint('=== ENV LOAD DEBUG ===');
    debugPrint('Env carregado. Verificando chave...');
    final apiKey = Env.geminiApiKey;
    final useMock = Env.useMockAi;
    debugPrint('API Key presente: ${apiKey != null && apiKey.isNotEmpty}');
    debugPrint('Usar Mock: $useMock');
  } catch (e) {
    // .env não existe ou não pode ser carregado - usar valores padrão
    debugPrint('Aviso: Arquivo .env não encontrado. Usando modo mock para IA.');
    debugPrint('Erro: $e');
  }
  
  runApp(const ProvaPlannerApp());
}

class ProvaPlannerApp extends StatelessWidget {
  const ProvaPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ProvaPlanner',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/policies': (context) => const PoliciesScreen(),
        '/profile-setup': (context) => const ProfileSetupScreen(),
        '/home': (context) => const MainScreen(),
      },
    );
  }
}

