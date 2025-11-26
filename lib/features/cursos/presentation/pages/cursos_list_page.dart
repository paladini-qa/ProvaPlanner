import 'package:flutter/material.dart';
import '../../../../widgets/app_icon.dart';
import '../dialogs/curso_actions_dialog.dart';
import '../dialogs/curso_edit_dialog.dart';
import '../dialogs/curso_remove_dialog.dart';

class CursosListPage extends StatefulWidget {
  const CursosListPage({super.key});

  @override
  State<CursosListPage> createState() => _CursosListPageState();
}

class _CursosListPageState extends State<CursosListPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  void _abrirDialogoAcoes(String cursoNome, {String? cursoId, String? descricao, int? cargaHoraria}) {
    CursoActionsDialog.show(context, cursoNome: cursoNome, cursoId: cursoId, descricao: descricao, cargaHoraria: cargaHoraria, onEditar: () => _editarCurso(cursoId: cursoId, nomeInicial: cursoNome, descricaoInicial: descricao, cargaHorariaInicial: cargaHoraria), onRemover: () => _removerCurso(cursoNome, cursoId));
  }

  Future<void> _editarCurso({String? cursoId, String? nomeInicial, String? descricaoInicial, int? cargaHorariaInicial}) async {
    final result = await CursoEditDialog.show(context, cursoId: cursoId, nomeInicial: nomeInicial, descricaoInicial: descricaoInicial, cargaHorariaInicial: cargaHorariaInicial);
    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Curso "${result['nome']}" ${cursoId != null ? 'atualizado' : 'criado'} com sucesso!'), backgroundColor: Colors.green));
    }
  }

  Future<void> _removerCurso(String cursoNome, String? cursoId) async {
    final confirmado = await CursoRemoveDialog.show(context, cursoNome: cursoNome);
    if (confirmado && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Curso "$cursoNome" removido com sucesso!'), backgroundColor: Colors.green));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Row(children: [AppIcon(size: 32), SizedBox(width: 12), Text('Cursos')])),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : _buildEmptyState(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.school, size: 64, color: Colors.grey[400]),
        const SizedBox(height: 16),
        Text('Nenhum curso cadastrado', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey[600])),
        const SizedBox(height: 8),
        Text('Os dados serão carregados aqui quando a funcionalidade for implementada', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]), textAlign: TextAlign.center),
        const SizedBox(height: 24),
        Card(margin: const EdgeInsets.symmetric(horizontal: 32), child: ListTile(leading: const Icon(Icons.school, color: Colors.blue), title: const Text('Curso de Exemplo'), subtitle: const Text('Toque para abrir o diálogo de ações'), onTap: () => _abrirDialogoAcoes('Curso de Exemplo', cursoId: 'exemplo-1', descricao: 'Este é um curso de exemplo', cargaHoraria: 40))),
      ]),
    );
  }
}

