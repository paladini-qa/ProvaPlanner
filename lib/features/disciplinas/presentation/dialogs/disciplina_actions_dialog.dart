import 'package:flutter/material.dart';

/// Diálogo de ações para Disciplina
/// 
/// Exibe um diálogo com três ações: FECHAR, EDITAR e REMOVER.
/// Este diálogo é não-dismissable (não pode ser fechado tocando fora).
class DisciplinaActionsDialog extends StatelessWidget {
  final String disciplinaNome;
  final String? disciplinaId;
  final String? professor;
  final String? periodo;
  final String? descricao;
  final VoidCallback? onEditar;
  final VoidCallback? onRemover;

  const DisciplinaActionsDialog({
    super.key,
    required this.disciplinaNome,
    this.disciplinaId,
    this.professor,
    this.periodo,
    this.descricao,
    this.onEditar,
    this.onRemover,
  });

  static Future<void> show(
    BuildContext context, {
    required String disciplinaNome,
    String? disciplinaId,
    String? professor,
    String? periodo,
    String? descricao,
    VoidCallback? onEditar,
    VoidCallback? onRemover,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Não pode fechar tocando fora
      builder: (context) => DisciplinaActionsDialog(
        disciplinaNome: disciplinaNome,
        disciplinaId: disciplinaId,
        professor: professor,
        periodo: periodo,
        descricao: descricao,
        onEditar: onEditar,
        onRemover: onRemover,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Detalhes da Disciplina'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Nome', disciplinaNome),
            if (professor != null) _buildDetailRow('Professor', professor!),
            if (periodo != null) _buildDetailRow('Período', periodo!),
            if (descricao != null && descricao!.isNotEmpty)
              _buildDetailRow('Descrição', descricao!),
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
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
          ),
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
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

