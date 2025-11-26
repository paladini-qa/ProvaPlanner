import 'package:flutter/material.dart';

import '../services/tutorial_service.dart';
import '../widgets/bottom_navigation.dart';
import '../features/disciplinas/presentation/pages/disciplinas_list_page.dart';
import '../features/alunos/presentation/pages/alunos_list_page.dart';
import '../features/tarefas/presentation/pages/tarefas_list_page.dart';
import '../features/cursos/presentation/pages/cursos_list_page.dart';
import '../features/anotacoes/presentation/pages/anotacoes_list_page.dart';
import 'daily_goals_screen.dart';
import 'disciplinas_screen.dart';
import 'home_screen.dart';
import 'perfil_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const DisciplinasScreen(),
    const DailyGoalsScreen(),
    const PerfilScreen(),
  ];

  final List<String> _tabNames = ['home', 'disciplinas', 'daily_goals', 'perfil'];

  @override
  void initState() {
    super.initState();
    _verificarTutorialInicial();
  }

  Future<void> _verificarTutorialInicial() async {
    // Aguardar um pouco para garantir que a tela está carregada
    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // Verificar se é a primeira vez que abre o app
    final isFirstLaunch = await TutorialService.isFirstLaunch();
    if (isFirstLaunch) {
      await _mostrarDialogoBemVindo();
      await TutorialService.markFirstLaunchComplete();
    }
  }

  Future<void> _mostrarDialogoBemVindo() async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('👋 Bem-vindo ao ProvaPlanner!'),
        content: const Text(
          'Este é o seu organizador de estudos. Use as abas na parte inferior para navegar entre as diferentes funcionalidades.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Verificar se é a primeira vez que clica nesta aba
    _verificarTutorialAba(index);
  }

  Future<void> _verificarTutorialAba(int index) async {
    if (index < 0 || index >= _tabNames.length) return;

    final tabName = _tabNames[index];
    final hasVisited = await TutorialService.hasVisitedTab(tabName);

    if (!hasVisited && mounted) {
      await _mostrarDialogoAba(tabName);
      await TutorialService.markTabVisited(tabName);
    }
  }

  Future<void> _mostrarDialogoAba(String tabName) async {
    if (!mounted) return;

    String title;
    String message;

    switch (tabName) {
      case 'home':
        title = '🏠 Tela Inicial';
        message = 'Aqui você pode ver seu calendário de provas e revisões. Use o botão + para adicionar novas provas.';
        break;
      case 'disciplinas':
        title = '📚 Disciplinas';
        message = 'Gerencie suas disciplinas aqui. Adicione novas disciplinas usando o botão + e organize por período.';
        break;
      case 'daily_goals':
        title = '🎯 Metas Diárias';
        message = 'Defina e acompanhe suas metas de estudo diárias para manter o foco e a organização. Use o botão + para adicionar uma nova meta.';
        break;
      case 'perfil':
        title = '👤 Perfil';
        message = 'Acesse suas configurações e informações do perfil aqui.';
        break;
      default:
        title = 'Nova Aba';
        message = 'Explore esta nova funcionalidade!';
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  void _navegarParaDisciplinas() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const DisciplinasListPage(),
      ),
    );
  }

  void _navegarParaAlunos() {
    Navigator.push(context, MaterialPageRoute<void>(builder: (context) => const AlunosListPage()));
  }

  void _navegarParaTarefas() {
    Navigator.push(context, MaterialPageRoute<void>(builder: (context) => const TarefasListPage()));
  }

  void _navegarParaCursos() {
    Navigator.push(context, MaterialPageRoute<void>(builder: (context) => const CursosListPage()));
  }

  void _navegarParaAnotacoes() {
    Navigator.push(context, MaterialPageRoute<void>(builder: (context) => const AnotacoesListPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'ProvaPlanner',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Gerenciamento de Entidades',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Disciplinas'),
              onTap: () {
                Navigator.pop(context);
                _navegarParaDisciplinas();
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Alunos'),
              onTap: () {
                Navigator.pop(context);
                _navegarParaAlunos();
              },
            ),
            ListTile(
              leading: const Icon(Icons.task),
              title: const Text('Tarefas'),
              onTap: () {
                Navigator.pop(context);
                _navegarParaTarefas();
              },
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Cursos'),
              onTap: () {
                Navigator.pop(context);
                _navegarParaCursos();
              },
            ),
            ListTile(
              leading: const Icon(Icons.note),
              title: const Text('Anotações'),
              onTap: () {
                Navigator.pop(context);
                _navegarParaAnotacoes();
              },
            ),
            // ListTile(
            //   leading: const Icon(Icons.assignment),
            //   title: const Text('Provas'),
            //   onTap: () {
            //     Navigator.pop(context);
            //     // Navegar para listagem de Provas
            //   },
            // ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 0;
                });
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
