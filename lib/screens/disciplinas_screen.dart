import 'package:flutter/material.dart';
import '../models/disciplina.dart';
import '../services/disciplina_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icon.dart';
import 'adicionar_disciplina_screen.dart';
import 'detalhes_disciplina_screen.dart';

class DisciplinasScreen extends StatefulWidget {
  const DisciplinasScreen({super.key});

  @override
  State<DisciplinasScreen> createState() => _DisciplinasScreenState();
}

class _DisciplinasScreenState extends State<DisciplinasScreen> {
  List<Disciplina> _disciplinas = [];
  bool _isLoading = true;
  String _periodoFiltro = 'Todos';

  final List<String> _periodos = [
    'Todos',
    '1º Período',
    '2º Período',
    '3º Período',
    '4º Período',
    '5º Período',
    '6º Período',
    '7º Período',
    '8º Período',
  ];

  @override
  void initState() {
    super.initState();
    _carregarDisciplinas();
  }

  Future<void> _carregarDisciplinas() async {
    setState(() => _isLoading = true);
    
    final disciplinas = await DisciplinaService.carregarDisciplinas();
    
    setState(() {
      _disciplinas = disciplinas;
      _isLoading = false;
    });
  }

  List<Disciplina> get _disciplinasFiltradas {
    if (_periodoFiltro == 'Todos') {
      return _disciplinas;
    }
    return _disciplinas.where((d) => d.periodo == _periodoFiltro).toList();
  }

  Future<void> _adicionarDisciplina() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const AdicionarDisciplinaScreen(),
      ),
    );
    
    if (result == true) {
      _carregarDisciplinas();
    }
  }

  Future<void> _editarDisciplina(Disciplina disciplina) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AdicionarDisciplinaScreen(disciplina: disciplina),
      ),
    );
    
    if (result == true) {
      _carregarDisciplinas();
    }
  }

  Future<void> _removerDisciplina(Disciplina disciplina) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja remover a disciplina "${disciplina.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      await DisciplinaService.removerDisciplina(disciplina.id);
      _carregarDisciplinas();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const AppIcon(size: 32),
            const SizedBox(width: 12),
            const Text('Disciplinas'),
          ],
        ),
        actions: [
          // Filtro de período
          PopupMenuButton<String>(
            onSelected: (periodo) {
              setState(() {
                _periodoFiltro = periodo;
              });
            },
            itemBuilder: (context) => _periodos.map((periodo) {
              return PopupMenuItem<String>(
                value: periodo,
                child: Row(
                  children: [
                    if (periodo == _periodoFiltro)
                      const Icon(Icons.check, color: AppTheme.indigo),
                    if (periodo == _periodoFiltro) const SizedBox(width: 8),
                    Text(periodo),
                  ],
                ),
              );
            }).toList(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.filter_list),
                  const SizedBox(width: 4),
                  Text(_periodoFiltro),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _disciplinasFiltradas.isEmpty
              ? _buildEmptyState()
              : _buildDisciplinasList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _adicionarDisciplina,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma disciplina cadastrada',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toque no + para adicionar uma disciplina',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisciplinasList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _disciplinasFiltradas.length,
      itemBuilder: (context, index) {
        final disciplina = _disciplinasFiltradas[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: disciplina.cor.withOpacity(0.1),
              child: Icon(
                Icons.school,
                color: disciplina.cor,
              ),
            ),
            title: Text(
              disciplina.nome,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Professor: ${disciplina.professor}'),
                Text('Período: ${disciplina.periodo}'),
                if (disciplina.descricao.isNotEmpty)
                  Text(
                    disciplina.descricao,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'editar':
                    _editarDisciplina(disciplina);
                    break;
                  case 'remover':
                    _removerDisciplina(disciplina);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'editar',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Editar'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'remover',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Remover', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetalhesDisciplinaScreen(disciplina: disciplina),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
