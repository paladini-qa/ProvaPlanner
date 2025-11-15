import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/app_icon.dart';
import '../theme/app_theme.dart';
import '../services/tutorial_service.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _navigateToNextScreen();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _animationController.forward();
  }

  Future<void> _navigateToNextScreen() async {
    // Simular tempo de carregamento
    await Future<void>.delayed(const Duration(milliseconds: 3000));

    if (!mounted) return;

    // Verificar autenticação primeiro
    bool isAuthenticated = false;
    try {
      isAuthenticated = AuthService.isAuthenticated;
    } catch (e) {
      // Se Supabase não estiver configurado, continuar sem autenticação
      isAuthenticated = false;
    }

    // Se não estiver autenticado, ir para login
    if (!isAuthenticated) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(builder: (context) => const LoginScreen()),
      );
      return;
    }

    // Se estiver autenticado, seguir o fluxo normal
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
    final hasAcceptedPolicies = prefs.getBool('has_accepted_policies') ?? false;
    final hasCompletedProfileSetup =
        prefs.getBool('profile_setup_completed') ?? false;

    if (!hasSeenOnboarding) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/onboarding');
    } else if (!hasAcceptedPolicies) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/policies');
    } else if (!hasCompletedProfileSetup) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/profile-setup');
    } else {
      // Iniciar tutorial se for primeira vez
      final tutorialCompleted = await TutorialService.isTutorialCompleted();
      final currentStep = await TutorialService.getCurrentStep();

      if (!mounted) return;

      if (!tutorialCompleted) {
        // Se o passo é none, iniciar o tutorial
        if (currentStep == TutorialStep.none) {
          await TutorialService.setCurrentStep(
              TutorialStep.navigateToDisciplinas);
        }
      }
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.indigo,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo animado
            Semantics(
              label: 'Logo do ProvaPlanner',
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: const AppIcon(size: 120),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 32),

            // Nome do app
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'ProvaPlanner',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                        ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Descrição
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'Organize suas provas e estudos',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),

            const SizedBox(height: 64),

            // Indicador de carregamento
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: const SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 3,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
