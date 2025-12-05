import 'package:flutter/material.dart';
import '../../../../presentation/widgets/app_icon.dart';
import '../dialogs/anotacao_actions_dialog.dart';
import '../dialogs/anotacao_edit_dialog.dart';
import '../dialogs/anotacao_remove_dialog.dart';

class AnotacoesListPage extends StatefulWidget {
  const AnotacoesListPage({super.key});

  @override
  State<AnotacoesListPage> createState() => _AnotacoesListPageState();
}

class _AnotacoesListPageState extends State<AnotacoesListPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  void _abrirDialogoAcoes(String anotacaoTitulo, {String? anotacaoId, String? descricao}) {
    AnotacaoActionsDialog.show(context, anotacaoTitulo: anotacaoTitulo, anotacaoId: anotacaoId, descricao: descricao, onEditar: () => _editarAnotacao(anotacaoId: anotacaoId, tituloInicial: anotacaoTitulo, descricaoInicial: descricao), onRemover: () => _removerAnotacao(anotacaoTitulo, anotacaoId));
  }

  Future<void> _editarAnotacao({String? anotacaoId, String? tituloInicial, String? descricaoInicial}) async {
    final result = await AnotacaoEditDialog.show(context, anotacaoId: anotacaoId, tituloInicial: tituloInicial, descricaoInicial: descricaoInicial);
    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Anotação "${result['titulo']}" ${anotacaoId != null ? 'atualizada' : 'criada'} com sucesso!'), backgroundColor: Colors.green));
    }
  }

  Future<void> _removerAnotacao(String anotacaoTitulo, String? anotacaoId) async {
    final confirmado = await AnotacaoRemoveDialog.show(context, anotacaoTitulo: anotacaoTitulo);
    if (confirmado && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Anotação "$anotacaoTitulo" removida com sucesso!'), backgroundColor: Colors.green));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Row(children: [AppIcon(size: 32), SizedBox(width: 12), Text('Anotações')])),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : _buildEmptyState(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.note, size: 64, color: Colors.grey[400]),
        const SizedBox(height: 16),
        Text('Nenhuma anotação cadastrada', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey[600])),
        const SizedBox(height: 8),
        Text('Os dados serão carregados aqui quando a funcionalidade for implementada', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]), textAlign: TextAlign.center),
        const SizedBox(height: 24),
        Card(margin: const EdgeInsets.symmetric(horizontal: 32), child: ListTile(leading: const Icon(Icons.note, color: Colors.blue), title: const Text('Anotação de Exemplo'), subtitle: const Text('Toque para abrir o diálogo de ações'), onTap: () => _abrirDialogoAcoes('Anotação de Exemplo', anotacaoId: 'exemplo-1', descricao: 'Esta é uma anotação de exemplo'))),
      ]),
    );
  }
}

