import 'package:flutter/material.dart';

class TarefaActionsDialog extends StatelessWidget {
  final String tarefaTitulo;
  final String? tarefaId;
  final String? descricao;
  final bool concluida;
  final VoidCallback? onEditar;
  final VoidCallback? onRemover;

  const TarefaActionsDialog({
    super.key,
    required this.tarefaTitulo,
    this.tarefaId,
    this.descricao,
    this.concluida = false,
    this.onEditar,
    this.onRemover,
  });

  static Future<void> show(
    BuildContext context, {
    required String tarefaTitulo,
    String? tarefaId,
    String? descricao,
    bool concluida = false,
    VoidCallback? onEditar,
    VoidCallback? onRemover,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => TarefaActionsDialog(
        tarefaTitulo: tarefaTitulo,
        tarefaId: tarefaId,
        descricao: descricao,
        concluida: concluida,
        onEditar: onEditar,
        onRemover: onRemover,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Detalhes da Tarefa'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Título', tarefaTitulo),
            if (descricao != null && descricao!.isNotEmpty)
              _buildDetailRow('Descrição', descricao!),
            _buildDetailRow('Status', concluida ? 'Concluída' : 'Pendente'),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Selecione uma ação:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('FECHAR'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onEditar?.call();
          },
          child: const Text('EDITAR'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onRemover?.call();
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('REMOVER'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

