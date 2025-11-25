import 'package:flutter/material.dart';
import '../../../../widgets/app_icon.dart';
import '../dialogs/disciplina_actions_dialog.dart';
import '../dialogs/disciplina_edit_dialog.dart';
import '../dialogs/disciplina_remove_dialog.dart';

/// Tela de listagem de Disciplinas
/// 
/// Esta tela implementa apenas a UI de listagem (modo listing-only).
/// Nenhum dado será exibido e nenhuma funcionalidade será implementada ainda.
/// Apenas a interface do usuário.
class DisciplinasListPage extends StatefulWidget {
  const DisciplinasListPage({super.key});

  @override
  State<DisciplinasListPage> createState() => _DisciplinasListPageState();
}

class _DisciplinasListPageState extends State<DisciplinasListPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simular carregamento inicial
    Future<void>.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _abrirDialogoAcoes(String disciplinaNome, {
    String? disciplinaId,
    String? professor,
    String? periodo,
    String? descricao,
  }) {
    DisciplinaActionsDialog.show(
      context,
      disciplinaNome: disciplinaNome,
      disciplinaId: disciplinaId,
      professor: professor,
      periodo: periodo,
      descricao: descricao,
      onEditar: () => _editarDisciplina(
        disciplinaId: disciplinaId,
        nomeInicial: disciplinaNome,
        professorInicial: professor,
        periodoInicial: periodo,
        descricaoInicial: descricao,
      ),
      onRemover: () => _removerDisciplina(disciplinaNome, disciplinaId),
    );
  }

  Future<void> _editarDisciplina({
    String? disciplinaId,
    String? nomeInicial,
    String? professorInicial,
    String? periodoInicial,
    String? descricaoInicial,
  }) async {
    final result = await DisciplinaEditDialog.show(
      context,
      disciplinaId: disciplinaId,
      nomeInicial: nomeInicial,
      professorInicial: professorInicial,
      periodoInicial: periodoInicial,
      descricaoInicial: descricaoInicial,
    );

    if (result != null && mounted) {
      // TODO: Implementar persistência via Repository/UseCase
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Disciplina "${result['nome']}" ${disciplinaId != null ? 'atualizada' : 'criada'} com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _removerDisciplina(String disciplinaNome, String? disciplinaId) async {
    final confirmado = await DisciplinaRemoveDialog.show(
      context,
      disciplinaNome: disciplinaNome,
    );

    if (confirmado && mounted) {
      // TODO: Implementar remoção via Repository/UseCase
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Disciplina "$disciplinaNome" removida com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            AppIcon(size: 32),
            SizedBox(width: 12),
            Text('Disciplinas'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildEmptyState(),
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
            'Os dados serão carregados aqui quando a funcionalidade for implementada',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Item de exemplo para testar o diálogo
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            child: ListTile(
              leading: const Icon(Icons.school, color: Colors.blue),
              title: const Text('Disciplina de Exemplo'),
              subtitle: const Text('Toque para abrir o diálogo de ações'),
              onTap: () => _abrirDialogoAcoes(
                'Disciplina de Exemplo',
                disciplinaId: 'exemplo-1',
                professor: 'Prof. Silva',
                periodo: '2024.1',
                descricao: 'Esta é uma disciplina de exemplo para testar as funcionalidades',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

