import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'home_screen.dart';
import 'disciplinas_screen.dart';
import 'daily_goals_screen.dart';
import 'perfil_screen.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/tutorial_overlay.dart';
import '../widgets/tutorial_arrow.dart';
import '../services/tutorial_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _showTutorialNav = false;
  final GlobalKey _navKey = GlobalKey();
  final GlobalKey _disciplinasNavKey = GlobalKey();

  final List<Widget> _screens = [
    const HomeScreen(),
    const DisciplinasScreen(),
    const DailyGoalsScreen(),
    const PerfilScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _verificarTutorialInicial();
  }

  Future<void> _verificarTutorialInicial() async {
    // Aguardar um pouco para garantir que as telas estão carregadas
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (!mounted) return;
    
    final step = await TutorialService.getCurrentStep();
    final completed = await TutorialService.isTutorialCompleted();
    
    // Se o tutorial não foi concluído e o passo é none, iniciar
    if (!completed && step == TutorialStep.none) {
      await TutorialService.setCurrentStep(TutorialStep.navigateToDisciplinas);
      
      if (mounted) {
        setState(() {
          _showTutorialNav = true;
        });
      }
      return;
    }
    
    // Passo 0: Mostrar tutorial na navegação
    if (step == TutorialStep.navigateToDisciplinas) {
      if (mounted) {
        setState(() {
          _showTutorialNav = true;
        });
      }
    }
    // Passo 1: Navegar para disciplinas e mostrar tutorial do FAB
    else if (step == TutorialStep.addDisciplina) {
      if (mounted) {
        setState(() {
          _currentIndex = 1; // Índice da tela de disciplinas
        });
      }
    }
  }

  Future<void> _proximoPassoTutorial() async {
    await TutorialService.nextStep();
    setState(() {
      _showTutorialNav = false;
    });
    
    // Após clicar na navegação, avançar para próximo passo
    final newStep = await TutorialService.getCurrentStep();
    if (newStep == TutorialStep.addDisciplina) {
      setState(() {
        _currentIndex = 1; // Navegar para disciplinas
      });
    }
  }

  Future<void> _pularTutorial() async {
    await TutorialService.skipTutorial();
    setState(() {
      _showTutorialNav = false;
    });
  }

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    // Se estava no tutorial de navegação e clicou em disciplinas
    if (_showTutorialNav && index == 1) {
      _proximoPassoTutorial();
    } else {
      // Verificar se precisa mostrar tutorial após mudança de tela
      _verificarTutorialAposNavegacao();
    }
  }

  Future<void> _verificarTutorialAposNavegacao() async {
    // Aguardar um pouco para a tela renderizar
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted) return;
    
    final step = await TutorialService.getCurrentStep();
    
    // Se está na tela de disciplinas e o passo é addDisciplina
    if (_currentIndex == 1 && step == TutorialStep.addDisciplina) {
      // A tela de disciplinas vai mostrar o tutorial automaticamente
    }
    // Se está na tela de home e o passo é addProva
    else if (_currentIndex == 0 && step == TutorialStep.addProva) {
      // A tela de home vai mostrar o tutorial automaticamente
    }
    // Se o passo mudou para addProva, navegar para home
    else if (step == TutorialStep.addProva && _currentIndex != 0) {
      setState(() {
        _currentIndex = 0; // Navegar para home
      });
    }
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Verificar tutorial periodicamente
    _verificarTutorialPeriodicamente();
  }
  
  Future<void> _verificarTutorialPeriodicamente() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    
    final step = await TutorialService.getCurrentStep();
    
    // Se o passo mudou para addProva e não está na home, navegar
    if (step == TutorialStep.addProva && _currentIndex != 0) {
      setState(() {
        _currentIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: CustomBottomNavigation(
            key: _navKey,
            currentIndex: _currentIndex,
            onTap: _onNavTap,
            highlightIndex: _showTutorialNav ? 1 : null,
            disciplinasKey: _showTutorialNav ? _disciplinasNavKey : null,
          ),
        ),
        if (_showTutorialNav)
          TutorialOverlay(
            title: '👋 Bem-vindo!',
            message: 'Vamos começar! Toque no ícone "Disciplinas" na barra de navegação abaixo para começar a organizar seus estudos.',
            targetKey: _disciplinasNavKey,
            arrowPosition: ArrowPosition.top,
            onNext: _proximoPassoTutorial,
            onSkip: _pularTutorial,
          ),
      ],
    );
  }
}
