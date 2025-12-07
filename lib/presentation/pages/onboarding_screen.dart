import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../widgets/app_icon.dart';
import '../widgets/animated_page_indicator.dart';
import '../../services/auth_service.dart';
import '../../services/consent_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final ScrollController _termsScrollController = ScrollController();
  int _currentPage = 0;
  bool _hasScrolledToEnd = false;
  bool _acceptedTerms = false;

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
  void initState() {
    super.initState();
    _termsScrollController.addListener(_checkScrollPosition);
  }

  void _checkScrollPosition() {
    if (_termsScrollController.hasClients) {
      final maxScroll = _termsScrollController.position.maxScrollExtent;
      final currentScroll = _termsScrollController.position.pixels;
      final threshold = maxScroll - 50; // 50px de margem

      if (currentScroll >= threshold && !_hasScrolledToEnd) {
        setState(() {
          _hasScrolledToEnd = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _termsScrollController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
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
    if (!_acceptedTerms || !_hasScrolledToEnd) return;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    
    // Aceitar políticas usando o ConsentService para garantir versionamento correto
    try {
      await ConsentService.acceptPolicies(
        acceptedTerms: true,
        acceptedPrivacy: true,
        acceptedDataProcessing: true,
        acceptedNotifications: false, // Usuário pode configurar depois
      );
    } catch (e) {
      // Se falhar, salvar diretamente como fallback
      await prefs.setBool('has_accepted_policies', true);
    }
    
    // Marcar onboarding como completo no Supabase
    try {
      await AuthService.markOnboardingCompleted();
    } catch (e) {
      // Se falhar, continuar mesmo assim - não é crítico
    }
    
    if (mounted) {
      // Navegar direto para a tela principal após onboarding
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Widget _buildNavigationButtons() {
    final colorScheme = Theme.of(context).colorScheme;

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
                color: colorScheme.onSurfaceVariant,
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
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
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
    final canProceed = _acceptedTerms && _hasScrolledToEnd;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      children: [
        // Checkbox de aceite
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: canProceed 
                ? colorScheme.primary.withValues(alpha: 0.05)
                : colorScheme.outline.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: canProceed 
                  ? colorScheme.primary.withValues(alpha: 0.3)
                  : colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: CheckboxListTile(
            value: _acceptedTerms,
            onChanged: (value) {
              setState(() {
                _acceptedTerms = value ?? false;
              });
            },
            title: const Text(
              'Li e aceito os Termos de Uso e Política de Privacidade',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            activeColor: colorScheme.primary,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Botão "Começar"
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canProceed ? _completeOnboarding : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canProceed ? colorScheme.primary : colorScheme.outline,
              foregroundColor: canProceed ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
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
        
        if (!_hasScrolledToEnd)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Por favor, role até o final dos termos',
              style: TextStyle(
                color: Colors.orange[700],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
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
                        color: colorScheme.primary,
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
                    // Resetar scroll quando mudar de página
                    if (index == _pages.length) {
                      _hasScrolledToEnd = false;
                      _acceptedTerms = false;
                    }
                  });
                },
                itemCount: _pages.length + 1, // +1 para página de termos
                itemBuilder: (context, index) {
                  if (index == _pages.length) {
                    return _buildTermsPage();
                  }
                  return _buildOnboardingPage(_pages[index]);
                },
              ),
            ),
            
            // Indicadores de página animados
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: AnimatedPageIndicator(
                currentPage: _currentPage,
                pageCount: _pages.length + 1, // +1 para página de termos
                activeColor: colorScheme.primary,
                inactiveColor: colorScheme.primary.withValues(alpha: 0.3),
                activeWidth: 24.0,
                inactiveWidth: 8.0,
                height: 8.0,
                animationDuration: const Duration(milliseconds: 300),
                animationCurve: Curves.easeInOut,
              ),
            ),
            
            // Botões de navegação
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: _currentPage == _pages.length 
                  ? _buildFinalButtons()
                  : _buildNavigationButtons(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingPage page) {
    final colorScheme = Theme.of(context).colorScheme;

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
              color: page.color.withValues(alpha: 0.1),
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
              color: colorScheme.onSurface,
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
              color: colorScheme.onSurfaceVariant,
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTermsPage() {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          controller: _termsScrollController,
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.security,
                          size: 40,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Termos e Políticas',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Por favor, leia e aceite os termos para continuar',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Política de Privacidade
                _buildPolicySection(
                  title: 'Política de Privacidade',
                  content: '''
O ProvaPlanner coleta e processa seus dados pessoais de forma transparente e segura:

• Dados de provas e estudos (nome, data, disciplina)
• Preferências de notificação
• Dados de uso para melhorar o aplicativo

Seus dados são armazenados localmente no seu dispositivo e não são compartilhados com terceiros sem seu consentimento explícito.
                  ''',
                ),
                
                const SizedBox(height: 24),
                
                // Termos de Uso
                _buildPolicySection(
                  title: 'Termos de Uso',
                  content: '''
Ao usar o ProvaPlanner, você concorda com:

• Uso responsável do aplicativo
• Não compartilhamento de conteúdo inadequado
• Respeito aos direitos de propriedade intelectual
• Manutenção da segurança da sua conta

O aplicativo é fornecido "como está" e nos reservamos o direito de atualizar estes termos.
                  ''',
                ),
                
                const SizedBox(height: 24),
                
                // Processamento de Dados
                _buildPolicySection(
                  title: 'Processamento de Dados (LGPD)',
                  content: '''
Conforme a Lei Geral de Proteção de Dados (LGPD):

• Base legal: Consentimento e execução de contrato
• Finalidade: Fornecimento do serviço de organização acadêmica
• Retenção: Dados mantidos enquanto necessário para o serviço
• Seus direitos: Acesso, correção, exclusão e portabilidade

Você pode exercer seus direitos entrando em contato conosco.
                  ''',
                ),
                
                const SizedBox(height: 24),
                
                // Informações Adicionais
                _buildPolicySection(
                  title: 'Informações Adicionais',
                  content: '''
• Seus dados são armazenados apenas localmente no dispositivo
• Não coletamos informações pessoais sensíveis
• Você pode excluir todos os dados a qualquer momento nas configurações
• O aplicativo funciona offline e não requer conexão com a internet para funcionalidades básicas
• Funcionalidades de IA são opcionais e requerem configuração de chave de API
                  ''',
                ),
                
                const SizedBox(height: 40), // Espaço extra no final para garantir scroll
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPolicySection({
    required String title,
    required String content,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content.trim(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
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
