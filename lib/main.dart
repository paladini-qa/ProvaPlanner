import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/policies_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/main_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'theme/app_theme.dart';
import 'config/env.dart';
import 'config/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carregar variáveis de ambiente (opcional - não falha se não existir)
  try {
    await Env.load();

    // Inicializar Supabase se as credenciais estiverem disponíveis
    try {
      await SupabaseConfig.initialize();
    } catch (e) {
      // Supabase não configurado ou credenciais inválidas - continua sem sincronização remota
    }
  } catch (e) {
    // .env não existe ou não pode ser carregado - silenciosamente
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
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}
