import 'package:flutter/material.dart';
import '../../../../widgets/app_icon.dart';
import '../dialogs/tarefa_actions_dialog.dart';
import '../dialogs/tarefa_edit_dialog.dart';
import '../dialogs/tarefa_remove_dialog.dart';

class TarefasListPage extends StatefulWidget {
  const TarefasListPage({super.key});

  @override
  State<TarefasListPage> createState() => _TarefasListPageState();
}

class _TarefasListPageState extends State<TarefasListPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  void _abrirDialogoAcoes(String tarefaTitulo, {
    String? tarefaId,
    String? descricao,
    bool? concluida,
  }) {
    TarefaActionsDialog.show(
      context,
      tarefaTitulo: tarefaTitulo,
      tarefaId: tarefaId,
      descricao: descricao,
      concluida: concluida ?? false,
      onEditar: () => _editarTarefa(
        tarefaId: tarefaId,
        tituloInicial: tarefaTitulo,
        descricaoInicial: descricao,
        concluidaInicial: concluida ?? false,
      ),
      onRemover: () => _removerTarefa(tarefaTitulo, tarefaId),
    );
  }

  Future<void> _editarTarefa({
    String? tarefaId,
    String? tituloInicial,
    String? descricaoInicial,
    bool? concluidaInicial,
  }) async {
    final result = await TarefaEditDialog.show(
      context,
      tarefaId: tarefaId,
      tituloInicial: tituloInicial,
      descricaoInicial: descricaoInicial,
      concluidaInicial: concluidaInicial ?? false,
    );

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tarefa "${result['titulo']}" ${tarefaId != null ? 'atualizada' : 'criada'} com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _removerTarefa(String tarefaTitulo, String? tarefaId) async {
    final confirmado = await TarefaRemoveDialog.show(
      context,
      tarefaTitulo: tarefaTitulo,
    );

    if (confirmado && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tarefa "$tarefaTitulo" removida com sucesso!'),
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
            Text('Tarefas'),
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
          Icon(Icons.task, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Nenhuma tarefa cadastrada',
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
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            child: ListTile(
              leading: const Icon(Icons.task, color: Colors.blue),
              title: const Text('Tarefa de Exemplo'),
              subtitle: const Text('Toque para abrir o diálogo de ações'),
              onTap: () => _abrirDialogoAcoes(
                'Tarefa de Exemplo',
                tarefaId: 'exemplo-1',
                descricao: 'Esta é uma tarefa de exemplo',
                concluida: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

