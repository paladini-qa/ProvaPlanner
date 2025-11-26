import 'package:flutter/material.dart';
import '../../../../widgets/app_icon.dart';
import '../dialogs/aluno_actions_dialog.dart';
import '../dialogs/aluno_edit_dialog.dart';
import '../dialogs/aluno_remove_dialog.dart';

/// Tela de listagem de Alunos
/// 
/// Esta tela implementa apenas a UI de listagem (modo listing-only).
/// Nenhum dado será exibido e nenhuma funcionalidade será implementada ainda.
/// Apenas a interface do usuário.
class AlunosListPage extends StatefulWidget {
  const AlunosListPage({super.key});

  @override
  State<AlunosListPage> createState() => _AlunosListPageState();
}

class _AlunosListPageState extends State<AlunosListPage> {
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

  void _abrirDialogoAcoes(String alunoNome, {
    String? alunoId,
    String? matricula,
    String? email,
  }) {
    AlunoActionsDialog.show(
      context,
      alunoNome: alunoNome,
      alunoId: alunoId,
      matricula: matricula,
      email: email,
      onEditar: () => _editarAluno(
        alunoId: alunoId,
        nomeInicial: alunoNome,
        matriculaInicial: matricula,
        emailInicial: email,
      ),
      onRemover: () => _removerAluno(alunoNome, alunoId),
    );
  }

  Future<void> _editarAluno({
    String? alunoId,
    String? nomeInicial,
    String? matriculaInicial,
    String? emailInicial,
  }) async {
    final result = await AlunoEditDialog.show(
      context,
      alunoId: alunoId,
      nomeInicial: nomeInicial,
      matriculaInicial: matriculaInicial,
      emailInicial: emailInicial,
    );

    if (result != null && mounted) {
      // TODO: Implementar persistência via Repository/UseCase
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Aluno "${result['nome']}" ${alunoId != null ? 'atualizado' : 'criado'} com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _removerAluno(String alunoNome, String? alunoId) async {
    final confirmado = await AlunoRemoveDialog.show(
      context,
      alunoNome: alunoNome,
    );

    if (confirmado && mounted) {
      // TODO: Implementar remoção via Repository/UseCase
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Aluno "$alunoNome" removido com sucesso!'),
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
            Text('Alunos'),
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
            Icons.person,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum aluno cadastrado',
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
              leading: const Icon(Icons.person, color: Colors.blue),
              title: const Text('Aluno de Exemplo'),
              subtitle: const Text('Toque para abrir o diálogo de ações'),
              onTap: () => _abrirDialogoAcoes(
                'Aluno de Exemplo',
                alunoId: 'exemplo-1',
                matricula: '2024001',
                email: 'aluno@exemplo.com',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

