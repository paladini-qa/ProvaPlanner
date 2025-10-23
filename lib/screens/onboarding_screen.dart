import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icon.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.calendar_today,
      title: 'Organize suas Provas',
      description: 'Mantenha todas as suas provas organizadas em um calendário visual e intuitivo.',
      color: AppTheme.indigo,
    ),
    OnboardingPage(
      icon: Icons.schedule,
      title: 'Planeje suas Revisões',
      description: 'Crie um cronograma de estudos personalizado com lembretes automáticos.',
      color: AppTheme.amber,
    ),
    OnboardingPage(
      icon: Icons.trending_up,
      title: 'Acompanhe seu Progresso',
      description: 'Visualize seu desempenho e mantenha o foco nos seus objetivos acadêmicos.',
      color: AppTheme.slate,
    ),
    OnboardingPage(
      icon: Icons.notifications,
      title: 'Nunca Perca uma Data',
      description: 'Receba notificações inteligentes para nunca esquecer de uma prova importante.',
      color: AppTheme.indigo,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/policies');
    }
  }

  Future<void> _aceitarTudo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    await prefs.setBool('has_accepted_policies', true);
    await prefs.setBool('notifications_enabled', true);
    
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/profile-setup');
    }
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Botão anterior
        if (_currentPage > 0)
          TextButton(
            onPressed: _previousPage,
            child: Text(
              'Anterior',
              style: TextStyle(
                color: AppTheme.slateLighter,
                fontSize: 16,
              ),
            ),
          )
        else
          const SizedBox(width: 80),
        
        // Botão próximo
        Semantics(
          button: true,
          label: 'Ir para próxima página',
          child: ElevatedButton(
            onPressed: _nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.indigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Próximo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinalButtons() {
    return Column(
      children: [
        // Botão "Aceitar Tudo"
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _aceitarTudo,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.indigo,
              side: BorderSide(color: AppTheme.indigo),
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Aceitar Tudo e Continuar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Botão "Começar" (navegação normal)
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.indigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Começar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Texto explicativo
        Text(
          'Ou continue para aceitar as políticas',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header com logo
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppIcon(size: 40),
                  const SizedBox(width: 12),
                  Text(
                    'ProvaPlanner',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.indigo,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // Páginas do onboarding
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(_pages[index]);
                },
              ),
            ),
            
            // Indicadores de página
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppTheme.indigo
                          : AppTheme.indigo.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
            
            // Botões de navegação
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: _currentPage == _pages.length - 1 
                  ? _buildFinalButtons()
                  : _buildNavigationButtons(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ícone
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 60,
              color: page.color,
            ),
          ),
          
          const SizedBox(height: 48),
          
          // Título
          Text(
            page.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.slate,
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // Descrição
          Text(
            page.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.slateLight,
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
