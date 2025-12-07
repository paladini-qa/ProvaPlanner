import 'package:flutter/material.dart';
import 'presentation/pages/splash_screen.dart';
import 'presentation/pages/onboarding_screen.dart';
import 'presentation/pages/policies_screen.dart';
import 'presentation/pages/profile_setup_screen.dart';
import 'presentation/pages/main_screen.dart';
import 'presentation/pages/login_screen.dart';
import 'presentation/pages/register_screen.dart';
import 'theme/app_theme.dart';
import 'config/env.dart';
import 'config/supabase_config.dart';
import 'features/app/theme_controller.dart';

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

  // Criar e carregar o controlador de tema
  final themeController = ThemeController();
  await themeController.load();

  runApp(ProvaPlannerApp(themeController: themeController));
}

class ProvaPlannerApp extends StatelessWidget {
  final ThemeController themeController;

  const ProvaPlannerApp({
    super.key,
    required this.themeController,
  });

  @override
  Widget build(BuildContext context) {
    // ThemeControllerProvider disponibiliza o controller para toda a árvore
    return ThemeControllerProvider(
      controller: themeController,
      // ListenableBuilder reconstrói quando o controller notifica
      child: ListenableBuilder(
        listenable: themeController,
        builder: (context, child) {
          return MaterialApp(
            title: 'ProvaPlanner',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeController.mode,
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
        },
      ),
    );
  }
}
